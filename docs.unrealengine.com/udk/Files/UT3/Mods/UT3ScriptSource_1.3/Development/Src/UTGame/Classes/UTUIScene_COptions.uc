/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_COptions extends UTUIFrontEnd
	config(Game);

var transient UILabel MenuLabel;
var transient UILabel SkillDesc;
var transient UIPanel LanGamePanel;
var transient UICheckBox SkillLevels[4];
var transient UICheckBox LanPlay;


var transient bool bNetworkOk;
var transient bool bNewGame;

/** Reference to the settings datastore that we will use to create the game. */
var transient UIDataStore_OnlineGameSettings	SettingsDataStore;

var localized string SkillDescriptions[4];

var transient string LaunchURL;

var transient bool bWasPublic;

var transient int ChapterToLoad;

var transient bool bIgnoreChange;

var string ChapterURLs[5];


event PostInitialize( )
{
	local int i;

    bNetworkOk = HasLinkConnection();

	`log("[Network]"@bNetworkOK ? "Network Is Available" : "Network is not Available");

	Super.PostInitialize();

	for (i=0;i<4;i++)
	{
		SkillLevels[i] = UICheckBox( FindChild( name("Check"$i), true));
		SkillLevels[i].OnValueChanged = SkillLevelChanged;
	}

	SettingsDataStore = UIDataStore_OnlineGameSettings(FindDataStore('UTGameSettings'));
	SkillDesc = UILabel(FindChild('Description',true));
	LanGamePanel = UIPanel(FindChild('LanGamePanel',true));
	LanPlay = UICheckBox( FindChild('LanPlay',true));

	MenuLabel = UILabel(FindChild('Title',true));

	// this used to be set here, so we'll need to clear it in case it got serialized
	OnPreRenderCallback=None;
}

/**
 * Handler for the 'show' animation completed.
 */
function OnMainRegion_Show_UIAnimEnd( UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq )
{
	Super.OnMainRegion_Show_UIAnimEnd(AnimTarget, AnimIndex, AnimSeq);

	if ( AnimTarget.AnimStack[AnimIndex].SeqRef.SeqName == 'SceneShowInitial' )
	{
		// make sure we can't choose "internet" if we aren't signed in online
		ValidateServerType();
	}
}

/**
 * Enables / disables the "server type" control based on whether we are signed in online.
 */
function ValidateServerType()
{
	local int PlayerIndex, PlayerControllerID;
	local string OnlineProfileRequiredMessage;

	OnlineProfileRequiredMessage = "<Strings:UTGameUI.Errors.OnlineRequiredForInternet_Message>";

	// find the "MatchType" control (contains the "LAN" and "Internet" options);  if we aren't signed in online,
	// don't have a link connection, or not allowed to play online, don't allow them to select one.
	PlayerIndex = GetPlayerIndex();
	PlayerControllerID = GetPlayerControllerId( PlayerIndex );

	if (!CheckLoginAndError(PlayerControllerID,true,,OnlineProfileRequiredMessage) || !CheckOnlinePrivilegeAndError( PlayerControllerID ) )
	{
		if ( LanPlay != None )
		{
			// check the lan checkbox
			LanPlay.SetValue(true, PlayerIndex);

			// now disable it
			LanPlay.DisableWidget(PlayerIndex);
		}

		if ( LanGamePanel != None )
		{
			LanGamePanel.DisableWidget(PlayerIndex);
		}
	}
	else
	{
		CheckNatTypeAndDisplayError(PlayerControllerID);
	}
}

/** Callback for when the login changes after showing the login UI. */
function OnLoginUI_LoginChange()
{
	local int PlayerIndex, PlayerControllerId;
	local bool bCanPlayOnline;
	local UIPanel SkillContainerPanel;

	PlayerIndex = GetPlayerIndex();
	PlayerControllerID = GetPlayerControllerId( PlayerIndex );

	if ( IsLoggedIn(PlayerControllerId, true) )
	{
		// we just connected to the online service
		// check online parental restrictions and NAT settings
		bCanPlayOnline = CanPlayOnline(PlayerControllerId) && GetNATType() < NAT_Strict;
		if ( bCanPlayOnline )
		{
			if ( LanPlay != None )
			{
				LanPlay.EnableWidget(PlayerIndex);
			}

			if ( LanGamePanel != None )
			{
				LanGamePanel.EnableWidget(PlayerIndex);
			}
		}
	}

	if ( !bCanPlayOnline )
	{
		if ( LanPlay != None )
		{
			if ( LanPlay.IsFocused(PlayerIndex) )
			{
				SkillContainerPanel = UIPanel(FindChild('OptionPanel', true));
				SkillContainerPanel.SetFocus(None, PlayerIndex);
			}

			// check the lan checkbox
			LanPlay.SetValue(true, PlayerIndex);

			// now disable it
			LanPlay.DisableWidget(PlayerIndex);
		}

		if ( LanGamePanel != None )
		{
			LanGamePanel.DisableWidget(PlayerIndex);
		}
	}

	Super.OnLoginUI_LoginChange();
}

function SkillLevelChanged( UIObject Sender, int PlayerIndex )
{
	local int i;
	local UTProfileSettings Profile;

	Profile = GetPlayerProfile();

	if (!bIgnoreChange)
	{
		bIgnoreChange = true;
		for (i=0;i<4;i++)
		{
			if ( SkillLevels[i] == Sender )
			{
				SkillLevels[i].SetValue(true);
				SkillDesc.SetValue(SkillDescriptions[i]);
				Profile.SetCampaignSkillLevel(i);
			}
			else
			{
				SkillLevels[i].SetValue(false);
			}
		}
		bIgnoreChange = false;
	}
}

function bool AllowInternetPlay()
{
//	local OnlineSubsystem OnlineSub;
	local LocalPlayer LP;

	// Check NAT.  If we are behind a strict nat, disable internet play
/*
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if ( OnlineSub != None && OnlineSub.SystemInterface.GetNATType() >= NAT_Strict )
	{
    	return false;
    }
*/
	LP = GetPlayerOwner();

	if ( LP == None )
	{
		return false;
	}
	if ( !IsLoggedIn(LP.ControllerID,true) )
	{
		`log("[Network] Not Logged in!");
		return false;
	}

	if (!CanPlayOnline(LP.ControllerID) )
	{
		`log("[Netowrk] User Is Restricted from Online");
		return false;
	}

	return true;
}


/** Sets up the button bar for the scene. */
function SetupButtonBar()
{

	if(ButtonBar != None)
	{
		ButtonBar.Clear();
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);

		if ( bNetworkOk )
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.StartPrivateGame>", OnButtonBar_Start);
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.StartPublicGame>", OnButtonBar_StartPublic);
		}
		else
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.StartGame>", OnButtonBar_Start);
		}

		if (!IsConsole())
		{
			ButtonBar.Buttons[1].SetFocus(none);
		}
	}
}

function Configure(bool bIsNewGame, int InChapterToLoad)
{
	local UTProfileSettings Profile;
	local int Skill;
	local string s;

	bNewGame = bIsNewGame;

	s = "[<Strings:UTGameUI.Campaign.CampaignOptionsPrefix>" @ (bIsNewGame ? "<Strings:UTGameUI.Campaign.CampaignTitleA>]" : "<Strings:UTGameUI.Campaign.CampaignTitleB>]");
    GetTitleLabel().SetDataStoreBinding(Caps(s));

	Profile = GetPlayerProfile();
	if ( bIsNewGame )
	{
		if ( Profile != none )
		{
			Profile.NewGame();
		}
	}

	Skill = Profile.GetCampaignSkillLevel();
	SkillLevels[Skill].SetValue( true );

	ChapterToLoad = InChapterToLoad;
}

function bool OnButtonBar_Start(UIScreenObject InButton, int InPlayerIndex)
{
	StartGame(InPlayerIndex, false);
	return true;
}

function bool OnButtonBar_StartPublic(UIScreenObject InButton, int InPlayerIndex)
{
	StartGame(InPlayerIndex, true);
	return true;
}

`define MaxCampaignPlayers 4

function StartGame(int InPlayerIndex, bool bPublic)
{
	local UTProfileSettings Profile;
	local int Skill;
	local bool bInternetAllowed;

	Profile = GetPlayerProfile();
	if ( Profile != none )
	{
		Skill = Profile.GetCampaignSkillLevel();
		SavePlayerProfile(0);
	}

	Skill *= 2;

	if (ChapterToLoad != INDEX_None)
	{
		LaunchURL = "open "$ChapterURLs[ChapterToLoad]$"?Difficulty="$Skill$"?MaxPlayers=" $ `MaxCampaignPlayers;
	}
	else
	{
		if ( bNewGame )
		{
			LaunchURL = "open UTM-MissionSelection?SPI=0?SPResult=1?Difficulty="$Skill$"?MaxPlayers=" $ `MaxCampaignPlayers;
		}
		else
		{
			LaunchURL = "open UTM-MissionSelection?Difficulty="$Skill$"?MaxPlayers=" $ `MaxCampaignPlayers;
		}
	}

	bWasPublic = bPublic;

	if ( bNetworkOk )
	{
		LaunchURL $= "?Listen";

		// We have a profile, see if we can play on the net....
		bInternetAllowed = AllowInternetPlay();
		if ( LanPlay.IsChecked() || bInternetAllowed )
		{
			CreateOnlineGame(InPlayerIndex, bPublic, LanPlay.IsChecked() || !bInternetAllowed);
		}
		else
		{
			ShowOnlinePrivilegeError();
		}
	}
	else
	{
		ConsoleCommand(LaunchURL);
	}
}

function ShowOnlinePrivilegeError()
{
	DisplayMessageBox("<Strings:UTGameUI.Errors.CampaignOnlineFailure>","<Strings:UTGameUI.Errors.CampaignOnlineFailure_Title>");
	GetMessageBoxScene().OnClosed = MessageBoxClosed;
}

function MessageBoxClosed()
{
	CreateOnlineGame(0, bWasPublic, true);
}


/************************ Online Game Interface **************************/

/** Creates the online game and travels to the map we are hosting a server on. */
function CreateOnlineGame(int PlayerIndex, bool bPublic, bool bIsLanMatch)
{
	local OnlineSubsystem OnlineSub;
	local OnlineGameInterface GameInterface;
	local OnlineGameSettings GameSettings;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the game interface to verify the subsystem supports it
		GameInterface = OnlineSub.GameInterface;
		if (GameInterface != None)
		{
			// Play the startgame sound
			PlayUISound('StartGame');

			// Setup server options based on server type.
			SettingsDataStore.SetCurrentByName('UTGameSettingsCampaign');
			GameSettings = SettingsDataStore.GetCurrentGameSettings();

			`log("Starting a Campaign --- ");

			GameSettings.bUsesArbitration=false;				`log("   bUseArbitration:"@GameSettings.bUsesArbitration);
			GameSettings.bAllowJoinInProgress = true;			`log("   bAllowJoinInProgress:"@GameSettings.bAllowJoinInProgress);
			GameSettings.bAllowInvites = true;					`log("   bAllowInvites:"@GameSettings.bAllowInvites);
			GameSettings.bIsLanMatch=bIsLanMatch;				`log("   bIsLanMatch:"@GameSettings.bIsLanMatch);

			if (bPublic)
			{
				GameSettings.NumPrivateConnections = 0;
				GameSettings.NumPublicConnections = 4;
				GameSettings.bShouldAdvertise = true;
			}
			else
			{
				GameSettings.NumPrivateConnections = 4;
				GameSettings.NumPublicConnections = 0;
				GameSettings.bShouldAdvertise = false;
			}

			`log("   bShouldAdvertise:"@GameSettings.bShouldAdvertise);
			`log("   NumPrivateConnections"@GameSettings.NumPrivateConnections);
			`log("   NumPublicConnections"@GameSettings.NumPublicConnections);

			// Create the online game
			GameInterface.AddCreateOnlineGameCompleteDelegate(OnGameCreated);

			if(SettingsDataStore.CreateGame(GetPlayerControllerId(PlayerIndex))==false)
			{
				GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
				`Log("UTUIScene_COption::CreateOnlineGame - Failed to create online game.");
			}
		}
		else
		{
			`Log("UTUIScene_COption::CreateOnlineGame - No GameInterface found.");
		}
	}
	else
	{
		`Log("UTUIScene_COption::CreateOnlineGame - No OnlineSubSystem found.");
	}
}

