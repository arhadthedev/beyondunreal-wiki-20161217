/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for a server browser.
 */

class UTUITabPage_ServerBrowser extends UTTabPage
	placeable;

`include(Core/Globals.uci)

const SERVERBROWSER_SERVERTYPE_LAN		= 0;
const SERVERBROWSER_SERVERTYPE_UNRANKED	= 1;	//	for platforms which do not support ranked matches, represents a normal internet match.
const SERVERBROWSER_SERVERTYPE_RANKED	= 2;	// only valid on platforms which support ranked matches

/** Reference to the list of servers */
var transient UIList						ServerList;
/** Reference to the list of rules for the selected server */
var transient UIList						DetailsList;
/** reference to the list of mutators for the selected server */
var transient UIList						MutatorList;

/** Reference to a label to display when refreshing. */
var transient UIObject						RefreshingLabel;

/** Reference to the label which displays the number of servers currently loaded in the list */
var	transient UILabel						ServerCountLabel;

/** Reference to the combobox containing the gametypes */
var	transient UTUIComboBox					GameTypeCombo;

/** Reference to the search datastore. */
var transient UTDataStore_GameSearchDM	SearchDataStore;

/** Reference to the string list datastore. */
var transient UTUIDataStore_StringList StringListDataStore;

/** Reference to the menu item datastore. */
var transient UTUIDataStore_MenuItems MenuItemDataStore;

/** Cached online subsystem pointer */
var transient OnlineSubsystem OnlineSub;

/** Cached game interface pointer */
var transient OnlineGameInterface GameInterface;

/** Indices for the button bar buttons */
var	transient int JoinButtonIdx, RefreshButtonIdx, DetailsButtonIdx;

/** Indicates that the current gametype was changed externally - submit a new query when possible */
var	private transient bool bGametypeOutdated;

/** stores the password entered by the user when attempting to connect to a server with a password */
var private transient string ServerPassword;


/** Go back delegate for this page. */
delegate transient OnBack();

/** Called when the user changes the game type using the combo box */
delegate transient OnSwitchedGameType();

/**
 * Called when we're about the submit a server query.  Usual thing to do is make sure the GameSearch object is up to date
 */
delegate transient OnPrepareToSubmitQuery( UTUITabPage_ServerBrowser Sender );

/** PostInitialize event - Sets delegates for the page. */
event PostInitialize( )
{
	local DataStoreClient DSClient;
	local UTUIList UTComboList;

	Super.PostInitialize();

	// Find the server list.
	ServerList = UIList(FindChild('lstServers', true));
	if(ServerList != none)
	{
		ServerList.OnSubmitSelection = OnServerList_SubmitSelection;
		ServerList.OnValueChanged = OnServerList_ValueChanged;
	}

	DetailsList = UIList(FindChild('lstDetails', true));
	MutatorList = UIList(FindChild('lstMutators', true));

	// Get reference to the refreshing/searching label.
	RefreshingLabel = FindChild('lblRefreshing', true);
	if ( RefreshingLabel != None )
	{
		RefreshingLabel.SetVisibility(false);
	}

	// get a reference to the server count label
	ServerCountLabel = UILabel(FindChild('lblServerCount', true));

	// get a reference to the combo holding the list of gametypes.
	GameTypeCombo = UTUIComboBox(FindChild('cmbGameType', true));
	if ( GameTypeCombo != None )
	{
		UTComboList = UTUIList(GameTypeCombo.ComboList);

		// UTUIComboBox sets this flag on its internal list for some reason - unset it so that the combobox works like
		// it's supposed to.
		if ( UTComboList != None )
		{
			UTComboList.bAllowSaving = true;
		}
	}

	// Get a reference to the datastore we are working with.
	// @todo: This should probably come from the list.
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		SearchDataStore = UTDataStore_GameSearchDM(DSClient.FindDataStore('UTGameSearch'));
		StringListDataStore = UTUIDataStore_StringList(DSClient.FindDataStore('UTStringList'));
		MenuItemDataStore = UTUIDataStore_MenuItems(DSClient.FindDataStore('UTMenuItems'));
	}

	// Store a reference to the game interface
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		GameInterface = OnlineSub.GameInterface;
	}

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.JoinGame.Servers>");

	AdjustLayout();

	UpdateServerCount();
}

/**
 * Causes this page to become (or no longer be) the tab control's currently active page.
 *
 * @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player that wishes to activate this page.
 * @param	bActivate	TRUE if this page should become the tab control's active page; FALSE if it is losing the active status.
 * @param	bTakeFocus	specify TRUE to give this panel focus once it's active (only relevant if bActivate = true)
 *
 * @return	TRUE if this page successfully changed its active state; FALSE otherwise.
 */
event bool ActivatePage( int PlayerIndex, bool bActivate, optional bool bTakeFocus=true )
{
	local bool bResult;

	bResult = Super.ActivatePage(PlayerIndex, bActivate, bTakeFocus);

	if ( bResult && bActivate )
	{
		if ( GameTypeCombo != None )
		{
			GameTypeCombo.OnValueChanged = OnGameTypeChanged;
		}

		if ( bGametypeOutdated )
		{
			`log(`location);
			NotifyGameTypeChanged();
			bGametypeOutdated = false;
		}
	}

	return bResult;
}

/**
 * Called when the owning scene is being closed - provides a hook for the tab page to ensure it's cleaned up all external
 * references (i.e. delegates, etc.)
 */
function Cleanup()
{
	if ( GameInterface != None )
	{
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
	}

	// if we're leaving the server browser area - clear all stored server query searches
	if ( SearchDataStore != None )
	{
		SearchDataStore.ClearAllSearchResults();
	}
}

/**
 * Adjusts the layout of the scene based on the current platform
 */
function AdjustLayout()
{
	local UTUIScene UTOwnerScene;
	local UIObject DetailsContainer, BackgroundContainer;

	UTOwnerScene = UTUIScene(GetScene());
	if ( UTOwnerScene != None
	&&	IsConsole() )
	{
		// if we're on a console, a few things need to change in the scene

		// we need to hide the gametype combo
		if ( GameTypeCombo != None )
		{
			GameTypeCombo.SetVisibility(false);
		}

		// hide the details panels
		DetailsContainer = FindChild('pnlDetailsContainer',true);
		if ( DetailsContainer != None )
		{
			DetailsContainer.SetVisibility(false);
		}

		// redock the server count label to the bottom of the background panel
		BackgroundContainer = FindChild('pnlBackgroundContainer', true);
		if ( BackgroundContainer != None )
		{
			ServerCountLabel.SetDockTarget(UIFACE_Bottom, BackgroundContainer, UIFACE_Bottom);
		}
	}
}

/**
 * Wrapper for grabbing a reference to a button bar button.
 */
function UTUIButtonBarButton GetButtonBarButton( int ButtonIndex )
{
	local UTUIFrontEnd UTOwnerScene;
	local UTUIButtonBarButton Result;

	UTOwnerScene = UTUIFrontEnd(GetScene());
	if (UTOwnerScene != None
	&&	UTOwnerScene.ButtonBar != None)
	{
		if ( ButtonIndex >= 0 && ButtonIndex < ArrayCount(UTOwnerScene.ButtonBar.Buttons) )
		{
			Result = UTOwnerScene.ButtonBar.Buttons[ButtonIndex];
		}
	}

	return Result;
}

/** Sets buttons for the scene. */
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	ButtonBar.Clear();
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
	JoinButtonIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.JoinServer>", OnButtonBar_JoinServer);
	RefreshButtonIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Refresh>", OnButtonBar_Refresh);

	if ( IsConsole() )
	{
		DetailsButtonIdx = ButtonBar.AppendButton( "<Strings:UTGameUI.ButtonCallouts.ServerDetails>", OnButtonBar_ServerDetails );
	}

	UpdateButtonStates();
}

/**
 * Updates the enabled state of certain button bar buttons depending on whether a server is selected or not.
 */
function UpdateButtonStates()
{
	local UTUIFrontEnd UTOwnerScene;
	local bool bValidServerSelected, bHasPendingSearches;
	local int PlayerIndex;

	UTOwnerScene = UTUIFrontEnd(GetScene());
	if (UTOwnerScene != None
	&&	UTOwnerScene.ButtonBar != None)
	{
		PlayerIndex = UTOwnerScene.GetPlayerIndex();
		bValidServerSelected = ServerList != None && ServerList.GetCurrentItem() != INDEX_NONE;

		// we must have a valid server selected in order to activate the Join Server button
		if ( JoinButtonIdx != INDEX_NONE )
		{
			UTOwnerScene.ButtonBar.Buttons[JoinButtonIdx].SetEnabled(bValidServerSelected, PlayerIndex);
		}

		// the refresh button and gametype combo can only be enabled if there are no searches currently working
		bHasPendingSearches = SearchDataStore.HasOutstandingQueries();
		if ( RefreshButtonIdx != INDEX_NONE && UTOwnerScene.ButtonBar.Buttons[RefreshButtonIdx] != None )
		{
			UTOwnerScene.ButtonBar.Buttons[RefreshButtonIdx].SetEnabled(!bHasPendingSearches, PlayerIndex);
		}

		if ( GameTypeCombo != None )
		{
			GameTypeCombo.SetEnabled(!bHasPendingSearches);
		}

		// we must have a valid server selected in order to activate the Server Details button.
		if (IsConsole()
		&&	DetailsButtonIdx != INDEX_NONE
		&&	UTOwnerScene.ButtonBar.Buttons[DetailsButtonIdx] != None)
		{
			UTOwnerScene.ButtonBar.Buttons[DetailsButtonIdx].SetEnabled(bValidServerSelected, PlayerIndex);
		}
	}
}

/**
 * Determines if the currently selected server is password protected.
 *
 * @return	TRUE if a valid server is selected and it is password protected; FALSE otherwise.
 */
function bool ServerIsPrivate()
{
	local bool bResult;
	local string LockedServerValueString;

	if ( GetDataStoreStringValue("<UTGameSearch:CurrentServerDetails.LockedServer>", LockedServerValueString, GetScene(), GetPlayerOwner()) )
	{
		bResult = bool(LockedServerValueString);
	}

	return bResult;
}

/**
 * Displays a dialog to the user which allows him to enter the password for the currently selected server.
 */
private function PromptForServerPassword()
{
	local UTUIScene UTSceneOwner;
	local UTUIScene_InputBox PasswordInputScene;

	ServerPassword = "";
	UTSceneOwner = UTUIScene(GetScene());
	if ( UTSceneOwner != None )
	{
		PasswordInputScene = UTSceneOwner.GetInputBoxScene();
		if ( PasswordInputScene != None )
		{
			PasswordInputScene.SetPasswordMode(true);
			PasswordInputScene.DisplayAcceptCancelBox(
				"<Strings:UTGameUI.MessageBox.EnterServerPassword_Message>",
				"<Strings:UTGameUI.MessageBox.EnterServerPassword_Title>",
				OnPasswordDialog_Closed
				);
		}
		else
		{
			`log("Failed to open the input box scene (" $ UTSceneOwner.InputBoxScene $ ")");
		}
	}
}

