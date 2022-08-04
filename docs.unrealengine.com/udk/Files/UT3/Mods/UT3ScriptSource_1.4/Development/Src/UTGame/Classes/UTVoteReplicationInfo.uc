/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTVoteReplicationInfo extends ReplicationInfo
	dependson(UTVoteCollector)
	nativereplication
	native;

struct native LocalGameEntry
{
	var string GameName;		// Displayed game name
	var byte NumVotes;
};

struct native LocalMapEntry
{
	var string MapName;
	var byte NumVotes;
	var bool bSelectable;		// Whether or not this map entry can be voted for
};

struct native LocalMutEntry
{
	var string MutName;		// Displayed mutator name
	var string MutDescription;	// Localized (or replicated, if localization fails) description of the mutator
	var byte NumVotes;
	var bool bIsActive;		// Is the mutator currently active? Determines whether the mutator is displayed in the 'Add' or 'Remove' list
};


// Clientside variables

/** Local vote information */
var array<LocalGameEntry> GameVotes;	// Current game votes
var array<LocalMapEntry> MapVotes;	// Current map votes
var array<LocalMutEntry> MutatorVotes;	// Current mutator votes
var array<KickVoteInfo> KickVotes;	// Current kick votes

var bool bMapVotingReady;		// Set when all mapvote info has finished transferring
var bool bGameVotingReady;		// Set when all gamevote info has finished transferring
var bool bMutatorVotingReady;		// As above, but relating to mutator voting
var int MutatorVotePercentage;		// The percentage of votes required in order to enable/disable a mutator

var byte WinningGameIndex;		// The index into 'GameTypes' for the winning gametype
var byte WinningMapIndex;		// As above, except relating to 'MapVotes'

/** Cached list of mutator data providers, for retrieving localized mutator descriptions */
var array<UTUIResourceDataProvider> MutProviders;

/** Cached list of map data providers, for sanitizing map names */
var array<UTUIDataProvider_MapInfo> MapProviders;


// Clientside/Serverside variables

/** Variables for tracking vote info transfers (usually done when the client first joins) */
var byte ListIndex;			// Used to count the progress of the current transfer
var int TransferFailCount;		// The number of failed item transfers

/** Information about the clients active votes */
var byte CurGameVoteIndex;		// The index of the clients current game vote
var byte CurMapVoteIndex;		// Index of the clients current map vote
var array<byte> CurMutVoteIndicies;	// The indicies representing mutators the client has voted
var array<int> CurKickVoteIDs;		// The list of PlayerID's the client has contributed kickvotes for

/** Random client/server vote status information */
var bool bVotingAllowed;		// Whether or not the server is currently accepting votes
var bool bSupportsNewVoting;		// Whether or not the client is compatible with the new vote and replication systems

var bool bMapVotingEnabled;
var bool bGameVotingEnabled;
var bool bMutatorVotingEnabled;
var bool bKickVotingEnabled;

var bool bMapVotePending;		// If true, then map voting will be enabled once game voting is over


// Serverside variables

/** Serverside transfer progress/state tracking variables */
var byte ElementIndex;			// The index of the current element which is being transferred

var bool bTransferTimerActive;		// Whether or not the main transfer timer (which controls the rate of transfer) is active
var bool bTransfersEnabled;		// Whether or not transferring has begun
var array<name> PendingTransferStates;	// Holds the names of special transfer-control states, which are waiting to become active
var array<name> CompletedTransfers;	// The names of transfer states which have completed transferring
var int TotalTransferCount;		// The estimated number of times that replicated functions which will be called (for transfer timing)
var name LastConfirmedState;		// The last state which the client has reported a successful transition to

var array<byte> PendingResends;		// A list of transfer items which the client wants the server to resend

var bool bOldClient;


/** Vote function replication limitation */
var float RecordVoteTimestamp;
var int RecordVoteCounter, KickVoteCounter;
var array<int> KickVoteHistory;


// Old vote system variables (some also relevant to new system, and some reused when playing on old servers)

/** Our local view of the map data */
var array<MapVoteInfo> Maps;

/** How many maps are we expecting */

var int MapCount;
var int SendIndex;
var int LastSendIndex;

/** Used to detect the setting of the owner without RepNotifing Owner */
var actor OldOwner;

var int dummy;

var deprecated int MyCurrnetVoteID;

var string LeadingMap;
var array<string> LeadingMaps;


var byte PendingBeginVoting;
var bool bVotingOver;


/** Cached reference to the vote collector */
var UTVoteCollector Collector;


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
	// Create the reference to myself in the PC
	if (ROLE < ROLE_Authority)
		UTPlayerController(Owner).VoteRI = self;

	// New vote code (includes engine version in case there are more breaking changes in the future)
	ServerClientIsReadyNew(WorldInfo.EngineVersion);

	// The old function must also be called for new clients to work on old servers;
	// delay it for a second though, to be doubly sure that the above call gets to the server first
	SetTimer(1.0 * WorldInfo.TimeDilation,, 'ServerClientIsReady');
}

function Initialize(UTVoteCollector NewCollector)
{
	Collector = NewCollector;

	if (Role == ROLE_Authority && bLocallyOwned())
		ClientHasOwner();
}

simulated reliable client function ClientTimesUp()
{
	local UTGameReplicationInfo GRI;

	bVotingOver = True;

	if (!bSupportsNewVoting)
		LeadingMaps.Length = 0;


	// Force a final update for the vote timer
	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (GRI != none && GRI.CurrentMidGameMenu != none)
		GRI.CurrentMidGameMenu.UpdateVote(GRI);
}

