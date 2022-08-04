/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTMissionSelectionGame extends UTEntryGame
	dependson(UTMissionInfo, UTSeqObj_SPMission);

enum ESinglePlayerMissionResult
{
	ESPMR_None,
	ESPMR_Win,
	ESPMR_Loss
};

var ESinglePlayerMissionResult LastMissionResult;
var string NextMissionURL;
var bool bNextMissionTeamGame;

var UTPlayerController HostPlayer;

var array<string> IronGuardPool;
var array<string> IronGuardEnhancedPool;
var array<string> LiandriPool;
var array<string> LiandriEnhancedPool;

/** This holds the set of bots that have been played from a card **/
var array<string> CardCharacters;

/** This is the set of characters that should always be custom characters **/
var array<string> CharactersThatShouldAlwaysBeCustomCharacters;

/**
 * Figure out if the last match was won or lost
 */
event InitGame( string Options, out string ErrorMessage )
{
	local string InOpt;

	MaxPlayers = GetIntOption(Options, "MaxPlayers", 4);

	GameDifficulty = FMax(0,GetIntOption(Options, "Difficulty", GameDifficulty));

	BroadcastHandler = Spawn(BroadcastHandlerClass);
	if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_DedicatedServer )
	{
		AccessControl = Spawn(AccessControlClass);
	}

	InOpt = ParseOption( Options, "SPResult");
	if ( InOpt != "" )
	{
		LastMissionResult = bool(InOpt) ? ESPMR_Win : ESPMR_Loss;
	}
	else
	{
		LastMissionResult = ESPMR_None;
	}

	InOpt = ParseOption(Options,"SPI");
	if ( InOpt != "" )
	{
		SinglePlayerMissionID = int(InOpt);
	}
	else
	{
		SinglePlayerMissionID = INDEX_NONE;
	}

	// Cache a pointer to the online subsystem
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// And grab one for the game interface since it will be used often
		GameInterface = OnlineSub.GameInterface;
	}
}

function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();

	UTGameReplicationInfo(GameReplicationInfo).bStoryMode = true;
}

/**
 * A new player has joined the server.  Figure out if that player
 * is the host.
 */
event PostLogin( PlayerController NewPlayer )
{
	Super.PostLogin(NewPlayer);
	ManageLogin(NewPlayer);
}

/**
 * A new player has returned to the server via Seamless travel.  We need
 * to determine if they are the host and setup the PRI accordingly
 */
event HandleSeamlessTravelPlayer(out Controller C)
{
	Super.HandleSeamlessTravelPlayer(C);
	if ( PlayerController(C) != none )
	{
		ManageLogin( PlayerController(C) );
	}
	else if ( UTBot(C) != none )
	{
		KillBot( UTBot(C) );
	}
}


function ManageLogin(PlayerController NewPlayer)
{
	local UTMissionSelectionPRI PRI;
	local UTMissionGRI MGRI;

	MGRI= UTMissionGRI(GameReplicationInfo);
	PRI = UTMissionSelectionPRI(NewPlayer.PlayerReplicationInfo);

	if ( MGRI.HostPRI == None && PRI != None && LocalPlayer(NewPlayer.Player) != none )
	{
		PRI.bIsHost = true;
		MGRI.HostPRI = PRI;

		HostPlayer = UTPlayerController(NewPlayer);

		// Yeah - We have a host, initialize the Mission System.

		InitializeMissionSystem(MGRI, NewPlayer);
	}
}

function byte PickTeam(byte num, Controller C)
{
	if (PlayerController(C) != None)
	{
		return 0;
	}
	else
	{
		return Super.PickTeam(num, C);
	}
}

/**
 * Find the current Mission and look to see if we have a forced path.  If we do, server travel
 */
