/**
 * This game search data store handles generating and receiving results for internet queries of all gametypes.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTDataStore_GameSearchDM extends UTDataStore_GameSearchBase
	dependson(UTUIFrontEnd_BrowserMutatorFilters)
	config(UI);

`include(UTOnlineConstants.uci)

/** Struct for defining a mutator filter setting */
struct MutatorFilter
{
	var string MutatorClass;	// Classname of the mutator (must not include package name)
	var bool bMutatorName;		// If true, MutatorClass represents a mutator name instead of class
	var int OfficialMutValue;	// If this is non-zero, then MutatorClass is ignored and this is treated as an official mutator

	var bool bMustBeOn;		// If true, the mutator must be enabled on the server, otherwise it must be disabled
};


var			class<UTDataStore_GameSearchHistory>	HistoryGameSearchDataStoreClass;

/** Reference to the search data store that handles the player's list of most recently visited servers */
var	transient	UTDataStore_GameSearchHistory		HistoryGameSearchDataStore;

/** Reference to the data store which handles the 'Find IP' and 'Add IP' IP search queries */
var transient UTDataStore_GameSearchFind FindGameSearchDataStore;


/** Can be set to ML_NoMutators (no mutators must be running), ML_AnyMutators (doesn't matter what mutators are running) and ML_Custom (checks MutatorFilters) */
var EMutatorList MutatorFilterSetting;

/** If 'MutatorFilterSetting' is set to ML_Custom, then servers must match the list of mutator filter settings defined here */
var array<MutatorFilter> MutatorFilters;


/** These lists are cached here for use by the mutator filter menu */
var array<EMutFilterList> InstalledMutFilters;
var array<EMutFilterList> AdditionalMutClassFilters;
var array<EMutFilterList> AdditionalMutNameFilters;
var bool bMutatorFilterSet;


/** When a custom gametype is selected in the server browser, this value is set to the gametypes class, and is used to properly filter that gametype */
var transient string CustomGameTypeClass;



/**
 * A simple mapping of localized setting ID to a localized setting value ID.
 */
struct PersistentLocalizedSettingValue
{
	/** the ID of the setting */
	var	config	int		SettingId;

	/** the id of the value */
	var	config	int		ValueId;
};

/**
 * Stores a list of values ids for a single game search configuration.
 */
struct GameSearchSettingsStorage
{
	/** the name of the game search configuration */
	var	config	name									GameSearchName;

	/** the list of stored values */
	var	config	array<PersistentLocalizedSettingValue>	StoredValues;
};

/** the list of search parameter values per game search configuration */
var	config	array<GameSearchSettingsStorage>	StoredGameSearchValues;


event Registered( LocalPlayer PlayerOwner )
{
	local DataStoreClient DSClient;

	Super.Registered(PlayerOwner);

	DSClient = GetDataStoreClient();
	if ( DSClient != None )
	{
		// now create the game history data store
		if ( HistoryGameSearchDataStoreClass == None )
		{
			HistoryGameSearchDataStoreClass = class'UTGame.UTDataStore_GameSearchHistory';
		}

		HistoryGameSearchDataStore = DSClient.CreateDataStore(HistoryGameSearchDataStoreClass);
		HistoryGameSearchDataStore.PrimaryGameSearchDataStore = Self;

		// and register it
		DSClient.RegisterDataStore(HistoryGameSearchDataStore, PlayerOwner);


		// Create the game find data store
		FindGameSearchDataStore = DSClient.CreateDataStore(Class'UTGame.UTDataStore_GameSearchFind');
		FindGameSearchDataStore.PrimaryGameSearchDataStore = Self;
		FindGameSearchDataStore.HistoryGameSearchDataStore = HistoryGameSearchDataStore;

		// Register it
		DSClient.RegisterDataStore(FindGameSearchDataStore, PlayerOwner);
	}

	LoadGameSearchParameters();
}

/**
 * Called to kick off an online game search and set up all of the delegates needed; this version saved the search parameters
 * to persistent storage and sets up extra filters.
 *
 * @param ControllerIndex the ControllerId for the player to perform the search for
 * @param bInvalidateExistingSearchResults	specify FALSE to keep previous searches (i.e. for other gametypes) in memory; default
 *											behavior is to clear all search results when switching to a different item in the game search list
 *
 * @return TRUE if the search call works, FALSE otherwise
 */