reliable server function ServerClientIsReady()
{
	if (bSupportsNewvoting || bOldClient || GetStateName() != Class.Name)
		return;

	bOldClient = True;
	UpdateVoteStatus();
}


simulated reliable client function ClientInitTransfer(int TotalMapCount)
{
	MapCount = TotalMapCount;
	ServerAckTransfer();
}


reliable server function ServerAckTransfer()
{
	if (bMapVotingEnabled && !bSupportsNewVoting && GetStateName() == Class.Name)
		GotoState('ReplicatingToClient');
}

/** We have received a map from the server.  Add it */
simulated reliable client function ClientRecvMapInfo(MapVoteInfo VInfo)
{
	local int Idx;

	Idx = GetMapIndex(VInfo.MapID);

	// Add one
	if (Idx == INDEX_None)
	{
		Idx = Maps.Length;
		Maps.Length = Maps.Length+1;
	}


	// Set the data
	Maps[Idx].MapID = VInfo.MapID;
	Maps[Idx].Map = VInfo.Map;
	Maps[Idx].NoVotes= VInfo.NoVotes;

	ServerAckTransfer();

	if (Idx == MapCount)
		bMapVotingReady = True;
}

simulated reliable client function ClientRecvMapUpdate(int MapId, byte VoteCntUpdate)
{
	local int Idx, LeadingVoteCount;
	local array<int> LeadingMapIndicies;

	Idx = GetMapIndex(MapID);

	if (Idx != INDEX_None)
		Maps[Idx].NoVotes = VoteCntUpdate;
	else
		`log("Received a map update for a none existant MapID ("$MapID$")",, 'UTVoting');


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

	if (GRI != none && DemoRecSpectator(Owner) == none && GRI.CurrentMidGameMenu != none)
		GRI.CurrentMidGameMenu.BeginVoting(self);
}

// Old (pre midgame-vote) clients wont receive this function call; I use this fact to ensure old clients only get 'ClientBeginVoting' at endgame
simulated reliable client function ClientBeginVotingNew()
{
	ClientBeginVoting();
}

reliable server function ServerRecordVoteFor(int MapIdToVoteFor)
{
	ServerRecordMapVote(MapIdToVoteFor);
}


/**
 * Replicate the votes to the client.  We send 1 vote at a time and wait for a response.
 */
state ReplicatingToClient
{
	function BeginState(name PrevStateName)
	{
		if (SendIndex >= 0 && SendIndex < Collector.MapVotes.Length)
		{
			ClientRecvMapInfo(Collector.MapVotes[SendIndex]);
			LastSendIndex = SendIndex;
		}
	}

	reliable server function ServerAckTransfer()
	{
		++SendIndex;

		// Replication is done asynchronously during tick
		Enable('Tick');

		// New vote handling for old clients
		if (SendIndex >= Collector.MapVotes.Length)
			GotoState('Voting');
	}

	function Tick(float DeltaTime)
	{
		if (SendIndex != LastSendIndex && SendIndex >= 0 && SendIndex < Collector.MapVotes.Length)
		{
			ClientRecvMapInfo(Collector.MapVotes[SendIndex]);
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
		// Old clients can receive 'ClientBeginVoting' calls, but not 'ClientBeginVotingNew'; only call on clients when a mapvote is in progress
		if (bMapVotingEnabled && Collector.CountdownInProgress())
			ClientBeginVoting();
		else
			ClientBeginVotingNew();
	}
}



// ***** New replication system


function NotifyVoteRoundUpdate()
{
	UpdateVoteStatus();
}

function UpdateVoteStatus()
{
	bMapVotingEnabled = Collector.bMapVotingActive;
	bGameVotingEnabled = Collector.bGameVotingActive;
	bMutatorVotingEnabled = Collector.bMutatorVotingActive;
	bKickVotingEnabled = Collector.bKickVotingActive;
	bMapVotePending = bGameVotingEnabled && Collector.bAllowMapVoting;

	if (bSupportsNewVoting)
	{
		if (bGameVotingEnabled)
			AddTransferState('GameVoteInfoTransfer', Collector.GameVotes.Length);

		if (bMapVotingEnabled)
			AddTransferState('MapVoteInfoTransfer', Collector.MapVotes.Length);

		if (bMutatorVotingEnabled)
			AddTransferState('MutatorInfoTransfer', Collector.MutatorVotes.Length);



		// If voting has already been enabled, then start transferring
		if (bVotingAllowed)
			EnableTransfers();


		ClientUpdateVoteStatus(bVotingAllowed, bMapVotingEnabled, bGameVotingEnabled, bMutatorVotingEnabled, bKickVotingEnabled, bMapVotePending);
	}
	else if (bOldClient && bMapVotingEnabled)
	{
		ClientInitTransfer(Collector.MapVotes.Length);
	}
}

reliable client function ClientUpdateVoteStatus(bool bVotingEnabled, bool bMapVoting, bool bGameVoting, bool bMutatorVoting, bool bKickVoting,
							optional bool bPendingMapVote)
{
	local UTGameReplicationInfo GRI;

	if (WorldInfo.NetMode == NM_DedicatedServer)
		return;


	bSupportsNewVoting = True;
	bVotingAllowed = bVotingEnabled;

	bMapVotingEnabled = bMapVoting;
	bGameVotingEnabled = bGameVoting;
	bMutatorVotingEnabled = bMutatorVoting;
	bKickVotingEnabled = bKickVoting;

	bMapVotePending = bPendingMapVote;


	if (bVotingEnabled)
	{
		// Update the menus again, as the above values must be set in order for the menu to display properly
		GRI = UTGameReplicationInfo(WorldInfo.GRI);

		if (GRI != none && DemoRecSpectator(Owner) == none && GRI.CurrentMidGameMenu != none)
			GRI.CurrentMidGameMenu.BeginVoting(self);
	}
}

reliable client function ClientOpenVoteMenu()
{
	UTPlayerController(Owner).ShowMidGameMenu('VoteTab', True);
}


// Delayed enabling of actual voting (replication starts early; votes later)
function NotifyAllowVoting()
{
	bVotingAllowed = True;

	UpdateVoteStatus();

	// Notify the client if map voting has been enabled at endgame or after a delay
	//if (bMapVotingEnabled && (Collector.InitialVoteDelay > 0 || !Collector.bMidGameMapVoting))
	//	PlayerController(Owner).ReceiveLocalizedMessage(WorldInfo.Game.GameMessageClass, 17);
}


// ***** Voting send/receive functions

reliable server function ServerRecordGameVote(byte GameIndex)
{
	if (!bVotingAllowed || VoteRepeatCounter() || GameIndex >= Collector.GameVotes.Length)
		return;

	// Only update the vote if it has actually changed
	if ( GameIndex != CurGameVoteIndex )
	{
		if (CurGameVoteIndex != 255)
			Collector.RemoveGameVote(Self);

		Collector.AddGameVote(Self, GameIndex);
	}
}

simulated reliable client function ClientGameVoteConfirmed(byte GameIndex)
{
	local UTGameReplicationInfo GRI;

	CurGameVoteIndex = GameIndex;

	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (GRI != none && GRI.CurrentMidGameMenu != none)
		GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self, True);
}

reliable server function ServerRecordMapVote(byte MapIndex)
{
	if (!bVotingAllowed || VoteRepeatCounter() || MapIndex >= Collector.MapVotes.Length)
		return;

	// Only update the vote if it has actually changed
	if ( MapIndex != CurMapVoteIndex )
	{
		if (CurMapVoteIndex != 255)
			Collector.RemoveMapVote(Self);

		Collector.AddMapVote(Self, MapIndex);
	}
}

simulated reliable client function ClientMapVoteConfirmed(byte MapIndex)
{
	local UTGameReplicationInfo GRI;

	CurMapVoteIndex = MapIndex;

	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (GRI != none && GRI.CurrentMidGameMenu != none)
		GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,, True);
}

reliable server function ServerRecordMutVote(byte MutIndex, bool bAddVote)
{
	if (!bVotingAllowed || VoteRepeatCounter() || MutIndex >= Collector.MutatorVotes.Length)
		return;

	if (bAddVote && CurMutVoteIndicies.Find(MutIndex) == INDEX_None)
		Collector.AddMutatorVote(Self, MutIndex);
	else if (!bAddVote && CurMutVoteIndicies.Find(MutIndex) != INDEX_None)
		Collector.RemoveMutatorVote(Self, MutIndex);
}

simulated reliable client function ClientMutVoteConfirmed(byte MutIndex, bool bAddVote)
{
	local UTGameReplicationInfo GRI;

	if (bAddVote)
		CurMutVoteIndicies.AddItem(MutIndex);
	else
		CurMutVoteIndicies.RemoveItem(MutIndex);

	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (GRI != none && GRI.CurrentMidGameMenu != none)
		GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,,, True);
}

reliable server function ServerRecordKickVote(int PlayerID, bool bAddVote)
{
	local PlayerReplicationInfo PRI;
	local bool bValid;

	// If voting is not allowed, or if you already added (or removed) the vote from the list, return
	if (!bVotingAllowed || VoteRepeatCounter() || (bAddVote ^^ CurKickVoteIDs.Find(PlayerID) == INDEX_None))
		return;


	// Check that the vote is valid
	foreach WorldInfo.GRI.PRIArray(PRI)
	{
		if (PRI.PlayerID == PlayerID)
		{
			if (PRI != UTPlayerController(Owner).PlayerReplicationInfo)
				bValid = True;

			break;
		}
	}

	// Invalid vote, count it as vote spam and return
	if (!bValid)
	{
		if (KickVoteSpamCounter(INDEX_None))
			Collector.HandleKickVoteSpam(Self);

		return;
	}


	if (bAddVote)
	{
		if (KickVoteSpamCounter(PlayerID))
			Collector.HandleKickVoteSpam(Self);
		else
			Collector.AddKickVote(Self, PlayerID);
	}
	else
	{
		Collector.RemoveKickVote(Self, PlayerID);
	}
}

simulated reliable client function ClientKickVoteConfirmed(int PlayerID, bool bAddVote)
{
	local UTGameReplicationInfo GRI;

	if (bAddVote)
		CurKickVoteIDs.AddItem(PlayerID);
	else
		CurKickVoteIDs.RemoveItem(PlayerID);

	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (GRI != none && GRI.CurrentMidGameMenu != none)
		GRI.CurrentMidGameMenu.ScoreTabKickVoteNotify();
}

// Limit vote calls to a maximum of 4 every two seconds
final function bool VoteRepeatCounter()
{
	if (WorldInfo.RealTimeSeconds - RecordVoteTimestamp < 2.0)
	{
		if (RecordVoteCounter < 4)
			++RecordVoteCounter;
		else
			return True;
	}
	else
	{
		RecordVoteCounter = 1;
		RecordVoteTimestamp = WorldInfo.RealTimeSeconds;
	}

	return False;
}

final function bool KickVoteSpamCounter(int KickID)
{
	if (KickVoteCounter < 16)
	{
		// Only repeat votes are counted
		if (KickID == INDEX_None || KickVoteHistory.Find(KickID) != INDEX_None)
			++KickVoteCounter;
		else
			KickVoteHistory.AddItem(KickID);
	}
	else
	{
		return True;
	}

	return False;
}

function NotifyGameVoteUpdate(byte GameIdx, byte NumVotes, optional bool bBroadcastVote, optional PlayerReplicationInfo VotePRI)
{
	if (bSupportsNewVoting)
		ClientReceiveGameVoteUpdate(GameIdx, NumVotes, bBroadcastVote, VotePRI);
}

function NotifyMapVoteUpdate(byte MapIdx, byte NumVotes, optional bool bBroadcastVote, optional PlayerReplicationInfo VotePRI)
{
	if (bSupportsNewVoting)
		ClientReceiveMapVoteUpdate(MapIdx, NumVotes, bBroadcastVote, VotePRI);
	else
		ClientRecvMapUpdate(MapIdx, NumVotes);
}

function NotifyMutVoteUpdate(byte MutIdx, byte NumVotes)
{
	if (bSupportsNewVoting)
		ClientReceiveMutVoteUpdate(MutIdx, NumVotes);
}

function NotifyKickVoteUpdate(KickVoteInfo KickVote)
{
	if (bSupportsNewVoting)
		ClientReceiveKickVoteUpdate(KickVote);
}


simulated reliable client function ClientReceiveGameVoteUpdate(byte GameIdx, byte NumVotes, optional bool bBroadcastVote, optional PlayerReplicationInfo VotePRI)
{
	local UTGameReplicationInfo GRI;
	local UTPlayerController PCOwner;
	local string VoteMsg;

	if (GameIdx < GameVotes.Length)
		GameVotes[GameIdx].NumVotes = NumVotes;

	// If all the game vote info has been transferred, then update the vote menu
	if (bGameVotingReady)
	{
		GRI = UTGameReplicationInfo(WorldInfo.GRI);

		if (GRI != none && GRI.CurrentMidGameMenu != none)
			GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self, True);
	}

	if (bBroadcastVote)
	{
		PCOwner = UTPlayerController(Owner);

		if (PCOwner != none)
		{
			VoteMsg = Repl(Class'GameMessage'.default.MapVoteSubmitted, "`p", VotePRI.GetPlayerAlias());
			VoteMsg = Repl(VoteMsg, "`m", GameVotes[GameIdx].GameName);

			PCOwner.TeamMessage(none, VoteMsg, 'Event');
		}
	}
}

