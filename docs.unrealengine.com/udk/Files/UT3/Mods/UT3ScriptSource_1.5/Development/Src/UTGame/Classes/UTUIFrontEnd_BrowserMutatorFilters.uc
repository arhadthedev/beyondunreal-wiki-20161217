/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * The mutator filter menu for the server browser
 */
Class UTUIFrontEnd_BrowserMutatorFilters extends UTUIFrontEnd
	dependson(UTUIDynamicOptionList)
	config(Game);

// Enums to help distinguish combolist selection values
enum EMutatorList
{
	ML_NoMutators,
	ML_AnyMutators,
	ML_Custom
};

enum EMutFilterList
{
	MFL_On,
	MFL_Off,
	MFL_Either,
	MFL_Delete
};


// A saved list of manually-added mutator class names
var config array<string> AdditionalMutClasses;

// As above, but for mutator names
var config array<string> AdditionalMutNames;



// Reference to the options page and list
var transient UTUITabPage_DynamicOptions OptionsPage;
var transient UTUIDynamicOptionList OptionsList;

var array<UTUIResourceDataProvider>	MutProviders;		// A cached list of mutator data providers, for retrieving installed mutator class names
var UTUIDataStore_2DStringList		StringDataStore;	// Data store for dynamically filling in UIList's
var UTDataStore_GameSearchDM		SearchDataStore;	// The game search data store, which indirectly handles mutator filter settings

var int FirstInstalledMutIdx;		// The start of the installed mutator entries in UTUIDynamicOptionList's 'DynamicOptionTemplates' list
var int FirstAdditionalMutClassIdx;	// As above, but corresponds to the 'AdditionalMutClasses' list
var int FirstAdditionalMutNameIdx;	// As above, but corresponds to the 'AdditionalMutNames' list
var int InstalledMutCount;		// The number of installed mutators on display

var bool			bOptionDefaultsSet;		// Used to determine whether or not the below values have been initialized
var bool			bOptionValuesSet;		// Used to avoid recursive modifications of the below values

var EMutatorList		MutatorsValue;			// Stores the current value of the 'Mutators' combo box
var array<EMutFilterList>	InstalledMutFilters;		// Stores all the values of the installed mutators list
var array<EMutFilterList>	AdditionalMutClassFilters;	// As above, but for the additional mutator classes list
var array<EMutFilterList>	AdditionalMutNameFilters;	// As above, but for additional mutator names

var float	SetupTimeStamp;	// Used to ensure that deferred timers are not set and executed within the same tick
var array<name>	DeferredTimers;	// A list of deferred timers which were setup during this tick

var bool bRegeneratingOptions;	// Used to detect when the options are being regenerated


