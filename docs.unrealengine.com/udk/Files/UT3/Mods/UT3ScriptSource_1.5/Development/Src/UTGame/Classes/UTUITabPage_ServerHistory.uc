/**
 * This class is a specialized server browser which displays the most recently visited servers.  It also allows the player
 * to move a server to the favorites list so that it doesn't get removed from the list if the player visits more servers than
 * the maximum number of servers allowed in the history.  This server browser does not respect filter options.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UTUITabPage_ServerHistory extends UTUITabPage_ServerBrowser;

`include(Core/Globals.uci)

/**
 * Sets the correct tab button caption.
 */
event PostInitialize()
{
	Super.PostInitialize();

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.JoinGame.History>");

	//Make sure the server details are bound to the right data store
	DetailsList.SetDataStoreBinding("<" $ SearchDSName $ ":CurrentServerDetails>");
	MutatorList.SetDataStoreBinding("<" $ SearchDSName $ ":CurrentServerMutators>");
	PlayerList.SetDataStoreBinding("<" $ SearchDSName $ ":CurrentServerPlayers>");
}

/**
 * Adjusts the layout of the scene based on the current platform
 */
function AdjustLayout()
{
	Super.AdjustLayout();

	// if we're on the console, the gametype combo will be hidden anyway
	if ( !IsConsole() && GameTypeCombo != None )
	{
		GameTypeCombo.SetVisibility(false);
	}
}

/**
 * Determines which type of matches the user wishes to search for (i.e. LAN, unranked, ranked, etc.)
 */
function int GetDesiredMatchType()
{
	// for history - always return unranked matches
	return SERVERBROWSER_SERVERTYPE_UNRANKED;
}

/**
 * Wrapper for getting a reference to the favorites data store.
 */
function UTDataStore_GameSearchFavorites GetFavoritesDataStore()
{
	local UTDataStore_GameSearchHistory HistorySearchDataStore;
	local UTDataStore_GameSearchFavorites Result;

	HistorySearchDataStore = UTDataStore_GameSearchHistory(SearchDataStore);
	if ( HistorySearchDataStore != None )
	{
		Result = HistorySearchDataStore.FavoritesGameSearchDataStore;
	}

	return Result;
}

/**
 * Provides an easy way for child classes to add additional buttons before the ButtonBar's button states are updated
 */
function SetupExtraButtons( UTUIButtonBar ButtonBar )
{
	Super.SetupExtraButtons(ButtonBar);
}

/**
 * Updates the enabled state of certain button bar buttons depending on whether a server is selected or not.
 */
function UpdateButtonStates()
{
	Super.UpdateButtonStates();
}

DefaultProperties
{
	SearchDSName=UTGameHistory
	AddFavoriteIdx=INDEX_NONE
}
