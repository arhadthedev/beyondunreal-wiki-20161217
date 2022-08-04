/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Join Game scene for UT3.
 */
class UTUIFrontEnd_JoinGame extends UTUIFrontEnd;

/** Tab page references for this scene. */
var UTUITabPage_ServerBrowser ServerBrowserTab;
var UTUITabPage_ServerFilter ServerFilterTab;

/** true when we're opened via the campaign menu's 'join online game' option */
var transient	bool		bCampaignMode;

/**
 * Tracks whether a query has been initiated.  Set to TRUE once the first query is started - this is how we catch cases
 * where the user clicked on the sb tab directly instead of clicking the Search button.
 */
var	transient	bool		bIssuedInitialQuery;

/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize()
{
	Super.PostInitialize();

	// Grab a reference to the server filter tab.
	ServerFilterTab = UTUITabPage_ServerFilter(FindChild('pnlServerFilter', true));

	if(ServerFilterTab != none)
	{
		TabControl.InsertPage(ServerFilterTab, 0, INDEX_NONE, true);
		ServerFilterTab.OnAcceptOptions = OnServerFilter_AcceptOptions;
		ServerFilterTab.OnSwitchedGameType = ServerFilterChangedGameType;
	}

	// Grab a reference to the server browser tab.
	ServerBrowserTab = UTUITabPage_ServerBrowser(FindChild('pnlServerBrowser', true));
	if(ServerBrowserTab != none)
	{
		TabControl.InsertPage(ServerBrowserTab, 0, INDEX_NONE, false);
		ServerBrowserTab.OnBack = OnServerBrowser_Back;
		ServerBrowserTab.OnSwitchedGameType = ServerBrowserChangedGameType;
		ServerBrowserTab.OnPrepareToSubmitQuery = PreSubmitQuery;
	}

	// Let the currently active page setup the button bar.
	SetupButtonBar();
}

/** Called just after this scene is removed from the active scenes array */
event SceneDeactivated()
{
	Super.SceneDeactivated();

	// if we're leaving the server browser area - clear all stored server query searches
	if ( ServerBrowserTab != None )
	{
		ServerBrowserTab.Cleanup();
	}
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
		ServerFilterTab.ValidateServerType();

		if ( bCampaignMode )
		{
			OnAcceptFilterOptions(GetBestPlayerIndex());
		}
	}
}

/**
 * Called when the server browser page is activated.  Begins a server list query if the page was activated by the user
 * clicking directly on the server browser's tab (as opposed clicking the Search button or pressing enter or something).
 *
 * @param	Sender			the tab control that activated the page
 * @param	NewlyActivePage	the page that was just activated
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 */
function OnPageActivated( UITabControl Sender, UITabPage NewlyActivePage, int PlayerIndex )
{
	Super.OnPageActivated(Sender, NewlyActivePage, PlayerIndex);

	if ( NewlyActivePage == ServerBrowserTab && !bIssuedInitialQuery )
	{
		bIssuedInitialQuery = true;

		ServerBrowserTab.RefreshServerList(PlayerIndex);
	}
}

/** Sets up the button bar for the scene. */
function SetupButtonBar()
{
	if(ButtonBar != None)
	{
		ButtonBar.Clear();

		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Search>", OnButtonBar_Search);

		if ( TabControl != None && UTTabPage(TabControl.ActivePage) != None )
		{
			// Let the current tab page try to setup the button bar
			UTTabPage(TabControl.ActivePage).SetupButtonBar(ButtonBar);
		}
	}
}

/**
 * Handler for the server filter panel's OnSwitchedGameType delegate - updates the combo box on the server browser menu
 */
function ServerFilterChangedGameType()
{
	if ( ServerBrowserTab != None )
	{
		ServerBrowserTab.NotifyGameTypeChanged();
	}
}

/**
 * Handler for the server browser panel's OnSwitchedGameType delegate - updates the options in the Filter panel
 * for the newly selected game type.
 */
function ServerBrowserChangedGameType()
{
	if ( ServerFilterTab != None )
	{
		ServerFilterTab.MarkOptionsDirty();
	}
}

/**
 * Handler for the sb tab's OnPrepareToSubmitQuery delegate.  Publishes all configured settings to the game search object.
 */
function PreSubmitQuery( UTUITabPage_ServerBrowser ServerBrowser )
{
	SaveSceneDataValues(false);
}

/** Shows the previous tab page, if we are at the first tab, then we close the scene. */
function ShowPrevTab()
{
	if(TabControl.ActivatePreviousPage(0,true,false)==false)
	{
		CloseScene(self);
	}
}

/** Shows the next tab page, if we are at the last tab, then we start the game. */
function ShowNextTab()
{
	TabControl.ActivateNextPage(0,true,false);
}

/** Called when the user accepts their filter settings and wants to go to the server browser. */
function OnAcceptFilterOptions(int PlayerIndex)
{
	bIssuedInitialQuery = true;

	ShowNextTab();

	// Start a game search
	if ( TabControl.ActivePage == ServerBrowserTab )
	{
		ServerBrowserTab.RefreshServerList(PlayerIndex);
	}
}

/** Called when the user accepts their filter settings and wants to go to the server browser. */
function OnServerFilter_AcceptOptions(UIScreenObject InObject, int PlayerIndex)
{
	OnAcceptFilterOptions(PlayerIndex);
}

/** Called when the user wants to back out of the server browser. */
function OnServerBrowser_Back()
{
	ShowPrevTab();
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_Search(UIScreenObject InButton, int PlayerIndex)
{
	OnAcceptFilterOptions(PlayerIndex);

	return true;
}


function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	ShowPrevTab();

	return true;
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
	local bool bResult;
	local UTTabPage CurrentTabPage;

	// Let the tab page's get first chance at the input
	CurrentTabPage = UTTabPage(TabControl.ActivePage);
	bResult=CurrentTabPage.HandleInputKey(EventParms);

	// If the tab page didn't handle it, let's handle it ourselves.
	if(bResult==false)
	{
		if(EventParms.EventType==IE_Released)
		{
			if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
			{
				ShowPrevTab();
				bResult=true;
			}
		}
	}

	return bResult;
}

/**
 * Switch to the Campaign filter and show the tab
 */
function UseCampaignMode()
{
	local int ValueIndex;
	ValueIndex = ServerFilterTab.MenuDataStore.FindValueInProviderSet('GameModeFilter', 'GameSearchClass', "UTGameSearchCampaign");

	if(ValueIndex != -1)
	{
		bCampaignMode = true;

		ServerFilterTab.MenuDataStore.GameModeFilter = ValueIndex;
		ServerFilterTab.MarkOptionsDirty();
		ServerFilterTab.SearchDataStore.SetCurrentByName('UTGameSearchCampaign', false);

		ServerFilterChangedGameType();
	}
}

defaultproperties
{
	bMenuLevelRestoresScene=true
	bRequiresNetwork=true
}
