/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Settings panels scene for UT3.  Actually holds all of the configuration panels.
 */
class UTUIFrontEnd_SettingsPanels extends UTUIFrontEnd;

/** References to the tab control and pages. */
var transient UTUITabPage_Options PlayerTab;
var transient UTUITabPage_Options VideoTab;
var transient UTUITabPage_Options AudioTab;
var transient UTUITabPage_Options InputTab;
var transient UTUITabPage_Options NetworkTab;
var transient UTUITabPage_Options WeaponsTab;
var transient UTUITabPage_Options HUDTab;

/** Whether or not we have been fully initialized. */
var transient bool bFullyInitialized;

/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize()
{
	Super.PostInitialize();
	
	// Player Settings - @todo: as of right now we dont need this.
	/*PlayerTab = UTUITabPage_Options(FindChild('pnlPlayer', true));
	if(PlayerTab != none)
	{
		PlayerTab.SetVisibility(true);
		PlayerTab.SetDataStoreBinding("<Strings:UTGameUI.Settings.Player>");
		TabControl.InsertPage(PlayerTab, 0, INDEX_NONE, true);
	}*/

	// Video Settings
	VideoTab = UTUITabPage_Options(FindChild('pnlVideo', true));
	if(VideoTab != none)
	{
		VideoTab.OnOptionChanged = OnOptionChanged;
		TabControl.InsertPage(VideoTab, 0, 0, false);
	}

	// Audio Settings
	AudioTab = UTUITabPage_Options(FindChild('pnlAudio', true));
	if(AudioTab != none)
	{
		AudioTab.OnOptionChanged = OnOptionChanged;
		TabControl.InsertPage(AudioTab, 0, 1, false);
	}

	// Input Settings
	InputTab = UTUITabPage_Options(FindChild('pnlInput', true));
	if(InputTab != none)
	{
		InputTab.OnOptionChanged = OnOptionChanged;
		TabControl.InsertPage(InputTab, 0, 2, false);
	}

	// Network Settings
	NetworkTab = UTUITabPage_Options(FindChild('pnlNetwork', true));
	if(NetworkTab != none)
	{
		NetworkTab.OnOptionChanged = OnOptionChanged;
		TabControl.InsertPage(NetworkTab, 0, 3, false);
	}

	// Weapon Settings
	WeaponsTab = UTUITabPage_Options(FindChild('pnlWeapons', true));
	if(WeaponsTab != none)
	{
		WeaponsTab.OnOptionChanged = OnOptionChanged;
		TabControl.InsertPage(WeaponsTab, 0, 4, false);
	}

	// HUD Settings
	HUDTab = UTUITabPage_Options(FindChild('pnlHUDSettings', true));
	if(HUDTab != none)
	{
		HUDTab.OnOptionChanged = OnOptionChanged;
		TabControl.InsertPage(HUDTab, 0, 5, false);
	}
}

/** Scene activation event, always sets focus to current tab page if activating the page for a second time. */
event SceneActivated(bool bInitialActivation)
{
	Super.SceneActivated(bInitialActivation);

	if(bInitialActivation==false)
	{
		if(TabControl.ActivePage != None)
		{
			TabControl.ActivePage.SetFocus(none);
		}
	}
}

/** Setup the scene's button bar. */
function SetupButtonBar()
{
	if(ButtonBar != None)
	{
		ButtonBar.Clear();
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);

		if(TabControl != None)
		{
			// Let the current tab page append buttons.
			UTTabPage(TabControl.ActivePage).SetupButtonBar(ButtonBar);
		}
	}
}

/** Delegate for when the user changes one of the options an option list. */
function OnOptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex)
{
	
}


/** On back handler, saves profile settings. */
function OnBack()
{
	local UIDataStore_OnlinePlayerData	PlayerDataStore;
	local UTUIScene_SaveProfile SaveProfileScene;
	// Force the widgets to save their subscriber values.
	SaveSceneDataValues(FALSE);

	ConsoleCommand("RetrieveSettingsFromProfile");

	// Save profile
	PlayerDataStore = UIDataStore_OnlinePlayerData(FindDataStore('OnlinePlayerData', GetPlayerOwner()));

	if(PlayerDataStore != none)
	{
		`Log("UTUIFrontEnd_SettingsPanels::OnBack() - Saving player profile.");
		SaveProfileScene = UTGameUISceneClient(GetSceneClient()).ShowSaveProfileScene(GetUTPlayerOwner());

		if(SaveProfileScene != None)
		{
			SaveProfileScene.OnSaveFinished = OnSaveProfileCompleted;
		}
		else
		{
			OnSaveProfileCompleted();
		}
	}
	else
	{
		`Log("UTUIFrontEnd_SettingsPanels::OnBack() - Unable to locate OnlinePlayerData datastore for saving out profile.");
		OnSaveProfileCompleted();
	}
}

/** Callback for when the profile save has completed. */
function OnSaveProfileCompleted()
{
	CloseScene(self);
}

/** Button bar callback. */
function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	OnBack();

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

	// Let the currently active tab try to handle input first.
	bResult=UTTabPage(TabControl.ActivePage).HandleInputKey(EventParms);

	// See if the user wants to close the scene.
	if(bResult==false && EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
		{
			OnBack();
			bResult=true;
		}
		else if(EventParms.InputKeyName=='XboxTypeS_LeftTrigger')
		{
			UTUITabPage_Options(TabControl.ActivePage).OnResetToDefaults();
			bResult=true;
		}
	}

	return bResult;
}

defaultproperties
{

}