simulated reliable client function ClientReceiveMapVoteUpdate(byte MapIdx, byte NumVotes, optional bool bBroadcastVote, optional PlayerReplicationInfo VotePRI)
{
	local UTGameReplicationInfo GRI;
	local UTPlayerController PCOwner;
	local string VoteMsg;

	if (MapIdx > MapVotes.Length)
		return;


	MapVotes[MapIdx].NumVotes = NumVotes;

	// Force the clients vote menu to update, but only if the maplists etc. have been transferred
	if (bMapVotingReady)
	{
		GRI = UTGameReplicationInfo(WorldInfo.GRI);

		if (GRI != none && GRI.CurrentMidGameMenu != none)
			GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,, True);
	}


	if (bBroadcastVote)
	{
		PCOwner = UTPlayerController(Owner);

		if (PCOwner != none)
		{
			VoteMsg = Repl(Class'GameMessage'.default.MapVoteSubmitted, "`p", VotePRI.GetPlayerAlias());
			VoteMsg = Repl(VoteMsg, "`m", MapVotes[MapIdx].MapName);

			PCOwner.TeamMessage(none, VoteMsg, 'Event');
		}
	}
}


simulated reliable client function ClientReceiveMutVoteUpdate(byte MutIdx, byte NumVotes)
{
	local UTGameReplicationInfo GRI;

	if (MutIdx < MutatorVotes.Length)
		MutatorVotes[MutIdx].NumVotes = NumVotes;

	// Force the clients vote menu to update, but only if all the mutators etc. have been transferred
	if (bMutatorVotingReady)
	{
		GRI = UTGameReplicationInfo(WorldInfo.GRI);

		if (GRI != none && GRI.CurrentMidGameMenu != none)
			GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,,, True);
	}
}

