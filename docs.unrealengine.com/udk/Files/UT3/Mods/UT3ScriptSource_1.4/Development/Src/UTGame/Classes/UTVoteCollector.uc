/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVoteCollector extends Info
	config(Vote)
	native;

/**
 * Information about a game vote
 */
struct native GameVoteInfo
{
	var byte GameIdx;	// The index into 'UTMapListManager.AvailableGameProfiles' of the gametype being voted for
	var int NumVotes;	// The total number of votes this gametype currently has
};

/**
 * Information about a mutator vote
 */
struct native MutatorVoteInfo
{
	var byte MutIdx;	// Index into 'VotableMutators' (for retrieving the mutator class and display name)
	var int ProviderIdx;	// Index into the 'MutProviders' list, for retrieving description data on request for clients
	var byte NumVotes;	// The current number of votes for this mutator
	var bool bIsActive;	// Whether or not the mutator is currently running; determines whether votes are for enabling or disabling the mutator
};

/**
 * Information about a kickvote
 */
struct native KickVoteInfo
{
	var int PlayerID;	// The ID of the player being voted against
	var byte NumVotes;	// The number of votes against the player
};


/**
 * The collection of maps + votes (used in the old and new vote systems)
 */
struct native MapVoteInfo
{
	var int 	MapID;		// An INT id that represents this map.
	var string 	Map;		// The Name of the map
	var byte 	NoVotes;	// Number of votes this map has

	structdefaultproperties
	{
		MapID = -1;	// Default to NO id.
	}
};

/**
 * Config structs
 */
struct native MutatorProfile
{
	var string MutClass;	// The mutator class this profile uses, must be in the format: 'Package.Class'
	var string MutName;	// The displayed mutator name (e.g. "Instagib")
};


// Configurable variables
var globalconfig bool bMidGameVoting;			// If false, users will only be able to vote at the end of the game
var globalconfig int MidGameVotePercentage;		// The percentage of votes required to initiate a map switch midgame
var globalconfig int MinMidGameVotes;			// The minimum number of votes requires to initiate a map switch midgame


var globalconfig bool bAllowGameVoting;			// If true, then users can vote to play a map in a specific game type
var globalconfig int GameVoteDuration;			// How long players are given to pick a gametype

var globalconfig bool bAllowMapVoting;			// If true, users can vote in order to pick the next map
var globalconfig int MapVoteDuration;			// How long players are given to pick a map

var globalconfig bool bAllowMutatorVoting;		// If true, then players can vote for a mutator to be enabled/disabled during the next game
var globalconfig array<MutatorProfile> VotableMutators;	// The list of votable mutators
var globalconfig int MutatorVotePercentage;		// The percentage of votes required to enable/disable mutators (only counted at end of the game)

var globalconfig bool bAllowKickVoting;			// If true, then players can vote to kick a player out of the server
var globalconfig bool bAnonymousKickVoting;		// If true, then kickvote messages will not display the name of the voter (except to admins)
var globalconfig int MinKickVotes;			// The minimum number of votes required in order to votekick a player
var globalconfig int KickVotePercentage;		// The percentage of votes required to kick a player from the server


var globalconfig int InitialVoteDelay;			// The amount of time that must pass before voting is initialized (only applies to midgame voting)
var globalconfig int InitialVoteTransferTime;		// Slows down vote data transfers, to spread out bandwidth usage and prevent lag
var globalconfig int RushVoteTransferTime;		// Speeds up vote transfers when the client opens the vote menu; used to quickly finish transfers




var class<UTVoteReplicationInfo> VRIClass;		// The VoteReplicationInfo class which is to be used


// New mapvote system
var array<GameVoteInfo>			GameVotes;	// Information about active game votes
var array<MapVoteInfo>			MapVotes;	// Information about active map votes
var array<MutatorVoteInfo>		MutatorVotes;	// Information about votable mutators and their vote counts
var array<KickVoteInfo>			KickVotes;	// Information about active kick votes

var array<UTUIResourceDataProvider>	MutProviders;	// Cached list of mutator data providers, for retrieving descriptions for clients on request

var bool				bGameVotingActive;	// Whether or not game voting is currently active
var bool				bMapVotingActive;	// Whether map voting is active
var bool				bMutatorVotingActive;	// Whether mutator voting is active
var bool				bKickVotingActive;	// Whether kick voting is active

var bool				bUpdateActiveMapList;	// Tells the code to update the maplist manager's active maplist
var UTMapList				MapVoteMapList;		// The maplist used for map voting
var int					ForceEnableMapIdx;	// The index of the map to be forcibly enabled, when all a maplists maps are disabled
var string				PendingGameClass;	// The game class set by game voting


var deprecated array<MapVoteInfo> Votes;


var array<UTVoteReplicationInfo> VRIList;

var bool bVoteDecided;		// Whether or not the winning map vote has been decided
var bool bInMidGameVote;	// A vote countdown has been enabled mid-game, and a map switch is imminent
var bool bInEndGameVote;	// As above, but relating to end game votes
var bool bVotingAllowed;	// If true, then the vote collector is accepting votes from clients

var int WinningIndex;		// The winning map vote index
var int ActiveGameProfileIdx;

// GameInfo/MapListManager cache; minimially cuts down on casting
var UTGame		GameInfoRef;
var UTMapListManager	MapListManager;


native function int GetMapIndex(int MapID);


