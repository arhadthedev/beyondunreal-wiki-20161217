/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_MidGameMenu extends UTUIScene_Hud
	dependson(UTUIScene_MessageBox)
	native(UI);

var transient UTUIButtonBar	ButtonBar;
var transient UTUITabControl TabControl;
var transient UTVoteReplicationInfo VoteRI;
var transient UILabel MapVoteClock;
var transient UIPanel LoadingPanel;
var transient UIImage LoadingRotator;
var transient bool bInitial;

var transient bool bNeedsProfileSave;
var transient bool bOkToAutoClose;

var transient UTUITabPage_InGame InGamePage;

var transient bool bLoading;
var transient bool bWaitingForReady;
var transient bool bReturningToMainMenu;

var transient UTUIScene_MessageBox MBScene;




function NotifyGameSessionEnded()
{
	VoteRI = none;
	Super.NotifyGameSessionEnded();
}

event SceneActivated( bool bInitialActivation )
{
	local WorldInfo WI;
	local int i,cnt;
	local UTPlayerController UTPC;

	Super.SceneActivated(bInitialActivation);

	if ( bInitialActivation )
	{
		UTPC = GetUTPlayerOwner();
		if ( UTPC != None )
		{
			// SceneActivated is called immediately after LoadSceneDataValues is called.  LoadSceneDataValues would caused
			// most of the widgets in the scene which are bound to the player profile's data store to re-initialize their value,
			// triggering a call to their ValueChanged delegate.  In the mid-game menu, the handler for this delegate sets the
			// "profile is dirty" flag in scene, but in the case of LoadSceneDataValues the profile isn't dirty so clear that
			// flag now.
			bNeedsProfileSave = false;
		}

		WI = GetWorldInfo();
		if ( WI != none && WI.GRI != none )
		{
			for (i=0;i<WI.GRI.PRIArray.Length;i++)
			{
				if ( WI.GRI.PRIArray[i] != none && !WI.GRI.PRIArray[i].bBot)
				{
					cnt++;
				}
			}

			if (!WI.GRI.bMatchIsOver && Cnt < 2)
			{
				bPauseGameWhileActive = true;
			}
		}
	}
}

event SceneDeactivated()
{
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;
	local UTPlayerController UTPC;

	Super.SceneDeactivated();

	UTPC = GetUTPlayerOwner();

	WI = GetWorldInfo();
    WI.ForceGarbageCollection();

	if (bNeedsProfileSave)
	{
		UTPC.SaveProfile(GetPlayerIndex());
		UTPC.LoadSettingsFromProfile(false);
	}

	GRI = UTGameReplicationInfo(WI.GRI);
	if ( GRI != none )
	{
		GRI.MidGameMenuClosed();
		if (GRI.bMatchIsOver && !bReturningToMainMenu)
		{
			UTPC.ShowScoreboard();
		}
    }

    VoteRI = None;
}


/**
 * Setup the delegates for the scene and cache all of the various UI Widgets
 */
event PostInitialize( )
{
	local class<UTGame> GameClass;

	Super.PostInitialize();

	// Store a reference to the button bar.
	ButtonBar = UTUIButtonBar(FindChild('ButtonBar', true));
	ButtonBar.ClearButton(0);
	ButtonBar.ClearButton(1);

    LoadingPanel = UIPanel(FindChilD('LoadingPanel',true));
    LoadingRotator = UIImage(FindChild('ConnectingImage',true));

	MapVoteClock = UILabel(FindChild('MapVoteClock',true));

	// Find the tab control

	TabControl = UTUITabControl( FindChild('TabControl',true) );

	if ( TabControl != none )
	{

		GameClass = Class<UTGame>( GetWorldInfo().GRI.GameClass);
		if ( GameClass != none && !GameClass.default.bMidGameHasMap )
		{
			TabControl.RemoveTabByTag('MapTab');
		}

		TabControl.OnPageActivated = OnPageActivated;

		if ( GetWorldInfo().NetMode == NM_StandALone || IsConsole() )
		{
			TabControl.RemoveTabByTag('ChatTab');
		}

		if ( GetWorldInfo().NetMode == NM_StandALone)
		{
			TabControl.RemoveTabByTag('FriendsTab');
		}
	}

	// Setup initial button bar
	SetupButtonBar();

	// Setup handler for input keys
	OnRawInputKey=HandleInputKey;
	OnPreRenderCallBack = PreRenderCallBack;

	InGamePage = UTUITabPage_InGame(FindChild('GameTab',true));

}

