/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for a set of options to filter join game server results by.
 */

class UTUITabPage_ServerFilter extends UTUITabPage_Options
	placeable;

`include(Core/Globals.uci)

/** Reference to the menu items datastore. */
var UTUIDataStore_MenuItems	MenuDataStore;

/** Reference to the game search datastore. */
var UTDataStore_GameSearchDM SearchDataStore;

/** Indicates that the list of options are out of date and need to be regenerated */
var	private transient bool bOptionsDirty;

/** Called when the user changes the game type */
delegate transient OnSwitchedGameType();

/* == Events == */
/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.JoinGame.Filter>");

	MenuDataStore = UTUIDataStore_MenuItems(UTUIScene(GetScene()).FindDataStore('UTMenuItems'));
	SearchDataStore = UTDataStore_GameSearchDM(UTUIScene(GetScene()).FindDataStore('UTGameSearch'));
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

	if ( bResult && bActivate && bOptionsDirty )
	{
		`log(`location@`showvar(bOptionsDirty),,'SBDEBUG');
		OptionList.RefreshAllOptions();
		bOptionsDirty = false;
	}

	return bResult;
}

/**
 * Marks the options list as out of date and if visible, refreshes the options list.  Called when the user
 * changes the gametype.
 */
function MarkOptionsDirty()
{
	if ( IsVisible() )
	{
		OptionList.RefreshAllOptions();
		bOptionsDirty = false;
	}
	else
	{
		bOptionsDirty = true;
	}
}

/**
 * Enables / disables the "match type" control based on whether we are signed in online.
 */
function ValidateServerType()
{
	local int PlayerIndex, ValueIndex, PlayerControllerID;
	local UIObject ServerTypeOption;
	local UTUIScene UTOwnerScene;
	local name MatchTypeName;
	local string OnlineProfileRequiredMessage;


	UTOwnerScene = UTUIScene(GetScene());
	if ( UTOwnerScene != None && StringListDataStore != None )
	{
		OnlineProfileRequiredMessage = "<Strings:UTGameUI.Errors.OnlineRequiredForInternet_Message>";
		MatchTypeName = IsConsole(CONSOLE_XBox360) ? 'MatchType360' : 'MatchType';

		// find the "MatchType" control (contains the "LAN" and "Internet" options);  if we aren't signed in online,
		// don't have a link connection, or not allowed to play online, don't allow them to select one.
		PlayerIndex = UTOwnerScene.GetPlayerIndex();
		PlayerControllerID = UTOwnerScene.GetPlayerControllerId( PlayerIndex );
		if ( !UTOwnerScene.CheckLoginAndError( PlayerControllerID,true,,OnlineProfileRequiredMessage) || !UTOwnerScene.CheckOnlinePrivilegeAndError( PlayerControllerID ) )
		{
			ServerTypeOption = FindChild('MatchType', true);
			if ( ServerTypeOption != None )
			{
				ValueIndex = StringListDataStore.GetCurrentValueIndex(MatchTypeName);
				if ( ValueIndex != class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN )
				{
					// make sure the "LAN" option is selected
					StringListDataStore.SetCurrentValueIndex(MatchTypeName,class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN);
					UIDataStoreSubscriber(ServerTypeOption).RefreshSubscriberValue();
				}

				//@todo ronp - should I be checking whether ServerTypeOption is the OptionList's selected item instead?
				if ( ServerTypeOption.IsFocused(PlayerIndex) )
				{
					// if the match type option is currently selected, activate the next one before we disable this one.
					OptionList.SelectNextItem(true);
				}

				// now disable the widget so it can't be changed.
				ServerTypeOption.DisableWidget(PlayerIndex);
			}
		}
	}
}

/** Pass through the option callback. */
function OnOptionList_OptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex)
{
	local string OutStringValue;
	local int ProviderIdx;
	local int OptionIdx, ValueIndex;
	local UIObject GameModeOption;
	local array<UIDataStore> OutDataStores;

	Super.OnOptionList_OptionChanged(InObject, OptionName, PlayerIndex);

	`log(`location@`showvar(OptionName),,'SBDEBUG');
	if(OptionName=='GameMode_Client')
	{
		OptionIdx = OptionList.GetObjectInfoIndexFromName('GameMode_Client');
		UIDataStorePublisher(OptionList.GeneratedObjects[OptionIdx].OptionObj).SaveSubscriberValue(OutDataStores);

		if(GetDataStoreStringValue("<UTMenuItems:GameModeFilterClass>", OutStringValue))
		{
			`Log("UTUITabPage_ServerFilter::OnOptionList_OptionChanged() - Game mode filter class set to "$OutStringValue);
			// make sure to update the GameSettings value - this is used to build the join URL
			SetDataStoreStringValue("<UTGameSettings:CustomGameMode>", OutStringValue);

			// find the index into the UTMenuItems data store for the gametype with the specified class name
			ProviderIdx = MenuDataStore.FindValueInProviderSet('GameModeFilter','GameMode', OutStringValue);

			// now that we know the index into the UTMenuItems data store, we can retrieve the tag that is used to identify the corresponding
			// game search object in the Game Search data store.
			if(ProviderIdx != INDEX_NONE && MenuDataStore.GetValueFromProviderSet('GameModeFilter','GameSearchClass', ProviderIdx, OutStringValue))
			{
				// Set the search settings class
				SearchDataStore.SetCurrentByName(name(OutStringValue), false);
			}

			// fire the delegate
			OnSwitchedGameType();
		}
	}
	else if ( OptionName == 'MatchType' || OptionName == 'MatchType360' )
	{
		GameModeOption = FindChild('GameModeFilter',true);
		if ( GameModeOption != None )
		{
			UIDataStorePublisher(OptionList.GeneratedObjects[OptionIdx].OptionObj).SaveSubscriberValue(OutDataStores);
			ValueIndex = StringListDataStore.GetCurrentValueIndex(OptionName);

			// if the user wants to search for LAN matches, disable the gametype combo
			GameModeOption.SetEnabled(ValueIndex != class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN);
		}
	}
}