function Initialize(array<string> MapList)
{
	local int i, j, k, CurProvIdx;
	local UTMapList MLObj;
	local UTPlayerController UTPC;
	local Mutator m;
	local string CurMut;
	local bool bValid;

	PendingGameClass = PathName(WorldInfo.Game.Class);

	if (bAllowGameVoting)
	{
		ActiveGameProfileIdx = MapListManager.GetCurrentGameProfileIndex();
		k = MapListManager.AvailableGameProfiles.Length;

		if (k > 1)
		{
			for (i=0; i<k; ++i)
			{
				// Verify that the game profile has a valid maplist
				MLObj = MapListManager.GetMapListByName(MapListManager.AvailableGameProfiles[i].MapListName);

				if (MLObj == none || MLObj.Maps.Length == 0)
					continue;


				// Make sure that there is at least one selectable map in the map list
				bValid = False;

				for (j=0; j<MLObj.Maps.Length; ++j)
				{
					if (MapListManager.bMapEnabled(MLObj, j))
					{
						bValid = True;
						break;
					}
				}

				if (!bValid)
					continue;


				// Add the new entry
				j = GameVotes.Length;
				GameVotes.Length = j+1;

				GameVotes[j].GameIdx = i;
			}

			if (GameVotes.Length < 2)
			{
				`log("Game voting disabled, as there are not enough valid game profiles",, 'UTVoting');
				bAllowGameVoting = False;
			}
		}
		else
		{
			`log("Game voting disabled, as the map list manager does not have enough GameProfiles set",, 'UTVoting');
			bAllowGameVoting = False;
		}
	}


	if (bAllowMutatorVoting)
	{
		// Check for and remove duplicate MutClass entries in the VotableMutators list
		for (i=0; i<VotableMutators.Length-1; ++i)
		{
			CurMut = VotableMutators[i].MutClass;

			for (j=i+1; j<VotableMutators.Length; ++j)
			{
				if (VotableMutators[j].MutClass ~= CurMut)
				{
					VotableMutators.Remove(j, 1);
					--j;
				}
			}
		}

		// Fill the 'MutProviders' list
		Class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(Class'UTUIDataProvider_Mutator', MutProviders);

		// Setup the votable mutator list
		for (i=0; i<VotableMutators.Length; ++i)
		{
			// Check the validity of the current votable mutator's class value
			if (InStr(VotableMutators[i].MutClass, ".") == INDEX_None)
			{
				`log("Invalid MutClass value for 'VotableMutators' index"@i$", must be in the format: 'Package.MutatorClass'",, 'UTVoting');
				continue;
			}

			// See if this mutator has a data provider entry, and if so, cache it's index
			CurProvIdx = -1;

			for (j=0; j<MutProviders.Length; ++j)
			{
				if (UTUIDataProvider_Mutator(MutProviders[j]).ClassName ~= VotableMutators[i].MutClass)
				{
					CurProvIdx = j;
					break;
				}
			}

			// Check that the mutator is not single player only
			if (CurProvIdx != INDEX_None && UTUIDataProvider_Mutator(MutProviders[CurProvIdx]).bStandaloneOnly)
			{
				`log("The mutator '"$VotableMutators[i].MutClass$"' is single player only, and can't be added for mutator voting",, 'UTVoting');
				continue;
			}

			// If 'MutName' is not set, try to automatically load the default mutator name
			if (VotableMutators[i].MutName == "")
			{
				if (CurProvIdx != INDEX_None)
					VotableMutators[i].MutName = UTUIDataProvider_Mutator(MutProviders[CurProvIdx]).FriendlyName;

				if (VotableMutators[i].MutName == "")
				{
					`log("Could not load a default name for 'VotableMutators.MutName' at index"@i$", falling back to class name",, 'UTVoting');
					VotableMutators[i].MutName = Mid(VotableMutators[i].MutClass, InStr(VotableMutators[i].MutClass, ".")+1);
				}
			}


			// Create and fill an entry into the 'MutatorVotes' list
			j = MutatorVotes.Length;
			MutatorVotes.Length = j+1;

			MutatorVotes[j].MutIdx = i;
			MutatorVotes[j].ProviderIdx = CurProvIdx;


			// Check if the current votable mutator is active
			for (m=GameInfoRef.BaseMutator; m!=none; m=m.NextMutator)
			{
				if (PathName(m.Class) ~= VotableMutators[i].MutClass)
				{
					MutatorVotes[j].bIsActive = True;
					break;
				}
			}
		}

		if (MutatorVotes.Length == 0)
		{
			`log("Mutator voting disabled as there are not enough valid 'VotableMutators' entries",, 'UTVoting');
			bAllowMutatorVoting = False;
		}

		// Call SaveConfig in case anything was changed
		SaveConfig();
	}


	foreach WorldInfo.AllControllers(class'UTPlayerController', UTPC)
	{
		AttachVoteReplicationInfo(UTPC);
	}


	if (bMidGameVoting)
	{
		if (InitialVoteDelay <= 0)
			InitializeVoting();
		else
			SetTimer(InitialVoteDelay * WorldInfo.TimeDilation, false, 'InitializeVoting');
	}
}

// Start accepting votes
function InitializeVoting()
{
	local int i;

	bVotingAllowed = True;

	// Set the appropriate voting state
	if (bAllowGameVoting)
		GotoState('GameVoteRound');
	else
		GotoState('MainVoteRound');


	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].NotifyAllowVoting();
}


function NotifyPlayerJoined(UTPlayerController Player)
{
	if (Player.PlayerReplicationInfo != none && !Player.PlayerReplicationInfo.bOnlySpectator)
		AttachVoteReplicationInfo(Player);
}

function NotifyPlayerExiting(UTPlayerController Player)
{
	if (Player.VoteRI != none)
	{
		RemoveAllVRIVotes(Player.VoteRI);

		// If any other players have kickvoted against the exiting player, then remove their votes
		if (bKickVotingActive)
			RemoveAllKickVotesFor(Player.PlayerReplicationInfo.PlayerID);


		VRIList.RemoveItem(Player.VoteRI);
		Player.VoteRI.Destroy();


		// Check if the existing player caused a vote to win, through reducing the number of required votes (only happens during midgame voting)
		if (bMidGameVoting)
		{
			if (!CountdownInProgress() && ((bGameVotingActive && CheckGameVoteCount(FindBestGame())) ||
				(bMapVotingActive && !CountdownInProgress() && CheckMapVoteCount(FindBestMap()))))
			{
				BeginVoteCountdown();
			}
		}
	}
}

function NotifyBecomeSpectator(UTPlayerController Player)
{
	// Treat a player moving to spectator as a player exiting the game
	NotifyPlayerExiting(Player);
}

function NotifyBecomeActivePlayer(UTPlayerController Player)
{
	// Treat spectators becoming active players, as players joining
	NotifyPlayerJoined(Player);
}

// Called when the game has ended, and the mapswitch countdown has begun
function NotifyEndGameVote()
{
	local int i;
	local PlayerController PC;

	// Force early allowance of voting, if the game ends unusually early
	if (IsTimerActive('InitializeVoting') || !bMidGameVoting)
	{
		InitializeVoting();
		ClearTimer('InitializeVoting');
	}

	if (CountdownInProgress() || (GetStateName() == Class.Name && bMidGameVoting))
		return;


	bInEndGameVote = True;
	BeginVoteCountdown();

	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].ClientBeginVoting();


	// Notify clients that voting has been initialized
	foreach WorldInfo.AllControllers(Class'PlayerController', PC)
		PC.ReceiveLocalizedMessage(GameInfoRef.GameMessageClass, 18);
}

// Called just before the final map switch
function NotifyRestartGame()
{
	local name MapListName;
	local UTMapList MLObj;
	local int i;

	// Used by the game vote code to switch the active maplist, before the maplist manager is asked to pick the next map
	if (bUpdateActiveMapList)
	{
		if (MapListManager.ActiveGameProfile != INDEX_None && MapListManager.ActiveGameProfile < MapListManager.AvailableGameProfiles.Length)
		{
			MapListName = MapListManager.AvailableGameProfiles[MapListManager.ActiveGameProfile].MapListName;

			if (MapListName != '')
			{
				MLObj = MapListManager.GetMapListByName(MapListName);

				if (MLObj != none && MLObj.Maps.Length != 0)
					MapListManager.ActiveMapList = MLObj;
			}
		}
	}

	if (!bVoteDecided && bMapVotingActive)
		MapVotePassed(FindBestMap());

	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].ClientTimesUp();
}


