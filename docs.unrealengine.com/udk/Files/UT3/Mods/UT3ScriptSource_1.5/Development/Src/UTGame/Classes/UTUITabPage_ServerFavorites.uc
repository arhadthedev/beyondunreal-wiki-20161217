/**
 * This class is a specialized server browser which displays only those servers which the player has marked as a favorite.
 * This server browser does not respect filter options.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UTUITabPage_ServerFavorites extends UTUITabPage_ServerBrowser;

var	transient	int		RemoveFavoriteIdx;
var transient int AddIPIdx;

/** Reference to the query helper object, which performs the query for retrieving server details from an IP */
var UTQueryHelper QueryHelper;


/**
 * Sets the correct tab button caption.
 */
event PostInitialize()
{
	Super.PostInitialize();

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.JoinGame.Favorites>");

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
	return UTDataStore_GameSearchFavorites(SearchDataStore);
}

/**
 * Provides an easy way for child classes to add additional buttons before the ButtonBar's button states are updated
 */
function SetupExtraButtons( UTUIButtonBar ButtonBar )
{
	//Commented out because I moved "Add Favorites" to ServerBrowser
	//Super.SetupExtraButtons(ButtonBar);

	if ( ButtonBar != None )
	{
		RemoveFavoriteIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.RemoveFromFavorite>", OnButtonBar_RemoveFavorite);
		AddIPIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.AddIP>", OnButtonBar_AddIP);

		if (AddIPIdx == INDEX_None)
		{
			// Nasty hack: Remove the 'back' button so that there is room for the 'add ip' button
			ButtonBar.ClearButton(0);
			BackButtonIdx = INDEX_None;
			CancelButtonIdx = INDEX_None;

			AddIPIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.AddIP>", OnButtonBar_AddIP);
		}
	}
}

/**
 * Updates the enabled state of certain button bar buttons depending on whether a server is selected or not.
 */
function UpdateButtonStates()
{
	local UTUIButtonBar ButtonBar;
	local UITabControl TabControlOwner;
	local bool bValidServerSelected;

	Super.UpdateButtonStates();

	TabControlOwner = GetOwnerTabControl();
	if ( (RemoveFavoriteIdx != INDEX_NONE || AddIPIdx != INDEX_None) && TabControlOwner != None && TabControlOwner.ActivePage == Self )
	{
		ButtonBar = GetButtonBar();
		if ( ButtonBar != None )
		{
			bValidServerSelected = ServerList != None && ServerList.GetCurrentItem() != INDEX_NONE;
			if ( RemoveFavoriteIdx != InDEX_NONE )
			{
				ButtonBar.Buttons[RemoveFavoriteIdx].SetEnabled(bValidServerSelected && HasSelectedServerInFavorites(GetBestControllerId()));
			}

			if (AddIPIdx != INDEX_None)
				ButtonBar.Buttons[AddIPIdx].SetEnabled(True);
		}
	}
}


/** ButtonBar - Remove from favorite */
function bool OnButtonBar_RemoveFavorite(UIScreenObject InButton, int InPlayerIndex)
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		RemoveFavorite(InPlayerIndex);
	}
	return true;
}

/** ButtonBar - Add IP to favourites */
function bool OnButtonBar_AddIP(UIScreenObject InButton, int InPlayerIndex)
{
	local UTUIScene CurScene;
	local UTUIScene_InputBox IPInputScene;

	CurScene = UTUIScene(GetScene());

	// Display a dialog box where the player can enter the servers IP and port
	if (CurScene != none)
		IPInputScene = CurScene.GetInputBoxScene();

	if (IPInputScene != none)
	{
		IPInputScene.DisplayAcceptCancelBox("<Strings:UTGameUI.MessageBox.AddServerIP_Message>",
							"<Strings:UTGameUI.MessageBox.AddServerIP_Title>",
							OnAddIPDialog_Closed);
	}
	else
	{
		`log("Failed to open the input box scene");
	}


	return True;
}


/**
 * Removes the currently selected server from the list of favorites
 */
function RemoveFavorite( int inPlayerIndex )
{
	local int CurrentSelection, ControllerId;
	local OnlineGameSearchResult SelectedGame;
	local UTDataStore_GameSearchFavorites FavsDataStore;
	local UITabControl TabControlOwner;

	CurrentSelection = ServerList.GetCurrentItem();
	if ( SearchDataStore.GetSearchResultFromIndex(CurrentSelection, SelectedGame) )
	{
		ControllerId = GetBestControllerId();
		FavsDataStore = GetFavoritesDataStore();

		// if this server is in the list of favorites
		if ( FavsDataStore != None && HasServerInFavorites(ControllerId, SelectedGame.GameSettings.OwningPlayerId) )
		{
			// remove it
			if ( FavsDataStore.RemoveServer(ControllerId, SelectedGame.GameSettings.OwningPlayerId) )
			{
				TabControlOwner = GetOwnerTabControl();
				if ( TabControlOwner != None && TabControlOwner.ActivePage == Self )
				{
					RefreshServerList(inPlayerIndex);
				}
			}
		}
	}
}

function OnAddIPDialog_Closed(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	local string ServerIP;
	local UTUIScene CurScene;

	if (SelectedOption == 0)
	{
		CurScene = UTUIScene(GetScene());
		ServerIP = UTUIScene_InputBox(MessageBox).GetValue();

		if (CurScene != none && ServerIP != "")
		{
			if (QueryHelper == none)
				QueryHelper = Class'UTQueryHelper'.static.GetQueryHelper(CurScene);


			QueryHelper.OnFindServerByIPComplete = FindServerByIPComplete;

			// Find the server, and if that fails, display an error
			if (!QueryHelper.FindServerByIP(ServerIP))
			{
				QueryHelper.DisplayFindIPError();

				QueryHelper.Release();
				QueryHelper = none;
			}
		}
	}
}

function FindServerByIPComplete(OnlineGameSearchResult Result)
{
	local int ControllerID;
	local UTDataStore_GameSearchFavorites FavDataStore;

	if (Result.GameSettings != none)
	{
		ControllerID = GetBestControllerID();
		FavDataStore = GetFavoritesDataStore();

		if (FavDataStore != none)
		{
			// Check that the server isn't already in favourites before adding it (N.B. '
			if (!HasServerInFavorites(ControllerID, Result.GameSettings.OwningPlayerID) && FavDataStore.AddServerPlusIP(
				ControllerID, Result.GameSettings.OwningPlayerID, Result.GameSettings.OwningPlayerName,
				Result.GameSettings.ServerIP))
			{
				RefreshServerList(GetBestPlayerIndex());
			}
			else
			{
				QueryHelper.DisplayFindIPError(,, QE_Custom, Localize("MessageBox", "AddIPAlreadyPresent_Message", "UTGameUI"));
			}
		}
		else
		{
			// So unlikely it's not worth localizing
			QueryHelper.DisplayFindIPError(,, QE_Custom, "Invalid Favorites Data store");
		}
	}
	else
	{
		QueryHelper.DisplayFindIPError(,, QE_InvalidResult);
	}

	QueryHelper.Release();
	QueryHelper = none;
}


DefaultProperties
{
	SearchDSName=UTGameFavorites
	RemoveFavoriteIdx=INDEX_NONE
}