simulated reliable client function ClientReceiveKickVoteUpdate(KickVoteInfo KickVote)
{
	local int i;

	i = KickVotes.Find('PlayerID', KickVote.PlayerID);

	if (KickVote.NumVotes > 0)
	{
		if (i == INDEX_None)
			KickVotes.AddItem(KickVote);
		else
			KickVotes[i].NumVotes = KickVote.NumVotes;

	}
	else if (i != INDEX_None)
	{
		KickVotes.Remove(i, 1);
	}
}

simulated reliable client function ClientSetWinningGameIndex(byte Index)
{
	local UTGameReplicationInfo GRI;

	WinningGameIndex = Index;
	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (GRI != none && GRI.CurrentMidGameMenu != none)
		GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self, True);
}

simulated reliable client function ClientSetWinningMapIndex(byte Index)
{
	local UTGameReplicationInfo GRI;

	WinningMapIndex = Index;
	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (GRI != none && GRI.CurrentMidGameMenu != none)
		GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,, True);
}



// ***** Transfer state handling (manages queuing and timing of the initial mapvote/mutvote/etc. data transfers)

function EnableTransfers()
{
	if (bTransfersEnabled)
		return;


	bTransfersEnabled = True;
	StartNextTransfer();

	if (!bLocallyOwned())
		SetDesiredTransferTime(Collector.InitialVoteTransferTime, TotalTransferCount, Collector.CountdownInProgress());
}

