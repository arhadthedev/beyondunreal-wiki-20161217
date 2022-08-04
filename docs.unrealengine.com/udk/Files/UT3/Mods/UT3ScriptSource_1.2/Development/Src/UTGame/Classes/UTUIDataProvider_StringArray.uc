/**
 * Dataprovider that provides an array of strings.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIDataProvider_StringArray extends UTUIDataProvider_SimpleElementProvider
	native(UI);



/** Strings being provided by this provider. */
var array<string> Strings;

/** @return Returns the number of elements(rows) provided. */
native function int GetElementCount();