/** Post initialize callback */
function PostInitialize()
{
	local DataStoreClient DSC;
	local int i;
	local string CurComboStr;
	local array<string> CurComboList;
	local string CurMutEntry;

	Super.PostInitialize();

	OptionsPage = UTUITabPage_DynamicOptions(FindChild('pnlOptions', True));
	OptionsPage.OnOptionChanged = OnOptionChanged;

	OptionsList = UTUIDynamicOptionList(FindChild('lstOptions', True));


	// Cache a list of mutator providers
	Class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(Class'UTUIDataProvider_Mutator', MutProviders);

	// Remove all singleplayer mutators from the list
	for (i=0; i<MutProviders.Length; ++i)
		if (UTUIDataProvider_Mutator(MutProviders[i]).bStandaloneOnly)
			MutProviders.Remove(i--, 1);


	// Setup the string data store and all required combo string lists
	if (StringDataStore == none)
	{
		// Get a reference to (or create) a 2D string list data store
		DSC = Class'UIInteraction'.static.GetDataStoreClient();

		StringDataStore = UTUIDataStore_2DStringList(DSC.FindDataStore('UT2DStringList'));

		if (StringDataStore == none)
		{
			StringDataStore = DSC.CreateDataStore(Class'UTUIDataStore_2DStringList');
			DSC.RegisterDataStore(StringDataStore);
		}


		// Setup and fill the data fields within the data store (if they are not already set)
		if (StringDataStore.GetFieldIndex('UTBrowserMutatorsCombo') == INDEX_None)
		{
			// 'Mutators' combo
			i = StringDataStore.AddField('UTBrowserMutatorsCombo');
			StringDataStore.AddFieldList(i, 'MutComboList');

			CurComboStr = Localize("MutatorFilterMenu", "MutatorComboList", "UTGameUI");
			ParseStringIntoArray(CurComboStr, CurComboList, ",", True);

			StringDataStore.UpdateFieldList(i, 'MutComboList', CurComboList);


			// Installed mutator combos
			i = StringDataStore.AddField('UTBrowserInstMutCombo');
			StringDataStore.AddFieldList(i, 'MutComboList');

			CurComboStr = Localize("MutatorFilterMenu", "MutatorInstalledComboList", "UTGameUI");
			ParseStringIntoArray(CurComboStr, CurComboList, ",", True);

			StringDataStore.UpdateFieldList(i, 'MutComboList', CurComboList);


			// Additional mutator class and name combos
			i = StringDataStore.AddField('UTBrowserAdditMutCombo');
			StringDataStore.AddFieldList(i, 'MutComboList');

			CurComboStr = Localize("MutatorFilterMenu", "MutatorAdditionalComboList", "UTGameUI");
			ParseStringIntoArray(CurComboStr, CurComboList, ",", True);

			StringDataStore.UpdateFieldList(i, 'MutComboList', CurComboList);
		}
	}

	if (SearchDataStore == none)
		SearchDataStore = UTDataStore_GameSearchDM(FindDataStore('UTGameSearch'));

	// Check if mutator filter settings have already been stored in the search data store, and if not, set them to the default values
	if (SearchDataStore.bMutatorFilterSet)
	{
		MutatorsValue = SearchDataStore.MutatorFilterSetting;

		for (i=0; i<SearchDataStore.InstalledMutFilters.Length; ++i)
			InstalledMutFilters[i] = SearchDataStore.InstalledMutFilters[i];

		for (i=0; i<SearchDataStore.AdditionalMutClassFilters.Length; ++i)
			AdditionalMutClassFilters[i] = SearchDataStore.AdditionalMutClassFilters[i];

		for (i=0; i<SearchDataStore.AdditionalMutNameFilters.Length; ++i)
			AdditionalMutNameFilters[i] = SearchDataStore.AdditionalMutNameFilters[i];

		bOptionDefaultsSet = True;
	}


	// Check that all of the 'AdditionalMutClasses' and 'AdditionalMutNames' entries are valid
	for (i=0; i<AdditionalMutClasses.Length; ++i)
	{
		CurMutEntry = AdditionalMutClasses[i];

		if (!ValidateMutClassString(CurMutEntry))
			AdditionalMutClasses.Remove(i--, 1);
		else
			AdditionalMutClasses[i] = CurMutEntry;

		default.AdditionalMutClasses[i] = AdditionalMutClasses[i];
	}

	for (i=0; i<AdditionalMutNames.Length; ++i)
	{
		CurMutEntry = AdditionalMutNames[i];

		if (!ValidateMutNameString(CurMutEntry))
			AdditionalMutNames.Remove(i--, 1);
		else
			AdditionalMutNames[i] = CurMutEntry;

		default.AdditionalMutNames[i] = AdditionalMutNames[i];
	}

	SaveConfig();
	StaticSaveConfig();


	SetupMenuOptions();
}


function SetupButtonBar()
{
	ButtonBar.Clear();
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Accept>", OnButtonBar_Accept);
}