function InitializeMissionSystem(UTMissionGRI MGRI,PlayerController Host)
{
	local UTProfileSettings Profile;
	local int CMID;
	local int CMResult;
	local UTSeqObj_SPMission PreviousMissionObj, MissionObj;
	local int i, NoChildren;
	local EMissionCondition Condition;
	local EMissionInformation Mission;
	local bool bNeedsProfileSaved, bForceSaveProfile;
	local string work;
	local name Card;

//	`log("[SinglePlayer] InitializeMission:"@SinglePlayerMissionID@LastMissionResult);

	if ( Host == none )
	{
		`log("Error: Attempted to Check for Forced Transitions without a host.  This should never happen.");
		return;
	}

	// Save the status to the profile

	Profile = UTProfileSettings( Host.OnlinePlayerData.ProfileProvider.Profile);

	// You always win the first mission
	if (SinglePlayerMissionID == 1)
	{
		LastMissionResult = ESPMR_Win;
	}

	if ( LastMissionResult != ESPMR_Win )	// Rising Sun always continues....
	{
		// Is there a game in progress

		if ( Profile.bGameInProgress() )
		{

//			`log("[SinglePlayer] Reloading last mission");

			Profile.GetCurrentMissionData(CMID, CMResult);
			SinglePlayerMissionID = CMID;
			LastMissionResult = ESinglePlayerMissionResult(CMResult);
		}
		else
		{
//			`log("[SinglePlayer] New Mission");
			SinglePlayerMissionID = 0;
			LastMissionResult = ESPMR_None;
		}

	}
	else	// Continuing this session
	{

		Card = UTGameUISceneClient(class'UIRoot'.static.GetSceneClient()).LastModifierCardUsed;
		if (Card != '')
		{

			// If we have a modifier card in play, clear it here
			HostPlayer.UseModifierCard(Card);
		}

		CMResult = INT(LastMissionResult);
		Profile.SetCurrentMissionData( SinglePlayerMissionID, CMResult);
		bNeedsProfileSaved = true;
		CMID = SinglePlayerMissionID;

//		`log("[SinglePlayer] Continuing to next mission");


	}

	// Look at all of the available missions for the last mission and fill out the GRI's array.
	// Also, check for CutSequences and Automatic Transitions here

	PreviousMissionObj = MGRI.GetMissionObj(CMID);

	if ( PreviousMissionObj != none )
	{
		// Mark the mission's as being visited

		if ( MGRI.GetMission(PreviousMissionObj.MissionID, Mission) )
		{
			Profile.BoneHasBeenVisited(Mission.GlobeBoneName);
			bNeedsProfileSaved = true;

			// If this was any of the containment maps, flag it

		    if ( InStr(Mission.Map,"Containment") > INDEX_None || PreviousMissionObj.MissionID == 33 || PreviousMissionObj.MissionID == 143)
	        {
	        	Profile.AddPersistentKey(ESPKey_DarkWalkerUnlock);
	        	Profile.AddPersistentKey(ESPKey_CanStealNecris);
				bForceSaveProfile = true;
	        }
		}

		// If we aren't a cutsequence or the first mission, we need to save the profile for the the mission progress
		if (bForceSaveProfile || (!PreviousMissionObj.bCutSequence && PreviousMissionObj.MissionID != 0) )
		{
			Profile.BoneHasBeenVisited(Mission.GlobeBoneName);
			bNeedsProfileSaved = true;
		}
		else
		{	// Otherwise don't save the profile
			bNeedsProfileSaved = false;
		}

		// We have to subtract 1 from UnlockChapterIndex because Jim used 1-X instead of 0-X.
		// This is also done in Profile.UnlockChapter

		// Look to see if we need to unlock a chapter
		if ( LastMissionResult == ESPMR_Win && PreviousMissionObj.bUnlockChapterWhenCompleted )
		{
			Profile.UnlockChapter(PreviousMissionObj.UnlockChapterIndex);

			work = Localize("Campaign","Chapter"$PreviousMissionObj.UnlockChapterIndex-1$"Unlock","UTGameUI");
			class'UTUIScene'.static.ShowOnlineToast(Work);
			bNeedsProfileSaved = true;
		}

		// Look to see if we should be clearing the cards

		if ( PreviousMissionObj.bClearCards )
		{
			Profile.ClearModifierCards();
			bNeedsProfileSaved = true;
		}


		NoChildren = PreviousMissionObj.NumChildren();
		for (i = 0; i < NoChildren; i++)
		{
			MissionObj = PreviousMissionObj.GetChild(i,Condition);

			if ( CheckMission(Profile, LastMissionResult, Condition) )
			{

				// Check to see if we should auto-forward

				if ( MGRI.GetMission(MissionObj.MissionID, Mission) )
				{
					if ( MissionObj.bCutSequence )
					{
						HandleCutSequence(Mission, MissionObj);

						if (bNeedsProfileSaved)
						{
							SaveProfile(Host);
						}

						return;
					}

					if ( MissionObj.bAutomaticTransition )
					{

						if (Mission.MissionID == 149)
						{
							ShowCredits();
						}
						else
						{
							HandleForcedTravel(Mission.MissionID);

							if (bNeedsProfileSaved)
							{
								SaveProfile(Host);
							}
						}

						return;
					}
					// Add to the Available Missions List
					MGRI.AddAvailableMission(Mission);
				}

			}
		}
	}

	MGRI.LastMissionResult = LastMissionResult;
	MGRI.LastMissionID = SinglePlayerMissionID;
	MGRI.HostChapterMask = Profile.GetChapterMask();

	// Open up the selection menu
	MGRI.ChangeMenuState(EMS_Selection);

	// Tell everyone which mission to select
	MGRI.ChangeMission(MGRI.AvailMissionList[0].MissionID);

	if (bNeedsProfileSaved)
	{
		SaveProfile(Host);
	}

	Profile.GetBoneMask(MGRI.BoneMask.A, MGRI.BoneMask.B);
	MGRI.ReplicatedEvent('BoneMask');


}

