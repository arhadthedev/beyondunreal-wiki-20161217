/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVoteCollector extends Info
	native;


var class<UTVoteReplicationInfo> VRIClass;

/**
 * The collection of maps + votes
 */
struct native MapVoteInfo
{
	var int 	MapID;			// An INT id that represents this map.
	var string 	Map;			// The Name of the map
	var byte 	NoVotes;		// Number of votes this map has

	structdefaultproperties
	{
		MapID = -1;	// Default to NO id.
	}
};

var array<MapVoteInfo> Votes;
var array<UTVoteReplicationInfo> VRIList;

var bool bVoteDecided;
var bool bInEndGameVote;

var int WinningIndex;

// GameInfo cache; minimially cuts down on casting
var UTGame GameInfoRef;


native function int GetMapIndex(int MapID);


// TODO: When adding gametype voting, initialize without taking in a maplist, and do another function for the maplists
function Initialize(array<string> MapList)
{
	local UTPlayerController UTPC;
	local int i;

	// Grab the map information from the game type.


	//`log("### VoteCollector.Initialize"@MapList.Length,, 'UTVotingDebug');

	Votes.Remove(0,Votes.Length);
	Votes.Length = MapList.Length;

	for (i=0;i<MapList.length;i++)
	{
		Votes[i].MapID = i;
		Votes[i].Map = MapList[i];
		Votes[i].NoVotes= 0;
	}

	foreach WorldInfo.AllControllers(class'UTPlayerController',UTPC)
	{
		AttachVoteReplicationInfo(UTPC);
	}
}


function NotifyPlayerJoined(UTPlayerController Player)
{
	//`log("UTVoteCollector::NotifyPlayerJoined, Player:"@Player,, 'UTVotingDebug');

	AttachVoteReplicationInfo(Player);
}

function NotifyPlayerExiting(UTPlayerController Player)
{
	local int i;

	//`log("UTVoteCollector::NotifyPlayerExiting, Player:"@Player,, 'UTVotingDebug');

	if (Player.VoteRI != none)
	{
		VRIList.RemoveItem(Player.VoteRI);

		if (Player.VoteRI.MyCurrnetVoteID > INDEX_None)
			RemoveVoteFor(Player.VoteRI.MyCurrnetVoteID);

		Player.VoteRI.Destroy();
	}


	// Check if the the exiting player caused a vote to win, by reducing the number of required votes (only happens during midgame voting)
	if (!MapVoteInProgress())
	{
		i = FindBestMap();

		if (CheckMapVoteCount(i))
			BeginMidGameMapVote(i);
	}
}

function NotifyEndGameVote()
{
	local int i;
	local PlayerController PC;

	if (MapVoteInProgress())
		return;

	bInEndGameVote = True;

	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].ClientBeginVoting();

	// Notify clients that voting has been initialized
	foreach WorldInfo.AllControllers(Class'PlayerController', PC)
		PC.ReceiveLocalizedMessage(GameInfoRef.GameMessageClass, 18);
}


