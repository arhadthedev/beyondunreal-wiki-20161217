/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTGameReplicationInfo extends GameReplicationInfo
	config(Game)
	native;

var float WeaponBerserk;
var int MinNetPlayers;
var int BotDifficulty;		// for bPlayersVsBots

var bool		bWarmupRound;	// Amount of Warmup Time Remaining
/** forces other players to be viewed on this machine with the default character */
var globalconfig bool bForceDefaultCharacter;
/** whether we have processed all the custom characters for players that were initially in the game (clientside flag) */
var bool bProcessedInitialCharacters;

/** Array of local players that have not been processed yet. */
var array<PlayerController> LocalPCsLeftToProcess;

/** Total number of players set to be processed so far. */
var int	TotalPlayersSetToProcess;

/** We hold a reference to the live scoreboard to adapt for split screen */
var UTUIScene_Scoreboard ScoreboardScene;

var float StartCreateCharTime;

struct native CreateCharStatus
{
	var		CustomCharMergeState	MergeState;
	var		UTCharFamilyAssetStore	AssetStore;
	var		UTCharFamilyAssetStore	ArmAssetStore;
	var		UTPlayerReplicationInfo	PRI;
	var		float					StartMergeTime;
	var		bool					bOtherTeamSkin;
	var		bool					bNeedsArms;
	var		bool					bForceFallbackArms;
};

var array<CreateCharStatus>		CharStatus;

var string SinglePlayerBotNames[4];

enum EFlagState
{
    FLAG_Home,
    FLAG_HeldFriendly,
    FLAG_HeldEnemy,
    FLAG_Down,
};

var EFlagState FlagState[2];

/** If this is set, the game is running in story mode */
var bool bStoryMode;

/** Holds the Mission index of the current mission */
var int SinglePlayerMissionID;

/** whether the server is a console so we need to make adjustments to sync up */
var bool bConsoleServer;

/** Which input types are allowed for this game **/
var bool bAllowKeyboardAndMouse;

/** set by level Kismet to disable announcements during tutorials/cinematics/etc */
var bool bAnnouncementsDisabled;

var repnotify bool bShowMOTD;

var databinding string MutatorList;
var databinding string RulesString;

//********** Map Voting **********8/

var int MapVoteTimeRemaining;

/** weapon overlays that are available in this map - figured out in PostBeginPlay() from UTPowerupPickupFactories in the level
 * each entry in the array represents a bit in UTPawn's WeaponOverlayFlags property
 * @see UTWeapon::SetWeaponOverlayFlags() for how this is used
 */
var array<MaterialInterface> WeaponOverlays;
/** vehicle weapon effects available in this map - works exactly like WeaponOverlays, except these are meshes
 * that get attached to the vehicle mesh when the corresponding bit is set on the driver's WeaponOverlayFlags
 */
struct native MeshEffect
{
	/** mesh for the effect */
	var StaticMesh Mesh;
	/** material for the effect */
	var MaterialInterface Material;
};
var array<MeshEffect> VehicleWeaponEffects;


//===================================================================
/*	These are client-side variables that hold references to the mid game menu.
    We store them here so that split-screen doesn't double up						*/
//===================================================================


/** Holds the current Mid Game Menu Scene */
var UTUIScene_MidGameMenu CurrentMidGameMenu;
var name LastUsedMidgameTab;

var bool bShowMenuOnDeath;

var bool bRequireReady;

replication
{
	if (bNetInitial)
		WeaponBerserk, MinNetPlayers, BotDifficulty, bStoryMode, bConsoleServer, bShowMOTD, MutatorList, RulesString, bRequireReady;

	if (bNetDirty)
		bWarmupRound, FlagState, MapVoteTimeRemaining, bAnnouncementsDisabled, bAllowKeyboardAndMouse;
}

simulated function PostBeginPlay()
{
	local UTPowerupPickupFactory Powerup;
	local Sequence GameSequence;
	local array<SequenceObject> AllFactoryActions;
	local SeqAct_ActorFactory FactoryAction;
	local UTActorFactoryPickup Factory;
	local int i;
	local UTGameUISceneClient SC;

	Super.PostBeginPlay();

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		SetTimer(1.0, false, 'StartProcessingCharacterData');
	}

	// using DynamicActors here so the overlays don't break if the LD didn't build paths
	foreach DynamicActors(class'UTPowerupPickupFactory', Powerup)
	{
		Powerup.AddWeaponOverlay(self);
	}

	// also check if any Kismet actor factories spawn powerups
	GameSequence = WorldInfo.GetGameSequence();
	if (GameSequence != None)
	{
		GameSequence.FindSeqObjectsByClass(class'SeqAct_ActorFactory', true, AllFactoryActions);
		for (i = 0; i < AllFactoryActions.length; i++)
		{
			FactoryAction = SeqAct_ActorFactory(AllFactoryActions[i]);
			Factory = UTActorFactoryPickup(FactoryAction.Factory);
			if (Factory != None && ClassIsChildOf(Factory.InventoryClass, class'UTInventory'))
			{
				class<UTInventory>(Factory.InventoryClass).static.AddWeaponOverlay(self);
			}
		}
	}

	// Look for a mid game menu and if it's there fix it up

	SC = UTGameUISceneClient(class'UIRoot'.static.GetSceneClient());
	if (SC != none )
	{
		CurrentMidGameMenu = UTUIScene_MidGameMenu(SC.FindSceneByTag('MidGameMenu'));
		if ( CurrentMidGameMenu != none )
		{
			CurrentMidGameMenu.Reset();
		}
	}
}

simulated function AddPRI(PlayerReplicationInfo PRI)
{
	local UTPlayerReplicationInfo UTPRI;

	Super.AddPRI(PRI);

	// increment constructed character count if this PRI already has a mesh
	UTPRI = UTPlayerReplicationInfo(PRI);
	if (UTPRI != None && UTPRI.CharacterMesh != None)
	{
		TotalPlayersSetToProcess++;
	}
}