// Queues a transfer state for execution (or executes it immediately if there are none currently running)
function AddTransferState(name StateName, optional int TransferCount, optional bool bForceTransfer)
{
	if (!IsChildState(StateName, 'TransferBase') || (!bForceTransfer && CompletedTransfers.Find(StateName) != INDEX_None))
		return;


	if (PendingTransferStates.Find(StateName) == INDEX_None || bForceTransfer)
	{
		PendingTransferStates.AddItem(StateName);
		TotalTransferCount += TransferCount;
	}

	if (bTransfersEnabled)
	{
		if (GetStateName() == Class.Name)
			StartNextTransfer();

		// Update the transfer timer (n.b. this only changes the rate of the timer, it doesn't start over)
		if (!bLocallyOwned())
			SetDesiredTransferTime(Collector.InitialVoteTransferTime, TotalTransferCount, Collector.CountdownInProgress());
	}
}

// Moves on to the next queued transfer state
function StartNextTransfer()
{
	local name NextState;
	local int i;

	if (PendingTransferStates.Length > 0)
	{
		if (!bLocallyOwned())
		{
			NextState = PendingTransferStates[0];
			PendingTransferStates.Remove(0, 1);

			GotoState(NextState);
			ClientGotoState(NextState, True);
		}
		else
		{
			for (i=0; i<PendingTransferStates.Length; ++i)
			{
				GotoState(PendingTransferStates[i]);
				ListenInstantTransfer();
			}

			PendingTransferStates.Length = 0;
			GotoState('');
		}
	}
	else
	{
		GotoState('');

		if (!bLocallyOwned())
			ClientGotoState(NextState);
	}
}


// Adjusts the timer used for sending off data, to send the remaining data very quickly (usually happens when the client opens the vote menu)
reliable server function ServerRushTransfers();

reliable client function ClientGotoState(name StateName, optional bool bConfirmStateChange)
{
	GotoState(StateName);

	if (bConfirmStateChange)
		ServerStateChangeConfirmed();
}

// Used to delay transfers until the client can confirm a state change
reliable server function ServerStateChangeConfirmed()
{
	local name CurState;

	CurState = GetStateName();

	if (LastConfirmedState != CurState)
	{
		LastConfirmedState = CurState;
		StateChangeConfirmed();
	}
}

function StateChangeConfirmed();
function ListenInstantTransfer();

// Optimised replication, allowing the class to spread out transfers over 'x' seconds
function SetDesiredTransferTime(optional int Seconds, optional int NumTransfers, optional bool bEnableTick);


// Gets the client to check the current transfer list for missing elements, and calls 'ServerResendInfo' for each missing element
simulated reliable client function ClientCheckTransferStatus();
reliable server function ServerResendInfo(byte Index);

reliable server function ServerTransferComplete();


// Base state for handling optimised transfer replication
state TransferBase
{
	simulated function BeginState(name PreviousStateName)
	{
		ListIndex = 0;
		TransferFailCount = 0;
		PendingResends.Length = 0;
		ElementIndex = 0;
	}

	// Optimised replication, allowing the class to spread out transfers over 'x' seconds
	function SetDesiredTransferTime(optional int Seconds, optional int NumTransfers, optional bool bEnableTick)
	{
		local float TransferRate;

		if (bEnableTick)
		{
			ClearTimer('TransferTimer');
			Enable('Tick');
		}
		else if (Seconds != 0 && NumTransfers != 0)
		{
			TransferRate = float(Seconds) / float(NumTransfers);

			if (TransferRate < 0.05)
			{
				ClearTimer('TransferTimer');
				Enable('Tick');
			}
			else
			{
				Disable('Tick');
				SetTimer(TransferRate * WorldInfo.TimeDilation, True, 'TransferTimer');
			}
		}
		else
		{
			ClearTimer('TransferTimer');
			Enable('Tick');
		}

		bTransferTimerActive = True;
	}

	function DisableTransferTimer()
	{
		Disable('Tick');
		ClearTimer('TransferTimer');
		bTransferTimerActive = False;
	}

	function Tick(float DeltaTime)
	{
		if (IsTimerActive('TransferTimer') || !bTransferTimerActive)
		{
			Disable('Tick');
			return;
		}


		TransferTimer();
	}

	function TransferTimer();


	reliable server function ServerRushTransfers()
	{
		SetDesiredTransferTime(Collector.RushVoteTransferTime, TotalTransferCount, Collector.CountdownInProgress());
	}


	// This shouldn't ever happen really, but there needs to be some attempted cleanup in case it does
	reliable server function ServerResendInfo(byte Index)
	{
		if (TransferFailCount > 10)
			return;

		if (PendingResends.Find(Index) == INDEX_None)
			PendingResends.AddItem(Index);

		++TransferFailCount;
	}


	function EndState(name NextStateName)
	{
		CompletedTransfers.AddItem(GetStateName());

		if (!IsChildState(NextStateName, 'TransferBase'))
			DisableTransferTimer();
	}
}


// ***** Replicated function stubs (implemented within appropriate transfer states)

simulated reliable client function ClientBeginGameVoteTransfer(byte InGameCount);
simulated reliable client function ClientReceiveGameVoteInfo(byte Index, string GameName, byte NumVotes);

simulated reliable client function ClientBeginMapVoteTransfer(byte InMapCount);
simulated reliable client function ClientReceiveMapVoteInfo(byte Index, string MapName, byte NumVotes, bool bSelectable);


simulated reliable client function ClientBeginMutVoteTransfer(byte InMutCount, byte InMutVotePercentage);
simulated reliable client function ClientReceiveMutVoteInfo(byte Index, string MutClass, string MutName, byte NumVotes, bool bIsActive);

