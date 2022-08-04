/**
 * Inherited version of the game resource datastore that exposes sets of options to the UI.
 * These option sets are then used to autogenerate widgets.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIDataStore_Options extends UIDataStore_GameResource
	native(UI)
	Config(Game);



/** collection of providers per part type. */
var	const	private	native	transient	MultiMap_Mirror		OptionProviders{TMultiMap<FName, class UUTUIResourceDataProvider*>};

/** Array of dynamically providers. */
var transient array<UTUIResourceDataProvider> DynamicProviders;

/** 
 * Clears all options in the specified set.
 *
 * @param SetName		Set to clear
 */
native function ClearSet(name SetName);

/** 
 * Appends N amount of providers to the specified set.
 *
 * @param SetName		Set to append to
 * @param NumOptions	Number of options to append
 */
native function AppendToSet(name SetName, int NumOptions);

/**
 * Retrieves a set of option providers.
 *
 * @param SetName		Set to retrieve
 * @param OutProviders	Storage array for resulting providers.
 * 
 */
native function GetSet(name SetName, out array<UTUIResourceDataProvider> OutProviders);


DefaultProperties
{
	Tag=UTOptions
	WriteAccessType=ACCESS_WriteAll
}


