/**
 * This data store class provides query and search results for the UTQueryHelper class.
 * This is a stripped down version of the history/favourites data store, which searches for servers based upon port and IP.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTDataStore_GameSearchFind extends UTDataStore_GameSearchPersonal;

var transient UTDataStore_GameSearchHistory HistoryGameSearchDataStore;

// Set by the UTQueryHelper object, before initiating a search
var string SearchIP;
var string SearchPort;


// Delegate for passing back a call to setup the query filter
delegate bool OnSetupQueryFilters(OnlineGameSearch Search)
{
	return False;
}


/**
 * @param	bRestrictCheckToSelf	if TRUE, will not check related game search data stores for outstanding queries.
 *
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries(optional bool bRestrictCheckToSelf)
{
	local bool bResult;

	bResult = Super.HasOutstandingQueries(bRestrictCheckToSelf);

	// N.B. I don't restrict the histories check because otherwise I would have to add even more duplicate code here.
	// Also, while this data store is querying, there should be a message box preventing the user from instigating more searches,
	// so there should be no need to pass on checks from this data store to others
	if (!bResult && !bRestrictCheckToSelf && HistoryGameSearchDataStore != none)
		bResult = HistoryGameSearchDataStore.HasOutstandingQueries();

	return bResult;
}


function OnSearchComplete(bool bWasSuccessful)
{
	Super(UTDataStore_GameSearchBase).OnSearchComplete(bWasSuccessful);
}

protected function bool OverrideQuerySubmission(byte ControllerId, OnlineGameSearch Search)
{
	return OnSetupQueryFilters(Search);
}


defaultproperties
{
	Tag=UTGameFind

	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchPersonal',DefaultGameSettingsClass=class'UTGame.UTGameSettingsPersonal',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchFind"))
}