// If the client can't localize a mutator description, this is called to retreive it from the server
reliable server function ServerRequestMutDescription(byte Index);
simulated reliable client function ClientReceiveMutDescription(byte Index, string MutDescription);



// ***** Data transfer states

state GameVoteInfoTransfer extends TransferBase
{
	// Called (indirectly) by the client, once the client has changed state
	function StateChangeConfirmed()
	{
		ClientBeginGameVoteTransfer(Collector.GameVotes.Length);
	}

	function TransferTimer()
	{
		local string GameName;
		local byte NumVotes;
		local int i;

		if (LastConfirmedState != GetStateName())
			return;


		if (ListIndex < Collector.GameVotes.Length)
		{
			if (Collector.GetGameVoteInfo(ListIndex, GameName, NumVotes))
				ClientReceiveGameVoteInfo(ListIndex, GameName, NumVotes);

			++ListIndex;

			if (ListIndex == Collector.GameVotes.Length)
				ClientCheckTransferStatus();
		}
		else if (PendingResends.Length > 0)
		{
			i = PendingResends.Length-1;

			if (Collector.GetGameVoteInfo(PendingResends[i], GameName, NumVotes))
				ClientReceiveGameVoteInfo(PendingResends[i], GameName, NumVotes);

			PendingResends.Length = i;

			if (PendingResends.Length == 0)
				ClientCheckTransferStatus();
		}
	}


	simulated reliable client function ClientBeginGameVoteTransfer(byte InGameCount)
	{
		GameVotes.Length = InGameCount;
	}

	simulated reliable client function ClientReceiveGameVoteInfo(byte Index, string GameName, byte NumVotes)
	{
		// 'GameName == ""' is used to check for failed transfers, so prevent blank GameName values from triggering resends
		if (GameName == "")
			GameName = " ";

		GameVotes[Index].GameName = GameName;
		GameVotes[Index].NumVotes = NumVotes;
	}


	// Replication verification/confirmation functions

	simulated reliable client function ClientCheckTransferStatus()
	{
		local int i;
		local UTGameReplicationInfo GRI;

		TransferFailCount = 0;

		for (i=0; i<GameVotes.Length; ++i)
		{
			if (GameVotes[i].GameName == "")
			{
				if (TransferFailCount > 10)
					break;

				ServerResendInfo(i);
				++TransferFailCount;
			}
		}

		if (TransferFailCount == 0)
		{
			bGameVotingReady = True;
			ServerTransferComplete();

			// Force the clients vote menu to update
			GRI = UTGameReplicationInfo(WorldInfo.GRI);

			if (GRI != none && GRI.CurrentMidGameMenu != none)
				GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self, True);
		}
	}

	reliable server function ServerTransferComplete()
	{
		if (ListIndex >= Collector.GameVotes.Length)
			StartNextTransfer();
	}


	// Handles instant-transfers for listen servers
	function ListenInstantTransfer()
	{
		local int i;
		local string GameName;
		local byte NumVotes;
		local UTGameReplicationInfo GRI;

		GameVotes.Length = Collector.GameVotes.Length;

		for (i=0; i<GameVotes.Length; ++i)
		{
			if (Collector.GetGameVoteInfo(i, GameName, NumVotes))
			{
				GameVotes[i].GameName = GameName;
				GameVotes[i].NumVotes = NumVotes;
			}
		}

		bGameVotingReady = True;


		// Force the clients vote menu to update
		GRI = UTGameReplicationInfo(WorldInfo.GRI);

		if (GRI != none && GRI.CurrentMidGameMenu != none)
			GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self, True);
	}
}


state MapVoteInfoTransfer extends TransferBase
{
	function StateChangeConfirmed()
	{
		ClientBeginMapVoteTransfer(Collector.MapVotes.Length);
	}

	function TransferTimer()
	{
		local int i;
		local UTMapListManager MLManager;

		if (LastConfirmedState != GetStateName())
			return;

		MLManager = Collector.MapListManager;

		if (ListIndex < Collector.MapVotes.Length)
		{
			ClientReceiveMapVoteInfo(ListIndex, Collector.MapVotes[ListIndex].Map, Collector.MapVotes[ListIndex].NoVotes,
				(ListIndex == Collector.ForceEnableMapIdx || MLManager.bMapEnabled(Collector.MapVoteMapList, ListIndex)));

			++ListIndex;

			if (ListIndex == Collector.MapVotes.Length)
				ClientCheckTransferStatus();
		}
		else if (PendingResends.Length > 0)
		{
			i = PendingResends.Length-1;

			ClientReceiveMapVoteInfo(PendingResends[i], Collector.MapVotes[PendingResends[i]].Map,
							Collector.MapVotes[PendingResends[i]].NoVotes,
							(ListIndex == Collector.ForceEnableMapIdx ||
								MLManager.bMapEnabled(Collector.MapVoteMapList, PendingResends[i])));

			PendingResends.Length = i;

			if (PendingResends.Length == 0)
				ClientCheckTransferStatus();
		}
	}

	simulated reliable client function ClientBeginMapVoteTransfer(byte InMapCount)
	{
		MapVotes.Length = InMapCount;
	}

	simulated reliable client function ClientReceiveMapVoteInfo(byte Index, string MapName, byte NumVotes, bool bSelectable)
	{
		SanitizeMapName(MapName);

		MapVotes[Index].MapName = MapName;
		MapVotes[Index].NumVotes = NumVotes;
		MapVotes[Index].bSelectable = bSelectable;
	}


	// Replication verification/confirmation functions

	simulated reliable client function ClientCheckTransferStatus()
	{
		local int i;
		local UTGameReplicationInfo GRI;

		TransferFailCount = 0;

		for (i=0; i<MapVotes.Length; ++i)
		{
			if (MapVotes[i].MapName == "")
			{
				if (TransferFailCount > 10)
					break;

				ServerResendInfo(i);
				++TransferFailCount;
			}
		}

		if (TransferFailCount == 0)
		{
			bMapVotingReady = True;
			ServerTransferComplete();

			// Force the clients vote menu to update
			GRI = UTGameReplicationInfo(WorldInfo.GRI);

			if (GRI != none && GRI.CurrentMidGameMenu != none)
				GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,, True);
		}
	}

	reliable server function ServerTransferComplete()
	{
		if (ListIndex >= Collector.MapVotes.Length)
			StartNextTRansfer();
	}

	function ListenInstantTransfer()
	{
		local int i;
		local UTGameReplicationInfo GRI;
		local string CurMapStr;

		MapVotes.Length = Collector.MapVotes.Length;

		for (i=0; i<Collector.MapVotes.Length; ++i)
		{
			CurMapStr = Collector.MapVotes[i].Map;
			SanitizeMapName(CurMapStr);

			MapVotes[i].MapName = CurMapStr;
			Mapvotes[i].Numvotes = Collector.MapVotes[i].NoVotes;
			MapVotes[i].bSelectable = (i == Collector.ForceEnableMapIdx || Collector.MapListManager.bMapEnabled(Collector.MapVoteMapList, i));
		}

		bMapVotingReady = True;


		// Force the clients vote menu to update
		GRI = UTGameReplicationInfo(WorldInfo.GRI);

		if (GRI != none && GRI.CurrentMidGameMenu != none)
			GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,, True);
	}
}