simulated event Destroyed()
{
	Super.Destroyed();

	// throw away any character data we didn't finish
	//@FIXME: this means that if the server finishes loading the destination level in a seamless travel
	//	before we finish character creation, those characters don't get finished
	//	because the server will wipe out the GRI/PRI/etc from under us
	//	unfortunately, there's not a reasonable workaround - we can add delays in places but that doesn't guarantee anything
	//	in retrospect, we probably should have taken the data we needed out of the RIs and used a separate object
	if (IsTimerActive('TickCharacterMeshCreation'))
	{
		SendCharacterProcessingNotification(false);
		// sanity check to make sure we don't get stuck waiting
		if (WorldInfo.IsInSeamlessTravel())
		{
			WorldInfo.SetSeamlessTravelMidpointPause(false);
		}
	}
}

simulated function ReplicatedEvent(name VarName)
{
	if ( VarName == 'bShowMOTD' )
	{
		DisplayMOTD();
	}
}

function SetFlagHome(int TeamIndex)
{
	FlagState[TeamIndex] = FLAG_Home;
	bForceNetUpdate = TRUE;
}

simulated function bool FlagIsHome(int TeamIndex)
{
	return ( FlagState[TeamIndex] == FLAG_Home );
}

simulated function bool FlagsAreHome()
{
	return ( FlagState[0] == FLAG_Home && FlagState[1] == FLAG_Home );
}

function SetFlagHeldFriendly(int TeamIndex)
{
	FlagState[TeamIndex] = FLAG_HeldFriendly;
}

simulated function bool FlagIsHeldFriendly(int TeamIndex)
{
	return ( FlagState[TeamIndex] == FLAG_HeldFriendly );
}

function SetFlagHeldEnemy(int TeamIndex)
{
	FlagState[TeamIndex] = FLAG_HeldEnemy;
}

simulated function bool FlagIsHeldEnemy(int TeamIndex)
{
	return ( FlagState[TeamIndex] == FLAG_HeldEnemy );
}

function SetFlagDown(int TeamIndex)
{
	FlagState[TeamIndex] = FLAG_Down;
}

simulated function bool FlagIsDown(int TeamIndex)
{
	return ( FlagState[TeamIndex] == FLAG_Down );
}

simulated function Timer()
{
	local byte TimerMessageIndex;
	local PlayerController PC;

	super.Timer();

	if ( WorldInfo.NetMode == NM_Client )
	{
		if ( bWarmupRound && RemainingTime > 0 )
			RemainingTime--;
	}

    if (WorldInfo.NetMode != NM_DedicatedServer && MapVoteTimeRemaining > 0)
    {
    	MapVoteTimeRemaining--;
    }

	// check if we should broadcast a time countdown message
	if (WorldInfo.NetMode != NM_DedicatedServer && (bMatchHasBegun || bWarmupRound) && !bStopCountDown && !bMatchIsOver && Winner == None)
	{
		switch (RemainingTime)
		{
			case 300:
				TimerMessageIndex = 16;
				break;
			case 180:
				TimerMessageIndex = 15;
				break;
			case 120:
				TimerMessageIndex = 14;
				break;
			case 60:
				TimerMessageIndex = 13;
				break;
			case 30:
				TimerMessageIndex = 12;
				break;
			default:
				if (RemainingTime <= 10 && RemainingTime > 0)
				{
					TimerMessageIndex = RemainingTime;
				}
				break;
		}
		if (TimerMessageIndex != 0)
		{
			foreach LocalPlayerControllers(class'PlayerController', PC)
			{
				PC.ReceiveLocalizedMessage(class'UTTimerMessage', TimerMessageIndex);
			}
		}
	}
}

/** @return whether we're still processing character data into meshes */
simulated function bool IsProcessingCharacterData()
{
	// Still characters to process..
	return(CharStatus.length > 0);
}

/** @return whether we should skip all character processing of any kind, even arms */
simulated function bool SkipAllProcessing()
{
	// don't ever do anything in PIE or the menu level
	return (WorldInfo.IsPlayInEditor() || (WorldInfo.NetMode == NM_Standalone && WorldInfo.Game.Class == class'UTEntryGame'));
}

/** called to notify all local players when character data processing is started/stopped */
simulated function SendCharacterProcessingNotification(bool bNowProcessing)
{
	local PlayerController PC;
	local UTPlayerController UTPC;
	local UTPlayerReplicationInfo PRI;

	if (!bNowProcessing && !bProcessedInitialCharacters && !SkipAllProcessing())
	{
		// make sure local players got arms - if not, don't allow the processing to end yet
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			PRI = UTPlayerReplicationInfo(PC.PlayerReplicationInfo);
			if (PRI != None && PRI.FirstPersonArmMesh == None)
			{
				ProcessCharacterData(PRI);
				bNowProcessing = true;
			}
		}
	}

	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		UTPC = UTPlayerController(PC);
		if (UTPC != None)
		{
			if (bNowProcessing)
			{
				if (!bProcessedInitialCharacters)
				{
					// open menu so player knows what's going on
					UTPC.SetPawnConstructionScene(true);
				}
			}
			else
			{
				UTPC.CharacterProcessingComplete();
			}
		}
	}

	if (!bNowProcessing)
	{
		bProcessedInitialCharacters = true;
		SetNoStreamWorldTextureForFrames(0);
		if (WorldInfo.IsInSeamlessTravel())
		{
			WorldInfo.SetSeamlessTravelMidpointPause(false);
		}
	}
}

