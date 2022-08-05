﻿/**
 * Dataprovider that gives a key/value list of details for a server given its search result row.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_ServerDetails extends UTUIDataProvider_SimpleElementProvider
	native(UI);



/** Provider that has server information. */
var transient int	SearchResultsRow;

/** @return Returns a reference to the search results provider that is used to generate data for this class. */
native function UIDataProvider_Settings GetSearchResultsProvider();

/** Returns the number of elements in the list. */
native function int GetElementCount();

DefaultProperties
{
}