function AttachVoteReplicationInfo(UTPlayerController PC)
{
	local UTVoteReplicationInfo VRI;

	if (PC.VoteRI != none || PC.PlayerReplicationInfo.bOnlySpectator)
		return;

	VRI = Spawn(VRIClass, PC);

	if (VRI != none)
	{
		PC.VoteRI = VRI;

		VRI.Initialize(Self);

		if (bVotingAllowed)
			VRI.NotifyAllowVoting();

		VRIList.AddItem(VRI);
	}
	else
	{
		`log("Could not spawn a vote replication info for"@PC.PlayerReplicationInfo.PlayerName@"("$PC$")",, 'UTVoting');
	}
}


// ***** Voting rounds: These states control each round of voting

function bool CountdownInProgress()
{
	return bInEndGameVote || IsTimerActive('EndVoteCountdown');
}

// Used to determine the total amount of time that the vote collector will spend counting down
function int GetTotalVoteDuration(optional bool bEndGameVote=bInEndGameVote)
{
	local int ReturnVal;

	if (bAllowGameVoting)
		ReturnVal += GameVoteDuration;

	if (bAllowMapVoting)
	{
		if (MapVoteDuration != 0)
			ReturnVal += MapVoteDuration;
		else if (GameVoteDuration != 0)
			ReturnVal += GameVoteDuration;
		else
			ReturnVal += 15;
	}

	if (bEndGameVote)
		ReturnVal = Max(GameInfoRef.RestartWait + GameInfoRef.EndTimeDelay, ReturnVal);

	return ReturnVal;
}


// Function stubs (implemented within states)
function BeginVoteCountdown(optional bool bInCountdown);
function EndVoteCountdown();

state GameVoteRound
{
	function BeginState(name PreviousStateName)
	{
		local int i;

		bGameVotingActive = bAllowGameVoting;
		bKickVotingActive = bAllowKickVoting;


		// Notify clients of the vote round update
		for (i=0; i<VRIList.Length; ++i)
			VRIList[i].NotifyVoteRoundUpdate();
	}

	function BeginVoteCountdown(optional bool bInCountdown)
	{
		local int i, RoundDuration;
		local UTGameReplicationInfo GRI;

		if (!bInEndGameVote)
			bInMidGameVote = True;

		if (GameVoteDuration > 0 || bInEndGameVote)
		{
			GRI = UTGameReplicationInfo(GameInfoRef.GameReplicationInfo);

			// If this is the start of the vote countdown, then set the GameReplicationInfos 'MapVoteTimeRemaining' value
			if (!bInCountdown)
				GRI.MapVoteTimeRemaining = GetTotalVoteDuration();

			// If it's an endgame vote, then take 'RestartWait' into consideration, by increasing the first rounds vote time
			if (bInEndGameVote && !bInCountdown)
				RoundDuration = (GetTotalVoteDuration(True) - GetTotalVoteDuration(False)) + GameVoteDuration;
			else if (GameVoteDuration > 0)
				RoundDuration = GameVoteDuration;
			else
				RoundDuration = 15;

			if (bGameVotingActive)
				GRI.SetVoteRoundTimeRemaining(RoundDuration);

			SetTimer(RoundDuration * WorldInfo.TimeDilation, False, 'EndVoteCountdown');


			for (i=0; i<VRIList.Length; ++i)
			{
				VRIList[i].SetDesiredTransferTime(,, True);
				VRIList[i].ClientBeginVoting();

				if (!bInEndGameVote)
					VRIList[i].ClientOpenVoteMenu();
			}
		}
		else
		{
			// If the game vote duration is set to 0, then end voting immediately
			EndVoteCountdown();
		}
	}

	function EndVoteCountdown()
	{
		local int BestGameIdx, i;
		local int RemainingTime;

		if (bInEndGameVote)
		{
			RemainingTime = (GameInfoRef.EndTime + GameInfoRef.RestartWait) - WorldInfo.RealTimeSeconds;
			UTGameReplicationInfo(GameInfoRef.GameReplicationInfo).SetVoteRoundTimeRemaining(RemainingTime);
		}


		BestGameIdx = FindBestGame();

		// Modify the maplist managers active game profile, to match the voted game profiles index
		if (BestGameIdx != INDEX_None)
		{
			for (i=0; i<VRIList.Length; ++i)
				VRIList[i].ClientSetWinningGameIndex(BestGameIdx);

			if (MapListManager.ActiveGameProfile != GameVotes[BestGameIdx].GameIdx)
			{
				if (GameVotes[BestGameIdx].GameIdx != INDEX_None)
					PendingGameClass = MapListManager.AvailableGameProfiles[GameVotes[BestGameIdx].GameIdx].GameClass;

				MapListManager.SetCurrentGameProfileIndex(GameVotes[BestGameIdx].GameIdx);
				bUpdateActiveMapList = True;
			}
		}

		GotoState('MainVoteRound');
	}

	function EndState(name NextStateName)
	{
		bGameVotingActive = False;
		bKickVotingActive = False;
	}
}

state MainVoteRound
{
	function BeginState(name PreviousStateName)
	{
		local int i, EnabledCount;
		local UTMapList MLObj;
		local bool bDisableMapVoting;
		local string NextMap, CurMutClass;
		local class<UTGame> NextGameClass;

		if (!bMapVotingActive && bAllowMapVoting)
		{
			// Setup the map vote list
			ActiveGameProfileIdx = MapListManager.ActiveGameProfile;

			if (ActiveGameProfileIdx == INDEX_None || ActiveGameProfileIdx >= MapListManager.AvailableGameProfiles.Length)
			{
				`log("Invalid 'ActiveGameProfileIdx', getting the current index",, 'UTVoting');
				ActiveGameProfileIdx = MapListManager.GetCurrentGameProfileIndex();
			}

			if (ActiveGameProfileIdx != INDEX_None)
			{
				MLObj = MapListManager.GetMapListByName(MapListManager.AvailableGameProfiles[ActiveGameProfileIdx].MapListName);

				if (MLObj != none && MLObj.Maps.Length != 0 && (bAllowGameVoting || MLObj.Maps.Length > 1))
				{
					MapVoteMapList = MLObj;
					MapVotes.Length = MLObj.Maps.Length;

					for (i=0; i<MLObj.Maps.Length; ++i)
					{
						EnabledCount += int(MapListManager.bMapEnabled(MLObj, i));

						MapVotes[i].MapID = i;
						MapVotes[i].Map = MLObj.GetMap(i);
					}


					// If none of the maps are enabled, then forcibly enable the next map in the list (if mid game voting is on)
					if (EnabledCount == 0)
					{
						if (bMidGameVoting)
						{
							NextMap = MapListManager.GetNextMap(MLObj);

							if (NextMap != "")
								ForceEnableMapIdx = MapVotes.Find('Map', NextMap);
						}

						if (ForceEnableMapIdx != INDEX_None)
						{
							`log("No enabled maps in the current map list, forcibly enabling '"$
								MapVotes[ForceEnableMapIdx].Map$"'",, 'UTVoting');
						}
						else
						{
							`log("Map voting disabled due to lack of enabled maps",, 'UTVoting');
							bDisableMapVoting = True;
						}
					}
				}
				else if (MLObj != none)
				{
					`log("Map voting disabled due to lack of maps",, 'UTVoting');
					bDisableMapVoting = True;
				}
				else
				{
					`log("Map voting disabled due to an invalid map list name",, 'UTVoting');
					bDisableMapVoting = True;
				}
			}
			else
			{
				`log("Map voting disabled due to invalid game profile index",, 'UTVoting');
				bDisableMapVoting = True;
			}
		}


		// Filter out mutators which aren't supported by the current or pending game class
		if (!bMutatorVotingActive && bAllowMutatorVoting)
		{
			if (PendingGameClass == PathName(WorldInfo.Game.Class))
			{
				NextGameClass = Class<UTGame>(WorldInfo.Game.Class);
			}
			else if (Left(PendingGameClass, 7) ~= "UTGame." || Left(PendingGameClass, 14) ~= "UTGameContent." ||
				Left(PendingGameClass, 12) ~= "UT3GoldGame.")
			{
				// Only load non-custom gametype classes for filtering
				NextGameClass = Class<UTGame>(DynamicLoadObject(PendingGameClass, Class'Class'));
			}


			if (NextGameClass != none)
			{
				for (i=0; i<MutatorVotes.Length; ++i)
				{
					CurMutClass = VotableMutators[MutatorVotes[i].MutIdx].MutClass;

					if (!NextGameClass.static.AllowMutator(CurMutClass))
						MutatorVotes.Remove(i--, 1);
				}
			}
		}


		bMapVotingActive = bAllowMapVoting && !bDisableMapVoting;
		bMutatorVotingActive = bAllowMutatorVoting;
		bKickVotingActive = bAllowKickVoting;


		if (bInEndGameVote || bInMidGameVote)
		{
			if (bMapVotingActive || bMutatorVotingActive)
				BeginVoteCountdown(PreviousStateName != '');
			else if (!bInEndGameVote)
				GameInfoRef.RestartGame();
		}


		// Notify clients of the vote round update
		for (i=0; i<VRIList.Length; ++i)
			VRIList[i].NotifyVoteRoundUpdate();
	}

	function BeginVoteCountdown(optional bool bInCountdown)
	{
		local int i, RoundDuration;
		local UTGameReplicationInfo GRI;

		if (!bInEndGameVote)
			bInMidGameVote = True;

		if (MapVoteDuration > 0 || bAllowGameVoting)
		{
			GRI = UTGameReplicationInfo(GameInfoRef.GameReplicationInfo);

			// If this is the start of the vote countdown, then set the GameReplicationInfos 'MapVoteTimeRemaining' value
			if (!bInCountdown)
				GRI.MapVoteTimeRemaining = GetTotalVoteDuration();


			// If it's an endgame vote and this is the first round, then take 'RestartWait' into consideration, by increasing the vote time
			if (bInEndGameVote && !bInCountdown)
				RoundDuration = (GetTotalVoteDuration(True) - GetTotalVoteDuration(False)) + MapVoteDuration;
			else
				RoundDuration = MapVoteDuration;

			if (MapVoteDuration == 0)
			{
				if (GameVoteDuration > 0)
					RoundDuration += GameVoteDuration;
				else
					RoundDuration += 15;
			}


			if (bMapVotingActive || bMutatorVotingActive)
				GRI.SetVoteRoundTimeRemaining(RoundDuration);

			SetTimer(RoundDuration * WorldInfo.TimeDilation, False, 'EndVoteCountdown');


			for (i=0; i<VRIList.Length; ++i)
			{
				VRIList[i].SetDesiredTransferTime(,, True);
				VRIList[i].ClientBeginVoting();

				if (!bInEndGameVote)
					VRIList[i].ClientOpenVoteMenu();
			}
		}
		else
		{
			// If the game vote duration is set to 0, then end voting immediately
			EndVoteCountdown();
		}
	}

	function EndVoteCountdown()
	{
		local int i;
		local int RemainingTime;

		if (bMapVotingActive)
			MapVotePassed(FindBestMap());
		else
			for (i=0; i<VRIList.Length; ++i)
				VRIList[i].ClientTimesUp();

		if (bInEndGameVote)
		{
			RemainingTime = (GameInfoRef.EndTime + GameInfoRef.RestartWait) - WorldInfo.RealTimeSeconds;
			UTGameReplicationInfo(GameInfoRef.GameReplicationInfo).SetVoteRoundTimeRemaining(RemainingTime);
		}
		else
		{
			GameInfoRef.RestartGame();
		}
	}

	function EndState(name NextStateName)
	{
		bMapVotingActive = False;
		bMutatorVotingActive = False;
		bKickVotingActive = False;
	}
}


// ***** Voting implementation

// Game Voting

function RemoveGameVote(UTVoteReplicationInfo VRI)
{
	if (!bGameVotingActive || VRI.CurGameVoteIndex > GameVotes.Length)
		return;


	--GameVotes[VRI.CurGameVoteIndex].NumVotes;

	if (GameVotes[VRI.CurGameVoteIndex].NumVotes == 255)
		GameVotes[VRI.CurGameVoteIndex].NumVotes = 0;

	UpdateGameVoteStatus(VRI.CurGameVoteIndex);

	VRI.CurGameVoteIndex = 255;
}

function AddGameVote(UTVoteReplicationInfo VRI, byte GameIdx)
{
	local UTPlayerController VotePC;

	if (!bGameVotingActive || GameIdx > GameVotes.Length || VRI.CurGameVoteIndex != 255)
		return;


	++GameVotes[GameIdx].NumVotes;


	VotePC = UTPlayerController(VRI.Owner);

	if (VotePC != none)
		UpdateGameVoteStatus(GameIdx, True, VotePC.PlayerReplicationInfo);
	else
		UpdateGameVoteStatus(GameIdx);


	VRI.CurGameVoteIndex = GameIdx;
	VRI.ClientGameVoteConfirmed(GameIdx);

	if (!CountdownInProgress() && CheckGameVoteCount(GameIdx))
		BeginVoteCountdown();
}

function UpdateGameVoteStatus(byte GameVoteIdx, optional bool bBroadcastVote, optional PlayerReplicationInfo VotePRI)
{
	local int i;

	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].NotifyGameVoteUpdate(GameVoteIdx, GameVotes[GameVoteIdx].NumVotes, bBroadcastVote, VotePRI);
}

function bool CheckGameVoteCount(byte Idx)
{
	local int i, VoteCount;
	local float ReqVotes;

	if (Idx >= GameVotes.Length)
		return False;

	ReqVotes = Max(Max(1.0, MinMidGameVotes) * 1000.0, float(GameInfoRef.GetNumPlayers()) * float(MidGameVotePercentage) * 10.0);

	// If GameVoteDuration is set, then check the total number of votes rather than the number of votes for the current map
	if (!CountdownInProgress() && GameVoteDuration > 0)
	{
		for (i=0; i<GameVotes.Length; ++i)
			VoteCount += GameVotes[i].NumVotes;

		if (float(VoteCount * 1000) >= ReqVotes)
			return True;
	}

	return (float(GameVotes[Idx].NumVotes) * 1000.0 >= ReqVotes);
}

function int FindBestGame()
{
	local byte i, BiggestNum;
	local array<byte> MostVoted;

	// Get the list of gametypes with most votes
	for (i=0; i<GameVotes.Length; ++i)
	{
		if (GameVotes[i].NumVotes > BiggestNum)
		{
			BiggestNum = GameVotes[i].NumVotes;

			MostVoted.Length = 1;
			MostVoted[0] = i;
		}
		else if (BiggestNum != 0 && GameVotes[i].NumVotes == BiggestNum)
		{
			MostVoted.AddItem(i);
		}
	}


	// Now pick the best one (or use the current gametype, if none have been voted for)
	if (MostVoted.Length != 0)
		return MostVoted[Rand(MostVoted.Length)];
	else
		return GameVotes.Find('GameIdx', ActiveGameProfileIdx);
}


// Map Voting

function RemoveMapVote(UTVoteReplicationInfo VRI)
{
	if (!bMapVotingActive || VRI.CurMapVoteIndex > MapVotes.Length)
		return;


	--MapVotes[VRI.CurMapVoteIndex].NoVotes;

	if (MapVotes[VRI.CurMapVoteIndex].NoVotes == 255)
		MapVotes[VRI.CurMapVoteIndex].NoVotes = 0;

	UpdateMapVoteStatus(VRI.CurMapVoteIndex);

	VRI.CurMapVoteIndex = 255;
}

function AddMapVote(UTVoteReplicationInfo VRI, byte MapIdx)
{
	local UTPlayerController VotePC;

	if (!bMapVotingActive || MapIdx > MapVotes.Length || VRI.CurMapVoteIndex != 255 ||
		(!MapListManager.bMapEnabled(MapVoteMapList, MapIdx) && MapIdx != ForceEnableMapIdx))
	{
		return;
	}


	++MapVotes[MapIdx].NoVotes;

	VotePC = UTPlayerController(VRI.Owner);

	if (VotePC != none)
		UpdateMapVoteStatus(MapIdx, True, VotePC.PlayerReplicationInfo);
	else
		UpdateMapVoteStatus(MapIdx);

	VRI.CurMapVoteIndex = MapIdx;
	VRI.ClientMapVoteConfirmed(MapIdx);

	if (!CountdownInProgress() && CheckMapVoteCount(MapIdx))
		BeginVoteCountdown();
}

function UpdateMapVoteStatus(byte MapVoteIdx, optional bool bBroadcastVote, optional PlayerReplicationInfo VotePRI)
{
	local int i;

	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].NotifyMapVoteUpdate(MapVoteIdx, MapVotes[MapVoteIdx].NoVotes, bBroadcastVote, VotePRI);
}

function bool CheckMapVoteCount(int Idx)
{
	local int i, VoteCount;
	local float ReqVotes;
	local bool bCountdownInProgress;

	if (Idx < 0 || Idx >= MapVotes.Length)
		return False;


	bCountdownInProgress = CountdownInProgress();

	if (bCountdownInProgress)
		ReqVotes = Max(1000.0, float(GameInfoRef.GetNumPlayers()) * float(MidGameVotePercentage) * 10.0);
	else
		ReqVotes = Max(Max(1.0, MinMidGameVotes) * 1000.0, float(GameInfoRef.GetNumPlayers()) * float(MidGameVotePercentage) * 10.0);


	// If VoteDuration is set, then check the total number of votes rather than the number of votes for the current map
	if (!bCountdownInProgress || MapVoteDuration > 0)
	{
		for (i=0; i<MapVotes.Length; ++i)
			VoteCount += MapVotes[i].NoVotes;


		if (float(VoteCount * 1000) >= ReqVotes)
			return True;
	}


	return (float(MapVotes[Idx].NoVotes) * 1000.0 >= ReqVotes);
}

function MapVotePassed(int WinIdx)
{
	local int i;

	bVoteDecided = True;

	if (WinIdx != INDEX_None)
		WinningIndex = WinIdx;

	for (i=0; i<VRIList.Length; ++i)
	{
		VRIList[i].ClientSetWinningMapIndex(WinIdx);

		if (VRIList[i].bSupportsNewVoting)
			VRIList[i].ClientTimesUpNew(MapVotes[WinIdx].Map);
		else
			VRIList[i].ClientTimesUp();
	}
}

function string GetWinningMap()
{
	if (bVoteDecided && WinningIndex != INDEX_None && WinningIndex < MapVotes.Length)
		return MapVotes[WinningIndex].Map;


	return "";
}

// Finds the mapvote with most votes; if there are multiple such mapvotes, pick one at random
function int FindBestMap()
{
	local int i;
	local array<int> MostVoted;
	local byte MostVotes;

	// Gather a list of maps with the most votes
	for (i=0; i<MapVotes.Length; ++i)
	{
		if (MapVotes[i].NoVotes > MostVotes)
		{
			MostVotes = MapVotes[i].NoVotes;
			MostVoted.Length = 1;

			MostVoted[0] = i;
		}
		else if (MostVotes != 0 && MapVotes[i].NoVotes == MostVotes)
		{
			MostVoted.AddItem(i);
		}
	}


	// Now pick the best map (randomly if necessary)
	if (MostVoted.Length != 0)
		return MostVoted[Rand(MostVoted.Length)];
	else if (MapVoteMapList != none)
		return MapVotes.Find('Map', MapListManager.GetNextMap(MapVoteMapList));
	else
		return INDEX_None;
}


// Mutator Voting

function RemoveMutatorVote(UTVoteReplicationInfo VRI, byte MutIdx)
{
	if (!bMutatorVotingActive || MutIdx > MutatorVotes.Length)
		return;

	--MutatorVotes[MutIdx].NumVotes;

	if (MutatorVotes[MutIdx].NumVotes == 255)
		MutatorVotes[MutIdx].NumVotes = 0;

	UpdateMutVoteStatus(MutIdx);
	VRI.CurMutVoteIndicies.RemoveItem(MutIdx);
	VRI.ClientMutVoteConfirmed(MutIdx, False);
}

function AddMutatorVote(UTVoteReplicationInfo VRI, byte MutIdx)
{
	if (!bMutatorVotingActive || MutIdx > MutatorVotes.Length)
		return;

	++MutatorVotes[MutIdx].NumVotes;
	UpdateMutVoteStatus(MutIdx);

	VRI.CurMutVoteIndicies.AddItem(MutIdx);
	VRI.ClientMutVoteConfirmed(MutIdx, True);
}

function UpdateMutVoteStatus(byte MutVoteIdx)
{
	local int i;

	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].NotifyMutVoteUpdate(MutVoteIdx, MutatorVotes[MutVoteIdx].NumVotes);
}

function bool CheckMutatorVoteCount(int Idx)
{
	local float ReqVotes;

	if (Idx < 0 || Idx >= MutatorVotes.Length)
		return False;

	ReqVotes = Max(1000.0, float(GameInfoRef.GetNumPlayers()) * float(MutatorVotePercentage) * 10.0);

	return (float(MutatorVotes[Idx].NumVotes) * 1000.0 >= ReqVotes);
}


// Kick Voting

function RemoveKickVote(UTVoteReplicationInfo VRI, int KickID)
{
	local int i;

	if (!bKickVotingActive)
		return;

	i = KickVotes.Find('PlayerID', KickID);

	// Shouldn't ever happen
	if (i == INDEX_None)
		return;


	--KickVotes[i].NumVotes;

	if (KickVotes[i].NumVotes == 255)
		KickVotes[i].NumVotes = 0;


	UpdateKickVoteStatus(i);

	if (KickVotes[i].NumVotes == 0)
		KickVotes.Remove(i, 1);


	VRI.CurKickVoteIDs.RemoveItem(KickID);
	VRI.ClientKickVoteConfirmed(KickID, False);
}

function AddKickVote(UTVoteReplicationInfo VRI, int KickID)
{
	local int i;
	local Controller C;

	if (!bKickVotingActive)
		return;

	i = KickVotes.Find('PlayerID', KickID);

	if (i == INDEX_None)
	{
		// Verify that the ID is valid
		foreach WorldInfo.AllControllers(Class'Controller', C)
		{
			if (PlayerController(C) != none && C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.PlayerID == KickID)
			{
				// Add a new entry
				i = KickVotes.Length;
				KickVotes.Length = i+1;
				KickVotes[i].PlayerID = KickID;

				break;
			}
		}


		if (i == INDEX_None)
			return;
	}


	// Kickvote notification messages
	foreach WorldInfo.AllControllers(Class'Controller', C)
		if (PlayerController(C) != none && C.PlayerReplicationInfo.PlayerID == KickID)
			break;

	if (bAnonymousKickVoting)
		BroadcastVoteMessage(20, PlayerController(VRI.Owner).PlayerReplicationInfo, C.PlayerReplicationInfo, 19);
	else
		BroadcastVoteMessage(19, PlayerController(VRI.Owner).PlayerReplicationInfo, C.PlayerReplicationInfo);


	++KickVotes[i].NumVotes;
	UpdateKickVoteStatus(i);
	VRI.CurKickVoteIDs.AddItem(KickID);
	VRI.ClientKickVoteConfirmed(KickID, True);

	if (CheckKickVoteCount(i))
		KickVotePassed(i);
}

function RemoveAllKickVotesFor(int PlayerID)
{
	local int i;

	for (i=0; i<VRIList.Length; ++i)
		if (VRIList[i].CurKickVoteIDs.Find(PlayerID) != INDEX_None)
			RemoveKickVote(VRIList[i], PlayerID);
}

function UpdateKickVoteStatus(byte KickVoteIdx)
{
	local int i;

	for (i=0; i<VRIList.Length; ++i)
		VRIList[i].NotifyKickVoteUpdate(KickVotes[KickVoteIdx]);
}

function bool CheckKickVoteCount(int Idx)
{
	local float ReqVotes;

	if (Idx < 0 || Idx > KickVotes.Length)
		return False;

	ReqVotes = Max(Max(1.0, MinKickVotes) * 1000.0, float(GameInfoRef.GetNumPlayers()) * float(KickVotePercentage) * 10.0);

	return (float(KickVotes[Idx].NumVotes) * 1000.0 >= ReqVotes);
}

function KickVotePassed(int WinIdx)
{
	local Controller C;
	local int WinID;

	WinID = KickVotes[WinIdx].PlayerID;
	RemoveAllKickVotesFor(KickVotes[WinIdx].PlayerID);


	// Get a reference to the controller and kick (if not an admin)
	foreach WorldInfo.AllControllers(Class'Controller', C)
		if (C.PlayerReplicationInfo.PlayerID == WinID)
			break;

	if (C != none && !C.PlayerReplicationInfo.bAdmin)
	{
		if (PlayerController(C) != none)
		{
			// Vote success message
			BroadcastVoteMessage(21, C.PlayerReplicationInfo);
			`log("Kick vote passed for player '"$C.PlayerReplicationInfo.GetPlayerAlias()$"'",, 'UTVoting');

			GameInfoRef.AccessControl.SessionBanPlayer(PlayerController(C));
		}
	}
}