simulated function StartProcessingCharacterData()
{
	local int i;
	local UTPlayerReplicationInfo PRI;
	local PlayerController PC;
	local UTPlayerController UTPC;

	// this is so ProcessCharacterData() knows this function has been called
	ClearTimer('StartProcessingCharacterData');

	// see if we already processed initial characters (i.e. because we did a seamless travel)
	foreach LocalPlayerControllers(class'UTPlayerController', UTPC)
	{
		bProcessedInitialCharacters = UTPC.bInitialProcessingComplete;
		if (bProcessedInitialCharacters)
		{
			break;
		}
	}

	if (!bProcessedInitialCharacters)
	{
		// Count how many local players there are.
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			LocalPCsLeftToProcess.AddItem(PC);
		}

		// process all character data that has already been received
		for (i = 0; i < PRIArray.length; i++)
		{
			PRI = UTPlayerReplicationInfo(PRIArray[i]);
			if (PRI != None && PRI.CharacterData.FamilyID != "" && PRI.CharacterMesh == None)
			{
				ProcessCharacterData(PRI);
			}
		}
	}

	SendCharacterProcessingNotification(IsProcessingCharacterData());
}

/** Reset merging on a character. */
simulated function ResetCharMerge(int StatusIndex)
{
	local CustomCharMergeState TempState;

	// Can't pass member of dynamic arrays by reference in UScript :(
	TempState = CharStatus[StatusIndex].MergeState;
	class'UTCustomChar_Data'.static.ResetCustomCharMerge(TempState);
	CharStatus[StatusIndex].MergeState = TempState;

	CharStatus[StatusIndex].AssetStore = None;
	CharStatus[StatusIndex].ArmAssetStore = None;

	CharStatus[StatusIndex].bNeedsArms = FALSE;
}

/** Attempt to finish merging - returns SkeletalMesh when done. */
simulated function SkeletalMesh FinishCharMerge(int StatusIndex)
{
	local CustomCharMergeState TempState;
	local SkeletalMesh NewMesh;

	// Can't pass member of dynamic arrays by reference in UScript :(
	TempState = CharStatus[StatusIndex].MergeState;
	NewMesh = class'UTCustomChar_Data'.static.FinishCustomCharMerge(TempState);
	CharStatus[StatusIndex].MergeState = TempState;

	return NewMesh;
}

/** Util to find an existing custom mesh with the same race/sex/team */
simulated function UTPlayerReplicationInfo FindExistingMeshForFamily(string FamilyID, byte TeamNum, UTPlayerReplicationInfo CurrentPRI)
{
	local int i;
	local UTPlayerReplicationInfo UTPRI;

	// Check family, gender and team are the same - and don't allow sharing local player mesh (they can change team)
	// in story mode, require exact match for red team - people need to be the right meshes (or fallback is ok)
	for(i=0; i<PRIArray.length; i++)
	{
		UTPRI = UTPlayerReplicationInfo( PRIArray[i] );
		if( UTPRI != None &&
			UTPRI != CurrentPRI &&
			((bStoryMode && TeamNum == 0) ? (UTPRI.CharacterData == CurrentPRI.CharacterData) : (UTPRI.CharacterData.FamilyID == FamilyID)) &&
			UTPRI.CharacterMesh != None &&
			UTPRI.CharPortrait != None &&
			UTPRI.GetTeamNum() == TeamNum &&
			!UTPRI.IsLocalPlayerPRI() )
		{
			return UTPRI;
		}
	}

	return None;
}

/** determines whether we should process the given player's character data into a mesh
 * and if so, gets that started
 * @note: this can be called multiple times for a given PRI if more info is received (e.g. Team)
 * @param PRI - the PlayerReplicationInfo that holds the data to process
 * @param bTeamChange - if this is the result of a team change
 */
