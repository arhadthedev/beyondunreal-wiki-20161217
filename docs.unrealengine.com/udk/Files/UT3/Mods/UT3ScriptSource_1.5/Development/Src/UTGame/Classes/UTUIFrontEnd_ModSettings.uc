/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Scene which let user's select which mod they want to configure
 */
Class UTUIFrontEnd_ModSettings extends UTUIFrontEnd
	placeable;

// Visual list of available mods
var transient UIList ModList;

var transient int CurModSelection;

// Label describing the purpose of the list
var transient UILabel DescriptionLabel;

// Reference to the 2D string list which holds the mod list
var transient UTUIDataStore_2DStringList StringDataStore;

// The list of mod data providers which have a valid settings scene
var transient array<UTUIDataProvider_GameModeInfo> ModProviders;


// Setup widget delegates
function PostInitialize()
{
	local DataStoreClient DSC;
	local array<UTUIResourceDataProvider> GameProviders;
	local int i, j;
	local UTUIDataProvider_GameModeInfo CurProvider;
	local array<string> ListData;

	ModList = UIList(FindChild('lstMods', True));
	DescriptionLabel = UILabel(FindChild('lblDescription', True));

	Super.PostInitialize();

	// Setup UIList delegates
	ModList.OnValueChanged = OnModList_ValueChanged;
	ModList.OnSubmitSelection = OnModList_SubmitSelection;


	// Initialize the 2D string list
	DSC = Class'UIInteraction'.static.GetDataStoreClient();

	StringDataStore = UTUIDataStore_2DStringList(DSC.FindDataStore('UT2DStringList'));

	if (StringDataStore == none)
	{
		StringDataStore = DSC.CreateDataStore(Class'UTUIDataStore_2DStringList');
		DSC.RegisterDataStore(StringDataStore);
	}


	// Get a list of mods with custom settings scenes
	Class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(Class'UTUIDataProvider_GameModeInfo', GameProviders);

	for (i=0; i<GameProviders.Length; ++i)
	{
		CurProvider = UTUIDataProvider_GameModeInfo(GameProviders[i]);

		if (CurProvider.ModClientSettingsScene != "")
			ModProviders.AddItem(CurProvider);
	}


	// Setup the mod list field within the data store
	i = StringDataStore.AddField('UTModSettingsList');
	StringDataStore.AddFieldList(i, 'ModList');

	if (ModProviders.Length > 0)
	{
		StringDataStore.SetFieldRowLength(i, ModProviders.Length);

		for (j=0; j<ModProviders.Length; ++j)
			ListData[j] = ModProviders[j].FriendlyName;

		StringDataStore.UpdateFieldList(i, 'ModList', ListData);
	}
}

function SetupButtonBar()
{
	ButtonBar.Clear();

	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);

	if (CurModSelection >= 0 && CurModSelection < ModProviders.Length)
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ConfigureMutator>", OnButtonBar_ConfigureMod);
}


// UIList callbacks

function OnModList_ValueChanged(UIObject Sender, int PlayerIndex)
{
	CurModSelection = ModList.GetCurrentItem();
	SetupButtonBar();
}

function OnModList_SubmitSelection(UIList Sender, optional int PlayerIndex=GetBestPlayerIndex())
{
	if (ModProviders.Length > 0)
	{
		CurModSelection = Sender.GetCurrentItem();

		ConfigureCurrentMod();
	}
}

function OnBack()
{
	CloseScene(self);
}


// ButtonBar callbacks

function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	OnBack();
	return True;
}

function bool OnButtonBar_ConfigureMod(UIScreenObject InButton, int PlayerIndex)
{
	ConfigureCurrentMod();
	return True;
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
				OnBack();
				bResult=true;
			}
		}
	}

	return bResult;
}


function ConfigureCurrentMod()
{
	if (CurModSelection >= 0 && CurModSelection < ModProviders.Length)
		OpenSceneByName(ModProviders[CurModSelection].ModClientSettingsScene, false);
}


defaultproperties
{
	CurModSelection=INDEX_None
}
