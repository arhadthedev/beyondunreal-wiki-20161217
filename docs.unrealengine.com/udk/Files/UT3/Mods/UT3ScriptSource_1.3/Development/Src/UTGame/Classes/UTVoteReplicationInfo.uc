/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVoteReplicationInfo extends ReplicationInfo
	dependson(UTVoteCollector)
	nativereplication
	native;

/** Cached reference to our collector */
var UTVoteCollector Collector;

/** Our local view of the map data */
var array<MapVoteInfo> Maps;

/** How many maps are we expecting */

var int MapCount;
var int SendIndex;
var int LastSendIndex;

/** Used to detect the setting of the owner without RepNotifing Owner */
var actor OldOwner;

var int dummy;

var int MyCurrnetVoteID;

var string LeadingMap;
var array<string> LeadingMaps;


// Function replication limitation
var float RecordVoteTimestamp;
var int RecordVoteCounter;

var byte PendingBeginVoting;
var bool bVotingOver;

replication
{
	if (ROLE==ROLE_Authority)
		dummy;
}





/**
 * @Returns the index of the a map given the ID or -1 if it's not in the array
 */
native function int GetMapIndex(int MapID);

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Dummy=3;
}


/**
 * Called when the client receives his owner.  Let the server know it can begin sending maps
 */
simulated event ClientHasOwner()
{
	local UTPlayerController PC;

	PC = UTPlayerController(Owner);

//	`log("### ClientHasOwner"@PC);

	if (ROLE < ROLE_Authority)
	{
		// Create the reference to myself in the PC
		PC.VoteRI = self;
	}

	ServerClientIsReady();
}

function Initialize(UTVoteCollector NewCollector)
{
	local int i;
	local PlayerController PC;
	Collector = NewCollector;

	// If we are a listen server and this is the local player's VoteRI, then
	// just setup the array and be done with it.

	if ( WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone )
	{
		PC = PlayerController(Owner);
		if ( PC != none && LocalPlayer(PC.Player) != none )
		{
//			`log("### Listen Server shortcut");

			Maps.Length = Collector.Votes.Length;
			for (i = 0; i < Collector.Votes.Length; i++)
			{
				Maps[i].Map = Collector.Votes[i].Map;
				Maps[i].MapID = Collector.Votes[i].MapID;
				Maps[i].NoVotes = Collector.Votes[i].NoVotes;
			}

			GotoState('Voting');
		}
	}
}

simulated reliable client function ClientTimesUp()
{
	local UTGameReplicationInfo GRI;

	bVotingOver = True;
	LeadingMaps.Length = 0;


	// Force a final update for the vote timer
	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (GRI != none && GRI.CurrentMidGameMenu != none)
	{
		//`log("Final vote timer update",, 'UTVotingDebug');
		GRI.CurrentMidGameMenu.UpdateVote(GRI);
	}
}

reliable server function ServerClientIsReady()
{
//	`log("### Client says he's ready");
	ClientInitTransfer( Collector.Votes.Length );
}


simulated reliable client function ClientInitTransfer(int TotalMapCount)
{
//	`log("### Received Map Count ("$TotalMapCount$") -- Requesting initiate transfer To/From"@Owner);

	MapCount = TotalMapCount;
	ServerAckTransfer();
}


reliable server function ServerAckTransfer()
{
//	`log("### Client"$Owner$" has ackd the initial transfer.  Ramping up!");
	GotoState('ReplicatingToClient');
}

/** We have received a map from the server.  Add it */
simulated reliable client function ClientRecvMapInfo(MapVoteInfo VInfo)
{
	local int Idx;

	Idx = GetMapIndex(VInfo.MapID);
	if (Idx == INDEX_None)		// Add one
	{
		Idx = Maps.Length;
		Maps.Length = Maps.Length+1;
	}

//	`log("### Recv'd a Map ("$VInfo.MapID@VInfo.Map@VInfo.NoVotes$")");

	// Set the data

	Maps[Idx].MapID = VInfo.MapID;
	Maps[Idx].Map = VInfo.Map;
	Maps[Idx].NoVotes= VInfo.NoVotes;

	ServerAckTransfer();

}