simulated singular function ProcessCharacterData(UTPlayerReplicationInfo PRI, optional bool bTeamChange)
{
	local int i;
	local bool bPRIAlreadyPresent, bDefaultCharParts, bLocalTeamChange;
	local CreateCharStatus NewCharStatus;
	local UTProcessedCharacterCache CharacterCache, OldestCharacterCache;
	local UTPlayerReplicationInfo ReplacementUTPRI;

	if (SkipAllProcessing())
	{
		return;
	}

	// Do nothing if CharData is not filled in
	if((PRI.CharacterData.FamilyID == "" || PRI.CharacterData.FamilyID == "NONE") && !PRI.IsLocalPlayerPRI())
	{
		return;
	}

	// see if this character is cached
 	foreach DynamicActors(class'UTProcessedCharacterCache', CharacterCache)
 	{
 		if (CharacterCache.GetCachedCharacter(PRI))
 		{
 			TotalPlayersSetToProcess++;
 			return;
 		}
 		else if (OldestCharacterCache != None)
 		{
 			OldestCharacterCache = CharacterCache;
 		}
 	}

	// we need to make sure we have called StartProcessingCharacterData() before we actually do anything
	if (IsTimerActive('StartProcessingCharacterData'))
	{
		if (GetTimerRate('StartProcessingCharacterData') > 0.001)
		{
			SetTimer(0.001, false, 'StartProcessingCharacterData');
		}
		return;
	}

	if(bProcessedInitialCharacters && bTeamChange && PRI.IsLocalPlayerPRI())
	{
		if( PRI.UpdateCustomTeamSkin() )
		{
			bLocalTeamChange = TRUE;
		}
	}

	// We don't allow non-local characters to be created once gameplay has begun.
	// also skip nonlocal spectators (spectators can join later, so build local mesh anyway so at least player sees his/her own custom mesh)
	if (((bProcessedInitialCharacters && !WorldInfo.IsInSeamlessTravel()) || PRI.bOnlySpectator || bForceDefaultCharacter) && !PRI.IsLocalPlayerPRI())
	{
		ReplacementUTPRI = FindExistingMeshForFamily(PRI.CharacterData.FamilyID, PRI.GetTeamNum(), PRI);
		if(ReplacementUTPRI != None)
		{
			PRI.SetCharacterMesh(ReplacementUTPRI.CharacterMesh, true);
			PRI.CharPortrait = ReplacementUTPRI.CharPortrait;
		}
		else
		{
			PRI.SetCharacterMesh(None);
		}

		return;
	}

	// Decrement count if this is a local player.
	if(PRI.IsLocalPlayerPRI())
	{
		LocalPCsLeftToProcess.RemoveItem(PlayerController(PRI.Owner));
	}
	// If this isn't a local player, don't process it if we haven't got space.
	else if((TotalPlayersSetToProcess + LocalPCsLeftToProcess.length) >= class'UTGame'.default.MaxCustomChars)
	{
		PRI.SetCharacterMesh(None);
		return;
	}

	if (!bProcessedInitialCharacters)
	{
		// make sure local players have been informed if we're running the initial processing
		SendCharacterProcessingNotification(true);
	}

	// remove any previous mesh and arms
	if(!bLocalTeamChange)
	{
		PRI.SetCharacterMesh(None);
	}

	PRI.SetFirstPersonArmInfo(None, None);

	// See if the parts you picked are actually the default char
	bDefaultCharParts = (class'UTCustomChar_Data'.static.CharDataToString(PRI.CharacterData) == "B,IRNM,A,C,NONE,NONE,B,A,A,A,A,T,T");

	// First see if this PRI is already present (eg may have changed team)
	bPRIAlreadyPresent = false;
	for(i=0; i<CharStatus.Length; i++)
	{
		// It is there - reset and abandon any merge work so far.
		if(CharStatus[i].PRI == PRI)
		{
			//`log("PRI in use - resetting:"@PRI);
			ResetCharMerge(i);
			// only do arms if we've already done initial characters
			CharStatus[i].bNeedsArms = (bProcessedInitialCharacters && !WorldInfo.IsInSeamlessTravel() && PRI.IsLocalPlayerPRI()) || bDefaultCharParts;

			bPRIAlreadyPresent = true;
		}
	}

	// Was not there - add to end of the array
	if(!bPRIAlreadyPresent)
	{
		//`log("Adding PRI:"@PRI);
		NewCharStatus.PRI = PRI;
		// only do arms if we've already done initial characters
		NewCharStatus.bNeedsArms = (bProcessedInitialCharacters && !WorldInfo.IsInSeamlessTravel() && PRI.IsLocalPlayerPRI());

		// Special case - when you actually picked the parts for the fallback mesh - just use that! Go straight to loading arms.
		if(!NewCharStatus.bNeedsArms && bDefaultCharParts)
		{
			NewCharStatus.bNeedsArms = TRUE;
		}

		CharStatus[CharStatus.length] = NewCharStatus;

		// Increment count of total players set to process (if we are not just asking for arms)
		if(!NewCharStatus.bNeedsArms)
		{
			TotalPlayersSetToProcess++;
		}

		// destroy oldest cached data to make sure we have enough room
		if (OldestCharacterCache != None)
		{
			OldestCharacterCache.Destroy();
			WorldInfo.ForceGarbageCollection();
		}
	}

	SetTimer(1.0 / 60.0, true, 'TickCharacterMeshCreation');

	// Start the character creation timer.
	StartCreateCharTime = WorldInfo.RealTimeSeconds;
}

/** Function that disables streaming of world textures for NumFrames. */
native final function SetNoStreamWorldTextureForFrames(int NumFrames);

