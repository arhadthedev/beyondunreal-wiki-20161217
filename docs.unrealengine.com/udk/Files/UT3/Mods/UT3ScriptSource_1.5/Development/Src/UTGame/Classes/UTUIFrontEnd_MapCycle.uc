/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * UI scene that allows the user to setup a map cycle.
 */
class UTUIFrontEnd_MapCycle extends UTUIFrontEnd
	dependson(UTGame, UTMapListManager);

/** List of available maps. */
var transient UIList AvailableList;

/** List of enabled maps. */
var transient UIList EnabledList;

/** The last focused UI List. */
var transient UIList LastFocused;

/** Label describing the currently selected map. */
var transient UILabel DescriptionLabel;

/** Arrow images. */
var transient UIImage ShiftRightImage;
var transient UIImage ShiftLeftImage;

/** Reference to the menu datastore */
var transient UTUIDataStore_MenuItems MenuDataStore;

/** If the mapcycle has been loaded from a named maplist, reference it here */
var transient UTMapList LoadedMapList;


/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Store widget references
	AvailableList = UIList(FindChild('lstAvailable', true));
	LastFocused = AvailableList;
	AvailableList.OnValueChanged = OnAvailableList_ValueChanged;
	AvailableList.OnSubmitSelection = OnAvailableList_SubmitSelection;
	AvailableList.NotifyActiveStateChanged = OnAvailableList_NotifyActiveStateChanged;
	AvailableList.OnRawInputKey = OnMapList_RawInputKey;

	EnabledList = UIList(FindChild('lstEnabled', true));
	EnabledList.OnValueChanged = OnEnabledList_ValueChanged;
	EnabledList.OnSubmitSelection = OnEnabledList_SubmitSelection;
	EnabledList.NotifyActiveStateChanged = OnEnabledList_NotifyActiveStateChanged;
	EnabledList.OnRawInputKey = OnMapList_RawInputKey;

	DescriptionLabel = UILabel(FindChild('lblDescription', true));
	ShiftRightImage = UIImage(FindChild('imgArrowLeft', true));
	ShiftLeftImage = UIImage(FindChild('imgArrowRight', true));


	// Get reference to the menu datastore
	MenuDataStore = UTUIDataStore_MenuItems(GetCurrentUIController().DataStoreManager.FindDataStore('UTMenuItems'));

	LoadMapCycle();
}

function name GetCurrentGameMode()
{
	local string GameMode;
	local int i;

	GetDataStoreStringValue("<Registry:SelectedGameMode>", GameMode);

	// Strip out package so we just have class name
	i = InStr(GameMode, ".");

	if (i != INDEX_None)
		GameMode = Mid(GameMode, i+1);

	return name(GameMode);
}

function name GetCurrentGameModeFull()
{
	local string GameMode;

	GetDataStoreStringValue("<Registry:SelectedGameMode>", GameMode);
	return name(GameMode);
}

function string StripOptions(coerce string InURL)
{
	local int i;

	i = InStr(InURL, "?");

	if (i == -1)
		return InUrl;


	return Left(InURL, i);
}

function string GrabOptions(string InURL)
{
	local int i;

	i = InStr(InURL, "?");

	if (i == -1)
		return "";

	return Mid(InURL, i);
}

/** Loads the map cycle for the current game mode and sets up the datastore's lists. */
function LoadMapCycle()
{
	local int MapIdx, LocateIdx, CycleIdx;
	local name GameMode, MapListName;
	local string FullGameMode, Options;
	local GameProfile NewGameProfile;

	MenuDataStore.MapCycle.length = 0;
	GameMode = GetCurrentGameMode();

	if (GameMode == 'None')
		return;


	// Load the maplist
	FullGameMode = string(GetCurrentGameModeFull());
	Options = GrabOptions(FullGameMode);

	if (Options != "")
	{
		GameMode = name(StripOptions(GameMode));
		FullGameMode = StripOptions(FullGameMode);
	}

	CycleIdx = Class'UTMapListManager'.static.StaticGetCurrentGameProfileIndex();

	if (CycleIdx == INDEX_None || !(Class'UTMapListManager'.default.GameProfiles[CycleIdx].GameClass ~= FullGameMode))
		CycleIdx = Class'UTMapListManager'.static.StaticFindGameProfileIndex(FullGameMode);

	// Create a new vote profile if necessary
	if (CycleIdx == INDEX_None)
	{
		NewGameProfile = Class'UTMapListManager'.static.CreateNewGameProfile(FullGameMode,, GameMode, Options);
		CycleIdx = Class'UTMapListManager'.default.GameProfiles.AddItem(NewGameProfile);
		Class'UTMapListManager'.static.StaticSaveConfig();
	}

	// Load the profiles maplist (creating it if it doesn't yet exist)
	MapListName = Class'UTMapListManager'.default.GameProfiles[CycleIdx].MapListName;
	LoadedMapList = Class'UTMapListManager'.static.StaticGetMapListByName(MapListName, True);

	// Now transfer the maplist data to the data store
	for (MapIdx=0; MapIdx<LoadedMapList.Maps.Length; ++MapIdx)
	{
		LocateIdx = MenuDataStore.FindValueInProviderSet('Maps', 'MapName', LoadedMapList.GetMap(MapIdx));

		if (LocateIdx != INDEX_None)
			MenuDataStore.MapCycle.AddItem(LocateIdx);
	}


	OnMapListChanged();
}