state MutatorInfoTransfer extends TransferBase
{
	function StateChangeConfirmed()
	{
		ClientBeginMutVoteTransfer(Collector.MutatorVotes.Length, Collector.MutatorVotePercentage);
	}

	function TransferTimer()
	{
		local int i;
		local string MutClass, MutName;
		local byte NumVotes;
		local byte bIsActive;

		if (LastConfirmedState != GetStateName())
			return;

		if (ListIndex < Collector.MutatorVotes.Length)
		{
			if (Collector.GetMutVoteInfo(ListIndex, MutClass, MutName, NumVotes, bIsActive))
				ClientReceiveMutVoteInfo(ListIndex, MutClass, MutName, NumVotes, bool(bIsActive));

			++ListIndex;

			if (ListIndex == Collector.MutatorVotes.Length)
				ClientCheckTransferStatus();
		}
		else if (PendingResends.Length > 0)
		{
			i = PendingResends.Length-1;

			if (Collector.GetMutVoteInfo(PendingResends[i], MutClass, MutName, NumVotes, bIsActive))
				ClientReceiveMutVoteInfo(PendingResends[i], MutClass, MutName, NumVotes, bool(bIsActive));

			PendingResends.Length = i;

			if (PendingResends.Length == 0)
				ClientCheckTransferStatus();
		}
	}


	simulated reliable client function ClientBeginMutVoteTransfer(byte InMutCount, byte InMutVotePercentage)
	{
		MutatorVotes.Length = InMutCount;
		MutatorVotePercentage = InMutVotePercentage;
	}

	simulated reliable client function ClientReceiveMutVoteInfo(byte Index, string MutClass, string MutName, byte NumVotes, bool bIsActive)
	{
		local int i;

		MutatorVotes[Index].MutName = MutName;
		MutatorVotes[Index].NumVotes = NumVotes;
		MutatorVotes[Index].bIsActive = bIsActive;


		// Fill the 'MutProviders' list if it has not yet been filled
		if (MutProviders.Length == 0)
			Class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(Class'UTUIDataProvider_Mutator', MutProviders);


		// Attempt to localize 'MutDescription'
		for (i=0; i<MutProviders.Length; ++i)
		{
			if (UTUIDataProvider_Mutator(MutProviders[i]).ClassName ~= MutClass)
			{
				MutatorVotes[Index].MutDescription = UTUIDataProvider_Mutator(MutProviders[i]).Description;
				break;
			}
		}


		// Request the description from the server if that fails (but not for mutators within UTGame)
		if (MutatorVotes[Index].MutDescription == "" && !(Left(MutClass, InStr(MutClass, ".")) ~= "UTGame"))
			ServerRequestMutDescription(Index);
	}

	// Not currently used (UIToolTip's, which would have displyed this info, are very unstable), but kept in case it can be used later
	reliable server function ServerRequestMutDescription(byte Index)
	{
		local string MutClass;
		local UTUIDataProvider_Mutator DP;

		// Limit the number of requests (ElementIndex isn't needed in this state, so recycle it to count requests)
		if (Index >= Collector.MutatorVotes.Length || ElementIndex >= Collector.MutatorVotes.Length)
			return;

		++ElementIndex;


		MutClass = Collector.VotableMutators[Collector.MutatorVotes[Index].MutIdx].MutClass;

		// The client should only ever request details from custom mutators, not stock mutators
		if (Left(MutClass, InStr(MutClass, ".")) ~= "UTGame")
			return;


		if (Collector.MutatorVotes[Index].ProviderIdx != INDEX_None)
			DP = UTUIDataProvider_Mutator(Collector.MutProviders[Collector.MutatorVotes[Index].ProviderIdx]);

		if (DP != none && DP.Description != "")
			ClientReceiveMutDescription(Index, DP.Description);
	}

	simulated reliable client function ClientReceiveMutDescription(byte Index, string MutDescription)
	{
		if (Index < MutatorVotes.Length)
			MutatorVotes[Index].MutDescription = MutDescription;
	}


	// Replication verification/confirmation functions

	simulated reliable client function ClientCheckTransferStatus()
	{
		local int i;
		local UTGameReplicationInfo GRI;

		TransferFailCount = 0;

		for (i=0; i<MutatorVotes.Length; ++i)
		{
			if (MutatorVotes[i].MutName == "")
			{
				if (TransferFailCount > 10)
					break;

				ServerResendInfo(i);
				++TransferFailCount;
			}
		}

		if (TransferFailCount == 0)
		{
			bMutatorVotingReady = True;

			// Force the clients vote menu to update
			GRI = UTGameReplicationInfo(WorldInfo.GRI);

			if (GRI != none && GRI.CurrentMidGameMenu != none)
				GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,,, True);


			// If there are entries with a missing description, delay 'ServerTransferComplete' to let any description requests finish
			if (MutatorVotes.Find('MutDescription', "") == INDEX_None)
				ServerTransferComplete();
			else
				SetTimer(1.0 * WorldInfo.TimeDilation,, 'ServerTransferComplete');
		}
	}

	reliable server function ServerTransferComplete()
	{
		if (ListIndex >= Collector.MutatorVotes.Length)
			StartNextTransfer();
	}


	// Handles instant transferral (i.e. copying) of mutator data when running as a listen server; ignores all regular transfer code
	function ListenInstantTransfer()
	{
		local int i, j;
		local string MutClass, MutName;
		local UTGameReplicationInfo GRI;
		local byte NumVotes, bIsActive;

		MutatorVotes.Length = Collector.MutatorVotes.Length;
		MutatorVotePercentage = Collector.MutatorVotePercentage;

		for (i=0; i<MutatorVotes.Length; ++i)
		{
			if (!Collector.GetMutVoteInfo(i, MutClass, MutName, NumVotes, bIsActive))
				continue;

			MutatorVotes[i].MutName = MutName;
			MutatorVotes[i].NumVotes = NumVotes;
			MutatorVotes[i].bIsActive = bool(bIsActive);

			// Attempt to localize the mutator description using the collectors mutator provider list
			for (j=0; j<Collector.MutProviders.Length; ++j)
			{
				if (UTUIDataProvider_Mutator(Collector.MutProviders[i]).ClassName ~= MutClass)
				{
					MutatorVotes[i].MutDescription = UTUIDataProvider_Mutator(Collector.MutProviders[i]).Description;
					break;
				}
			}
		}


		bMutatorVotingReady = True;

		// Force the clients vote menu to update
		GRI = UTGameReplicationInfo(WorldInfo.GRI);

		if (GRI != none && GRI.CurrentMidGameMenu != none)
			GRI.CurrentMidGameMenu.UpdateVoteMenuLists(Self,,, True);
	}
}