/** called when character meshes are being processed to update it */
simulated function TickCharacterMeshCreation()
{
	local int i, NextCharIndex;
	local UTCharFamilyAssetStore ActiveAssetStore;
	local bool bMergePending, bMergeWasPending;
	local SkeletalMesh NewMesh, ArmMesh;
	local string TeamString, LoadFamily, ArmMeshName, ArmMaterialName;
	local CustomCharTextureRes TexRes;
	local class<UTFamilyInfo> FamilyInfoClass;
	local MaterialInterface ArmMaterial;
	local CharPortraitSetup PortraitSetup;
	local UTPlayerReplicationInfo PRI, ReplacementUTPRI;

	// To speed up streaming parts - disable level streaming.
	SetNoStreamWorldTextureForFrames(100000);

	// First, clear out and reset any entries with a NULL PRI (that is, someone disconnected)
	for(i=CharStatus.Length-1; i>=0; i--)
	{
		if (CharStatus[i].PRI == None || CharStatus[i].PRI.bDeleteMe)
		{
			//`log("PRI NULL - Removing.");
			ResetCharMerge(i);
			CharStatus.Remove(i,1);
		}
	}

	// Invariant: At this point all PRI's are valid

	// Now look to see if one is at phase 2 (that is, streaming textures).
	for(i=CharStatus.Length-1; i>=0; i--)
	{
		if(CharStatus[i].MergeState.bMergeInProgress)
		{
			bMergeWasPending = true;

			// Should never be trying to merge without an AssetStore, or with AssetStore not finished loading.
			assert(CharStatus[i].AssetStore != None);
			assert(CharStatus[i].AssetStore.NumPendingPackages == 0);
			// Should only ever have one in this state at a time!
			assert(bMergePending == false);
			// Set flag to indicate there is currently a merge pending
			bMergePending = true;

			//`log("PRI Merge Pending:"@CharStatus[i].PRI);

			// See if we can create skeletal mesh
			NewMesh = FinishCharMerge(i);
			if(!CharStatus[i].MergeState.bMergeInProgress)
			{
				// Merge is done
				`log("CUSTOMCHAR Complete:"@CharStatus[i].PRI@"  (Tex stream:"@(WorldInfo.RealTimeSeconds - CharStatus[i].StartMergeTime)@"Secs)");

				if(NewMesh != None)
				{
					// If this was a construction for the other team skin - save that
					if(CharStatus[i].bOtherTeamSkin)
					{
						CharStatus[i].PRI.SetOtherTeamSkin(NewMesh);
					}
					else
					{
						// Save newly created mesh into PRI.
						CharStatus[i].PRI.SetCharacterMesh(NewMesh);

						// Add an offset specific to the family.
						PortraitSetup = class'UTCustomChar_Data'.default.PortraitSetup;
						FamilyInfoClass = class'UTCustomChar_Data'.static.FindFamilyInfo(CharStatus[i].PRI.CharacterData.FamilyID);
						PortraitSetup.MeshOffset += FamilyInfoClass.default.PortraitExtraOffset;

						// Render the portrait texture.
						CharStatus[i].PRI.CharPortrait = class'UTCustomChar_Data'.static.MakeCharPortraitTexture (NewMesh, PortraitSetup, class'UTCustomChar_Data'.default.PortraitBackgroundMesh);
					}
				}
				else
				{
					CharStatus[i].PRI.SetCharacterMesh(None);
				}

				// If this is a local player, we have some extra steps - make skin for other team, and store a pointer to the first-person arm mesh.

				if(CharStatus[i].PRI.IsLocalPlayerPRI())
				{
					if( WorldInfo.GetGameClass().default.bTeamGame && // Only need other team skin for team games
						!CharStatus[i].bOtherTeamSkin && // Make sure we didn't just try and do this (avoids infinite loop)
						(CharStatus[i].PRI.GetTeamNum() == 0 || CharStatus[i].PRI.GetTeamNum() == 1) && // check they are on red or blue (not spectator)
						(CharStatus[i].PRI.BlueHeadMIC == None || CharStatus[i].PRI.RedHeadMIC == None) ) // Are missing a skin
					{
						TeamString = CharStatus[i].PRI.GetCustomCharOtherTeamString();

						`log("PRI Other Merge Start:" @ CharStatus[i].PRI @ CharStatus[i].PRI.PlayerName @ TeamString);

						// Choose texture res based on whether you are the local player
						TexRes = (CharStatus[i].PRI.IsLocalPlayerPRI()) ? CCTR_Self : CCTR_Normal;
						CharStatus[i].MergeState = class'UTCustomChar_Data'.static.StartCustomCharMerge(CharStatus[i].PRI.CharacterData, TeamString, None, TexRes);
						CharStatus[i].StartMergeTime = WorldInfo.RealTimeSeconds;
						CharStatus[i].bOtherTeamSkin = TRUE;
						bMergePending = true;
					}
					else
					{
						CharStatus[i].bNeedsArms = TRUE;
						CharStatus[i].AssetStore = None;
						bMergePending = false;
					}
				}
				else
				{
					// We are done! Remove this entry from the array. This will let the AssetStore go away next GC.
					CharStatus.Remove(i,1);

					// No merges pending any more
					bMergePending = false;
				}
			}
			// See if merge is invalid, or we have taken too long waiting for textures to stream in.
			else if(CharStatus[i].MergeState.bInvalidChar || (WorldInfo.RealTimeSeconds - CharStatus[i].StartMergeTime) > class'UTCustomChar_Data'.default.CustomCharTextureStreamTimeout)
			{
				`log("TIMEOUT: Streaming Textures for custom char."@CharStatus[i].PRI);
				ResetCharMerge(i);
				CharStatus[i].PRI.SetCharacterMesh(None);

				// Even though we timed out while streaming, we still try to load the FP arm mesh.
				if(CharStatus[i].PRI.IsLocalPlayerPRI())
				{
					CharStatus[i].bNeedsArms = TRUE;
				}
				else
				{
					// We are done! Remove this entry from the array. This will let the AssetStore go away next GC.
					CharStatus.Remove(i,1);
				}

				bMergePending = false;
			}
		}
	}

	// If no merge going, but still PRIs left to process, get the next one going
	if(!bMergePending && CharStatus.length > 0)
	{
		// Look to see if any are at phase 1 (that is, loading assets from disk - has an AssetStore)
		for(i=0; i<CharStatus.Length && !bMergePending; i++)
		{
			// This entry has an asset store
			if(CharStatus[i].AssetStore != None)
			{
				// Make sure it matches the PRI's character setup data
				assert(CharStatus[i].AssetStore.FamilyID == CharStatus[i].PRI.CharacterData.FamilyID);

				// If this is the first entry with a store, remember it
				if(ActiveAssetStore == None)
				{
					ActiveAssetStore = CharStatus[i].AssetStore;
				}
				// If not the first - make sure all AssetStores are the same. Only want one 'in flight' at a time.
				else
				{
					assert(CharStatus[i].AssetStore == ActiveAssetStore);
				}

				// If all assets are loaded, we can start a merge.
				if(CharStatus[i].AssetStore.NumPendingPackages == 0)
				{
					TeamString = CharStatus[i].PRI.GetCustomCharTeamString();

					`log("CUSTOMCHAR Start:" @ CharStatus[i].PRI @ CharStatus[i].PRI.PlayerName @ TeamString);

					// Choose texture res based on whether you are the local player
					TexRes = (CharStatus[i].PRI.IsLocalPlayerPRI()) ? CCTR_Self : CCTR_Normal;
					CharStatus[i].MergeState = class'UTCustomChar_Data'.static.StartCustomCharMerge(CharStatus[i].PRI.CharacterData, TeamString, None, TexRes);
					CharStatus[i].StartMergeTime = WorldInfo.RealTimeSeconds;
					bMergePending = true;
				}
			}
			// If its an arm-loading case
			else if(CharStatus[i].ArmAssetStore != None)
			{
				assert((CharStatus[i].ArmAssetStore.FamilyID == CharStatus[i].PRI.CharacterData.FamilyID) || CharStatus[i].bForceFallbackArms);

				ActiveAssetStore = CharStatus[i].ArmAssetStore;

				// If we've finished loading packages containing arms
				if(CharStatus[i].ArmAssetStore.NumPendingPackages == 0)
				{
					LoadFamily = CharStatus[i].PRI.CharacterData.FamilyID;
					// If we just had bogus family, use fallback arms.
					if(CharStatus[i].bForceFallbackArms || LoadFamily == "" || LoadFamily == "NONE")
					{
						ArmMeshName = class'UTCustomChar_Data'.default.DefaultArmMeshName;
						if (CharStatus[i].PRI.Team != None)
						{
							if (CharStatus[i].PRI.Team.TeamIndex == 0)
							{
								ArmMaterialName = class'UTCustomChar_Data'.default.DefaultRedArmSkinName;
							}
							else if (CharStatus[i].PRI.Team.TeamIndex == 1)
							{
								ArmMaterialName = class'UTCustomChar_Data'.default.DefaultBlueArmSkinName;
							}
						}
					}
					// We have decent family, look in info class
					else
					{
						FamilyInfoClass = class'UTCustomChar_Data'.static.FindFamilyInfo(CharStatus[i].PRI.CharacterData.FamilyID);
						ArmMeshName = FamilyInfoClass.default.ArmMeshName;
						if (CharStatus[i].PRI.Team != None)
						{
							if (CharStatus[i].PRI.Team.TeamIndex == 0)
							{
								ArmMaterialName = FamilyInfoClass.default.RedArmSkinName;
							}
							else if (CharStatus[i].PRI.Team.TeamIndex == 1)
							{
								ArmMaterialName = FamilyInfoClass.default.BlueArmSkinName;
							}
						}
					}

					// Find arm material by name (if we want one)
					if(ArmMaterialName != "")
					{
						ArmMaterial = MaterialInterface(FindObject(ArmMaterialName, class'MaterialInterface'));
						if(ArmMaterial == None)
						{
							`log("WARNING: Could not find ArmMaterial:"@ArmMaterialName);
						}
					}

					// Find arm mesh by name
					ArmMesh = SkeletalMesh(FindObject(ArmMeshName, class'SkeletalMesh'));
					if(ArmMesh == None)
					{
						`log("WARNING: Could not find ArmMesh:"@ArmMeshName);
					}

					// Apply mesh/material to character
					CharStatus[i].PRI.SetFirstPersonArmInfo(ArmMesh, ArmMaterial);

					// Done with this char now! Remove from array.
					CharStatus.Remove(i,1);
					i--;
				}
			}
		}

		// If none have an asset store - create one now and start getting assets loaded
		if(ActiveAssetStore == None)
		{
			// Force garbage collection if merge was pending and hold off kicking off more async loading for a frame so the GC can occur.
			if( bMergeWasPending )
			{
				WorldInfo.ForceGarbageCollection();
			}
			else
			{
				// Look for the next character that isn't needing arms.
				// We also set bNeedsArms on any chars that just need arms.
				NextCharIndex = INDEX_NONE;
				for(i=0; i<CharStatus.length; i++)
				{
					if(!CharStatus[i].bNeedsArms)
					{
						// Any characters with bogus FamilyInfo, we just want to load default arms.
						// This should ONLY be for local PRIs (see ).
						LoadFamily = CharStatus[i].PRI.CharacterData.FamilyID;
						if(LoadFamily == "" || LoadFamily == "NONE")
						{
							assert(CharStatus[i].PRI.IsLocalPlayerPRI());
							CharStatus[i].bNeedsArms = TRUE;
						}
						else
						{
							NextCharIndex = i;
							break;
						}
					}
				}

				// We found a non-arms mesh (needs store for parts)
				if(NextCharIndex != INDEX_NONE)
				{
					LoadFamily = CharStatus[NextCharIndex].PRI.CharacterData.FamilyID;
					`log("CustomChar - Load Assets:"@LoadFamily);

					// During initial character creation, block on loading character packages
					if(!bProcessedInitialCharacters)
					{
						WorldInfo.bRequestedBlockOnAsyncLoading = true;
					}

					CharStatus[NextCharIndex].AssetStore = class'UTCustomChar_Data'.static.LoadFamilyAssets(LoadFamily, FALSE, FALSE);

					if(CharStatus[NextCharIndex].AssetStore != None)
					{
						// Look for others using the same family, and assign same asset
						for(i=0; i<CharStatus.length; i++)
						{
							if((i != NextCharIndex) && CharStatus[i].PRI.CharacterData.FamilyID == LoadFamily)
							{
								CharStatus[i].AssetStore = CharStatus[NextCharIndex].AssetStore;
							}
						}
					}
					else
					{
						// We failed to find any parts, remove this character from the processing set.
						`log("Error loading parts for:"@LoadFamily@" - Aborting.");

						if(CharStatus[NextCharIndex].PRI.IsLocalPlayerPRI())
						{
							CharStatus[NextCharIndex].bNeedsArms = TRUE;
						}
						else
						{
							CharStatus.Remove(NextCharIndex, 1);
						}
					}
				}
				// Arms loading case
				else
				{
					// Invariant : The only thing left in CharStatus now is PRIs in need of arms.

					LoadFamily = CharStatus[0].PRI.CharacterData.FamilyID;
					`log("CustomChar - Load Arms:"@LoadFamily);

					if(!bProcessedInitialCharacters)
					{
						WorldInfo.bRequestedBlockOnAsyncLoading = true;
					}

					// Try loading packages for arms
					CharStatus[0].ArmAssetStore = class'UTCustomChar_Data'.static.LoadFamilyAssets(LoadFamily, FALSE, TRUE);

					// If that failed, load the default arm package
					if(CharStatus[0].ArmAssetStore == None)
					{
						CharStatus[0].ArmAssetStore = class'UTCustomChar_Data'.static.LoadFamilyAssets("", FALSE, TRUE);
						CharStatus[0].bForceFallbackArms = TRUE;
					}
					// If we found the arm package we were looking, look for others using the same family, and assign same asset
					else
					{
						for(i=1; i<CharStatus.length; i++)
						{
							if(CharStatus[i].PRI.CharacterData.FamilyID == LoadFamily)
							{
								CharStatus[i].ArmAssetStore = CharStatus[NextCharIndex].ArmAssetStore;
							}
						}
					}
				}
			}
		}
	}

	// if we're done, clear the timer and tell local PCs
	if (!IsProcessingCharacterData())
	{
		if (bMergeWasPending)
		{
			// do a final GC before we officially finish
			WorldInfo.ForceGarbageCollection();
		}
		else
		{
			ClearTimer('TickCharacterMeshCreation');
			SendCharacterProcessingNotification(false);

			`Log("Finished creating custom characters in "$(WorldInfo.RealTimeSeconds - StartCreateCharTime)$" seconds");

			// see if there are any characters that we skipped that we can fill in with the newly created meshes
			if (!bForceDefaultCharacter)
			{
				for (i = 0; i < PRIArray.length; i++)
				{
					PRI = UTPlayerReplicationInfo(PRIArray[i]);
					if ( PRI != None && PRI.CharacterMesh == None && PRI.CharacterData.FamilyID != "" &&
						PRI.CharacterData.FamilyID != "NONE" && !PRI.IsLocalPlayerPRI() )
					{
						ReplacementUTPRI = FindExistingMeshForFamily(PRI.CharacterData.FamilyID, PRI.GetTeamNum(), PRI);
						if (ReplacementUTPRI != None)
						{
							PRI.SetCharacterMesh(ReplacementUTPRI.CharacterMesh, true);
							PRI.CharPortrait = ReplacementUTPRI.CharPortrait;
						}
					}
				}
			}
		}
	}
}

