/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Used to copy data from any Settings class derivative, and store it in a .ini file;
 * Primarily used by the instant action and host game menus, to save game settings values
 */
Class SettingsProfile extends Object
	config(Game)
	perobjectconfig;


// A struct used to hold data retrieved from a databinding object property
struct DataBindingInfo
{
	var name Property;
	var string Value;
};

struct LocalizedSettingInfo
{
	var int ID;
	var int Value;
};


var config name				SettingsClassName;	// The class of the settings object which the current data was taken from

var config array<DataBindingInfo>	DataBindingProperties;	// A list of saved databinding object properties
var config array<LocalizedSettingInfo>	LocalizedSettings;	// A list of saved localized settings
var config array<DataBindingInfo>	PropertySettings;	// A list of saved property settings (uses 'DataBindingInfo' struct for convenience)


// Copies and saves the settings from the input object
function SaveSettings(Settings InObj)
{
	local array<Name> DBProperties;
	local int i, j;
	local DataBindingInfo CurProp;
	local LocalizedSettingInfo CurLocSetting;

	SettingsClassName = InObj.Class.Name;


	// First store all of the settings databinding properties
	DataBindingProperties.Length = 0;

	InObj.GetDataBindingProperties(DBProperties);

	for (i=0; i<DBProperties.Length; ++i)
	{
		if (InObj.GetDataBindingValue(DBProperties[i], CurProp.Value, True))
		{
			CurProp.Property = DBProperties[i];
			DataBindingProperties.AddItem(CurProp);
		}
	}


	// Then store the settings localized values
	LocalizedSettings.Length = 0;
	j = InObj.LocalizedSettings.Length;

	for (i=0; i<j; ++i)
	{
		// Skip settings that are still at their default values
		if (InObj.LocalizedSettings[i].ValueIndex == InObj.default.LocalizedSettings[i].ValueIndex)
			continue;


		CurLocSetting.ID = InObj.LocalizedSettings[i].ID;
		CurLocSetting.Value = InObj.LocalizedSettings[i].ValueIndex;

		LocalizedSettings.AddItem(CurLocSetting);
	}


	// Finally, store all of the settings properties
	PropertySettings.Length = 0;
	j = InObj.Properties.Length;

	for (i=0; i<j; ++i)
	{
		CurProp.Property = InObj.GetPropertyName(InObj.Properties[i].PropertyID);
		CurProp.Value = InObj.GetPropertyAsStringByName(CurProp.Property);

		// Don't add blank properties
		if (CurProp.Value != "")
			PropertySettings.AddItem(CurProp);
	}


	// Save the values
	SaveConfig();
}

// Transfers this profiles current settings to the specified input object
function TransferSettings(Settings InObj, optional bool bForceTransfer)
{
	local DataBindingInfo CurProp;
	local LocalizedSettingInfo CurLocSetting;
	local int i;

	if (InObj.Class.Name != SettingsClassName && !bForceTransfer)
		return;


	// Copy over all of the databinding values
	foreach DataBindingProperties(CurProp)
		InObj.SetDataBindingValue(CurProp.Property, CurProp.Value);


	// Copy over all of the localized values
	foreach LocalizedSettings(CurLocSetting)
	{
		i = InObj.LocalizedSettings.Find('ID', CurLocSetting.ID);

		if (i != INDEX_None)
			InObj.LocalizedSettings[i].ValueIndex = CurLocSetting.Value;
	}


	// Finally, copy over all of the properties
	foreach PropertySettings(CurProp)
		InObj.SetPropertyFromStringByName(CurProp.Property, CurProp.Value);
}