event bool SubmitGameSearch(byte ControllerIndex, optional bool bInvalidateExistingSearchResults=true)
{
	local int i, OfficialMutsOn, OfficialMutsOff;
	local OnlineGameSearch GS;
	local ClientOnlineGameSearchOrClause CurClientFilter;
	local RawOnlineGameSearchOrClause CurRawFilter;
	local array<string> CustomMutClassesOn, CustomMutClassesOff, CustomMutNamesOn, CustomMutNamesOff;

	// Setup the filters
	GS = GetCurrentGameSearch();
	GS.ResetFilters();

	if (MutatorFilterSetting == ML_NoMutators)
	{
		// Setup the clientside filter to remove all servers running any official mutators
		CurClientFilter.OrParams.Length = 1;
		CurClientFilter.OrParams[0].EntryId = PROPERTY_EPICMUTATORS;
		CurClientFilter.OrParams[0].EntryType = OGSET_Property;
		CurClientFilter.OrParams[0].ComparisonDelegate = NoOfficialMuts;
		CurClientFilter.OrParams[0].ComparedValue = "0";

		GS.ClientsideFilters.AddItem(CurClientFilter);


		// Setup the 'raw' master server query to removal all servers running custom mutators
		CurRawFilter.OrParams.Length = 1;
		CurRawFilter.OrParams[0].EntryId = PROPERTY_CUSTOMMUTCLASSES;
		CurRawFilter.OrParams[0].EntryType = OGSET_Property;
		CurRawFilter.OrParams[0].ComparisonOperator = "=";
		CurRawFilter.OrParams[0].ComparedValue = "''";

		GS.RawFilterQueries.AddItem(CurRawFilter);


		// Check the mutator names field as well as the mutator classes field
		CurRawFilter.OrParams[0].EntryId = PROPERTY_CUSTOMMUTATORS;
		GS.RawFilterQueries.AddItem(CurRawFilter);
	}
	else if (MutatorFilterSetting == ML_Custom)
	{
		// First generate the official mutator bitmasks and custom mutator lists
		for (i=0; i<MutatorFilters.Length; ++i)
		{
			if (MutatorFilters[i].OfficialMutValue != 0)
			{
				if (MutatorFilters[i].bMustBeOn)
					OfficialMutsOn = OfficialMutsOn | MutatorFilters[i].OfficialMutValue;
				else
					OfficialMutsOff = OfficialMutsOff | MutatorFilters[i].OfficialMutValue;
			}
			else if (MutatorFilters[i].MutatorClass != "")
			{
				if (MutatorFilters[i].bMutatorName)
				{
					if (MutatorFilters[i].bMustBeOn)
						CustomMutNamesOn.AddItem(MutatorFilters[i].MutatorClass);
					else
						CustomMutNamesOff.AddItem(MutatorFilters[i].MutatorClass);
				}
				else
				{
					if (MutatorFilters[i].bMustBeOn)
						CustomMutClassesOn.AddItem(MutatorFilters[i].MutatorClass);
					else
						CustomMutClassesOff.AddItem(MutatorFilters[i].MutatorClass);
				}
			}
		}


		// Now setup the clientside filters for the official mutator bitmask filters (must be done clientside since Gamespy can't do bitmask operations)
		CurClientFilter.OrParams.Length = 1;
		CurClientFilter.OrParams[0].EntryId = PROPERTY_EPICMUTATORS;
		CurClientFilter.OrParams[0].EntryType = OGSET_Property;

		if (OfficialMutsOn != 0)
		{
			CurClientFilter.OrParams[0].ComparisonDelegate = OfficialMutEnabled;
			CurClientFilter.OrParams[0].ComparedValue = string(OfficialMutsOn);

			GS.ClientsideFilters.AddItem(CurClientFilter);
		}

		if (OfficialMutsOff != 0)
		{
			CurClientFilter.OrParams[0].ComparisonDelegate = OfficialMutDisabled;
			CurClientFilter.OrParams[0].ComparedValue = string(OfficialMutsOff);

			GS.ClientsideFilters.AddItem(CurClientFilter);
		}


		// Setup the 'raw' master server filters for the custom mutator class filters
		CurRawFilter.OrParams.Length = 1;
		CurRawFilter.OrParams[0].EntryId = PROPERTY_CUSTOMMUTCLASSES;
		CurRawFilter.OrParams[0].EntryType = OGSET_Property;

		if (CustomMutClassesOn.Length != 0)
		{
			CurRawFilter.OrParams[0].ComparisonOperator = " LIKE";

			for (i=0; i<CustomMutClassesOn.Length; ++i)
			{
				// N.B. All mutator class entries are encased with a special character, Chr(28)
				CurRawFilter.OrParams[0].ComparedValue = "'%"$Chr(28)$CustomMutClassesOn[i]$Chr(28)$"%'";
				GS.RawFilterQueries.AddItem(CurRawFilter);
			}
		}

		if (CustomMutClassesOff.Length != 0)
		{
			CurRawFilter.OrParams[0].ComparisonOperator = " NOT LIKE";

			for (i=0; i<CustomMutClassesOff.Length; ++i)
			{
				CurRawFilter.OrParams[0].ComparedValue = "'%"$Chr(28)$CustomMutClassesOff[i]$Chr(28)$"%'";
				GS.RawFilterQueries.AddItem(CurRawFilter);
			}
		}


		// Finally, setup the raw filters for the custom mutator name filters
		CurRawFilter.OrParams[0].EntryId = PROPERTY_CUSTOMMUTATORS;

		if (CustomMutNamesOn.Length != 0)
		{
			CurRawFilter.OrParams[0].ComparisonOperator = " LIKE";

			for (i=0; i<CustomMutNamesOn.Length; ++i)
			{
				// N.B. It can't be guaranteed that the Chr(28) delimiter will be present in the names list, so don't include it in the query
				CurRawFilter.OrParams[0].ComparedValue = "'%"$CustomMutNamesOn[i]$"%'";
				GS.RawFilterQueries.AddItem(CurRawFilter);
			}
		}

		if (CustomMutNamesOff.Length != 0)
		{
			CurRawFilter.OrParams[0].ComparisonOperator = " NOT LIKE";

			for (i=0; i<CustomMutNamesOff.Length; ++i)
			{
				CurRawFilter.OrParams[0].ComparedValue = "'%"$CustomMutNamesOff[i]$"%'";
				GS.RawFilterQueries.AddItem(CurRawFilter);
			}
		}
	}

	// If the current search is a custom gametype search, then add a filter for that gametypes classname
	if (CustomGameTypeClass != "" && GameSearchCfgList[SelectedIndex].SearchName == 'UTGameSearchCustom')
	{
		CurRawFilter.OrParams.Length = 1;
		CurRawFilter.OrParams[0].EntryId = PROPERTY_CUSTOMGAMEMODE;
		CurRawFilter.OrParams[0].EntryType = OGSET_Property;
		CurRawFilter.OrParams[0].ComparisonOperator = "=";
		CurRawFilter.OrParams[0].ComparedValue = "'"$CustomGameTypeClass$"'";

		GS.RawFilterQueries.AddItem(CurRawFilter);
	}


	if ( bInvalidateExistingSearchResults || !HasExistingSearchResults() )
	{
		SaveGameSearchParameters();
	}

	return Super.SubmitGameSearch(ControllerIndex, bInvalidateExistingSearchResults);
}