/**
 * Displays the message of the day by finding a hud and passing off the call.
 */
simulated function DisplayMOTD()
{
	local PlayerController PC;
	local UTPlayerController UTPC;

	return;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		UTPC = UTPlayerController(PC);
		if ( UTPC != none )
		{
			UTHud(UTPC.MyHud).DisplayMOTD();
		}

		break;
	}
}

simulated function PopulateMidGameMenu(UTSimpleMenu Menu)
{
	if ( CanChangeTeam() )
	{
		Menu.AddItem("<Strings:UTGameUI.MidGameMenu.ChangeTeam>",0);
	}

	Menu.AddItem("<Strings:UTGameUI.MidGameMenu.Settings>",1);

	if ( WorldInfo.NetMode == NM_Client )
	{
		Menu.AddItem("<Strings:UTGameUI.MidGameMenu.Reconnect>",2);
	}

	Menu.AddItem("<Strings:UTGameUI.MidGameMenu.LeaveGame>",3);
}

/** Whether a player can change teams or not.  Used by menus and such. */
simulated function bool CanChangeTeam()
{
	if ( GameClass.Default.bTeamGame && !bStoryMode && class<UTDuelGame>(GameClass) == None )
	{
		return true;
	}
	return false;
}

/** hook to allow the GRI to prevent pausing; used when it's performing asynch tasks that must be completed */
simulated function bool PreventPause()
{
	if ( IsProcessingCharacterData() || IsTimerActive('StartProcessingCharacterData') )
	{
		return true;
	}

	return Super.PreventPause();
}

