/**
 * Inherited version of the game resource datastore that exposes the various customizeable character parts to the UI.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataStore_CustomChar extends UIDataStore
	native(UI)
	transient
	implements(UIListElementProvider)
	Config(CustomChar)
	dependson(UTCustomChar_Data);



/** collection of providers per part type. */
var	const	private	native	transient	MultiMap_Mirror		PartProviders{TMultiMap<FName, class UUIDataProvider*>};

/** Array of FNames for the parts map, this should map directly to the ECharPart enum. */
var array<name>	PartTags;

/** Set of currently active bots that the player is going to play against. */
var array<int>	ActiveBots;

/** The family of parts we are going to show the player. */
var string	CurrentFamily;

/** The currently selected character. */
var string	CurrentCharacter;

/** The currently selected faction. */
var string	CurrentFaction;

/**
 * Attempts to find the index of a provider given a provider field name, a search tag, and a value to match.
 *
 * @return	Returns the index of the provider or INDEX_NONE if the provider wasn't found.
 */
native function int FindValueInProviderSet(name ProviderFieldName, name SearchTag, string SearchValue);

/**
 * Attempts to find the value of a provider given a provider cell field.
 *
 * @return	Returns true if the value was found, false otherwise.
 */
native function bool GetValueFromProviderSet(name ProviderFieldName, name SearchTag, int ListIndex, out string OutValue);

/**
 * Attempts to find the number of list elements given a provider field.
 *
 * @return	Returns the number of elements.
 */
native function int GetProviderElementCount(name ProviderFieldName);

/**
 * Returns a set of filtered list element indices for the specified provider.
 *
 * @return	An array of list elements.
 */
native function array<int> GetProviderListElements(name ProviderFieldName);

DefaultProperties
{
	Tag=UTCustomChar
	WriteAccessType=ACCESS_WriteAll
	PartTags=("Heads","Helmets","Facemasks","Goggles","Torsos","ShoulderPads","Arms","Thighs","Boots") 
}


