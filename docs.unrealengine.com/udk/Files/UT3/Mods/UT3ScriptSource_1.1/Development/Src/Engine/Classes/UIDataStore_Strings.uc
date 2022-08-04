/**
 * This datastore provides the UI with access to localized strings.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIDataStore_Strings extends UIDataStore
	native(inherit)
	transient;

/** list of data providers for each loc file */
var		transient		array<UIConfigFileProvider>		LocFileProviders;



DefaultProperties
{
	Tag=Strings
}