// ***** Helper functions

// For use with listen servers
final function bool bLocallyOwned()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && Owner != none && LocalPlayer(PlayerController(Owner).Player) != none)
		return True;

	return False;
}


final simulated function SanitizeMapName(out string MapName)
{
	local array<UTUIResourceDataProvider> MapProviderList;
	local int i, j, k;
	local array<string> Loc;
	local bool bSkipPrefixCheck;

	if (MapProviders.Length == 0)
	{
		Class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo', MapProviderList);

		for (i=0; i<MapProviderList.Length; ++i)
			if (MapProviderList[i] != none)
				MapProviders.AddItem(UTUIDataProvider_MapInfo(MapProviderList[i]));
	}


	// Sanitize the map name (trying to use any available UI map name first)
	for (i=0; i<MapProviders.Length; ++i)
	{
		if (MapProviders[i].MapName ~= MapName)
		{
			bSkipPrefixCheck = True;

			j = InStr(Caps(MapProviders[i].FriendlyName), "<STRINGS:");

			if (j == INDEX_None)
			{
				MapName = MapProviders[i].FriendlyName;
				break;
			}


			MapName = Right(MapProviders[i].FriendlyName, Len(MapProviders[i].FriendlyName) - j - 9);
			k = InStr(MapName, ">");

			if (k != INDEX_None)
			{
				MapName = Left(MapName, k);
				ParseStringIntoArray(MapName, Loc, ".", True);

				if (Loc.Length >= 3)
					MapName = Localize(Loc[1], Loc[2], Loc[0]);
			}
		}
	}


	// Strip the prefix
	if (!bSkipPrefixCheck)
	{
		i = InStr(MapName, "-");

		if (i != INDEX_None)
			MapName = Right(MapName, Len(MapName) - i - 1);
	}


	// If there is still a link setup in the map name, then remove it
	i = InStr(Caps(MapName), "?LINKSETUP=");

	if (i != INDEX_None)
		MapName = Left(MapName, i)@"("$Mid(MapName, i+11)$")";
}


simulated reliable client function ClientTimesUpNew(string WinningMap)
{
	LeadingMaps.Length = 1;
	LeadingMaps[0] = WinningMap;

	ClientTimesUp();
}

// Clients that support gametype voting call this function instead of the above
reliable server function ServerClientIsReadyNew(string ClientVersion)
{
	// Only call once
	if (bSupportsNewVoting)
		return;


	bSupportsNewVoting = True;

	// Immediately initialize new clients
	ClientBeginVotingNew();

	// Valid calls only occur from outside of state code
	if (GetStateName() != Class.Name)
		return;


	UpdateVoteStatus();
}


defaultproperties
{
	bSkipActorPropertyReplication=false
 	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	NetUpdateFrequency=1

	MyCurrnetVoteID=-1

	CurGameVoteIndex=255
	CurMapVoteIndex=255
	WinningGameIndex=255
	WinningMapIndex=255
}