// Initializes the menu option templates, and regenerates the option list
function SetupMenuOptions()
{
	local DynamicMenuOption CurMenuOpt;
	local int i;
	local UTUIDataProvider_Mutator CurProv;

	bRegeneratingOptions = True;

	OptionsList.DynamicOptionTemplates.Length = 0;


	// First add the default menu options

	// 'Mutators' combo
	CurMenuOpt.OptionName = 'MutatorCombo';
	CurMenuOpt.OptionType = UTOT_ComboReadOnly;
	CurMenuOpt.FriendlyName = Localize("MutatorFilterMenu", "MutatorCombo", "UTGameUI");
	CurMenuOpt.Description = Localize("MutatorFilterMenu", "MutatorComboDesc", "UTGameUI");
	OptionsList.DynamicOptionTemplates.AddItem(CurMenuOpt);

	// 'Add Mutator Class' combo
	CurMenuOpt.OptionName = 'MutatorClassAddEdit';
	CurMenuOpt.OptionType = UTOT_EditBox;
	CurMenuOpt.FriendlyName = Localize("MutatorFilterMenu", "MutatorClassAddEdit", "UTGameUI");
	CurMenuOpt.Description = Localize("MutatorFilterMenu", "MutatorClassAddEditDesc", "UTGameUI");
	OptionsList.DynamicOptionTemplates.AddItem(CurMenuOpt);

	// 'Add Mutator Name' combo
	CurMenuOpt.OptionName = 'MutatorNameAddEdit';
	CurMenuOpt.OptionType = UTOT_EditBox;
	CurMenuOpt.FriendlyName = Localize("MutatorFilterMenu", "MutatorNameAddEdit", "UTGameUI");
	CurMenuOpt.Description = Localize("MutatorFilterMenu", "MutatorNameAddEditDesc", "UTGameUI");
	OptionsList.DynamicOptionTemplates.AddItem(CurMenuOpt);


	// Add all of the currently installed mutators
	FirstInstalledMutIdx = OptionsList.DynamicOptionTemplates.Length;
	InstalledMutCount = 0;

	CurMenuOpt.OptionType = UTOT_ComboReadOnly;

	for (i=0; i<MutProviders.Length; ++i)
	{
		CurProv = UTUIDataProvider_Mutator(MutProviders[i]);

		CurMenuOpt.OptionName = Name("InstalledMutFilter"$InstalledMutCount);
		CurMenuOpt.FriendlyName = "";//"<Color:R=1.0,G=1.0,B=0.0,A=1.0>";

		if (CurProv.FriendlyName != "")
			CurMenuOpt.FriendlyName $= CurProv.FriendlyName;
		else
			CurMenuOpt.FriendlyName $= Mid(CurProv.FriendlyName, InStr(CurProv.FriendlyName, ".")+1);

		CurMenuOpt.Description = CurProv.Description;

		OptionsList.DynamicOptionTemplates.AddItem(CurMenuOpt);

		++InstalledMutCount;
	}


	// Add all of the 'AdditionalMutClasses' mutators
	FirstAdditionalMutClassIdx = OptionsList.DynamicOptionTemplates.Length;

	CurMenuOpt.Description = Localize("MutatorFilterMenu", "MutatorFilterDesc", "UTGameUI");

	for (i=0; i<AdditionalMutClasses.Length; ++i)
	{
		CurMenuOpt.OptionName = Name("AdditionalMutClassFilter"$i);
		CurMenuOpt.FriendlyName = /*"<Color:R=1.0,G=0.25,B=0.0,A=1.0>"$*/AdditionalMutClasses[i];

		OptionsList.DynamicOptionTemplates.AddItem(CurMenuOpt);
	}


	// Add all of the 'AdditionalMutName' mutators
	FirstAdditionalMutNameIdx = OptionsList.DynamicOptionTemplates.Length;

	for (i=0; i<AdditionalMutNames.Length; ++i)
	{
		CurMenuOpt.OptionName = Name("AdditionalMutNameFilter"$i);
		CurMenuOpt.FriendlyName = /*"<Color:R=1.0,G=0.0,B=0.0,A=1.0>"$*/AdditionalMutNames[i];

		OptionsList.DynamicOptionTemplates.AddItem(CurMenuOpt);
	}


	// Generate the option controls
	i = OptionsList.CurrentIndex;

	OptionsList.OnSetupOptionBindings = SetupOptionBindings;
	OptionsList.RegenerateOptions();

	// Disable the scrollbar if the 'Mutators' combo is not set to 'Custom
	if (MutatorsValue != ML_Custom)
		OptionsList.VerticalScrollbar.SetEnabled(False);

	// If the list index was set, return to the previous position
	if (i != INDEX_None)
	{
		i = Clamp(i, 0, OptionsList.GeneratedObjects.Length-1);
		OptionsList.GeneratedObjects[i].OptionObj.SetFocus(None);

		// Disable the initiated selection change animation, so that it jumps to the focused object immediately
		OptionsList.bAnimatingBGPrefab = False;
	}
}

