/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for mapping properties in an Settings
 * object to something that the UI system can consume.
 */
class UIDataProvider_Settings extends UIDynamicDataProvider
	native(inherit)
	transient;

/** Holds the settings object that will be exposed to the UI */
var Settings Settings;

/** Keeps a list of providers for each settings id */
struct native SettingsArrayProvider
{
	/** The settings id that this provider is for */
	var int SettingsId;
	/** Cached to avoid extra look ups */
	var name SettingsName;
	/** The provider object to expose the data with */
	var UIDataProvider_SettingsArray Provider;
};

/** The list of mappings from settings id to their provider */
var array<SettingsArrayProvider> SettingsArrayProviders;

/** Whether this provider is a row in a list (removes array handling) */
var bool bIsAListRow;



defaultproperties
{
	WriteAccessType=ACCESS_WriteAll
}