// If players spam kick votes in order to flood the screen with kickvote messages, session ban them
function HandleKickVoteSpam(UTVoteReplicationInfo SpammerVRI)
{
	if (SpammerVRI.Owner != none && !PlayerController(SpammerVRI.Owner).PlayerReplicationInfo.bAdmin)
	{
		GameInfoRef.AccessControl.SessionBanPlayer(PlayerController(SpammerVRI.Owner));
		BroadcastVoteMessage(22, PlayerController(SpammerVRI.Owner).PlayerReplicationInfo);
	}
}


function RemoveAllVRIVotes(UTVoteReplicationInfo VRI)
{
	local int i;

	if (bGameVotingActive && VRI.CurGameVoteIndex != 255)
		RemoveGameVote(VRI);

	if (bMapVotingActive && VRI.CurMapVoteIndex != 255)
		RemoveMapVote(VRI);

	if (bMutatorVotingActive)
		while (VRI.CurMutVoteIndicies.Length > 0 && ++i < 256)
			RemoveMutatorVote(VRI, VRI.CurMutVoteIndicies[0]);

	if (bKickVotingActive)
		while (VRI.CurKickVoteIDs.Length > 0 && ++i < 256)
			RemoveKickVote(VRI, VRI.CurKickVoteIDs[0]);
}

