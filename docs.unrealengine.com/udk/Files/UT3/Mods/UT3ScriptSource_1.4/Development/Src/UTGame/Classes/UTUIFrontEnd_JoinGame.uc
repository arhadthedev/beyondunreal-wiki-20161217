/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Join Game scene for UT3.
 */
class UTUIFrontEnd_JoinGame extends UTUIFrontEnd;

/** Tab page references for this scene. */
var UTUITabPage_ServerBrowser	ServerBrowserTab;
var UTUITabPage_ServerFilter 	ServerFilterTab;
var	UTUITabPage_ServerHistory	ServerHistoryTab;
var	UTUITabPage_ServerFavorites	ServerFavoritesTab;

/** true when we're opened via the campaign menu's 'join online game' option */
var transient	bool		bCampaignMode;

/**
 * Tracks whether a query has been initiated.  Set to TRUE once the first query is started - this is how we catch cases
 * where the user clicked on the sb tab directly instead of clicking the Search button.
 */
var	transient	bool		bIssuedInitialQuery, bIssuedInitialHistoryQuery, bIssuedInitialFavoritesQuery;

/** The scene which is opened when the player clicks on the 'Mutator' button */
var string MutatorScene;

var bool bJoinSpectate;


/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize()
{
	local UIList List;

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

		ServerBrowserTab.OnAddToFavorite = OnServerHistory_AddToFavorite;

		// this is no longer needed, as we call SaveSubscriberValue on each option as its changed
		//ServerBrowserTab.OnPrepareToSubmitQuery = PreSubmitQuery;

		List = UIList(ServerBrowserTab.FindChild('lstDetails', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];

		List = UIList(ServerBrowserTab.FindChild('lstMutators', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];

		List = UIList(ServerBrowserTab.FindChild('lstPlayers', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];
	}

	ServerHistoryTab = UTUITabPage_ServerHistory(FindChild('pnlServerHistory', true));
	if ( ServerHistoryTab != None )
	{
		TabControl.InsertPage(ServerHistoryTab, GetBestPlayerIndex(),, false);
		ServerHistoryTab.OnBack = OnServerBrowser_Back;
		ServerHistoryTab.OnAddToFavorite = OnServerHistory_AddToFavorite;

		// this is no longer needed, as we call SaveSubscriberValue on each option as its changed
		//ServerHistoryTab.OnPrepareToSubmitQuery = PreSubmitQuery;

		List = UIList(ServerHistoryTab.FindChild('lstDetails', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];

		List = UIList(ServerHistoryTab.FindChild('lstPlayers', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];

		List = UIList(ServerHistoryTab.FindChild('lstMutators', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];
	}

	ServerFavoritesTab = UTUITabPage_ServerFavorites(FindChild('pnlServerFavorites',true));
	if ( ServerFavoritesTab != None )
	{
		TabControl.InsertPage(ServerFavoritesTab, GetBestPlayerIndex(), , false);
		ServerFavoritesTab.OnBack = OnServerBrowser_Back;

		List = UIList(ServerFavoritesTab.FindChild('lstDetails', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];

		List = UIList(ServerFavoritesTab.FindChild('lstPlayers', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];

		List = UIList(ServerFavoritesTab.FindChild('lstMutators', true));
		List.ItemOverlayStyle[1] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[1] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[2] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[2] = List.GlobalCellStyle[0];
		List.ItemOverlayStyle[3] = List.ItemOverlayStyle[0]; List.GlobalCellStyle[3] = List.GlobalCellStyle[0];
	}

	// Let the currently active page setup the button bar.
	SetupButtonBar();
}

/** Called just after this scene is removed from the active scenes array */
event SceneDeactivated()
{
	Super.SceneDeactivated();

	// If the player is exiting the server browser, unset the 'WasShowingBrowser' registry vaue
	SetDataStoreStringValue("<Registry:WasShowingBrowser>", "0");

	// if we're leaving the server browser area - clear all stored server query searches
	if ( ServerBrowserTab != None )
	{
		ServerBrowserTab.Cleanup();
	}

	if ( ServerHistoryTab != None )
	{
		ServerHistoryTab.Cleanup();
	}

	if ( ServerFavoritesTab != None )
	{
		ServerFavoritesTab.Cleanup();
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
		if (ServerFilterTab != None)
		{
			ServerFilterTab.ValidateServerType();
		}
		
/*
		if ( bCampaignMode )
		{
			OnAcceptFilterOptions(GetBestPlayerIndex());
		}
*/
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

	// Set the 'WasShowingBrowser' registry value to 1, so that the player can return directly to the browser after joining and exiting a game
	SetDataStoreStringValue("<Registry:WasShowingBrowser>", "1");

	if ( NewlyActivePage == ServerBrowserTab && !bIssuedInitialQuery )
	{
		bIssuedInitialQuery = true;
		ServerBrowserTab.RefreshServerList(PlayerIndex);
	}
	else if ( !bIssuedInitialHistoryQuery && NewlyActivePage == ServerHistoryTab )
	{
		bIssuedInitialHistoryQuery = true;
		ServerHistoryTab.RefreshServerList(PlayerIndex);
	}
	else if ( !bIssuedInitialFavoritesQuery && NewlyActivePage == ServerFavoritesTab )
	{
		bIssuedInitialFavoritesQuery = true;
		ServerFavoritesTab.RefreshServerList(PlayerIndex);
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
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.SelectMutators>", OnButtonBar_Mutators);
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.JoinIP>", OnButtonBar_JoinIP);
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.SpectateIP>", OnButtonBar_SpectateIP);

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

	//These invisible (unused and undeletable) combo boxes must be updated as well or else they will overwrite 
	//the true value (from ServerFilter) when you back out of the scene and SaveSubscriberValues is called
	if (ServerHistoryTab != None)
	{
		ServerHistoryTab.GameTypeCombo.RefreshSubscriberValue();
	}

	if (ServerFavoritesTab != None)
	{
		ServerFavoritesTab.GameTypeCombo.RefreshSubscriberValue();
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
		//ServerFilterTab.OptionList.RefreshSubscriberValue();
	}

	//These invisible (unused and undeletable) combo boxes must be updated as well or else they will overwrite 
	//the true value (from ServerFilter) when you back out of the scene and SaveSubscriberValues is called
	if (ServerHistoryTab != None)
	{
		ServerHistoryTab.GameTypeCombo.RefreshSubscriberValue();
	}

	if (ServerFavoritesTab != None)
	{
		ServerFavoritesTab.GameTypeCombo.RefreshSubscriberValue();
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
	if ( !TabControl.ActivatePreviousPage(0,false,false) )
	{
		if ((ServerBrowserTab == None	|| ServerBrowserTab.AllowCloseScene())
		&&	(ServerHistoryTab == None	|| ServerHistoryTab.AllowCloseScene())
		&&	(ServerFavoritesTab == None	|| ServerFavoritesTab.AllowCloseScene()))
		{
			CloseScene(self);
		}
	}
}

/** Shows the next tab page, if we are at the last tab, then we start the game. */
function ShowNextTab()
{
	TabControl.ActivateNextPage(0,false,false);
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

/** Called when the user clicks on the 'Mutators' button, to open up the mutator filter menu */
function OnFilterMutators()
{
	OpenSceneByName(MutatorScene, false);
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

/**
 * Handler for when user moves a server from the server history tab to the server favorites tab; refreshes
 * the server favorites query if the favorites tab is active; otherwise flags the server favorites to be
 * requeried the next time that tab is shown
 */
function OnServerHistory_AddToFavorite()
{
	if (ServerFavoritesTab != None && TabControl != None )
	{
		if ( TabControl.ActivePage == ServerFavoritesTab )
		{
			ServerFavoritesTab.RefreshServerList(GetBestPlayerIndex());
		}
		else
		{
			bIssuedInitialFavoritesQuery = false;
		}
	}
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_Search(UIScreenObject InButton, int PlayerIndex)
{
	OnAcceptFilterOptions(PlayerIndex);

	return true;
}

function bool OnButtonBar_Mutators(UIScreenObject InButton, int PlayerIndex)
{
	OnFilterMutators();

	return True;
}

function bool OnButtonBar_JoinIP(UIScreenObject InButton, int PlayerIndex)
{
	local UTUIScene_InputBox IPInputScene;

	// Display a dialog box where the player can enter the servers IP and port
	IPInputScene = GetInputBoxScene();

	if (IPInputScene != none)
	{
		bJoinSpectate = False;
		IPInputScene.DisplayAcceptCancelBox("<Strings:UTGameUI.MessageBox.EnterServerIP_Message>",
							"<Strings:UTGameUI.MessageBox.EnterServerIP_Title>",
							OnJoinIPDialog_Closed);
	}
	else
	{
		`log("Failed to open the input box scene ("$InputBoxScene$")");
	}


	return True;
}

function bool OnButtonBar_SpectateIP(UIScreenObject InButton, int PlayerIndex)
{
	local UTUIScene_InputBox IPInputScene;

	// Display a dialog box where the player can enter the servers IP and port
	IPInputScene = GetInputBoxScene();

	if (IPInputScene != none)
	{
		bJoinSpectate = True;
		IPInputScene.DisplayAcceptCancelBox("<Strings:UTGameUI.MessageBox.EnterServerIP_Message>",
							"<Strings:UTGameUI.MessageBox.EnterServerIP_Title>",
							OnJoinIPDialog_Closed);
	}
	else
	{
		`log("Failed to open the input box scene ("$InputBoxScene$")");
	}


	return True;
}

function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	ShowPrevTab();

	return true;
}


function OnJoinIPDialog_Closed(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	local string ServerIP, FallbackURL;
	local UTQueryHelper QueryHelper;

	if (SelectedOption == 0)
	{
		ServerIP = UTUIScene_InputBox(MessageBox).GetValue();

		if (ServerIP != "")
		{
			if (QueryHelper == none)
				QueryHelper = Class'UTQueryHelper'.static.GetQueryHelper(Self);


			FallbackURL = ServerIP$"?Name="$GetPlayerName();

			if (bJoinSpectate)
				FallbackURL $= "?SpectatorOnly=1";

			QueryHelper.JoinServerByIP(ServerIP,, bJoinSpectate, FallbackURL);
		}
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

	TabControl.ActivatePage(ServerBrowserTab, GetBestPlayerIndex());
	TabControl.RemovePage(ServerFilterTab, GetBestPlayerIndex());
	TabControl.RemovePage(ServerHistoryTab, GetBestPlayerIndex());
	TabControl.RemovePage(ServerFavoritesTab, GetBestPlayerIndex());
	ServerFilterTab = None;
	ServerHistoryTab = None;
	ServerFavoritesTab = None;
}

/**
 * Setup the server filter/browser for LAN mode
 */
function UseLANMode()
{
	local int ValueIndex;
	ValueIndex = ServerFilterTab.MenuDataStore.FindValueInProviderSet('GameModeFilter', 'GameSearchClass', "UTGameSearchDM");

	//Force DM search mode (prevents campaign filtering out non-campaign games)
	if(ValueIndex != -1)
	{
		ServerFilterTab.MenuDataStore.GameModeFilter = ValueIndex;
		ServerFilterTab.MarkOptionsDirty();
		ServerFilterTab.SearchDataStore.SetCurrentByName('UTGameSearchDM', false);

		ServerFilterChangedGameType();
	}

	TabControl.ActivatePage(ServerBrowserTab, GetBestPlayerIndex());
	TabControl.RemovePage(ServerFilterTab, GetBestPlayerIndex());
	TabControl.RemovePage(ServerHistoryTab, GetBestPlayerIndex());
	TabControl.RemovePage(ServerFavoritesTab, GetBestPlayerIndex());
	ServerFilterTab = None;
	ServerHistoryTab = None;
	ServerFavoritesTab = None;
}

/**
 * Notification that the player's connection to the platform's online service is changed.
 */
function NotifyOnlineServiceStatusChanged( EOnlineServerConnectionStatus NewConnectionStatus )
{
	Super.NotifyOnlineServiceStatusChanged(NewConnectionStatus);

	if ( NewConnectionStatus != OSCS_Connected )
	{
		// make sure we are using the LAN option
		ServerFilterTab.ForceLANOption(GetBestPlayerIndex());
		if ( bIssuedInitialQuery )
		{
			ServerBrowserTab.CancelQuery(QUERYACTION_RefreshAll);
		}
		if ( bIssuedInitialHistoryQuery )
		{
			ServerHistoryTab.CancelQuery(QUERYACTION_RefreshAll);
		}
		if ( bIssuedInitialHistoryQuery )
		{
			ServerFavoritesTab.CancelQuery(QUERYACTION_RefreshAll);
		}

		ServerBrowserTab.NotifyGameTypeChanged();
	}
}

defaultproperties
{
	bMenuLevelRestoresScene=true
	bRequiresNetwork=true

	MutatorScene="UI_Scenes_FrontEnd.Scenes.BrowserMutatorFilters"
}