function SaveProfile(PlayerController TargetPC)
{
	UTPlayerController(TargetPC).SaveProfile();
}

/**
 * Checks to see if a mission can be added to the mission list
 *
 * @param Profile		The profile we are using
 * @param Result		The result of the last match
 * @param Condition 	The conditions to check against
 *
 * @returns true if this mission is good to go
 */
function bool CheckMission(UTProfileSettings Profile, ESinglePlayerMissionResult Result, EMissionCondition Condition)
{
	local int i;
	// Quick Win/Lost Short Circuit
	if ( (Condition.MissionResult == EMResult_Won && Result != ESPMR_Win) ||
		(Condition.MissionResult == EMResult_Lost && Result != ESPMR_Loss) )
	{
		return false;
	}

	// Check for any required persistent keys
	for (i=0;i<Condition.RequiredPersistentKeys.Length;i++)
	{
		if ( !Profile.HasPersistentKey(Condition.RequiredPersistentKeys[i]) )
		{
			return false;
		}
	}

	// Check to see if we are restricted by a persistent key
	for (i=0;i<Condition.RequiredPersistentKeys.Length;i++)
	{
		if ( Profile.HasPersistentKey(Condition.RestrictedPersistentKeys[i]) )
		{
			return false;
		}
	}

	// This mission is ok

	return true;
}


/**
 * Travel to a cut sequence
 */

function HandleCutSequence(EMissionInformation Mission, UTSeqObj_SPMission MissionObj)
{
	local string URL;
	local UTMissionGRI MissionGRI;

	MissionGRI = UTMissionGRI(GameReplicationInfo);

	if ( MissionObj.bIsBinkSequence )
	{
//		`log("[SinglePlayer] Executing a BINK cut sequence ("$Mission.Map$")");

		MissionGRI.CurrentMissionID = Mission.MissionID;
		MissionGRI.PlayBinkMission = Mission.MissionID;
		MissionGRI.ReplicatedEvent('PlayBinkMission');	// Fake replication on listen server hosts
		MissionGRI.OnBinkMovieFinished = BinkMovieFinished;
	}
	else
	{
//		`log("[SinglePlayer] Executing a in-game cut sequence @"@WorldInfo.TimeSeconds);
		URL = Mission.Map $ Mission.URL $ "?SPI="$Mission.MissionID;
		WorldInfo.ServerTravel(URL);
	}
}