// Special broadcast function to allow sending of new vote messages to old clients
function BroadcastVoteMessage(int MessageIdx, optional PlayerReplicationInfo PRI1, optional PlayerReplicationInfo PRI2, optional int AdminMessageIdx=-1)
{
	local UTPlayerController PC;

	if (AdminMessageIdx == INDEX_None)
		AdminMessageIdx = MessageIdx;

	foreach WorldInfo.AllControllers(Class'UTPlayerController', PC)
	{
		if (PC.VoteRI == none || PC.VoteRI.bSupportsNewVoting)
			PC.ReceiveLocalizedMessage(GameInfoRef.GameMessageClass, (PC.PlayerReplicationInfo.bAdmin ? AdminMessageIdx : MessageIdx), PRI1, PRI2);
		else
			PC.ClientMessage(GameInfoRef.GameMessageClass.static.GetString((PC.PlayerReplicationInfo.bAdmin ? AdminMessageIdx : MessageIdx),, PRI1, PRI2));
	}
}


// Used to add default URL options upon map change, must NOT be used to remove options; that should be done in ModifyOptions instead
//	(called from UTGame::GetNextMap)
function string AddDefaultOptions(string CurOptions)
{
	local int i;
	local string MutStr;
	local array<string> AddList;

	// Construct the list of mutators to be added
	for (i=0; i<MutatorVotes.Length; ++i)
	{
		if (!MutatorVotes[i].bIsActive && CheckMutatorVoteCount(i))
		{
			MutStr = VotableMutators[MutatorVotes[i].MutIdx].MutClass;

			if (AddList.Find(MutStr) == INDEX_None)
				AddList.AddItem(MutStr);
		}
	}

	if (AddList.Length != 0)
		Class'UTMapListManager'.static.ModifyMutatorOptions(CurOptions, AddList);

	return CurOptions;
}