/** Converts the current map cycle to a string map names and stores them in the config saved array. */
function GenerateMapCycleList(out GameMapCycle Cycle)
{
	local int MapIdx;
	local string MapName;

	Cycle.Maps.length = 0;

	for(MapIdx=0; MapIdx<MenuDataStore.MapCycle.length; MapIdx++)
	{
		if(MenuDataStore.GetValueFromProviderSet('Maps', 'MapName', MenuDataStore.MapCycle[MapIdx], MapName))
		{
			Cycle.Maps.AddItem(MapName);
		}
	}
}

/** Added for maplist objects. */
function GenerateMapCycleListNew(out UTMapList MLObj)
{
	local int MapIdx, i;
	local string MapName;

	MLObj.Maps.Length = 0;

	for (MapIdx=0; MapIdx<MenuDataStore.MapCycle.length; ++MapIdx)
	{
		if(MenuDataStore.GetValueFromProviderSet('Maps', 'MapName', MenuDataStore.MapCycle[MapIdx], MapName))
		{
			i = MLObj.Maps.Length;
			MLObj.Maps.Length = i + 1;
			MLObj.SetMap(i, MapName);
		}
	}
}

/** Transfers the current map cycle in the menu datastore to our array of config saved map cycles for each gamemode. */
function SaveMapCycle()
{
	GenerateMapCycleListNew(LoadedMapList);

	// Reset the maplists last active map, and save
	LoadedMapList.SetLastActiveIndex(INDEX_None);
	LoadedMapList.SaveConfig();
}

/** Sets up the button bar for the parent scene. */
function SetupButtonBar()
{
	ButtonBar.Clear();
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Cancel>", OnButtonBar_Back);
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Accept>", OnButtonBar_Accept);

	if(EnabledList != None)
	{
		if(LastFocused==EnabledList)
		{
			if(EnabledList.Items.length > 0)
			{
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.RemoveMap>", OnButtonBar_MoveMap);
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ShiftUp>", OnButtonBar_ShiftUp);
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ShiftDown>", OnButtonBar_ShiftDown);
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ClearAll>", OnButtonBar_ClearMaps);
			}
		}
		else
		{
			if(AvailableList.Items.length > 0)
			{
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.AddMap>", OnButtonBar_MoveMap);
			}
		}
	}
}

/** Called whenever one of the map lists changes. */
function OnMapListChanged()
{
	local int EnabledIndex;
	local int AvailableIndex;

	AvailableIndex = AvailableList.Index;
	EnabledIndex = EnabledList.Index;

	// Have both lists refresh their subscriber values
	AvailableList.RefreshSubscriberValue();
	EnabledList.RefreshSubscriberValue();

	AvailableList.SetIndex(AvailableIndex);
	EnabledList.SetIndex(EnabledIndex);
}

/** Clears the enabled map list. */
function OnClearMaps()
{
	MenuDataStore.MapCycle.length=0;
	OnMapListChanged();

	// Set focus to the available list.
	AvailableList.SetFocus(none);
	OnSelectedMapChanged();
}

/** Updates widgets when the currently selected map changes. */
function OnSelectedMapChanged()
{
	UpdateDescriptionLabel();
	SetupButtonBar();

	// Update arrows
	if(LastFocused==EnabledList)
	{
		ShiftLeftImage.SetEnabled(false);
		ShiftRightImage.SetEnabled(true);
	}
	else
	{
		ShiftLeftImage.SetEnabled(true);
		ShiftRightImage.SetEnabled(false);
	}
}

/** Callback for when the user tries to move a map from one list to another. */
function OnMoveMap()
{
	local int MapId;

	if(LastFocused==AvailableList)
	{
		if(AvailableList.Items.length > 0)
		{	
			MapId = AvailableList.GetCurrentItem();
			if(MenuDataStore.MapCycle.Find(MapId)==INDEX_NONE)
			{
				MenuDataStore.MapCycle.AddItem(MapId);
				OnMapListChanged();
			}

			if(AvailableList.Items.length==0)
			{
				EnabledList.SetFocus(none);
			
			}
		}
	}
	else
	{
		if(EnabledList.Items.length > 0)
		{
			MapId = EnabledList.GetCurrentItem();
			if(MenuDataStore.MapCycle.Find(MapId)!=INDEX_NONE)
			{
				MenuDataStore.MapCycle.RemoveItem(MapId);

				// If we removed all of the enabled maps, set focus back to the available list.
				if(MenuDataStore.MapCycle.length==0 && EnabledList.IsFocused())
				{
					AvailableList.SetFocus(none);
				}

				OnMapListChanged();
			}

			if(EnabledList.Items.length==0)
			{
				AvailableList.SetFocus(none);
			}
		}
	}

	OnSelectedMapChanged();
}