/**
 * The user has made a selection of the choices available to them.
 */
private function OnPasswordDialog_Closed(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	local UTUIScene_InputBox PasswordInputScene;

	PasswordInputScene = UTUIScene_InputBox(MessageBox);
	if ( PasswordInputScene != None && SelectedOption == 0 )
	{
		ServerPassword = PasswordInputScene.GetValue();
	}
	else
	{
		ServerPassword = "";
	}

	ProcessJoin();
}

/** Joins the currently selected server. */
function JoinServer()
{
	local UTUIScene UTScene;
	local int CurrentSelection;

	UTScene = UTUIScene(GetScene());
	if(UTScene != None)
	{
		CurrentSelection = ServerList.GetCurrentItem();
		if ( CurrentSelection >= 0 )
		{
			if ( ServerIsPrivate() && ServerPassword == "" )
			{
				PromptForServerPassword();
			}
			else
			{
				ProcessJoin();
			}
		}
	}
}

private function ProcessJoin()
{
	local UTUIScene UTScene;
	local OnlineGameSearchResult GameToJoin;
	local int ControllerId, CurrentSelection;

	UTScene = UTUIScene(GetScene());
	if(UTScene.ConditionallyCheckNumControllers())	// Check to make sure that the player has 2 controllers connected if they are trying to join as splitscreen.
	{
		if ( GameInterface != None )
		{
			CurrentSelection = ServerList.GetCurrentItem();
			if(SearchDataStore.GetSearchResultFromIndex(CurrentSelection, GameToJoin))
			{
				`Log("UTUITabPage_ServerBrowser::JoinServer - Joining Search Result " $ CurrentSelection);

				// Play the startgame sound
				PlayUISound('StartGame');

				// Check for split screen
				UTUIScene(GetScene()).ConditionallyStartSplitscreen();

				if (GameToJoin.GameSettings != None)
				{
					// Set the delegate for notification
					GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

					// Start the async task
					ControllerId = GetBestControllerId();
					if (!GameInterface.JoinOnlineGame(ControllerId,GameToJoin))
					{
						//@todo - should we do anything here?  OnJoinGameComplete will be called even if the call to JoinOnlineGame returns FALSE.
					}
				}
				else
				{
					`Log("UTUITabPage_ServerBrowser::JoinServer - Failed to join game because of a NULL GameSettings object in the search result.");
					OnJoinGameComplete(false);
				}
			}
			else
			{
				ServerPassword = "";
				`Log("UTUITabPage_ServerBrowser::JoinServer - Unable to get search result for index "$CurrentSelection);
			}
		}
		else
		{
			ServerPassword = "";
			`Log("UTUITabPage_ServerBrowser::JoinServer - Unable to join game, GameInterface is NULL!");
		}
	}
	else
	{
		ServerPassword = "";
	}
}