// TODO: Modify to allow/reject spectators when you add a 'bAllowSpectatorVote' (or some such) config variable
//	N.B. This would also require you to add in spectator->player/player->spectator notifications (would be nice to have as mutator hooks too)
function AttachVoteReplicationInfo(UTPlayerController PC)
{
	local UTVoteReplicationInfo VRI;

	if (PC.VoteRI != none)
		return;

	VRI = Spawn(VRIClass, PC);

	if (VRI != none)
	{
		PC.VoteRI = VRI;
		VRI.Initialize(Self);

		VRIList.AddItem(VRI);
	}
	else
	{
		`log("Could not spawn a VOTERI for"@PC.PlayerReplicationInfo.PlayerName@"("$PC$")",, 'UTVoting');
	}
}

function BroadcastVoteChange(int MapID, byte VoteCount)
{
	local int i;

//	`log("### Broadcasting Vote Update"@MapID@VoteCount);

	for (i=0;i<VRIList.Length;i++)
	{
		//`log("### Sending Vote Change to "@VRIList[i],, 'UTVotingDebug');
		VRIList[i].ClientRecvMapUpdate(MapId, VoteCount);
	}
}


function RemoveVoteFor(out int CurrentVoteID)
{
	local int index;

//	`log("### Removing Vote for:"@CurrentVoteId@bVoteDecided);

	if ( bVoteDecided )
	{
		return;
	}


	Index = GetMapIndex(CurrentVoteID);

	if ( Index != INDEX_None )
	{
		Votes[Index].NoVotes = Clamp(int(Votes[Index].NoVotes) - 1, 0, 255);
		BroadcastVoteChange(Votes[Index].MapID, Votes[Index].NoVotes);
	}
}

function int AddVoteFor(out int CurrentVoteID)
{
	local int index;

//	`log("### Adding Vote For"@CurrentVoteId@bVoteDecided);

	if ( bVoteDecided )
	{
		return INDEX_None;
	}

	Index = GetMapIndex(CurrentVoteID);

	if ( Index != INDEX_None )
	{
		Votes[Index].NoVotes = Clamp(int(Votes[Index].NoVotes) + 1, 0, 255);
		BroadcastVoteChange(Votes[Index].MapID, Votes[Index].NoVotes);

		if (!MapVoteInProgress() && CheckMapVoteCount(Index))
			BeginMidGameMapVote(Index);

		return Votes[Index].MapID;
	}

	return INDEX_None;
}

function bool CheckMapVoteCount(int Idx)
{
	local int i, VoteCount;
	local float ReqVotes;

	ReqVotes = Max(Max(1.0, GameInfoRef.MinMapVotes) * 1000.0, float(GameInfoRef.GetNumPlayers()) * float(GameInfoRef.MapVotePercentage) * 10);


	// If VoteDuration is set, then check the total number of votes rather than the number of votes for the current map
	if (GameInfoRef.VoteDuration > 0)
	{
		for (i=0; i<Votes.Length; ++i)
			VoteCount += Votes[i].NoVotes;


		if (float(VoteCount * 1000) >= ReqVotes)
			return True;
	}


	if (float(Votes[Idx].NoVotes) * 1000.0 >= ReqVotes)
		return True;

	return False;
}

function MapVotePassed(int WinIdx)
{
	local int i;

	bVoteDecided = True;

	if (Votes[WinIdx].NoVotes > 0)
	{
		WinningIndex = WinIdx;

		// TODO: Vote win announement
	}

	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].ClientTimesUp();


	// If it's not an endgame vote, it must be a midgame vote; end the current map
	if (!bInEndGameVote)
	{
		//`log("Midgame-MapVote passed",, 'UTVotingDebug');

		GameInfoRef.RestartGame();
	}
}

function BeginMidGameMapVote(optional int CurWinIndex)
{
	local int i;
	local PlayerController PC;

	// Initiate a countdown, if VoteDuration is set (otherwise, switch immediately)
	if (GameInfoRef.VoteDuration > 0)
	{
		UTGameReplicationInfo(GameInfoRef.GameReplicationInfo).MapVoteTimeRemaining = GameInfoRef.VoteDuration;
		SetTimer(GameInfoRef.VoteDuration * WorldInfo.TimeDilation, False, 'TimesUp');

		for (i=0; i<VRIList.Length; ++i)
		{
			VRIList[i].ClientBeginVoting();
			//`log("Calling ClientBeginVoting on"@VRIList[i],, 'UTVotingDebug');
		}

		// Notify clients that voting has been initialized
		foreach WorldInfo.AllControllers(Class'PlayerController', PC)
			PC.ReceiveLocalizedMessage(GameInfoRef.GameMessageClass, 18);
	}
	else
	{
		MapVotePassed(CurWinIndex != INDEX_None ? CurWinIndex : FindBestMap());
	}
}

function TimesUp()
{
	MapVotePassed(FindBestMap());
}



// Finds the map with most votes; if there are multiple such maps, pick one at random
function int FindBestMap()
{
	local int i;
	local array<int> MostVoted;
	local byte MostVotes;

	// Gather a list of maps with the most votes
	for (i=0; i<Votes.Length; ++i)
	{
		if (Votes[i].NoVotes > MostVotes)
		{
			MostVotes = Votes[i].NoVotes;
			MostVoted.Length = 1;

			MostVoted[0] = i;
		}
		else if (MostVotes != 0 && Votes[i].NoVotes == MostVotes)
		{
			MostVoted.AddItem(i);
		}
	}


	// Now pick the best map (randomly if necessary)
	// TODO: Take replay count into consideration
	if (MostVoted.Length != 0)
		return MostVoted[Rand(MostVoted.Length)];
	else
		return Rand(Votes.Length);
}

function bool MapVoteInProgress()
{
	return bInEndGameVote || IsTimerActive('TimesUp');
}

function string GetWinningMap()
{
	if (WinningIndex != INDEX_None)
	{
		return Votes[WinningIndex].Map;
	}
	else
	{
		return "";
	}
}


defaultproperties
{
	WinningIndex=-1
	VRIClass=Class'UTVoteReplicationInfo'
}