/** Shifts maps up and down in the map cycle. */
function OnShiftMap(bool bShiftUp)
{
	local int SelectedItem;
	local int SwapItem;
	local int NewIndex;

	SelectedItem = EnabledList.Index;

	if(bShiftUp)
	{
		NewIndex = SelectedItem-1;
	}
	else
	{
		NewIndex = SelectedItem+1;
	}

	if(NewIndex >= 0 && NewIndex < MenuDataStore.MapCycle.length)
	{
		SwapItem = MenuDataStore.MapCycle[NewIndex];
		MenuDataStore.MapCycle[NewIndex] = MenuDataStore.MapCycle[SelectedItem];
		MenuDataStore.MapCycle[SelectedItem] = SwapItem;

		OnMapListChanged();

		EnabledList.SetIndex(NewIndex);
	}
}

/** The user has finished setting up their cycle and wants to save changes. */
function OnAccept()
{
	SaveMapCycle();

	CloseScene(self);
}

/** The user wants to back out of the map cycle scene. */
function OnBack()
{
	CloseScene(self);
}

/** Updates the description label. */
function UpdateDescriptionLabel()
{
	local string NewDescription;
	local int SelectedItem;

	SelectedItem = LastFocused.GetCurrentItem();

	if(class'UTUIMenuList'.static.GetCellFieldString(LastFocused, 'Description', SelectedItem, NewDescription))
	{
		DescriptionLabel.SetDataStoreBinding(NewDescription);
	}
}

/**
 * Callback for when the user selects a new item in the available list.
 */
function OnAvailableList_ValueChanged( UIObject Sender, int PlayerIndex )
{
	OnSelectedMapChanged();
}

/**
 * Callback for when the user submits the selection on the available list.
 */
function OnAvailableList_SubmitSelection( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() )
{
	OnMoveMap();
}

/** Callback for when the object's active state changes. */
function OnAvailableList_NotifyActiveStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	if(NewlyActiveState.Class == class'UIState_Focused'.default.Class)
	{
		LastFocused = AvailableList;
		OnSelectedMapChanged();
	}
}

/**
 * Callback for when the user selects a new item in the enabled list.
 */
function OnEnabledList_ValueChanged( UIObject Sender, int PlayerIndex )
{
	OnSelectedMapChanged();
}

/**
 * Callback for when the user submits the selection on the enabled list.
 */
function OnEnabledList_SubmitSelection( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() )
{
	OnMoveMap();
}

/** Callback for when the object's active state changes. */
function OnEnabledList_NotifyActiveStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	if(NewlyActiveState.Class == class'UIState_Focused'.default.Class)
	{
		LastFocused = EnabledList;
		OnSelectedMapChanged();
	}
}


/** Callback for the map lists, captures the accept button before the lists get to it. */
function bool OnMapList_RawInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;

	bResult = false;

	if(EventParms.EventType==IE_Released && EventParms.InputKeyName=='XboxTypeS_A')
	{
		OnAccept();
		bResult = true;
	}

	return bResult;
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_Accept(UIScreenObject InButton, int PlayerIndex)
{
	OnAccept();

	return true;
}

function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	OnBack();

	return true;
}

function bool OnButtonBar_ClearMaps(UIScreenObject InButton, int PlayerIndex)
{
	OnClearMaps();

	return true;
}

function bool OnButtonBar_MoveMap(UIScreenObject InButton, int PlayerIndex)
{
	OnMoveMap();

	return true;
}

function bool OnButtonBar_ShiftUp(UIScreenObject InButton, int PlayerIndex)
{
	OnShiftMap(true);

	return true;
}

function bool OnButtonBar_ShiftDown(UIScreenObject InButton, int PlayerIndex)
{
	OnShiftMap(false);

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

	bResult=false;

	if(EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_A' || EventParms.InputKeyName=='XboxTypeS_Enter')	// Accept Cycle
		{
			OnAccept();

			bResult=true;
		}
		if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')				// Cancel
		{
			OnBack();

			bResult=true;
		}
		else if(EventParms.InputKeyName=='XboxTypeS_Y')		// Move map
		{
			OnMoveMap();

			bResult=true;
		}
		else if(EventParms.InputKeyName=='XboxTypeS_X')		// Clear map cycle
		{
			OnClearMaps();

			bResult=true;
		}
		else if(EventParms.InputKeyName=='XboxTypeS_LeftShoulder')
		{
			OnShiftMap(true);

			bResult=true;
		}
		else if(EventParms.InputKeyName=='XboxTypeS_RightShoulder')
		{
			OnShiftMap(false);

			bResult=true;
		}
	}

	return bResult;
}