/** Callback for when the join completes. */
function OnJoinGameComplete(bool bSuccessful)
{
	local string URL;
	local UTUIScene UTOwnerScene;

	`Log(`location@`showvar(bSuccessful));

	// Figure out if we have an online subsystem registered
	if (GameInterface != None)
	{
		if (bSuccessful)
		{
			// Get the platform specific information
			if (GameInterface.GetResolvedConnectString(URL))
			{
				UTOwnerScene = UTUIScene(GetScene());

				// Call the game specific function to appending/changing the URL
				URL = BuildJoinURL(URL);

				// @TODO: This is only temporary
				URL $= "?name=" $ UTOwnerScene.GetPlayerName();

				`Log("UTUITabPage_ServerBrowser::OnJoinGameComplete - Join Game Successful, Traveling: "$URL$"");

				// Get the resolved URL and build the part to start it
				UTOwnerScene.ConsoleCommand(URL);
			}
		}
		else
		{
			// display error message
		}

		// Remove the delegate from the list
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
	}

	ServerPassword = "";
}

/**
 * Builds the string needed to join a game from the resolved connection:
 *		"open 172.168.0.1"
 *
 * NOTE: Overload this method to modify the URL before exec-ing it
 *
 * @param ResolvedConnectionURL the platform specific URL information
 *
 * @return the final URL to use to open the map
 */
