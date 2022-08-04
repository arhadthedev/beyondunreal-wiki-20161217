//=============================================================================
// PlayerReplicationInfo.
// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
	native
	nativereplication;

`include(Core/Globals.uci)

var databinding float				Score;			// Player's current score.
var databinding float				Deaths;			// Number of player's deaths.
var byte				Ping;
var Actor				PlayerLocationHint;
var databinding int					NumLives;

var databinding repnotify string	PlayerName;		// Player name, or blank if none.
var databinding repnotify string 	PlayerAlias;	// The Player's current alias or blank if we are using the Player Name
var databinding int					PlayerRanking;  // Player ranking, 1000 is default

var string				OldName;
var int					PlayerID;		// Unique id number.
var RepNotify TeamInfo	Team;			// Player Team
var int					TeamID;			// Player position in team.

var databinding bool				bAdmin;				// Player logged in as Administrator
var databinding bool				bIsFemale;
var databinding bool				bIsSpectator;
var databinding bool				bOnlySpectator;
var databinding bool				bWaitingPlayer;
var databinding bool				bReadyToPlay;
var databinding bool				bOutOfLives;
var databinding bool				bBot;
var databinding bool				bHasFlag;
var	databinding bool				bHasBeenWelcomed;	// client side flag - whether this player has been welcomed or not

/** Means this PRI came from the GameInfo's InactivePRIArray */
var repnotify bool bIsInactive;
/** indicates this is a PRI from the previous level of a seamless travel,
 * waiting for the player to finish the transition before creating a new one
 * this is used to avoid preserving the PRI in the InactivePRIArray if the player leaves
 */
var bool bFromPreviousLevel;
/**@hack: patch compatibility hack - can't add replication to bFromPreviousLevel */
var repnotify bool bFromPreviousLevel_Replicated;

/** This determines whether the user has turned on or off their Controller Vibration **/
var bool                bControllerVibrationAllowed;

var byte				PacketLoss;

// Time elapsed.
var int					StartTime;

var localized String	StringDead;
var localized String    StringSpectating;
var localized String	StringUnknown;

var databinding int					Kills;				// not replicated

var class<GameMessage>	GameMessageClass;

var float				ExactPing;

var string				SavedNetworkAddress;	/** Used to match up InactivePRI with rejoining playercontroller. */

/**
 * The id used by the network to uniquely identify a player.
 * NOTE: this property should *never* be exposed to the player as it's transient
 * and opaque in meaning (ie it might mean date/time followed by something else)
 */
var repnotify UniqueNetId UniqueId;

/** ID of the friend you followed into the game, if applicable **/
var UniqueNetId FriendFollowedId;


/** Number of matches played (maybe remove this before shipping)  This is really useful for doing soak testing and such to see how long you lasted! NOTE:  This is not replicated out to clients atm. **/
var int NumberOfMatchesPlayed;





replication
{
	// Things the server should send to the client.
	if ( bNetDirty && (Role == Role_Authority) )
		Score, Deaths, bHasFlag, PlayerLocationHint,
		PlayerName, PlayerAlias, Team, TeamID, bIsFemale, bAdmin,
		bIsSpectator, bOnlySpectator, bWaitingPlayer, bReadyToPlay,
		StartTime, bOutOfLives, UniqueId, bControllerVibrationAllowed,
		bFromPreviousLevel_Replicated;

	if ( bNetDirty && (Role == Role_Authority) && (!bNetOwner || bDemoRecording) )
		PacketLoss, Ping;

	if ( bNetInitial && (Role == Role_Authority) )
		PlayerID, bBot, bIsInactive;
}


/**
* Returns true if the id from the other PRI matches this PRI's id
*
* @param OtherPRI the PRI to compare IDs with
*/
native final function bool AreUniqueNetIdsEqual(PlayerReplicationInfo OtherPRI);


/**
 * Returns the alias to use for this player.  If PlayerAlias is blank, then the player name
 * is returned.
 */
native function string GetPlayerAlias();


simulated event PostBeginPlay()
{
	// register this PRI with the game's ReplicationInfo
	if ( WorldInfo.GRI != None )
		WorldInfo.GRI.AddPRI(self);

	if ( Role < ROLE_Authority )
		return;

    if (AIController(Owner) != None)
	{
		bBot = true;
	}

	StartTime = WorldInfo.GRI.ElapsedTime;
	Timer();
	SetTimer(1.5 + FRand(), true);
}

/* epic ===============================================
* ::ClientInitialize
*
* Called by Controller when its PlayerReplicationInfo is initially replicated.
* Now that
*
* =====================================================
*/
simulated function ClientInitialize(Controller C)
{
	local Actor A;

	SetOwner(C);

	if ( PlayerController(C) != None )
	{
		BindPlayerOwnerDataProvider();

		// any replicated playercontroller  must be this client's playercontroller
		if ( Team != Default.Team )
		{
			// wasnt' able to call this in ReplicatedEvent() when Team was replicated, because PlayerController did not have me as its PRI
			ForEach AllActors(class'Actor', A)
				A.NotifyLocalPlayerTeamReceived();
		}
	}
}

/* epic ===============================================
* ::ReplicatedEvent
*
* Called when a variable with the property flag "RepNotify" is replicated
*
* =====================================================
*/
simulated event ReplicatedEvent(name VarName)
{
	local Pawn P;
	local PlayerController PC;
	local int WelcomeMessageNum;
	local Actor A;
	local OnlineSubsystem Online;

	if ( VarName == 'Team' )
	{
		ForEach DynamicActors(class'Pawn', P)
		{
			// find my pawn and tell it
			if ( P.PlayerReplicationInfo == self )
			{
				P.NotifyTeamChanged();
				break;
			}
		}
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( PC.PlayerReplicationInfo == self )
			{
				ForEach AllActors(class'Actor', A)
					A.NotifyLocalPlayerTeamReceived();
			}
			break;
		}
	}
	else if ( VarName == 'PlayerName' )
	{
		// If the new name doesn't match what the local player thinks it should be,
		// then reupdate the name forcing it to be the unique profile name
		if (IsInvalidName())
		{
			return;
		}

		if ( WorldInfo.TimeSeconds < 2 )
		{
			bHasBeenWelcomed = true;
			OldName = PlayerName;
			return;
		}

		// new player or name change
		if ( bHasBeenWelcomed )
		{
			if( ShouldBroadCastWelcomeMessage() && !WorldInfo.IsConsoleBuild() )
			{
				ForEach LocalPlayerControllers(class'PlayerController', PC)
				{
					PC.ReceiveLocalizedMessage( GameMessageClass, 2, self );
				}
			}
		}
		else
		{
			if ( bOnlySpectator )
				WelcomeMessageNum = 16;
			else
				WelcomeMessageNum = 1;

			bHasBeenWelcomed = true;

			if( ShouldBroadCastWelcomeMessage() )
			{
				ForEach LocalPlayerControllers(class'PlayerController', PC)
				{
					PC.ReceiveLocalizedMessage( GameMessageClass, WelcomeMessageNum, self );
				}
			}
		}
		OldName = PlayerName;
	}
	else if (VarName == 'UniqueId')
	{
		Online = class'GameEngine'.static.GetOnlineSubsystem();
		if (Online != None && Online.GameInterface != None && Online.GameInterface.GetGameSettings() != None)
		{
			// Register the player as part of the session
			Online.GameInterface.RegisterPlayer(UniqueId,false);
		}
	}
	else if (VarName == 'bIsInactive')
	{
		// remove and re-add from the GRI so it's in the right list
		WorldInfo.GRI.RemovePRI(self);
		WorldInfo.GRI.AddPRI(self);
	}
	//@hack: patch compatibility hack - can't add replication to bFromPreviousLevel
	else if (VarName == 'bFromPreviousLevel_Replicated')
	{
		bFromPreviousLevel = bFromPreviousLevel_Replicated;
	}
}

/* epic ===============================================
* ::UpdatePing
update average ping based on newly received round trip timestamp.
*/
final native function UpdatePing(float TimeStamp);

/**
 * Returns true if should broadcast player welcome/left messages.
 * Current conditions: must be a human player a network game */
simulated function bool ShouldBroadCastWelcomeMessage()
{
	return (!bIsInactive && WorldInfo.NetMode != NM_StandAlone);
}

simulated event Destroyed()
{
	local PlayerController PC;
	local OnlineSubsystem OnlineSub;
	local UniqueNetId ZeroId;

	if ( WorldInfo.GRI != None )
	{
		WorldInfo.GRI.RemovePRI(self);
	}

	if( ShouldBroadCastWelcomeMessage() )
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			PC.ReceiveLocalizedMessage( GameMessageClass, 4, self);
		}
	}

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	// If there is a game and we are a client, unregister this remote player
	if (WorldInfo.NetMode == NM_Client &&
		OnlineSub != None &&
		OnlineSub.GameInterface != None &&
		OnlineSub.GameInterface.GetGameSettings() != None &&
		UniqueId != ZeroId)
	{
		// Register the player as part of the session
		OnlineSub.GameInterface.UnregisterPlayer(UniqueId);
	}

    Super.Destroyed();
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Score = 0;
	Kills = 0;
	Deaths = 0;
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
	bForceNetUpdate = TRUE;
}

simulated function string GetHumanReadableName()
{
	return PlayerName;
}

simulated function string GetLocationName()
{
	local String LocationString;

    if( PlayerLocationHint == None )
		return StringSpectating;

	LocationString = PlayerLocationHint.GetLocationStringFor(self);
	return (LocationString == "") ? StringUnknown : LocationString;
}

function UpdatePlayerLocation()
{
    local Volume V, Best;
    local Pawn P;

    if( Controller(Owner) != None )
	{
		P = Controller(Owner).Pawn;
	}

    if( P == None )
	{
		PlayerLocationHint = None;
		return;
    }

    foreach P.TouchingActors( class'Volume', V )
    {
		if( V.LocationName == "" )
			continue;

		if( (Best != None) && (V.LocationPriority <= Best.LocationPriority) )
			continue;

		if( V.Encompasses(P) )
			Best = V;
	}
	PlayerLocationHint = (Best != None) ? Best : P.WorldInfo;
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(HUD HUD, out float YL, out float YPos)
{
	local float XS, YS;

	if ( Team == None )
		HUD.Canvas.SetDrawColor(255,255,0);
	else if ( Team.TeamIndex == 0 )
		HUD.Canvas.SetDrawColor(255,0,0);
	else
		HUD.Canvas.SetDrawColor(64,64,255);
	HUD.Canvas.SetPos(4, YPos);
    HUD.Canvas.Font	= class'Engine'.Static.GetSmallFont();
	HUD.Canvas.StrLen(PlayerName@"["$GetPlayerAlias()$"]", XS, YS);
	HUD.Canvas.DrawText(PlayerName@"["$GetPlayerAlias()$"]");
	HUD.Canvas.SetPos(4 + XS, YPos);
	HUD.Canvas.Font	= class'Engine'.Static.GetTinyFont();
	HUD.Canvas.SetDrawColor(255,255,0);
	if ( bHasFlag )
		HUD.Canvas.DrawText("   has flag ");

	YPos += YS;
	HUD.Canvas.SetPos(4, YPos);

	if ( !bBot && (PlayerController(HUD.Owner).ViewTarget != PlayerController(HUD.Owner).Pawn) )
	{
		HUD.Canvas.SetDrawColor(128,128,255);
		HUD.Canvas.DrawText("      bIsSpec:"@bIsSpectator@"OnlySpec:"$bOnlySpectator@"Waiting:"$bWaitingPlayer@"Ready:"$bReadyToPlay@"OutOfLives:"$bOutOfLives);
		YPos += YL;
		HUD.Canvas.SetPos(4, YPos);
	}
}

event Timer()
{
	UpdatePlayerLocation();
	SetTimer(1.5 + FRand(), true);
}

event SetPlayerName(string S)
{
	PlayerName = S;

	// ReplicatedEvent() won't get called by net code if we are the server
	if (WorldInfo.NetMode == NM_Standalone || WorldInfo.NetMode == NM_ListenServer)
	{
		ReplicatedEvent('PlayerName');
	}
	OldName = PlayerName;
	bForceNetUpdate = TRUE;
}

function SetWaitingPlayer(bool B)
{
	bIsSpectator = B;
	bWaitingPlayer = B;
	bForceNetUpdate = TRUE;
}

/* epic ===============================================
* ::Duplicate
Create duplicate PRI (for saving Inactive PRI)
*/
function PlayerReplicationInfo Duplicate()
{
	local PlayerReplicationInfo NewPRI;

	NewPRI = Spawn(class);
	CopyProperties(NewPRI);
	return NewPRI;
}

/* epic ===============================================
* ::OverrideWith
Get overridden properties from old PRI
*/
function OverrideWith(PlayerReplicationInfo PRI)
{
	bIsSpectator = PRI.bIsSpectator;
	bOnlySpectator = PRI.bOnlySpectator;
	bWaitingPlayer = PRI.bWaitingPlayer;
	bReadyToPlay = PRI.bReadyToPlay;
	bOutOfLives = PRI.bOutOfLives || bOutOfLives;
	FriendFollowedId = PRI.FriendFollowedID;

	Team = PRI.Team;
	TeamID = PRI.TeamID;
}

/* epic ===============================================
* ::CopyProperties
Copy properties which need to be saved in inactive PRI
*/
function CopyProperties(PlayerReplicationInfo PRI)
{
	PRI.Score = Score;
	PRI.Deaths = Deaths;
	PRI.Ping = Ping;
	PRI.NumLives = NumLives;
	PRI.PlayerName = PlayerName;
	PRI.PlayerID = PlayerID;
	PRI.StartTime = StartTime;
	PRI.Kills = Kills;
	PRI.bOutOfLives = bOutOfLives;
	PRI.SavedNetworkAddress = SavedNetworkAddress;
	PRI.Team = Team;
	PRI.UniqueId = UniqueId;
	PRI.NumberOfMatchesPlayed = NumberOfMatchesPlayed;
	PRI.FriendFollowedId = PRI.FriendFollowedID;
}

/** called by seamless travel when initializing a player on the other side - copy properties to the new PRI that should persist */
function SeamlessTravelTo(PlayerReplicationInfo NewPRI)
{
	CopyProperties(NewPRI);
	NewPRI.bOnlySpectator = bOnlySpectator;
}

/**
 * Finds the PlayerDataProvider that was registered with the CurrentGame data store for this PRI and links it to the
 * owning player's PlayerOwner data store.
 */
simulated function BindPlayerOwnerDataProvider()
{
	local PlayerController PlayerOwner;
	local LocalPlayer LP;
	local DataStoreClient DataStoreManager;
	local CurrentGameDataStore CurrentGameData;
	local PlayerDataProvider DataProvider;

	`log(">>" @ Self $ "::BindPlayerOwnerDataProvider" @ "(" $ PlayerName $ ")",,'DevDataStore');

	PlayerOwner = PlayerController(Owner);
	if ( PlayerOwner != None )
	{
		// only works if this is a local player
		LP = LocalPlayer(PlayerOwner.Player);
		if ( LP != None )
		{
			// get the global data store client
			DataStoreManager = class'UIInteraction'.static.GetDataStoreClient();
			if ( DataStoreManager != None )
			{
				// find the "CurrentGame" data store
				CurrentGameData = CurrentGameDataStore(DataStoreManager.FindDataStore('CurrentGame'));
				if ( CurrentGameData != None )
				{
					// find the PlayerDataProvider that was created when this PRI was added to the GRI's PRI array.
					DataProvider = CurrentGameData.GetPlayerDataProvider(Self);
					if ( DataProvider != None )
					{
						// link it to the CurrentPlayer data provider
						PlayerOwner.SetPlayerDataProvider(DataProvider);
					}
					else
					{
						// @todo - is this an error or should we create one here?
						`log("No player data provider registered for player " $ Self @ "(" $ PlayerName $ ")",,'DevDataStore');
					}
				}
				else
				{
					`log("'CurrentGame' data store not found!",,'DevDataStore');
				}
			}
			else
			{
				`log("Data store manager not found!",,'DevDataStore');
			}
		}
		else
		{
			`log("Non local player:" @ PlayerOwner.Player,,'DevDataStore');
		}
	}
	else
	{
		`log("Invalid owner:" @ Owner,,'DevDataStore');
	}

	`log("<<" @ Self $ "::BindPlayerOwnerDataProvider" @ "(" $ PlayerName $ ")",,'DevDataStore');
}

/** Utility for seeing if this PRI is for a locally controller player. */
simulated function bool IsLocalPlayerPRI()
{
	local PlayerController PC;
	local LocalPlayer LP;

	PC = PlayerController(Owner);
	if(PC != None)
	{
		LP = LocalPlayer(PC.Player);
		return (LP != None);
	}

	return FALSE;
}

simulated native function byte GetTeamNum();

/**
 * Validates that the new name matches the profile if the player is logged in
 *
 * @return TRUE if the name doesn't match, FALSE otherwise
 */
simulated function bool IsInvalidName()
{
	local LocalPlayer LocPlayer;
	local PlayerController PC;
	local string ProfileName;
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		PC = PlayerController(Owner);
		if (PC != None)
		{
			LocPlayer = LocalPlayer(PC.Player);
			if (LocPlayer != None &&
				OnlineSub.GameInterface != None &&
				OnlineSub.PlayerInterface != None)
			{
				// Check to see if they are logged in locally or not
				if (OnlineSub.PlayerInterface.GetLoginStatus(LocPlayer.ControllerId) == LS_LoggedIn)
				{
					// Ignore what ever was specified and use the profile's nick
					ProfileName = OnlineSub.PlayerInterface.GetPlayerNickname(LocPlayer.ControllerId);
					if (ProfileName != PlayerName)
					{
						// Force an update to the proper name
						PC.SetName(ProfileName);
						return true;
					}
				}
			}
		}
	}
	return false;
}

function SetPlayerAlias(string NewAlias)
{
	PlayerAlias = NewAlias;
}

defaultproperties
{
	TickGroup=TG_DuringAsyncWork

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
    NetUpdateFrequency=1
	GameMessageClass=class'GameMessage'

	bControllerVibrationAllowed=TRUE
}