// Used to modify URL options upon map change, e.g. to remove mutators which have been voted out
//	(called from UTGame::GetNextMap)
function ModifyOptions(out string CurOptions)
{
	local int i;
	local string MutStr;
	local array<string> RemoveList;

	// Construct the list of mutators to be removed
	for (i=0; i<MutatorVotes.Length; ++i)
	{
		if (MutatorVotes[i].bIsActive && CheckMutatorVoteCount(i))
		{
			MutStr = VotableMutators[MutatorVotes[i].MutIdx].MutClass;

			if (RemoveList.Find(MutStr) == INDEX_None)
				RemoveList.AddItem(MutStr);
		}
	}

	if (RemoveList.Length != 0)
		Class'UTMapListManager'.static.ModifyMutatorOptions(CurOptions,, RemoveList);
}


// Various helper functions

final function bool GetGameVoteInfo(byte Index, out string GameName, out byte NumVotes)
{
	if (Index >= GameVotes.Length)
		return False;

	GameName = MapListManager.AvailableGameProfiles[GameVotes[Index].GameIdx].GameName;
	NumVotes = GameVotes[Index].NumVotes;

	return True;
}

final function bool GetMutVoteInfo(byte Index, out string MutClass, out string MutName, out byte NumVotes, out byte bIsActive)
{
	if (Index >= MutatorVotes.Length)
		return False;

	MutClass = VotableMutators[MutatorVotes[Index].MutIdx].MutClass;
	MutName = VotableMutators[MutatorVotes[Index].MutIdx].MutName;
	NumVotes = MutatorVotes[Index].NumVotes;
	bIsActive = byte(MutatorVotes[Index].bIsActive);

	return True;
}


// Unused function stubs (kept for binary compatibility)
function BroadcastVoteChange(int MapID, byte VoteCount);
function RemoveVoteFor(out int CurrentVoteID);
function int AddVoteFor(out int CurrentVoteID);
function BeginMidGameMapVote(optional int CurWinIndex);
function TimesUp();
function bool MapVoteInProgress();


defaultproperties
{
	WinningIndex=-1
	ForceEnableMapIdx=-1

	VRIClass=Class'UTVoteReplicationInfo'
}