simulated function bool MidMenuMenu(UTPlayerController UTPC, UTSimpleList List, int Index)
{
	//local UTUIScene S;
	switch ( List.List[Index].Tag)
	{
		case 0:
			UTPC.ChangeTeam();
			return true;
			break;

		case 1:
			/*
			S = UTUIScene( List.GetScene() );
			S.GetSceneClient().CloseScene(S);
			UTPC.OpenUIScene(class'UTUIFrontEnd_MainMenu'.default.SettingsScene);
			*/
			break;

		case 2:
			UTPC.ConsoleCommand("Reconnect");
			break;

		case 3:
			UTPC.QuitToMainMenu();
			return true;
			break;
	}


	return false;
}

/** @return whether the given team is Necris (used by e.g. vehicle factories to control whether they can activate for this team) */
simulated function bool IsNecrisTeam(byte TeamNum);


/**
 * In a single player campaign, this function will be called to insure all of
 * the players are properly assigned to a given team.  It insure that the host
 * of the game is assigned to Reaper, and then assigns the other players in order.
 *
 *@Param	PRI		The PRI of the player to Assign a character for
 */


function AssignSinglePlayerCharacters(UTPlayerReplicationInfo PRI)
{
	local int i, CharIndex;
	local UTPlayerController PC;
	local UTPlayerReplicationInfo Chars[4], OtherPRI;
	local CharacterInfo CharInfo;
	local UTBot B;
	local CustomCharData UseCharData;

    // We only do this in story mode

	if ( !bStoryMode )
	{
		return;
	}

	PC = UTPlayerController(PRI.Owner);
	if (PC != None && !PRI.bOnlySpectator)
	{
		if ( PRI.SinglePlayerCharacterIndex >= 0 )
		{
			// We already have an assigned player.  Validate it.
			if (PRI.SinglePlayerCharacterIndex == 0) 	// Reaper
			{
				if ( PC.Player != none && LocalPlayer(PC.Player) != None )
				{
					Chars[0] = PRI;
				}
				else
				{
					// We are not the local host, or there is already local
					// Reaper, so reset this player.
					PRI.SinglePlayerCharacterIndex = -1;
				}
			}
		}

		// figure out who we already have
		for (i = 0; i < PRIArray.length; i++)
		{
			OtherPRI = UTPlayerReplicationInfo(PRIArray[i]);
			if (OtherPRI != None && OtherPRI.SinglePlayerCharacterIndex >= 0)
			{
				if ( OtherPRI != PRI && OtherPRI.SinglePlayerCharacterIndex != PRI.SinglePlayerCharacterIndex &&
					PRI.SinglePlayerCharacterIndex != 0 )
				{
					PRI.SinglePlayerCharacterIndex = -1;
				}
				Chars[OtherPRI.SinglePlayerCharacterIndex] = OtherPRI;
			}
		}

		// At this point, a player is either seeded correctly
		// or waiting for a seed (Index <0).  If needed, seed him now

		if ( PRI.SinglePlayerCharacterIndex < 0 )
		{
			for (i=0;i<4;i++)
			{
				if ( Chars[i] == none )
				{
					PRI.SinglePlayerCharacterIndex = i;
					Chars[i] = PRI;
					break;
				}
			}

		}

		// One final check.  If we get here and the player
		// hasn't been seeded, there are too many players in the game.
		// If this occurs, set them to spectators for now.  The game
		// will attempt to reseed them next map.


		if ( PRI.SinglePlayerCharacterIndex < 0 )
		{
			`log("Server has found an additional Player.  Setting to Spectator!");
			UTGame(WorldInfo.Game).BecomeSpectator(PC);
			return;
		}

		// Set the player's Character

		CharIndex = class'UTCustomChar_Data'.default.Characters.Find('CharName', SinglePlayerBotNames[PRI.SinglePlayerCharacterIndex]);
		CharInfo  = class'UTCustomChar_Data'.default.Characters[CharIndex];

		// If we have no 'based on' char ref, just fill it in with this char. Thing like VoiceClass look at this.
		UseCharData = CharInfo.CharData;
		if(UseCharData.BasedOnCharID == "")
		{
			UseCharData.BasedOnCharID = CharInfo.CharID;
		}

		PRI.SetCharacterData(UseCharData);

		// kick the bot playing this character, if it's present
		foreach WorldInfo.AllControllers(class'UTBot', B)
		{
			if (B.PlayerReplicationInfo.PlayerName ~= SinglePlayerBotNames[PRI.SinglePlayerCharacterIndex])
			{
				B.Destroy();
			}
		}
	}

}

/**
 * Open the mid-game menu
 */
simulated function UTUIScene_MidGameMenu ShowMidGameMenu(UTPlayerController InstigatorPC, optional name TabTag,optional bool bEnableInput)
{
	local UIScene Scene;
	local UTUIScene Template;
	local class<UTGame> UTGameClass;

	if (TabTag == '')
	{
		if (LastUsedMidgameTab != '')
		{
			TabTag = LastUsedMidGameTab;
		}
	}

	if ( CurrentMidGameMenu != none )
	{
		if ( TabTag != '' && TabTag != 'ChatTab' )
		{
//			CurrentMidGameMenu.ActivateTab(TabTag);
		}
		return CurrentMidGameMenu;
	}

	if ( ScoreboardScene != none )	// Force the scoreboards to close
	{
		ShowScores(false, none, none );
	}


	UTGameClass = class<UTGame>(GameClass);
	if (UTGameClass == none)
	{
		return None;
	}

	Template = UTGameClass.Default.MidGameMenuTemplate;

	if ( Template != none )
	{
		Scene = OpenUIScene(InstigatorPC,Template);
		if ( Scene != none )
		{
			CurrentMidGameMenu = UTUIScene_MidGameMenu(Scene);
			ToggleViewingMap(true);

			if (bMatchIsOver)
			{
				CurrentMidGameMenu.TabControl.RemoveTabByTag('SettingsTab');
			}

			if ( TabTag != '' )
			{
				CurrentMidGameMenu.ActivateTab(TabTag);
			}
		}
		else
		{
			`log("ERROR - Could not open the mid-game menu:"@Template);
		}
	}

	if ( CurrentMidGameMenu != none && bEnableInput)
	{
		CurrentMidGameMenu.SetSceneInputMode(INPUTMODE_Free);
	}

	return CurrentMidGameMenu;
}