simulated reliable client function ClientRecvMapUpdate(int MapId, byte VoteCntUpdate)
{
	local int Idx, LeadingVoteCount;
	local array<int> LeadingMapIndicies;

//	`log("### ClientRecMapUpdate"@MapID@VoteCntUpdate);

	Idx = GetMapIndex(MapID);
	if (Idx != INDEX_None)
	{
		Maps[Idx].NoVotes = VoteCntUpdate;
	}
	else
	{
		`log("Received a map update for a none existant MapID ("$MapID$")");
	}


	// Generate the list of leading maps
	if (!bVotingOver)
	{
		for (Idx=0; Idx<Maps.Length; ++Idx)
		{
			if (LeadingMapIndicies.Length == 0 || Maps[Idx].NoVotes > LeadingVoteCount)
			{
				LeadingMapIndicies.Length = 1;

				LeadingMapIndicies[0] = Idx;
				LeadingVoteCount = Maps[Idx].NoVotes;
			}
			else if (Maps[Idx].NoVotes == LeadingVoteCount)
			{
				LeadingMapIndicies.AddItem(Idx);
			}
		}


		LeadingMaps.Length = 0;

		for (Idx=0; Idx<LeadingMapIndicies.Length; ++Idx)
			LeadingMaps.AddItem(Maps[LeadingMapIndicies[Idx]].Map);
	}
}

simulated reliable client function ClientBeginVoting()
{
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	//`log("### Client beginning to vote"@GRI@GRI.CurrentMidGameMenu,, 'UTVotingDebug');

	if (GRI != none && DemoRecSpectator(Owner) == none)
	{
		if (GRI.CurrentMidGameMenu != none)
			GRI.CurrentMidGameMenu.BeginVoting(self);
	}
}

// Old (pre midgame-vote) clients wont receive this function call; I use this fact to ensure old clients only get 'ClientBeginVoting' at endgame
simulated reliable client function ClientBeginVotingNew()
{
	ClientBeginVoting();
}

reliable server function ServerRecordVoteFor(int MapIdToVoteFor)
{
	// Limit calls to a maximum of 4 every two seconds
	if (WorldInfo.RealTimeSeconds - RecordVoteTimestamp < 2.0)
	{
		if (RecordVoteCounter < 4)
			++RecordVoteCounter;
		else
			return;
	}
	else
	{
		RecordVoteCounter = 1;
		RecordVoteTimestamp = WorldInfo.RealTimeSeconds;
	}

	// Stop if the client is revoting the same map
	if (MapIdToVoteFor == MyCurrnetVoteID)
		return;

	//`log("### Client"@(Controller(Owner).PlayerReplicationInfo.GetPlayerAlias())@"wants to vote for"@MapIdToVoteFor,, 'UTVotingDebug');


	if (MyCurrnetVoteID > INDEX_None)
		Collector.RemoveVoteFor(MyCurrnetVoteID);

	MyCurrnetVoteID = Collector.AddVoteFor(MapIdToVoteFor);
}


/**
 * Replicate the votes to the client.  We send 1 vote at a time and wait for a response.
 */
state ReplicatingToClient
{
	function BeginState(name PrevStateName)
	{
//		`log("...Replicating Map ["$Collector.Votes[SendIndex].Map$"] to"$Owner);

		ClientRecvMapInfo(Collector.Votes[SendIndex]);
		LastSendIndex = SendIndex;
	}

	reliable server function ServerAckTransfer()
	{
		++SendIndex;

		// Replication is done asynchronously during tick
		Enable('Tick');


		if (SendIndex == Collector.Votes.Length)
		{
			GotoState('Voting');
		}

//		`log("### Client"$Owner$" has ackd Queing"@Collector.Votes[SendIndex].Map@SendIndex@Collector.Votes.Length);

	}

	function Tick(float DeltaTime)
	{
		if (SendIndex != LastSendIndex && SendIndex < Collector.Votes.Length)
		{
//			`log("### Sending "$Collector.Votes[SendIndex].Map$" from que");

			ClientRecvMapInfo(Collector.Votes[SendIndex]);
			LastSendIndex = SendIndex;
		}

		// Optimise by enabling/disabling tick as needed
		Disable('Tick');
	}
}


state Voting
{
	function BeginState(name PrevStateName)
	{
//		`log("### Server tells client to begin voting");

		// Old clients can receive 'ClientBeginVoting' calls, but not 'ClientBeginVotingNew'; only call on clients when a mapvote is in progress
		if (Collector.MapVoteInProgress())
			ClientBeginVoting();
		else
			ClientBeginVotingNew();
	}
}


defaultproperties
{
	bSkipActorPropertyReplication=false
 	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
    NetUpdateFrequency=1

    MyCurrnetVoteID=-1
}
