/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Warfare specific datastore for TDM game searches
 */
class UTDataStore_GameSearchDM extends UIDataStore_OnlineGameSearch
	native(UI);



/** Reference to the dataprovider that will provide details for a specific search result. */
var transient UTUIDataProvider_ServerDetails ServerDetailsProvider;

/**
 * Retrieves the list of currently enabled mutators.
 *
 * @param	MutatorIndices	indices are from the list of UTUIDataProvider_Mutator data providers in the
 *							UTUIDataStore_MenuItems data store which are currently enabled.
 *
 * @return	TRUE if the list of enabled mutators was successfully retrieved.
 */
native final function bool GetEnabledMutators( out array<int> MutatorIndices );

/**
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries()
{
	local bool bResult;
	local int i;

	for ( i = 0; i < GameSearchCfgList.Length; i++ )
	{
		if ( GameSearchCfgList[i].Search != None && GameSearchCfgList[i].Search.bIsSearchInProgress )
		{
			bResult = true;
			break;
		}
	}

	return bResult;
}

/**
 * @return	TRUE if the current game search has completed a query.
 */
function bool HasExistingSearchResults()
{
	local bool bQueryCompleted;

	// ok, this is imprecise - we may have already issued a query, but no servers were found...
	// could add a bool
	if ( SelectedIndex >=0 && SelectedIndex < GameSearchCfgList.Length )
	{
		bQueryCompleted = GameSearchCfgList[SelectedIndex].Search.Results.Length > 0;
	}

	return bQueryCompleted;
}

defaultproperties
{
	GameSearchCfgList.Empty
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchDM',DefaultGameSettingsClass=class'UTGame.UTGameSettingsDM',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchDM"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchTDM',DefaultGameSettingsClass=class'UTGame.UTGameSettingsTDM',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchTDM"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchCTF',DefaultGameSettingsClass=class'UTGame.UTGameSettingsCTF',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchCTF"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchVCTF',DefaultGameSettingsClass=class'UTGame.UTGameSettingsVCTF',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchVCTF"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchWAR',DefaultGameSettingsClass=class'UTGame.UTGameSettingsWAR',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchWAR"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchDUEL',DefaultGameSettingsClass=class'UTGame.UTGameSettingsDUEL',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchDUEL"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchCampaign',DefaultGameSettingsClass=class'UTGame.UTGameSettingsCampaign',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchCampaign"))

	Tag=UTGameSearch
}