function BinkMovieFinished()
{
	local UTMissionGRI MissionGRI;

//	`log("[SinglePlayer] Bink movie finished @"@WorldInfo.TimeSeconds@"continuing Re-initializing Mission System");

	MissionGRI = UTMissionGRI(GameReplicationInfo);
	MissionGRI.PlayBinkMission = -1;
	LastMissionResult = ESPMR_WIN;
	SinglePlayerMissionID = MissionGRI.CurrentMissionID;
	InitializeMissionSystem(MissionGRI, HostPlayer);
}

/**
 * Create the URL and travel to a given mission.
 */
function HandleForcedTravel(int MissionID)
{
	local EMissionInformation Mission;
	UTMissionGRI(GameReplicationInfo).CurrentMissionID = MissionID;
	UTMissionGRI(GameReplicationInfo).GetCurrentMission(Mission);
//	`log("[SinglePlayer] Force Travel to :"@MissionId@Mission.MissionId@Mission.Map);
	AcceptMission();
}




function BriefMission()
{
	local UTMissionGRI MGRI;
	MGRI = UTMissionGRI(GameReplicationInfo);
	MGRI.ChangeMenuState(EMS_Brief);
}

/**
 * The host has accepted a mission.  Signal the clients to travel and wait for
 * them to sync up.
 */

function AcceptMission()
{
	local UTMissionGRI MGRI;
	local string URL, GameType;
	local EMissionInformation Mission;
	local int i;
	local UTPlayerController PC;
	local UTProfileSettings Profile;
	local UTBot B;

	// Log any bots still hanging around
	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		`Warn("BOT STILL AROUND!" @ B.PlayerReplicationInfo.PlayerName @ B);
		//@hack: pretty sure the right fix is to prevent Logout() from adding a bot to replace an exiting human
		//	when we haven't accepted the mission yet, but this is a safer fix at this point
		B.Destroy();
	}

	MGRI = UTMissionGRI(GameReplicationInfo);
	if ( MGRI != none && MGRI.GetCurrentMission(Mission) )
	{

		UTGameUISceneClient(class'UIRoot'.static.GetSceneClient()).MissionText = " DEBUG Prev. MissionID: "$SinglePlayerMissionID$" \n DEBUG MissionID: "$Mission.MissionID$" \n\ "$Mission.BriefingText;

		GameType = ParseOption(Mission.URL, "game");
		// default to Team DM if no gametype specified for DM maps
		if (GameType == "" && Left(Mission.Map, 3) ~= "DM-")
		{
			Mission.URL $= "?game=UTGame.UTTeamGame";
			bNextMissionTeamGame = true;
		}
		else
		{
			//@hack: we can't load the game class on console, so assume deathmatch is the only FFA type
			bNextMissionTeamGame = !(GameType ~= "utgame.utdeathmatch");
		}

		Profile = UTProfileSettings( HostPlayer.OnlinePlayerData.ProfileProvider.Profile );

		// Always read the skill level from the profile....
		GameDifficulty = Profile.GetCampaignSkillLevel() * 2;

		URL = Mission.Map $ Mission.URL $ "?SPI="$Mission.MissionID$"?PlayersMustBeReady=1?Difficulty="$GameDifficulty$"?MaxPlayers="$MaxPlayers;
		if (InStr(Caps(URL), "?TIMELIMIT=") == INDEX_NONE)
		{
			URL $= "?TimeLimit=20";
		}

		if ( Profile == none  || !Profile.HasPersistentKey(ESPKey_CanStealNecris) )
		{
			URL $= "?NecrisLocked=1";
		}

		if (HostPlayer != None)
		{

			if ( Mission.MissionID == 149 )	// We won, clear out the mission data in the profile.
			{
				Profile.SetCurrentMissionData(INDEX_None, INDEX_None);
			}


			if (MGRI.GameModifierCard != '')
			{
				ProcessModifierCard(MGRI.GameModifierCard, Profile, URL, Mission);
			}

			// Clear Any Must use cards
			for (i=0;i<class'UTGameModifierCard'.default.Deck.Length; i++)
			{
				if (class'UTGameModifierCard'.default.Deck[i].bMustUse)
				{
					HostPlayer.UseModifierCard(class'UTGameModifierCard'.default.Deck[i].Tag);
				}
			}
		}

		// we need to call this twice so we first add all of the characters that must have customized meshes and then with everyone else
		AddBotsFromMissionData( Mission, TRUE );
		AddBotsFromMissionData( Mission, FALSE );

		// make sure all the humans are on the correct team
		foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
		{
			SetTeam(PC, bNextMissionTeamGame ? Teams[0] : None, false);
		}

		NextMissionURL = URL;
		MGRI.ChangeMenuState(EMS_Launch);
		GotoState('SyncClients');
	}
	else
	{
		`log("Warning: The Single Play game could not accept a mission.");
	}
}

