/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for exposing the Gamma setting to the UI
 */
class UIDataStore_Gamma extends UIDataStore
	native(inherit)
	config(Engine)
	transient;



defaultproperties
{
	Tag=Display
	WriteAccessType=ACCESS_WriteAll
}
