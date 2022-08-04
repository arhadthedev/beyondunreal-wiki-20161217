/**
 * Dataprovider that returns a row for each installed content package.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIDataProvider_InstalledContent extends UTUIDataProvider_SimpleElementProvider
	native(UI);



/** @return Returns the number of elements(rows) provided. */
native function int GetElementCount();

DefaultProperties
{
	
}