// Setup the data source bindings (but not the values)
function SetupOptionBindings()
{
	local UTUIComboBox CurCombo;
	local UTUIEditBox CurEditBox;
	local int i;

	// If the options have not yet been given default values, set them up now
	if (!bOptionDefaultsSet)
	{
		MutatorsValue = ML_AnyMutators;

		for (i=0; i<InstalledMutCount; ++i)
			InstalledMutFilters[i] = MFL_Either;

		for (i=0; i<AdditionalMutClasses.Length; ++i)
			AdditionalMutClassFilters[i] = MFL_Either;

		for (i=0; i<AdditionalMutNames.Length; ++i)
			AdditionalMutNameFilters[i] = MFL_Either;

		bOptionDefaultsSet = True;
	}


	// Find the main mutator combo box
	CurCombo = FindOptionComboByName(OptionsList, 'MutatorCombo');

	if (CurCombo != none)
		CurCombo.ComboList.SetDataStoreBinding("<UT2DStringList:UTBrowserMutatorsCombo>");

	// Find the 'add mutator class' edit box
	CurEditBox = FindOptionEditBoxByName(OptionsList, 'MutatorClassAddEdit');

	if (CurEditBox != none)
	{
		CurEditBox.OnSubmitText = OnMutatorClassAdd;

		// Set the option as enabled/disabled, depending upon whether the 'Mutators' combo is set to 'Custom'
		OptionsList.EnableItem(GetBestPlayerIndex(), CurEditBox, (MutatorsValue == ML_Custom));
	}

	// Find the 'add mutator name' edit box
	CurEditBox = FindOptionEditBoxByName(OptionsList, 'MutatorNameAddEdit');

	if (CurEditBox != none)
	{
		CurEditBox.OnSubmitText = OnMutatorNameAdd;

		// Set the option as enabled/disabled, depending upon whether the 'Mutators' combo is set to 'Custom'
		OptionsList.EnableItem(GetBestPlayerIndex(), CurEditBox, (MutatorsValue == ML_Custom));
	}


	// Iterate the 'InstalledMutFilter' combo's
	for (i=0; i<InstalledMutCount; ++i)
	{
		CurCombo = FindOptionComboByName(OptionsList, Name("InstalledMutFilter"$i));

		if (CurCombo != none)
			CurCombo.ComboList.SetDataStoreBinding("<UT2DStringList:UTBrowserInstMutCombo>");

		OptionsList.EnableItemAtIndex(GetBestPlayerIndex(), FirstInstalledMutIdx+i, (MutatorsValue == ML_Custom));
	}

	// Iterate the 'AdditionalMutClassFilter' combo's
	for (i=0; i<AdditionalMutClasses.Length; ++i)
	{
		CurCombo = FindOptionComboByName(OptionsList, Name("AdditionalMutClassFilter"$i));

		if (CurCombo != none)
			CurCombo.ComboList.SetDataStoreBinding("<UT2DStringList:UTBrowserAdditMutCombo>");

		OptionsList.EnableItemAtIndex(GetBestPlayerIndex(), FirstAdditionalMutClassIdx+i, (MutatorsValue == ML_Custom));
	}

	// Iterate the 'AdditionalMutNameFilter' combo's
	for (i=0; i<AdditionalMutNames.Length; ++i)
	{
		CurCombo = FindOptionComboByName(OptionsList, Name("AdditionalMutNameFilter"$i));

		if (CurCombo != none)
			CurCombo.ComboList.SetDataStoreBinding("<UT2DStringList:UTBrowserAdditMutCombo>");

		OptionsList.EnableItemAtIndex(GetBestPlayerIndex(), FirstAdditionalMutNameIdx+i, (MutatorsValue == ML_Custom));
	}

	// Set the scrollbars enabled/disabled status
	OptionsList.VerticalScrollbar.SetEnabled(MutatorsValue == ML_Custom);



	// Setup a timer to perform post-generation modification of the controls (e.g. adding entries into combo boxes, setting up delegates etc.)
	DeferTimer('SetupMenuOptionValues');


	bRegeneratingOptions = False;
}

