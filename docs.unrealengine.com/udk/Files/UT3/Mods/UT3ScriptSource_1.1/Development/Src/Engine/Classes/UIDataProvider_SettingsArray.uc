/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for exposing string settings as arrays to the ui
 */
class UIDataProvider_SettingsArray extends UIDataProvider
	native(inherit)
	DependsOn(Settings)
	implements(UIListElementProvider,UIListElementCellProvider)
	transient;

/** Holds the settings object that will be exposed to the UI */
var Settings Settings;

/** The settings id this provider is responsible for managing */
var int SettingsId;

/** Cache for faster compares */
var name SettingsName;

/**
 * string to use in list column headers for this setting; assigned from the ColumnHeaderText property for the corresponding
 * property or setting from the Settings object.
 */
var	const	string	ColumnHeaderText;

/** Cached set of possible values for this array */
var array<Settings.IdToStringMapping> Values;



defaultproperties
{
	WriteAccessType=ACCESS_WriteAll
}