function string BuildJoinURL(string ResolvedConnectionURL)
{
	local string ConnectURL;

	ConnectURL = "open " $ ResolvedConnectionURL;
	if ( ServerPassword != "" )
	{
		ConnectURL $= "?Password=" $ ServerPassword;
	}

	return ConnectURL;
}

/**
 * Refreshes the server list by submitting a new query if certain conditions are met.
 */
function ConditionalRefreshServerList( int PlayerIndex )
{
	local bool bHasExistingResults, bHasOutstandingQueries;

	bHasExistingResults = SearchDataStore.HasExistingSearchResults();
	bHasOutstandingQueries = SearchDataStore.HasOutstandingQueries();

	// if we don't have any results for this gametype yet (either this is our first time switching to it or
	// we didn't find any servers last time) and we don't have an existing search pending, start a search using the new gametype.
	if ( !bHasExistingResults && !bHasOutstandingQueries )
	{
		// fire the query!
		RefreshServerList(PlayerIndex);
	}
	else
	{
		if ( bHasExistingResults )
		{
			// refresh the list with the items from the currently selected gametype's cached query
			ServerList.RefreshSubscriberValue();
		}

		// update the server count label with the number of servers received so far for this gametype
		UpdateServerCount();
	}
}

/** Refreshes the server list. */
function RefreshServerList(int InPlayerIndex, optional int MaxResults=1000)
{
	local OnlineGameSearch GameSearch;
	local int ValueIndex;

	if ( !SearchDataStore.HasOutstandingQueries() )
	{
		// Play the refresh sound
		PlayUISound('RefreshServers');

		// Get current filter from the string list datastore
		GameSearch = SearchDataStore.GetCurrentGameSearch();

		// Set max results
		GameSearch.MaxSearchResults = MaxResults;

		// Get the match type based on the platform.
		if( IsConsole(CONSOLE_XBox360) )
		{
			ValueIndex = StringListDataStore.GetCurrentValueIndex('MatchType360');
		}
		else
		{
			ValueIndex = StringListDataStore.GetCurrentValueIndex('MatchType');
		}

		switch(ValueIndex)
		{
		case SERVERBROWSER_SERVERTYPE_LAN:
			`Log("UTUITabPage_ServerBrowser::RefreshServerList - Searching for a LAN match.");
			GameSearch.bIsLanQuery=TRUE;
			GameSearch.bUsesArbitration=FALSE;
			break;

		case SERVERBROWSER_SERVERTYPE_RANKED:
			if ( IsConsole(CONSOLE_XBox360) )
			{
				`Log("UTUITabPage_ServerBrowser::RefreshServerList - Searching for a ranked match.");
				GameSearch.bIsLanQuery=FALSE;
				GameSearch.bUsesArbitration=TRUE;
				break;
			}

			// falls through - platform doesn't support ranked matches.

		case SERVERBROWSER_SERVERTYPE_UNRANKED:
			`Log("UTUITabPage_ServerBrowser::RefreshServerList - Searching for an unranked match.");
			GameSearch.bIsLanQuery=FALSE;
			GameSearch.bUsesArbitration=FALSE;
			break;
		}

		SubmitServerListQuery(InPlayerIndex);
	}
}

/**
 * Submits a query for the list of servers which match the current configuration.
 */
function SubmitServerListQuery( int PlayerIndex )
{
	`log(`location@`showvar(SearchDataStore.HasOutstandingQueries(),QueryActive)@`showvar(SearchDataStore.HasExistingSearchResults(),ExistingResults),,'SBDEBUG');

	OnPrepareToSubmitQuery( Self );

	// show the "refreshing" label
	if(RefreshingLabel != None)
	{
		RefreshingLabel.SetVisibility(true);
	}

	// Add a delegate for when the search completes.  We will use this callback to do any post searching work.
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);

	// Start a search
	if ( !SearchDataStore.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex), false) )
	{
		RefreshingLabel.SetVisibility(false);
	}

	// update the server count label and button states while we're waiting for the query results
	UpdateServerCount();
	UpdateButtonStates();
}

/**
 * Delegate fired each time a new server is recieved, or when the action completes (if there was an error)
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnFindOnlineGamesCompleteDelegate(bool bWasSuccessful)
{
	local bool bSearchCompleted;

	bSearchCompleted = !SearchDataStore.HasOutstandingQueries();
	`Log(`location @ `showvar(bWasSuccessful) @ `showvar(bSearchCompleted),,'SBDEBUG');

	// Hide refreshing label.
	if ( RefreshingLabel != None )
	{
		RefreshingLabel.SetVisibility(false);
	}

	// update the server count label
	UpdateServerCount();

	if ( bSearchCompleted )
	{
		// Clear delegate
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);

		OnFindOnlineGamesComplete(bWasSuccessful);
	}

	// update the enabled state of the button bar buttons
	UpdateButtonStates();
}

/**
 * Delegate fired when the search for an online game has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnFindOnlineGamesComplete(bool bWasSuccessful)
{
}

/**
 * Updates the server count label with the number of servers received so far for the currently selected gametype.
 */
function UpdateServerCount()
{
	local int ServerCount;
	local OnlineGameSearch CurrentSearch;

	if ( ServerCountLabel != None && SearchDataStore != None )
	{
		CurrentSearch = SearchDataStore.GetCurrentGameSearch();
		if ( CurrentSearch != None )
		{
			ServerCount = CurrentSearch.Results.Length;
		}
	}

	SetDataStoreStringValue("<SceneData:NumServersReceived>", string(ServerCount), GetScene(), GetPlayerOwner(GetBestPlayerIndex()));
	if ( ServerCountLabel != None )
	{
		ServerCountLabel.RefreshSubscriberValue();
	}
}

/** Refreshes the game details list using the currently selected item in the server list. */
function RefreshDetailsList()
{
	if ( SearchDataStore != None )
	{
		SearchDataStore.ServerDetailsProvider.SearchResultsRow = ServerList.GetCurrentItem();
	}

	DetailsList.RefreshSubscriberValue();
	MutatorList.RefreshSubscriberValue();
}

/**
 * Opens a custom UIScene which displays more verbose details about the server currently selected in the server browser.
 * Console only.
 */
function ShowServerDetails()
{
	local int ServerIndex;

	if ( SearchDataStore != None )
	{
		ServerIndex = SearchDataStore.ServerDetailsProvider.SearchResultsRow;
		if ( ServerIndex != INDEX_NONE )
		{
			UTUIScene(GetScene()).OpenSceneByName("UI_Scenes_FrontEnd.Popups.ServerDetails");
		}
		else
		{
			//@todo - play error sound?  this shouldn't happen because we disable the button in this case.
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

	bResult=false;

	if(EventParms.EventType==IE_Released)
	{
		if ( EventParms.InputKeyName=='XboxTypeS_X' )
		{
			OnButtonBar_Refresh(GetButtonBarButton(RefreshButtonIdx), EventParms.PlayerIndex);
			bResult=true;
		}
		else if( EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape' )
		{
			OnButtonBar_Back(GetButtonBarButton(0), EventParms.PlayerIndex);
			bResult=true;
		}
		else if ( EventParms.InputKeyName == 'XboxTypeS_Y' && IsConsole() )
		{
			OnButtonBar_ServerDetails(GetButtonBarButton(DetailsButtonIdx), EventParms.PlayerIndex);
			bResult = true;
		}
	}

	return bResult;
}

/** ButtonBar - JoinServer */
function bool OnButtonBar_JoinServer(UIScreenObject InButton, int InPlayerIndex)
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		// we must have a valid server selected in order to activate the Join Server button
		JoinServer();
	}
	return true;
}

/** ButtonBar - Back */
function bool OnButtonBar_Back(UIScreenObject InButton, int InPlayerIndex)
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		OnBack();
	}
	return true;
}

/** ButtonBar - Refresh */
function bool OnButtonBar_Refresh(UIScreenObject InButton, int InPlayerIndex)
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		RefreshServerList(InPlayerIndex);
	}
	return true;
}

/** ButtonBar - ServerDetails (console only) */
function bool OnButtonBar_ServerDetails( UIScreenObject InButton, int InPlayerIndex )
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		ShowServerDetails();
	}
	return true;
}

/** Server List - Submit Selection. */
function OnServerList_SubmitSelection( UIList Sender, int PlayerIndex )
{
	OnButtonBar_JoinServer(GetButtonBarButton(JoinButtonIdx), PlayerIndex);
}

/** Server List - Value Changed. */
function OnServerList_ValueChanged( UIObject Sender, int PlayerIndex )
{
	`log(`location,,'SBDEBUG');

	RefreshDetailsList();
	if ( IsVisible() )
	{
		UpdateButtonStates();
	}
	else
	{
		bGametypeOutdated = true;
	}
}

/**
 * Retrieve the index in the game search data store's list of search results for the specified gametype class
 *
 * @param	GameClassName	the path name of the gametype to find; if not specified, uses the currently selected gametype
 *
 * @return	the index into the UIDataStore_OnlineGameSearch's GameSearchCfgList array for the gametype specified.
 */
function int GetGameTypeSearchProviderIndex( optional string GameClassName )
{
	local int ProviderIdx;
	local string SearchTag;

	ProviderIdx = INDEX_NONE;
	if ( GameClassName == "" )
	{
		// if no gametype was specified, use the currently selected gametype
		GetDataStoreStringValue("<UTGameSettings:CustomGameMode>", GameClassName);
	}

	if ( GameClassName != "" && MenuItemDataStore != None && SearchDataStore != None )
	{
		// in order to find the search datastore index for the gametype, we need to get its search tag.  This comes from
		// the menu items data store (for some reason)
		// first, find the location of this gametype in the UTMenuItems data store's list of gametypes
		ProviderIdx = MenuItemDataStore.FindValueInProviderSet('GameModeFilter', 'GameMode', GameClassName);

		// now that we know the index into the UTMenuItems data store, we can retrieve the tag that is used to identify the corresponding
		// game search configuration in the Game Search data store.
		if (ProviderIdx != INDEX_NONE
		&&	MenuItemDataStore.GetValueFromProviderSet('GameModeFilter', 'GameSearchClass', ProviderIdx, SearchTag)
		&&	SearchTag != "")
		{
			ProviderIdx = SearchDataStore.FindSearchConfigurationIndex(name(SearchTag));
		}
		else
		{
			ProviderIdx = INDEX_NONE;
		}
	}

	return ProviderIdx;
}

/**
 * Called when the user changes the currently selected gametype via the gametype combo.
 *
 * @param	Sender			the UIObject whose value changed
 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
function OnGameTypeChanged( UIObject Sender, int PlayerIndex )
{
	local int ProviderIdx;
	local array<UIDataStore> BoundDataStores;
	local string GameTypeClassName;

	`log(`location,,'SBDEBUG');
	if (!IsConsole() && IsVisible()
	&&	GameTypeCombo != None && GameTypeCombo.ComboList != None

	// calling SaveSubscriberValue on the combobox list will set the currently selected gametype as the value for the UTMenuItems:GameModeFilter field
	&&	GameTypeCombo.ComboList.SaveSubscriberValue(BoundDataStores)

	// so now we just retrieve this field
	&&	GetDataStoreStringValue("<UTMenuItems:GameModeFilterClass>", GameTypeClassName))
	{
		// make sure to update the GameSettings value - this is used to build the join URL
		SetDataStoreStringValue("<UTGameSettings:CustomGameMode>", GameTypeClassName);

		// find the index into the UTMenuItems data store for the gametype with the specified class name
		ProviderIdx = GetGameTypeSearchProviderIndex(GameTypeClassName);
		`Log(`location@"- Game mode filter class set to" @ GameTypeClassName @ "(" $ ProviderIdx $ ")");

		if ( ProviderIdx != INDEX_NONE )
		{
			MenuItemDataStore.GameModeFilter = ProviderIdx;

			// update the online game search data store's current gametype
			SearchDataStore.SetCurrentByIndex(ProviderIdx, false);
			OnSwitchedGameType();

			ConditionalRefreshServerList(PlayerIndex);
		}
	}
}

/**
 * Notification that the currently selected gametype was changed externally.  Update this tab page to reflect the new
 * gametype.
 */
function NotifyGameTypeChanged()
{
	`log(`location@`showvar(IsVisible()),,'SBDEBUG');
	if ( IsVisible() )
	{
		if (GameTypeCombo != None && !IsConsole())
		{
			// update the gametype combo to reflect the currently selected gametype.  This will cause OnGameTypeChanged
			// to be called
			GameTypeCombo.ComboList.RefreshSubscriberValue();
		}
		else
		{
			ConditionalRefreshServerList(GetBestPlayerIndex());
		}
	}
	else
	{
		// set a bool to indicate that a new query should be submitted when this tab page is shown
		bGametypeOutdated = true;
	}
}

defaultproperties
{
	JoinButtonIdx=INDEX_NONE
	RefreshButtonIdx=INDEX_NONE
	DetailsButtonIdx=INDEX_NONE
}