/** This will look down the list of chars that should always be custom and then return true of the passed in string is in that list **/
function bool IsACharacterThatShouldAlwaysBeCustom( string CharName )
{
	local bool Retval;
	local int i;

	for( i = 0; i < CharactersThatShouldAlwaysBeCustomCharacters.length; ++i )
	{
		if( CharactersThatShouldAlwaysBeCustomCharacters[i] == CharName )
		{
			Retval = TRUE;
			break;
		}
	}

	return Retval;
}

/**
 * This function is called when we are adding a character to the game.  It is meant to be called twice.  The first time
 * with bAddOnlyCustomizedCharacters being TRUE so all of the characters that we want customized will actually be that way.
 * And then with bAddOnlyCustomizedCharacters FALSE so we add all of the other characters into the world.
 *
 * The mission data has a number of ways in which it organizes that data so we need to do two passes over that data in order
 * to make certain that we get the most optimal set of customized characters.
 *
 * NOTE: this will just order the list with the "important to be customized" first.  Machine settings could make it such that
 * only a subset actually get customized characters or that all of them do!
 *
 **/
function AddBotsFromMissionData( EMissionInformation Mission, bool bAddOnlyCustomizedCharacters )
{
	local int i;
	local UTBot B;

	// add any card characters first as they are important!
	for (i = 0; i < CardCharacters.length; i++)
	{
		if( IsACharacterThatShouldAlwaysBeCustom( CardCharacters[i] ) == bAddOnlyCustomizedCharacters )
		{
			SinglePlayerAddBot(CardCharacters[i], true, 0);
		}
	}

	// spawn the bots in advance, so the custom mesh construction takes place while traveling
	for (i = 0; i < Mission.RequiredTeammates.length; i++)
	{
		if( IsACharacterThatShouldAlwaysBeCustom( Mission.RequiredTeammates[i] ) == bAddOnlyCustomizedCharacters )
		{
			SinglePlayerAddBot(Mission.RequiredTeammates[i], true, 0);
		}
	}

	for (i = 0; i < Mission.RequiredOpponents.length; i++)
	{
		if( IsACharacterThatShouldAlwaysBeCustom( Mission.RequiredOpponents[i] ) == bAddOnlyCustomizedCharacters )
		{
			SinglePlayerAddBot(Mission.RequiredOpponents[i], true, 1);
		}
	}

	for (i = 0; i < Mission.PrecachedTeammates.length; i++)
	{
		if( IsACharacterThatShouldAlwaysBeCustom( Mission.PrecachedTeammates[i] ) == bAddOnlyCustomizedCharacters )
		{
			B = SinglePlayerAddBot(Mission.PrecachedTeammates[i], true, 0);
			if (B != None)
			{
				UTPlayerReplicationInfo(B.PlayerReplicationInfo).bPrecachedBot = true;
			}
		}
	}

	for (i = 0; i < Mission.PrecachedOpponents.length; i++)
	{
		if( IsACharacterThatShouldAlwaysBeCustom( Mission.PrecachedOpponents[i] ) == bAddOnlyCustomizedCharacters )
		{
			B = SinglePlayerAddBot(Mission.PrecachedOpponents[i], true, 1);
			if (B != None)
			{
				UTPlayerReplicationInfo(B.PlayerReplicationInfo).bPrecachedBot = true;
			}
		}
	}
}