// Called one tick after 'SetupOptionBindings', used to refresh the controls
function SetupMenuOptionValues()
{
	local UTUIComboBox CurCombo;
	local int i;

	// If this function was set to be executed during the next tick, and the next tick has not yet been reached, return
	if (!bTimerDeferred('SetupMenuOptionValues'))
		return;

	bOptionValuesSet = False;


	// Find the main mutator combo box
	CurCombo = FindOptionComboByName(OptionsList, 'MutatorCombo');

	if (CurCombo != none)
	{
		// Due to a bug, the combolist will not update if it's set to the value it's already at (in this case, 0); this fixes that
		if (MutatorsValue == 0)
			CurCombo.ComboList.SetIndex(1);

		CurCombo.ComboList.SetIndex(MutatorsValue);
	}

	// Iterate the 'InstalledMutFilter' combo's
	for (i=0; i<InstalledMutCount; ++i)
	{
		CurCombo = FindOptionComboByName(OptionsList, Name("InstalledMutFilter"$i));

		if (CurCombo != none)
		{
			if (InstalledMutFilters[i] == 0)
				CurCombo.ComboList.SetIndex(1);

			CurCombo.ComboList.SetIndex(InstalledMutFilters[i]);
		}
	}

	// Iterate the 'AdditionalMutClassFilter' combo's
	for (i=0; i<AdditionalMutClasses.Length; ++i)
	{
		CurCombo = FindOptionComboByName(OptionsList, Name("AdditionalMutClassFilter"$i));

		if (CurCombo != none)
		{
			if (AdditionalMutClassFilters[i] == 0)
				CurCombo.ComboList.SetIndex(1);

			CurCombo.ComboList.SetIndex(AdditionalMutClassFilters[i]);
		}
	}

	// Iterate the 'AdditionalMutNameFilter' combo's
	for (i=0; i<AdditionalMutClasses.Length; ++i)
	{
		CurCombo = FindOptionComboByName(OptionsList, Name("AdditionalMutNameFilter"$i));

		if (CurCombo != none)
		{
			if (AdditionalMutNameFilters[i] == 0)
				CurCombo.ComboList.SetIndex(1);

			CurCombo.ComboList.SetIndex(AdditionalMutNameFilters[i]);
		}
	}


	bOptionValuesSet = True;
}

// Used to update the state of the menu option controls
function UpdateMenuOptions()
{
	local int i;

	// Update the 'Add Mutator Class' edit box
	i = OptionsList.GetObjectInfoIndexFromName('MutatorClassAddEdit');

	OptionsList.EnableItemAtIndex(GetBestPlayerIndex(), i, (MutatorsValue == ML_Custom));

	// Update the 'Add Mutator Name' edit box
	i = OptionsList.GetObjectInfoIndexFromName('MutatorNameAddEdit');

	OptionsList.EnableItemAtIndex(GetBestPlayerIndex(), i, (MutatorsValue == ML_Custom));

	// Now the installed mutators
	for (i=0; i<InstalledMutCount; ++i)
		OptionsList.EnableItemAtIndex(GetBestPlayerIndex(), FirstInstalledMutIdx+i, (MutatorsValue == ML_Custom));

	// Then the additional mutator classes
	for (i=0; i<AdditionalMutClasses.Length; ++i)
		OptionsList.EnableItemAtIndex(GetBestPlayerIndex(), FirstAdditionalMutClassIdx+i, (MutatorsValue == ML_Custom));

	// Finally the additional mutator names
	for (i=0; i<AdditionalMutNames.Length; ++i)
		OptionsList.EnableItemAtIndex(GetBestPlayerIndex(), FirstAdditionalMutNameIdx+i, (MutatorsValue == ML_Custom));

	// Update the vertical scrollbar
	OptionsList.VerticalScrollbar.SetEnabled(MutatorsValue == ML_Custom);
}