// Clientside mutator filter operators

// For official mutators which must be on
final function bool OfficialMutEnabled(string PropertyValue, string ComparedValue)
{
	return !bool(~int(PropertyValue) & int(ComparedValue));
}

// For official muts which must be off
final function bool OfficialMutDisabled(string PropertyValue, string ComparedValue)
{
	return !bool(int(PropertyValue) & int(ComparedValue));
}

// No official muts at all
final function bool NoOfficialMuts(string PropertyValue, string ComparedValue)
{
	return int(PropertyValue) == 0;
}


/**
 * @param	bRestrictCheckToSelf	if TRUE, will not check related game search data stores for outstanding queries.
 *
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries( optional bool bRestrictCheckToSelf )
{
	local bool bResult;

	bResult = Super.HasOutstandingQueries(bRestrictCheckToSelf);
	if ( !bResult && !bRestrictCheckToSelf && HistoryGameSearchDataStore != None )
	{
		bResult = HistoryGameSearchDataStore.HasOutstandingQueries(true);
		if ( !bResult && HistoryGameSearchDataStore.FavoritesGameSearchDataStore != None )
		{
			bResult = HistoryGameSearchDataStore.FavoritesGameSearchDataStore.HasOutstandingQueries(true);
		}
	}

	return bResult;
}

/** these have been moved up a class and are left like this for binary compatibility */
function bool GetEnabledMutators(out array<int> MutatorIndices)
{
	return Super.GetEnabledMutators(MutatorIndices);
}
function bool HasExistingSearchResults()
{
	return Super.HasExistingSearchResults();
}



