/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Settings scene for UT3.
 */
class UTUIFrontEnd_Settings extends UTUIFrontEnd_BasicMenu;

// Menu options
const SETTINGS_OPTION_VIDEO = 0;
const SETTINGS_OPTION_AUDIO = 1;
const SETTINGS_OPTION_INPUT = 2;
const SETTINGS_OPTION_NETWORK = 3;
const SETTINGS_OPTION_WEAPONS = 4;
const SETTINGS_OPTION_HUD = 5;
const SETTINGS_OPTION_CREDITS = 6;
const SETTINGS_OPTION_INSTALL = 7;

/** Reference to credits screen. */
var string	CreditsScene;

/** Reference to the actual scene that holds all of the settings panels. */
var string SettingsPanelsScene;

/** Index of the tabpage to show after the settings panels scene is opened. */
var transient int SelectedPage;

/**
 * Executes a action based on the currently selected menu item.
 */
function OnSelectItem(int PlayerIndex=0)
{
	local int SelectedItem;
	SelectedItem = MenuList.GetCurrentItem();

	switch(SelectedItem)
	{
	case SETTINGS_OPTION_VIDEO:case SETTINGS_OPTION_AUDIO:case SETTINGS_OPTION_INPUT:case SETTINGS_OPTION_NETWORK:case SETTINGS_OPTION_WEAPONS:case SETTINGS_OPTION_HUD:
		SelectedPage = SelectedItem-SETTINGS_OPTION_VIDEO;
		OpenSceneByName(SettingsPanelsScene, false, OnPanelsSceneOpened);
		break;
	case SETTINGS_OPTION_CREDITS:
		OpenSceneByName(CreditsScene);
		break;
	case SETTINGS_OPTION_INSTALL:
		InstallPS3();
		break;
	}
}

/** Callback for when the settings scene has opened after its intro animation. */
function OnPanelsSceneOpened(UIScene OpenedScene, bool bInitialActivation)
{
	local UTUIFrontEnd_SettingsPanels PanelsSceneInst;

	if ( bInitialActivation )
	{
		PanelsSceneInst = UTUIFrontEnd_SettingsPanels(OpenedScene);
		PanelsSceneInst.TabControl.ActivatePage(PanelsSceneInst.TabControl.GetPageAtIndex(SelectedPage), GetBestPlayerIndex());
	}
}

function MidGameMenuSetup()
{
	// Remove any special options here.
}

function UILabel GetTitleLabel()
{
	local UILabel T;

	T = Super.GetTitleLabel();
	if ( T == none )
	{
		T = UILabel(FindChild('lblTitle',true));
	}
	return t;
}

defaultproperties
{
	CreditsScene="UI_Scenes_FrontEnd.Scenes.Credits"
	SettingsPanelsScene="UI_Scenes_ChrisBLayout.Scenes.SettingsPanels"
}