/** OptionList callbacks */
function OnOptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex)
{
	local string OptionString;
	local UTUIEditBox CurEditBox;
	local string CurEditValue;
	local int i;

	if (bRegeneratingOptions)
		return;


	OptionString = string(OptionName);

	if (OptionName == 'MutatorCombo')
	{
		if (bOptionValuesSet)
		{
			MutatorsValue = EMutatorList(UTUIComboBox(InObject).ComboList.Index);
			UpdateMenuOptions();
		}
	}
	// If this is an edit box, then block invalid characters from being entered
	else if (OptionName == 'MutatorClassAddEdit')
	{
		CurEditBox = UTUIEditBox(InObject);

		if (CurEditBox != none)
		{
			CurEditValue = CurEditBox.GetValue();

			// Check the last entered value
			if (CurEditValue != "" && bInvalidClassChar(Asc(Right(CurEditValue, 1))))
				CurEditBox.SetValue(Left(CurEditValue, Len(CurEditValue)-1),, True);
		}
	}
	else if (OptionName == 'MutatorNameAddEdit')
	{
		CurEditBox = UTUIEditBox(InObject);

		if (CurEditBox != none)
		{
			CurEditValue = CurEditBox.GetValue();

			// Check the last entered value
			if (CurEditValue != "" && bInvalidNameChar(Asc(Right(CurEditValue, 1))))
				CurEditBox.SetValue(Left(CurEditValue, Len(CurEditValue)-1),, True);
		}
	}
	else if (Left(OptionString, 18) == "InstalledMutFilter")
	{
		if (bOptionValuesSet)
		{
			i = int(Mid(OptionString, 18));
			InstalledMutFilters[i] = EMutFilterList(UTUIComboBox(InObject).ComboList.Index);
		}
	}
	else if (Left(OptionString, 24) == "AdditionalMutClassFilter")
	{
		if (bOptionValuesSet)
		{
			i = int(Mid(OptionString, 24));
			AdditionalMutClassFilters[i] = EMutFilterList(UTUIComboBox(InObject).ComboList.Index);

			// If the user wants to delete an entry, do so and update the list
			if (AdditionalMutClassFilters[i] == MFL_Delete)
			{
				AdditionalMutClassFilters.Remove(i, 1);
				AdditionalMutClasses.Remove(i, 1);
				default.AdditionalMutClasses.Remove(i, 1);

				SaveConfig();
				StaticSaveConfig();

				// Propogate change to the search data store, if neccessary
				if (SearchDataStore.bMutatorFilterSet)
					SearchDataStore.AdditionalMutClassFilters.Remove(i, 1);

				SetupMenuOptions();
			}
		}
	}
	else if (Left(OptionString, 23) == "AdditionalMutNameFilter")
	{
		if (bOptionValuesSet)
		{
			i = int(Mid(OptionString, 23));
			AdditionalMutNameFilters[i] = EMutFilterList(UTUIComboBox(InObject).ComboList.Index);

			// If the user wants to delete an entry, do so and update the list
			if (AdditionalMutNameFilters[i] == MFL_Delete)
			{
				AdditionalMutNameFilters.Remove(i, 1);
				AdditionalMutNames.Remove(i, 1);
				default.AdditionalMutNames.Remove(i, 1);

				SaveConfig();
				StaticSaveConfig();

				// Propogate change to the search data store, if neccessary
				if (SearchDataStore.bMutatorFilterSet)
					SearchDataStore.AdditionalMutNameFilters.Remove(i, 1);

				SetupMenuOptions();
			}
		}
	}
}

// Called when the user presses enter on the 'Add Mutator Class' edit box
function bool OnMutatorClassAdd(UIEditBox Sender, int PlayerIndex)
{
	local string MutClass;

	MutClass = Sender.GetValue();

	if (ValidateMutClassString(MutClass) && AdditionalMutClasses.Find(MutClass) == INDEX_None)
	{
		// Setup the default value for the new filter
		AdditionalMutClassFilters[AdditionalMutClasses.Length] = MFL_Either;

		AdditionalMutClasses.AddItem(MutClass);
		default.AdditionalMutClasses.AddItem(MutClass);

		SaveConfig();
		StaticSaveConfig();

		// Propogate change to the search data store, if neccessary
		if (SearchDataStore.bMutatorFilterSet)
			SearchDataStore.AdditionalMutClassFilters.AddItem(MFL_Either);


		SetupMenuOptions();

		return True;
	}

	return False;
}