/**
 * Finds the index of the saved parameters for the specified game search.
 *
 * @param	GameSearchName	the name of the game search to find saved parameters for
 *
 * @return	the index for the saved parameters associated with the specified gametype, or INDEX_NONE if not found.
 */
function int FindStoredSearchIndex( name GameSearchName )
{
	local int i, Result;

	Result = INDEX_NONE;
	for ( i = 0; i < StoredGameSearchValues.Length; i++ )
	{
		if ( StoredGameSearchValues[i].GameSearchName == GameSearchName )
		{
			Result = i;
			break;
		}
	}

	return Result;
}

/**
 * Find the index for the specified setting in a game search configuration's saved parameters.
 *
 * @param	StoredGameSearchIndex	the index of the game search configuration to lookup
 * @param	LocalizedSettingId		the id of the setting to find the value for
 * @param	bAddIfNecessary			if the specified setting Id is not found in the saved parameters for the game search config,
 *									automatically creates an entry for that setting if this value is TRUE
 *
 * @return	the index of the setting in the game search configuration's saved parameters list of settings, or INDEX_NONE if
 *			it doesn't exist.
 */
function int FindStoredSettingValueIndex( int StoredGameSearchIndex, int LocalizedSettingId, optional bool bAddIfNecessary )
{
	local int i, Result;

	Result = INDEX_NONE;
	if ( StoredGameSearchIndex >= 0 && StoredGameSearchIndex < StoredGameSearchValues.Length )
	{
		for ( i = 0; i < StoredGameSearchValues[StoredGameSearchIndex].StoredValues.Length; i++ )
		{
			if ( StoredGameSearchValues[StoredGameSearchIndex].StoredValues[i].SettingId == LocalizedSettingId )
			{
				Result = i;
				break;
			}
		}

		if ( Result == INDEX_NONE && bAddIfNecessary )
		{
			Result = StoredGameSearchValues[StoredGameSearchIndex].StoredValues.Length;

			StoredGameSearchValues[StoredGameSearchIndex].StoredValues.Length = Result + 1;
			StoredGameSearchValues[StoredGameSearchIndex].StoredValues[Result].SettingId = LocalizedSettingId;
		}
	}

	return Result;
}

/**
 * Loads the saved game search parameters from disk and initializes the game search objects with the previously
 * selected values.
 */
function LoadGameSearchParameters()
{
	local OnlineGameSearch Search;
	local int GameIndex, SettingIndex, SettingId,
		StoredSearchIndex, SettingValueIndex, SettingValueId;

	// for each game configuration
	for ( GameIndex = 0; GameIndex < GameSearchCfgList.Length; GameIndex++ )
	{
		Search = GameSearchCfgList[GameIndex].Search;
		if ( Search != None )
		{
			// find the index of the persistent settings for this gametype
			StoredSearchIndex = FindStoredSearchIndex(GameSearchCfgList[GameIndex].SearchName);
			if ( StoredSearchIndex != INDEX_NONE )
			{
				// for each localized setting in this game search object, copy the stored value into the search object for this game search configuration.
				for ( SettingIndex = 0; SettingIndex < Search.LocalizedSettings.Length; SettingIndex++ )
				{
					SettingId = Search.LocalizedSettings[SettingIndex].Id;

					// skip the gametype property
					if ( SettingId != class'UTGameSearchCommon'.const.CONTEXT_GAME_MODE )
					{
						SettingValueIndex = FindStoredSettingValueIndex(StoredSearchIndex, SettingId);
						if (SettingValueIndex >= 0
						&&	SettingValueIndex < StoredGameSearchValues[StoredSearchIndex].StoredValues.Length)
						{
							SettingValueId = StoredGameSearchValues[StoredSearchIndex].StoredValues[SettingValueIndex].ValueId;

							// apply it to the settings object
							Search.SetStringSettingValue(SettingId, SettingValueId, false);
						}
					}
				}
			}
		}
	}
}

