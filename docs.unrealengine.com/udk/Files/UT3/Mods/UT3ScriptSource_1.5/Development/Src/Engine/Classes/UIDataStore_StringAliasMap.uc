/**
 * This datastore allows games to map aliases to strings that may change based on the current platform or language setting.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 */
class UIDataStore_StringAliasMap extends UIDataStore
	native(inherit)
	Config(Game);

/** Struct to store the field values and how they map to localized strings */
struct native UIMenuInputMap
{
	var name FieldName;
	var name Set;
	var string MappedText;
};

/** Array of input string mappings for use in the front end. */
var config array<UIMenuInputMap> MenuInputMapArray;

/** collection of list element provider instances that are associated with each ElementProviderType */
var	const	private	native	transient	Map_Mirror		MenuInputSets{TMap<FName, TMap<FName, INT> >};

/** The index [into the Engine.GamePlayers array] for the player that this data store provides settings for. */
var	const transient int PlayerIndex;



/**
 * Returns a reference to the ULocalPlayer that this PlayerSettingsProvdier provider settings data for
 */
native final function LocalPlayer GetPlayerOwner() const;

/**
 * Attempts to find a mapping index given a field name.
 *
 * @param FieldName		Fieldname to search for.
 *
 * @return Returns the index of the mapping in the mapping array, otherwise INDEX_NONE if the mapping wasn't found.
 */
native final function int FindMappingWithFieldName( optional String FieldName="", optional String SetName="" );

/**
 * Set MappedString to be the localized string using the FieldName as a key
 * Returns the index into the mapped string array of where it was found.
 */
native virtual function int GetStringWithFieldName( String FieldName, out String MappedString );

DefaultProperties
{
	Tag=StringAliasMap
	WriteAccessType=ACCESS_ReadOnly
	PlayerIndex=INDEX_NONE
}