/**
 * Clean up
 */
function simulated MidGameMenuClosed( )
{
	ToggleViewingMap(false);
	CurrentMidGameMenu = none;
}

function ToggleViewingMap(bool bIsViewing)
{
	local UTPlayerController PC;

	foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
	{
		if ( LocalPlayer(PC.Player) != none )
		{
			PC.ServerViewingMap(bIsViewing);
		}
	}
}

simulated function UIScene OpenUIScene(UTPlayerController InstigatorPC, UIScene Template)
{
	local UIInteraction UIController;
	local LocalPlayer LP;
	local UIScene s;

	// Check all replication conditions

	LP = LocalPlayer(InstigatorPC.Player);
	UIController = LP.ViewportClient.UIController;
	if ( UIController != none )
	{
		UIController.OpenScene(Template,LP,s);
	}

	return S;
}

simulated function ShowScores(bool bShow, UTPlayerController Host, UTUIScene_Scoreboard Template)
{
	local UIScene Scene;

	// Regardless of what's going on, if the mid game menu is up, don't ever show scores
	if ( CurrentMidGameMenu != none )
	{
		bShow = false;
	}

	if ( bShow )
	{
		if (ScoreboardScene == none )
		{
			Scene = OpenUIScene(Host, Template);
			ScoreboardScene = UTUIScene_Scoreboard(Scene);
			ScoreboardScene.Host = Host;
			SetHudShowScores(true);
		}
	}
	else
	{
		if (ScoreboardScene != none && (Host == none || ScoreboardScene.Host == Host) )
		{
			ScoreboardScene.Host = none;
			ScoreboardScene.CloseScene(ScoreboardScene);
			ScoreboardScene = none;
			SetHudShowScores(false);
		}
	}
}

simulated function SetHudShowScores(bool bShow)
{
	local UTPlayerController PC;
	foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
	{
		if ( PC.MyHUD != none )
		{
			PC.MyHud.bShowScores = bShow;
		}
	}
}

function AddGameRule(string Rule)
{
	RulesString $= ((RulesString != "") ? "\n" : "")$Rule;
}

defaultproperties
{
	WeaponBerserk=+1.0
	BotDifficulty=-1
	FlagState[0]=FLAG_Home
	FlagState[1]=FLAG_Home
	TickGroup=TG_PreAsyncWork

	SinglePlayerBotNames(0)="Reaper"
	SinglePlayerBotNames(1)="Othello"
	SinglePlayerBotNames(2)="Bishop"
	SinglePlayerBotNames(3)="Jester"
	bShowMenuOnDeath=false

}
