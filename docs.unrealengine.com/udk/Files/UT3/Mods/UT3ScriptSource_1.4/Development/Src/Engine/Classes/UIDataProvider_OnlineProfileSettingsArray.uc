/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for exposing string settings as arrays to the ui
 */
class UIDataProvider_OnlineProfileSettingsArray extends UIDataProvider
	native(inherit)
	implements(UIListElementProvider,UIListElementCellProvider)
	transient;

/** Holds the profile object that will be exposed to the UI */
var OnlineProfileSettings ProfileSettings;

/** The settings id this provider is responsible for managing */
var int ProfileSettingId;

/** Cache for faster compares */
var name ProfileSettingsName;

/**
 * string to use in list column headers for this setting; assigned from the ColumnHeaderText property for the corresponding
 * property or setting from the Settings object.
 */
var	const	string	ColumnHeaderText;

/** Cached set of possible values for this array */
var array<name> Values;



defaultproperties
{
	WriteAccessType=ACCESS_WriteAll
}