function PreRenderCallBack()
{
	local UTPlayerController PC;

	PC = GetUTPlayerOwner(0);

	if (PC != none && PC.VoteRI != none )
	{
		VoteRI = PC.VoteRI;
		BeginVoting(VoteRI);
	}

	bCloseOnLevelChange = false;

	OnPreREnderCallBack = none;
}


function ActivateTab(name TabTag)
{

	if (TabTag == 'ChatTab' && IsConsole())
	{
		TabTag = 'ScoreTab';
	}

	if ( TabControl != none )
	{
		if ( TabControl.ActivePage.WidgetTag != 'ChatTab' && TabControl.ActivateTabByTag(TabTag) )
		{
			return;
		}
	}
}

/** Function that sets up a buttonbar for this scene, automatically routes the call to the currently selected tab of the scene as well. */
function SetupButtonBar()
{
	local UTGameReplicationInfo GRI;
	local WorldInfo WI;
	if(ButtonBar != none)
	{

    	WI = GetWorldInfo();
    	GRI = UTGameReplicationInfo(WI.GRI);

		ButtonBar.Clear();

		// Depending on when we are, set the proper button.

		if ( WI != none )
		{
			if ( !WI.IsInSeamlessTravel() )
			{

				if ( bWaitingForReady )
				{
				    ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Ready>", ButtonBarBack);
				}
				else
				{
				    ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", ButtonBarBack);
				}

			    if ( WI.NetMode == NM_StandAlone || GRI.bStoryMode )
			    {
					ButtonBar.AppendButton("<Strings:UTGameUI.MidGameMenu.Forfeit>",ButtonBarDisconnect) ;
				}
				else
			    {
					ButtonBar.AppendButton("<Strings:UTGameUI.MidGameMenu.LeaveGame>",ButtonBarDisconnect) ;
				}

				if(!bWaitingForReady && TabControl != none)
				{
					// Let the current tab page try to setup the button bar
					UTTabPage(TabControl.ActivePage).SetupButtonBar(ButtonBar);
				}
			}
		}
	}
}


/**
 * Called when a new page is activated.
 *
 * @param	Sender			the tab control that activated the page
 * @param	NewlyActivePage	the page that was just activated
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 */
function OnPageActivated( UITabControl Sender, UITabPage NewlyActivePage, int PlayerIndex )
{
	// Anytime the tab page is changed, update the buttonbar.
	SetupButtonBar();
	bOkToAutoClose = false;
}

/**
 * Back was selected, exit the menu
 * @Param	InButton			The button that selected
 * @Param	InPlayerIndex		Index of the local player that made the selection
 */

function bool ButtonBarBack(UIScreenObject InButton, int InPlayerIndex)
{
	Back();
	return true;
}

function Back()
{
	UTUITabPage_MapTab( FindChild('MapTab',true)).bIgnoreChange=true;
	SceneClient.CloseScene(self);
}

function bool ButtonBarDisconnect(UIScreenObject InButton, int InPlayerIndex)
{
	Disconnect();
	return true;

}


function CleanUpScoreboards()
{
	local array<UIObject> Kids;
	local int i;


	Kids = GetChildren(true);
	for (i=0;i<Kids.Length;i++)
	{
		if ( UTScoreboardPanel(Kids[i]) != none )
		{
			UTScoreboardPanel(Kids[i]).SelectedPRI = none;
		}
	}

	UTUITabPage_Scoreboard(FindChild('ScoreTab',true)).SelectedPRI = none;

}

function MB_Selection(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	local UTPlayerController PC;

	TabControl.PlayUIAnimation('FadeIn',,5.0);
	ButtonBar.PlayUIAnimation('FadeIn',,5.0);

	if (SelectedOption == 0)
	{
		bReturningToMainMenu = true;
		CleanUpScoreboards();
		SceneClient.CloseScene(self);
		PC = GetUTPlayerOwner();
		PC.QuitToMainMenu();
	}
	MBScene = none;
}


function Disconnect()
{
	MBScene = GetMessageBoxScene();
	if(MBScene != none)
	{
		TabControl.PlayUIAnimation('FadeOut',,5.0);
		ButtonBar.PlayUIAnimation('FadeOut',,5.0);
		MBScene.DisplayAcceptCancelBox("<Strings:UTGameUI.MidGameMenu.ExitMatchWarning>","<Strings:UTGameUI.Campaign.Confirmation", MB_Selection);
	}
}