function ProcessModifierCard(name GameModifierCard, UTProfileSettings Profile, out string URL, out EMissionInformation Mission)
{
	local int i,j,r, OldNum, RemoveCount;
	local array<string> Pool;

	URL = URL$Class'UTGameModifierCard'.static.GetURL(GameModifierCard);

	CardCharacters.Length = 0; // reset the CardCharacters

	if ( GameModifierCard == 'IronGuard' )
	{
		if ( Profile.HasPersistentKey( class'UTGameModifierCard'.static.GetAltKey(GameModifierCard)) )
		{
			i = CardCharacters.Length;
			CardCharacters.Length = i + 2;

			CardCharacters[i] = "Lauren";
			j = Rand(IronGuardEnhancedPool.Length);
			CardCharacters[i+1] = IronGuardEnhancedPool[j];
		}
		else
		{
			i = CardCharacters.Length;
			CardCharacters.Length = i + 2;
			for (j=0;j<2;j++)
			{
				r = Rand(IronGuardPool.Length);
				CardCharacters[i+j] = IronGuardPool[r];
				IronGuardPool.Remove(r,1);
			}
		}
	}
	else if ( GameModifierCard == 'Liandri' )
	{
		Pool = Profile.HasPersistentKey(class'UTGameModifierCard'.static.GetAltKey(GameModifierCard)) ? LiandriEnhancedPool : LiandriPool;

		// first, try to pick random characters and only choose those not already in the mission
		i = CardCharacters.Length;
		CardCharacters.Length = i + 2;
		while (i < CardCharacters.length && Pool.length > 0)
		{
			r = Rand(Pool.length);
			if (Mission.RequiredOpponents.Find(Pool[r]) == INDEX_NONE && Mission.PrecachedOpponents.Find(Pool[r]) == INDEX_NONE)
			{
				CardCharacters[i] = Pool[r];
				i++;
			}
			Pool.Remove(r, 1);
		}

		if (i < CardCharacters.length)
		{
			// now just pick in order and don't care about duplicates
			Pool = Profile.HasPersistentKey(class'UTGameModifierCard'.static.GetAltKey(GameModifierCard)) ? LiandriEnhancedPool : LiandriPool;
			for (r = 0; r < Pool.length && i < CardCharacters.length; r++)
			{
				if (CardCharacters.Find(Pool[r]) == INDEX_NONE)
				{
					CardCharacters[i] = Pool[r];
					i++;
				}
			}
		}
	}
	else if (GameModifierCard == 'TacticalDiversion')
	{
		if ( Mission.RequiredOpponents.length <= Mission.RequiredTeammates.length + 1 )
			RemoveCount = Min(1, Mission.RequiredOpponents.length - 1);
		else
		RemoveCount = Min(2, Mission.RequiredOpponents.length - 1);
		if (RemoveCount > 0)
		{
			Mission.RequiredOpponents.Remove(Mission.RequiredOpponents.length - RemoveCount, RemoveCount);
		}
		else
		{
			RemoveCount = 0;
		}
		// also update the URL's number of players
		i = InStr(Caps(URL), "?NUMPLAY=");
		if (i != INDEX_NONE)
		{
			// we have to strip out the mapname for GetIntOption() to work
			OldNum = GetIntOption(Right(URL, Len(URL) - InStr(URL, "?")), "numplay", 0);

			URL = Left(URL, i) $ "?numplay=" $ (OldNum - RemoveCount) $ Right(URL, Len(URL) - i - 9 - ((OldNum >= 10) ? 2 : 1));
			if (RemoveCount < 2)
			{
				URL $= "?diverted=" $ (2 - RemoveCount);
			}
		}
	}


	UTGameUISceneClient(class'UIRoot'.static.GetSceneClient()).LastModifierCardUsed = GameModifierCard;
}