/** Callback for when the game is finish being created. */
function OnGameCreated(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;
	local OnlineGameInterface GameInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the game interface to verify the subsystem supports it
		GameInterface = OnlineSub.GameInterface;
		if (GameInterface != None)
		{
			// Clear the delegate we set.
			GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);

			// If we were successful, then travel.
			if(bWasSuccessful)
			{
				ConsoleCommand(LaunchURL);
			}
			else
			{
				`Log("UTUIScene_COption::OnGameCreated - Game Creation Failed.");
			}
		}
		else
		{
			`Log("UTUIScene_COption::OnGameCreated - No GameInterface found.");
		}
	}
	else
	{
		`Log("UTUIScene_COption::OnGameCreated - No OnlineSubSystem found.");
	}
}



/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	if(EventParms.InputKeyName=='XboxTypeS_Y')
	{
		if (EventParms.EventType==IE_Released)
		{
			StartGame(EventParms.PlayerIndex,false);
		}
		return true;
	}

	if( EventParms.InputKeyName=='XboxTypeS_X' && bNetworkOk )
	{
		if (EventParms.EventType==IE_Released)
		{
			StartGame(EventParms.PlayerIndex,true);
		}
		return true;
	}

	if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
	{
		if (EventParms.EventType==IE_Released)
		{
			OnBack();
		}
		return true;
	}

	return Super.HandleInputKey(EventParms);
}


/** Buttonbar Callbacks. */
function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	OnBack();

	return true;
}

/** Callback for when the user wants to exit the scene. */
function OnBack()
{
	CloseScene(self);
}


defaultproperties
{
	ChapterURLs(0)="UTM-MissionSelection?SPI=0?SPResult=1"
	ChapterURLs(1)="UTM-MissionSelection?SPI=1?SPResult=1"
	ChapterURLs(2)="UTM-MissionSelection?SPI=15?SPResult=1"
	ChapterURLs(3)="UTM-MissionSelection?SPI=24?SPResult=1"
	ChapterURLs(4)="UTM-MissionSelection?SPI=33?SPResult=1"
}