// Called when the user presses enter on the 'Add Mutator Name' edit box
function bool OnMutatorNameAdd(UIEditBox Sender, int PlayerIndex)
{
	local string MutName;

	MutName = Sender.GetValue();

	if (ValidateMutNameString(MutName) && AdditionalMutNames.Find(MutName) == INDEX_None)
	{
		// Setup the default value for the new filter
		AdditionalMutNameFilters[AdditionalMutNames.Length] = MFL_Either;

		AdditionalMutNames.AddItem(MutName);
		default.AdditionalMutNames.AddItem(MutName);

		SaveConfig();
		StaticSaveConfig();

		// Propogate change to the search data store, if neccessary
		if (SearchDataStore.bMutatorFilterSet)
			SearchDataStore.AdditionalMutNameFilters.AddItem(MFL_Either);


		SetupMenuOptions();

		return True;
	}

	return False;
}

/** Button bar callbacks */
function bool OnButtonBar_Accept(UIScreenObject InButton, int PlayerIndex)
{
	OnAccept();
	CloseScene(Self);

	return true;
}

function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	OnBack();

	return true;
}


function OnBack()
{
	CloseScene(self);
}

function OnAccept()
{
	local int i, j;
	local string MutClass;
	local UTUIDataProvider_Mutator CurProv;

	// Make the neccessary changes to the search data store
	SearchDataStore.MutatorFilterSetting = MutatorsValue;

	SearchDataStore.MutatorFilters.Length = 0;
	SearchDataStore.InstalledMutFilters.Length = InstalledMutFilters.Length;
	SearchDataStore.AdditionalMutClassFilters.Length = AdditionalMutClassFilters.Length;
	SearchDataStore.AdditionalMutNameFilters.Length = AdditionalMutNameFilters.Length;

	for (i=0; i<InstalledMutFilters.Length; ++i)
	{
		SearchDataStore.InstalledMutFilters[i] = InstalledMutFilters[i];

		if (InstalledMutFilters[i] != MFL_On && InstalledMutFilters[i] != MFL_Off)
			continue;


		j = SearchDataStore.MutatorFilters.Length;
		SearchDataStore.MutatorFilters.Length = j+1;

		CurProv = UTUIDataProvider_Mutator(MutProviders[i]);

		// If this is not an official mutator, copy its classname; otherwise copy its bitvalue
		if (CurProv.BitValue == 0)
		{
			MutClass = CurProv.ClassName;
			MutClass = Mid(MutClass, InStr(MutClass, ".")+1);

			SearchDataStore.MutatorFilters[j].MutatorClass = MutClass;
		}
		else
		{
			SearchDataStore.MutatorFilters[j].OfficialMutValue = CurProv.BitValue;
		}

		SearchDataStore.MutatorFilters[j].bMustBeOn = (InstalledMutFilters[i] == MFL_On);
	}

	for (i=0; i<AdditionalMutClassFilters.Length; ++i)
	{
		SearchDataStore.AdditionalMutClassFilters[i] = AdditionalMutClassFilters[i];

		if (AdditionalMutClassFilters[i] != MFL_On && AdditionalMutClassFilters[i] != MFL_Off)
			continue;


		j = SearchDataStore.MutatorFilters.Length;
		SearchDataStore.MutatorFilters.Length = j+1;

		SearchDataStore.MutatorFilters[j].MutatorClass = AdditionalMutClasses[i];
		SearchDataStore.MutatorFilters[j].bMustBeOn = (AdditionalMutClassFilters[i] == MFL_On);
	}

	for (i=0; i<AdditionalMutNameFilters.Length; ++i)
	{
		SearchDataStore.AdditionalMutNameFilters[i] = AdditionalMutNameFilters[i];

		if (AdditionalMutNameFilters[i] != MFL_On && AdditionalMutNameFilters[i] != MFL_Off)
			continue;


		j = SearchDataStore.MutatorFilters.Length;
		SearchDataStore.MutatorFilters.Length = j+1;

		SearchDataStore.MutatorFilters[j].MutatorClass = AdditionalMutNames[i];
		SearchDataStore.MutatorFilters[j].bMustBeOn = (AdditionalMutNameFilters[i] == MFL_On);
		SearchDataStore.MutatorFilters[j].bMutatorName = True;
	}


	SearchDataStore.bMutatorFilterSet = True;
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

	// Let the binding list get first chance at the input because the user may be binding a key.
	bResult=OptionsPage.HandleInputKey(EventParms);

	if(bResult == false)
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


// Helper functions

// Defers the calling of a timer function by one tick
function DeferTimer(name FunctionName)
{
	local PlayerController PC;

	PC = GetPlayerOwner().Actor;

	if (PC != none && DeferredTimers.Find(FunctionName) == INDEX_None)
	{
		PC.SetTimer(0.001, False, FunctionName, Self);

		DeferredTimers.AddItem(FunctionName);
		SetupTimeStamp = PC.WorldInfo.TimeSeconds;
	}
}

// Verifies that a deferred timer is being called during the correct tick
function bool bTimerDeferred(name FunctionName)
{
	local PlayerController PC;

	// If the function name is not in the defer list, consider it to be a regular function call
	if (DeferredTimers.Find(FunctionName) == INDEX_None)
		return True;


	PC = GetPlayerOwner().Actor;

	// If we are still in the same tick, setup the timer again (can sometimes randomly happen)
	if (PC.WorldInfo.TimeSeconds ~= SetupTimeStamp)
	{
		PC.SetTimer(0.001, False, FunctionName, Self);
		return False;
	}


	DeferredTimers.RemoveItem(FunctionName);

	return True;
}

// Verifies that the passed in string is a valid mutator class name, returning true if the string was valid (or made valid)
static final function bool ValidateMutClassString(out string MutString)
{
	local int i, SLen, CurChar;

	// If a package name was specified, strip it
	i = InStr(MutString, ".");

	if (i != INDEX_None)
		MutString = Mid(MutString, i+1);

	if (MutString == "")
		return False;


	// Now iterate the strings characters, looking for invalid characters; return false if any are detected
	SLen = Len(MutString);

	for (i=0; i<SLen; ++i)
	{
		CurChar = Asc(Left(Mid(MutString, i), 1));

		if (bInvalidClassChar(CurChar))
			return False;
	}

	return True;
}

// Verifies that the passed in string is a valid mutator name, returning true if the string was valid (or made valid)
static final function bool ValidateMutNameString(out string MutString)
{
	local int i, SLen, CurChar;

	if (MutString == "")
		return False;


	// Iterate the strings characters, looking for invalid characters; return false if any are detected
	SLen = Len(MutString);

	for (i=0; i<SLen; ++i)
	{
		CurChar = Asc(Left(Mid(MutString, i), 1));

		if (bInvalidNameChar(CurChar))
			return False;
	}

	return True;
}

static final function bool bInvalidClassChar(int InChar)
{
	return (InChar < 48 || (InChar > 57 && InChar < 65) || (InChar > 90 && InChar < 95) || InChar == 96 || InChar > 122);
}

static final function bool bInvalidNameChar(int InChar)
{
	return (InChar < 32 || (InChar > 32 && InChar < 48) || (InChar > 57 && InChar < 65) || (InChar > 90 && InChar < 95) || InChar == 96 || InChar > 122);
}

// Handles finding and casting generated option controls
static final function UTUIComboBox FindOptionComboByName(UTUIOptionList List, name OptionName)
{
	local int i;

	i = List.GetObjectInfoIndexFromName(OptionName);

	if (i != INDEX_None)
		return UTUIComboBox(List.GeneratedObjects[i].OptionObj);

	return None;
}

static final function UTUIEditBox FindOptionEditBoxByName(UTUIOptionList List, name OptionName)
{
	local int i;

	i = List.GetObjectInfoIndexFromName(OptionName);

	if (i != INDEX_None)
		return UTUIEditBox(List.GeneratedObjects[i].OptionObj);

	return None;
}