function UTTeamInfo GetBotTeam(optional int TeamBots, optional bool bUseTeamIndex, optional int TeamIndex)
{
	if (bNextMissionTeamGame)
	{
		return Super.GetBotTeam(TeamBots, bUseTeamIndex, TeamIndex);
	}
	else
	{
		EnemyRosterName = "UTGame.UTDMRoster";
		return Super(UTGame).GetBotTeam(TeamBots, bUseTeamIndex, TeamIndex);
	}
}

function UTBot AddBot(optional string BotName, optional bool bUseTeamIndex, optional int TeamIndex)
{
	local UTBot B;

	B = Super.AddBot(BotName, bUseTeamIndex, TeamIndex);
	if (B != None)
	{
		B.GotoState('RoundEnded');
	}

	return B;
}

/**
 * We need to give clients time to bring the briefing menu up and become ready to travel.  We do
 * this by pausing here and waiting for bReadyToPlay to be set for each player
 */
state SyncClients
{
	// Check ready status 4x a second
	function BeginState(name PrevStateName)
	{
		Super.BeginState(PrevStateName);
		SetTimer(0.25, true);
		SetTimer(5.0, false, 'GiveUpWaiting');
	}

	// Look at the PRI list and see if anyone still isn't ready.
	function Timer()
	{
		local int i;
		local bool bReadyToGo;
		local PlayerReplicationInfo PRI;

		bReadyToGo = true;
		for (i=0;i<GameReplicationInfo.PRIArray.Length;i++)
		{
			PRI = GameReplicationInfo.PRIArray[i];
			if ( !PRI.bOnlySpectator && !PRI.bReadyToPlay && !PRI.bBot)
			{
				bReadyToGo = false;
			}
		}

		if (bReadyToGo)
		{
			ClearTimer();
			ClearTimer('GiveUpWaiting');
			WorldInfo.ServerTravel(NextMissionURL,true);
		}
	}

	function GiveUpWaiting()
	{
		ClearTimer();
		WorldInfo.ServerTravel(NextMissionURL, true);
	}
}

function SetModifierCard(name Card)
{
	UTMissionGRI(GameReplicationInfo).SetModifierCard(Card);
}

function bool TooManyBots(Controller botToRemove)
{
	return false;
}

function bool NeedPlayers()
{
	return false;
}

auto State PendingMatch
{
	function bool MatchIsInProgress()
	{
		return false;
	}

	/**
	 * Tells all of the currently connected clients to register with arbitration.
	 * The clients will call back to the server once they have done so, which
	 * will tell this state to see if it is time for the server to register with
	 * arbitration.
	 */
	function StartMatch()
	{
		return;
	}
}

function ShowCredits()
{
	WorldInfo.ServerTravel("UTCin-UT3Credits",true);
}


DefaultProperties
{
	PlayerReplicationInfoClass=class'UTMissionSelectionPRI'
	GameReplicationInfoClass=class'UTMissionGRI'

	PlayerControllerClass=class'UTGame.UTMissionPlayerController'
	ConsolePlayerControllerClass=class'UTGame.UTMissionPlayerController'
	HUDType=none

	IronGuardPool=("Cain","Blackjack","Johnson","Kregore","Talan")
	IronGuardEnhancedPool=("Barktooth","Harlin","Slain","Blain")
	LiandriPool=("Torque","Syntax","Raptor","Mihr")
	LiandriEnhancedPool=("Matrix","Aspect","Cathode","Enigma")

	// this could be moved to the CustomChar data to say they are important
	CharactersThatShouldAlwaysBeCustomCharacters=("Reaper","Jester","Othello","Bishop","Lauren","Akasha","Loque","Matrix","Scythe","Alanna","Arachne","Ariel","Avalon","Cassidy","Desiree","Freylis","Kai","Kira","Malise","Metridia","Raven","Visse")
}