/**
 * Saves the user selected game search options to disk.
 */
function SaveGameSearchParameters()
{
	local OnlineGameSearch Search;
	local int GameIndex, SettingIndex, SettingId,
		StoredSearchIndex, SettingValueIndex;
	local bool bDirty;

	// for each game configuration
	for ( GameIndex = 0; GameIndex < GameSearchCfgList.Length; GameIndex++ )
	{
		Search = GameSearchCfgList[GameIndex].Search;
		if ( Search != None )
		{
			// find the index of the persistent settings for this gametype
			StoredSearchIndex = FindStoredSearchIndex(GameSearchCfgList[GameIndex].SearchName);
			if ( StoredSearchIndex == INDEX_NONE )
			{
				// if not found, add a new entry to hold this game configuration's search params
				StoredSearchIndex = StoredGameSearchValues.Length;
				StoredGameSearchValues.Length = StoredSearchIndex + 1;
				StoredGameSearchvalues[StoredSearchIndex].GameSearchName = GameSearchCfgList[GameIndex].SearchName;
				bDirty = true;
			}

			// for each localized setting in this game search object, copy the current value into our persistent storage
			for ( SettingIndex = 0; SettingIndex < Search.LocalizedSettings.Length; SettingIndex++ )
			{
				SettingId = Search.LocalizedSettings[SettingIndex].Id;

				// skip the gametype property
				if ( SettingId != class'UTGameSearchCommon'.const.CONTEXT_GAME_MODE )
				{
					SettingValueIndex = FindStoredSettingValueIndex(StoredSearchIndex, SettingId, true);
					bDirty = bDirty || StoredGameSearchValues[StoredSearchIndex].StoredValues[SettingValueIndex].ValueId != Search.LocalizedSettings[SettingIndex].ValueIndex;
					StoredGameSearchValues[StoredSearchIndex].StoredValues[SettingValueIndex].ValueId = Search.LocalizedSettings[SettingIndex].ValueIndex;
				}
			}
		}
	}

	if ( bDirty )
	{
		SaveConfig();
	}
}

function SetCurrentByIndex(int NewIndex, optional bool bInvalidateExistingSearchResults=True)
{
	// Reset 'CustomGameTypeClass' if the current search index isn't set to the custom search index
	if (NewIndex == INDEX_None || NewIndex >= GameSearchCfgList.Length || GameSearchCfgList[NewIndex].SearchName != 'UTGameSearchCustom')
		CustomGameTypeClass = "";

	Super.SetCurrentByIndex(NewIndex, bInvalidateExistingSearchResults);
}

function SetCurrentByName(name SearchName, optional bool bInvalidateExistingSearchResults=True)
{
	if (SearchName != 'UTGameSearchCustom')
		CustomGameTypeClass = "";

	Super.SetCurrentByName(SearchName, bInvalidateExistingSearchResults);
}

DefaultProperties
{
	Tag=UTGameSearch
	HistoryGameSearchDataStoreClass=class'UTGame.UTDataStore_GameSearchHistory'

	MutatorFilterSetting=ML_AnyMutators

	GameSearchCfgList.Empty
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchDM',DefaultGameSettingsClass=class'UTGame.UTGameSettingsDM',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchDM"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchTDM',DefaultGameSettingsClass=class'UTGame.UTGameSettingsTDM',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchTDM"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchCTF',DefaultGameSettingsClass=class'UTGame.UTGameSettingsCTF',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchCTF"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchVCTF',DefaultGameSettingsClass=class'UTGame.UTGameSettingsVCTF',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchVCTF"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchWAR',DefaultGameSettingsClass=class'UTGame.UTGameSettingsWAR',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchWAR"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchDUEL',DefaultGameSettingsClass=class'UTGame.UTGameSettingsDUEL',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchDUEL"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchCampaign',DefaultGameSettingsClass=class'UTGame.UTGameSettingsCampaign',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchCampaign"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchCustom',DefaultGameSettingsClass=class'UTGame.UTGameSettingsDM',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchCustom"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchGreed',DefaultGameSettingsClass=class'UTGame.UTGameSettingsGreed',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchGreed"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchBetrayal',DefaultGameSettingsClass=class'UTGame.UTGameSettingsBetrayal',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchBetrayal"))
}
