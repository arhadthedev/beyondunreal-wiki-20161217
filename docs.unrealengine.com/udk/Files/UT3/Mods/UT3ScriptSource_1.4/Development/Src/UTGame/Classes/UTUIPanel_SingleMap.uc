/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Single map screen for UT3.
 */

class UTUIPanel_SingleMap extends UTTabPage
	placeable
	dependson(UTMapListManager);

/** Preview image for a map. */
var transient UIImage	MapPreviewImage;

/** Description label for the map. */
var transient UILabel	DescriptionLabel;

/** NumPlayers label for the map. */
var transient UILabel	NumPlayersLabel;

/** List of maps widget. */
var transient UTUIList MapList;

/** scrollframe which contains the description label - allows the player to read long descriptions */
var	transient UIScrollFrame DescriptionScroller;

/** Delegate for when the user selects a map on this page. */
delegate OnMapSelected();

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Setup delegates
	MapList = UTUIList(FindChild('lstMaps', true));
	if(MapList != none)
	{
		MapList.OnSubmitSelection = OnMapList_SubmitSelection;
		MapList.OnValueChanged = OnMapList_ValueChanged;
	}

	// Store widget references
	MapPreviewImage = UIImage(FindChild('imgMapPreview1', true));

	DescriptionLabel = UILabel(FindChild('lblDescription', true));
	NumPlayersLabel = UILabel(FindChild('lblNumPlayers', true));

	DescriptionScroller = UIScrollFrame(FindChild('DescriptionScrollFrame',true));
	
	// if we're on a console platform, make the scrollframe not focusable.
	if ( IsConsole() && DescriptionScroller != None )
	{
		DescriptionScroller.SetPrivateBehavior(PRIVATE_NotFocusable, true);
	}
}

/** @return Returns the current game mode. */
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

/** Sets up a map cycle consisting of 1 map. */
function SetupMapCycle(string SelectedMap)
{
	local string FullGameMode, Options;
	local name GameMode, MapListName;
	local int i;
	local GameProfile NewGameProfile;
	local UTMapList MLObj;

	// Determine the game profile that will be in use
	FullGameMode = string(GetCurrentGameModeFull());
	Options = GrabOptions(FullGameMode);

	if (Options != "")
	{
		GameMode = name(StripOptions(GetCurrentGameMode()));
		FullGameMode = StripOptions(FullGameMode);
	}

	i = Class'UTMapListManager'.static.StaticGetCurrentGameProfileIndex();

	if (i == INDEX_None || !(Class'UTMapListManager'.default.GameProfiles[i].GameClass ~= FullGameMode))
		i = Class'UTMapListManager'.static.StaticFindGameProfileIndex(FullGameMode);


	// Create a new profile if necessary
	if (i == INDEX_None)
	{
		NewGameProfile = Class'UTMapListManager'.static.CreateNewGameProfile(FullGameMode,, GameMode, Options);
		i = Class'UTMapListManager'.default.GameProfiles.AddItem(NewGameProfile);
		Class'UTMapListManager'.static.StaticSaveConfig();
	}

	// Load the profiles maplist (creating it if it doesn't yet exist)
	MapListName = Class'UTMapListManager'.default.GameProfiles[i].MapListName;
	MLObj = Class'UTMapListManager'.static.StaticGetMapListByName(MapListName, True);

	MLObj.Maps.Length = 1;
	MLObj.SetMap(0, SelectedMap);

	// Save the maplist
	MLObj.SaveConfig();
}

/** @return Returns the currently selected map. */
function string GetSelectedMap()
{
	local int SelectedItem;
	local string MapName;

	MapName="";
	SelectedItem = MapList.GetCurrentItem();
	class'UTUIMenuList'.static.GetCellFieldString(MapList, 'MapName', SelectedItem, MapName);

	SetupMapCycle(MapName);

	return MapName;
}

/**
 * Called when the user changes the current list index.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnMapList_SubmitSelection( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() )
{
	OnMapSelected();
}

/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnMapList_ValueChanged( UIObject Sender, optional int PlayerIndex=0 )
{
	local int SelectedItem;
	local string StringValue;


	SelectedItem = MapList.GetCurrentItem();

	// Preview Image
	if(class'UTUIMenuList'.static.GetCellFieldString(MapList, 'PreviewImageMarkup', SelectedItem, StringValue))
	{
		SetPreviewImageMarkup(StringValue);
	}

	// Map Description
	if(class'UTUIMenuList'.static.GetCellFieldString(MapList, 'Description', SelectedItem, StringValue))
	{
		DescriptionLabel.SetDatastoreBinding(StringValue);
	}

	// Num Players
	if(class'UTUIMenuList'.static.GetCellFieldString(MapList, 'NumPlayers', SelectedItem, StringValue))
	{
		NumPlayersLabel.SetDatastoreBinding(StringValue);
	}
}

/** Changes the preview image for a map. */
function SetPreviewImageMarkup(string InMarkup)
{
	MapPreviewImage.SetDatastoreBinding(InMarkup);
}