function bool HandleInputKey( const out InputEventParameters EventParms )
{

	local UTGameUISceneClient UTSceneClient;

	if ( ButtonBar.IsHidden() )
	{
		return true;
	}

	// Don't allow console commands when in seamless travel.

	if (EventParms.EventType == IE_Released)
	{
		if (!bWaitingForReady )
		{
			if (EventParms.InputKeyName == 'XBoxtypeS_B' || EventParms.InputKeyName == 'Escape' || EventParms.InputKeyName == 'XBoxTypeS_Start')
			{
			    UTSceneClient = UTGameUISceneClient(SceneClient);
				if ( UTSceneClient != none && UTSceneClient.IsInSeamlessTravel() )
				{
					return true;
				}

				Back();
				return true;
			}
		}

		if (EventParms.InputKeyName == 'XBoxTypeS_Y')
		{
			Disconnect();
			return true;
		}
	}

	if ( UTTabPage(TabControl.ActivePage) != none )
	{
		return UTTabPage(TabControl.ActivePage).HandleInputKey( EventParms );
	}
	return false;
}

event UpdateVote(UTGameReplicationInfo GRI, bool bVoteInProgress)
{
	local string s;

	if (bVoteInProgress)
	{

	    S = "<Strings:UTGameUI.MidGameMenu.VoteTimePrefix>"@GRI.MapVoteTimeRemaining;
	    S @= (GRI.MapVoteTimeRemaining > 1) ? "<Strings:UTGameUI.MidGameMenu.VoteTimeSuffixA>" : "<Strings:UTGameUI.MidGameMenu.VoteTimeSuffixA>";
	    if( (VoteRI != none) && (VoteRI.LeadingMap != "") )
	    {
	    	S @= "("$InGamePage.TrimGameType(VoteRI.LeadingMap)$")";
	    }

	 	MapVoteClock.SetDataStoreBinding(S);

		if ( MapVoteClock.IsHidden() )
		{
	        MapVoteClock.SetVisibility(true);
	    }
	}
	else if (MapVoteClock.IsVisible() )
	{
		MapVoteClock.SetVisibility(False);
	}
}

function BeginVoting(UTVoteReplicationInfo NewVoteRI)
{
	local UTUITabPAge_InGame GameTab;


	GameTab = UTUITabPAge_InGame( FindChild('GameTab',true));
//	`log("### BeginVoting"@GameTab);
	if (GameTab != none )
	{
		VoteRI = NewVoteRI;
		GameTab.BeginVoting(NewVoteRI);
	}
}

/**
 * Parse the scrollback and create a string out of it
 */
function string ParseScrollback(const out array<string> Scrollback)
{
	local int i,Start;
	local string s, Result;

	Result = "";

	Start = (Scrollback.Length < 150) ? 0 : Scrollback.Length-150;
	for (i=Start;i<Scrollback.Length;i++)
	{
		if ( (Left(Scrollback[i],7) ~= ">>> Say") || (Left(Scrollback[i],11) ~= ">>> TeamSay") )
		{
			continue;
		}
		else
		{
			s = Repl(Scrollback[i],">","");
			s = Repl(S,"<","");

			Result $= s $ " \n ";
		}
	}

	return Result;
}

/**
 * Reset will set the bWaitingForReady flag and reset the button bar
 */
function Reset()
{
	local UTUITabPage_InGame InGameTab;

	bOkToAutoClose = true;

	bWaitingForReady = true;
	InGameTab = UTUITabPage_InGame( FindChild('GameTab',true));
	InGameTab.Reset(GetWorldInfo());
	SetupButtonBar();
}

event BeginLoading()
{
	local rotator r;

	if ( MBScene != none )
	{
		MBScene.CloseScene(self);
	}

	bLoading = true;
	LoadingPanel.SetVisibility(true);
	LoadingRotator.RotateWidget(r,false);
	ButtonBar.SetVisibility(false);
}

event EndLoading()
{

	bLoading = false;
	LoadingPanel.SetVisibility(false);
	ButtonBar.SetVisibility(true);
	SetupButtonBar();
}



defaultproperties
{
	SceneInputMode=INPUTMODE_None
	SceneRenderMode=SPLITRENDER_Fullscreen
	bDisplayCursor=true
	bRenderParentScenes=false
	bAlwaysRenderScene=true
	bCloseOnLevelChange=true
	bPauseGameWhileActive=false
	bSaveSceneValuesOnClose=false
}

