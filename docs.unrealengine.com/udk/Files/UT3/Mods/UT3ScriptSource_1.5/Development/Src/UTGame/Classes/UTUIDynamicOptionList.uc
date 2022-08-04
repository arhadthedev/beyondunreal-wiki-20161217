/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Version of UTUIOptionList which allows you to add options at runtime, but which doesn't use data providers
 */
Class UTUIDynamicOptionList extends UTUIOptionList
	native(UIFrontEnd)
	dependson(UTUIDataProvider_MenuOption);

// Struct which holds information for a dynamic menu option (based off of UTUIDataProvider_MenuOption)
struct native DynamicMenuOption
{
	var name			OptionName;		// The name used to identify the menu option

	var EUTOptionType		OptionType;		// Name of the option set that this option belongs to
	var name			RequiredGameMode;	// Game mode required for this option to appear

	var string			FriendlyName;		// Friendly name which is displayed to the player (should be localized before assigment)
	var string			Description;		// Description of the option (should also be localized)

	var bool			bEditableCombo;		// Whether or not the options presented to the user are the only options they can choose from
	var bool			bNumericCombo;		// Whether or not the combobox is numeric
	var int				EditBoxMaxLength;	// Maximum length of the editbox property
	var EEditBoxCharacterSet	EditboxAllowedChars;	// The allowed character set for editboxes

	var UIRangeData			RangeData;		// Range data for the option, only used if its a slider type

	var bool			bKeyboardOrMouseOption;	// Whether the option is a keyboard or mouse option

	var bool			bOnlineOnly;		// Whether the option is an online only option or not
	var bool			bOfflineOnly;		// Whether the option is an offline only option or not
};

// The list of menu option templates which are automatically created
var array<DynamicMenuOption> DynamicOptionTemplates;





// Called when setting up option bindings, after the options have been generated
delegate OnSetupOptionBindings();


// Function stub
function RefreshAllOptions();

function SetupOptionBindings()
{
	Super.SetupOptionBindings();

	OnSetupOptionBindings();
}


// Returns a 'DynamicOptionTemplates' index based upon name
function int GetDynamicOptionIndexByName(name InName)
{
	return DynamicOptionTemplates.Find('OptionName', InName);
}

// Returns a 'DynamicOptionTemplates' index based upon an object instance
function int GetDynamicOptionIndexByObject(UIObject InObject)
{
	local int i;

	i = GetObjectInfoIndexFromObject(InObject);

	if (i != INDEX_None)
		return GetDynamicOptionIndexByName(GeneratedObjects[i].OptionProviderName);

	return INDEX_None;
}

