/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base settings for an online game search
 */
class OnlineGameSearch extends Settings
	native;

/** Max number of queries returned by the matchmaking service */
var int MaxSearchResults;

/** The query to use for finding matching servers */
var LocalizedStringSetting Query;

/** Whether the query is intended for LAN matches or not */
var databinding bool bIsLanQuery;

/** Whether to use arbitration or not */
var databinding bool bUsesArbitration;

/** Whether the search object in question is in progress or not. This is the union of the other flags */
var const bool bIsSearchInProgress;

/** Whether or not this is a full server refresh (as compared to just a single server update) */
var const bool bIsFullServerUpdate;

/** Whether the search object in question has a listen server search in progress or not */
var const bool bIsListenServerSearchInProgress;

/** Whether the search object in question has a dedicated server search in progress or not */
var const bool bIsDedicatedServerSearchInProgress;

/** Whether the search object in question has a list play search in progress or not */
var const bool bIsListPlaySearchInProgress;

/** Whether the search should include dedicated servers or not */
var databinding bool bShouldIncludeDedicatedServers;

/** Whether the search should include listen servers or not */
var databinding bool bShouldIncludeListenServers;

/** Whether the search should include list play servers or not */
var databinding bool bShouldIncludeListPlayServers;

/** The total number of list play servers available if a list play search */
var databinding int NumListPlayServersAvailable;

/** Struct used to return matching servers */
struct native OnlineGameSearchResult
{
	/** The settings used by this particular server */
	var const OnlineGameSettings GameSettings;
	/**
	 * Platform/online provider specific data
	 * NOTE: It is imperative that the subsystem be called to clean this data
	 * up or the PlatformData will leak memory!
	 */
	var const native pointer PlatformData{void};

	/** Platform/online provider specific data */
	var const native pointer ServerSearchData{void};

	
};

/** The class to create for each returned result from the search */
var class<OnlineGameSettings> GameSettingsClass;

/** Platform specific data related to the game search */
var native const transient private pointer SearchHandle{void};

/** The list of servers and their settings that match the search */
var const array<OnlineGameSearchResult> Results;

/**
 * Used to search for named properties on game setting objects
 */
struct native NamedObjectProperty
{
	/** The name of the property to search with */
	var name ObjectPropertyName;
	/** The string value to compare against */
	var string ObjectPropertyValue;
};

/** The list of named properties to search on */
var array<NamedObjectProperty> NamedProperties;

/** String that is tacked onto the end of the search query */
var string AdditionalSearchCriteria;

/** The type of data to use to fill out an online parameter */
enum EOnlineGameSearchEntryType
{
	/** A property is used to filter with */
	OGSET_Property,
	/** A localized setting is used to filter with */
	OGSET_LocalizedSetting,
	/** A property on the game settings object to filter with */
	OGSET_ObjectProperty
};

/** The type of comparison to perform on the search entry */
enum EOnlineGameSearchComparisonType
{
	OGSCT_Equals,
	OGSCT_NotEquals,
	OGSCT_GreaterThan,
	OGSCT_GreaterThanEquals,
	OGSCT_LessThan,
	OGSCT_LessThanEquals
};

/** Struct used to describe a search criteria */
struct native OnlineGameSearchParameter
{
	/** The Id of the property or localized string */
	var int EntryId;
	/** The name of the property to search with */
	var name ObjectPropertyName;
	/** Whether this parameter to compare against comes from a property or a localized setting */
	var EOnlineGameSearchEntryType EntryType;
	/** The type of comparison to perform */
	var EOnlineGameSearchComparisonType ComparisonType;
};

/** Used to indicate which way to sort a result set */
enum EOnlineGameSearchSortType
{
	OGSSO_Ascending,
	OGSSO_Descending
};

/** Struct used to describe the sorting of items */
struct native OnlineGameSearchSortClause
{
	/** The Id of the property or localized string */
	var int EntryId;
	/** The name of the property to search with */
	var name ObjectPropertyName;
	/** Whether this parameter to compare against comes from a property or a localized setting */
	var EOnlineGameSearchEntryType EntryType;
	/** The type of comparison to perform */
	var EOnlineGameSearchSortType SortType;
};

/** Matches parameters using a series of OR comparisons */
struct native OnlineGameSearchORClause
{
	/** The list of parameters to compare and use as an OR clause */
	var array<OnlineGameSearchParameter> OrParams;
};

/** Struct used to describe a query */
struct native OnlineGameSearchQuery
{
	/** A set of OR clauses that are ANDed together to filter potential servers */
	var array<OnlineGameSearchORClause> OrClauses;
	/** A list of sort operations used to order the servers that match the filtering */
	var array<OnlineGameSearchSortClause> SortClauses;
};


/** Holds the query to use when filtering servers and they require non-predefined queries */
var const OnlineGameSearchQuery FilterQuery;



/** Raw (manually defined) queries */
/** Unlike 'FilterQuery' filters, these allow more flexibility in defining the query, and can be evaluated clientside if the query limit (512 bytes) is reached */

/** Template struct used to define a search parameter with manually defined comparision operator and value fields */
struct native RawOnlineGameSearchParameterTemplate
{
	/** The Id of the property or localized string to be compared */
	var int EntryId;
	/** The name of the property to search with */
	var name ObjectPropertyName;
	/** Whether this parameter to compare against comes from a property or a localized setting */
	var EOnlineGameSearchEntryType EntryType;

	/** If set, this string overrides the above variables, and will represent the server property that will be compared */
	var string EntryValue;
	/** The value to be compared against (N.B. For string comparisons, % is a wildcard, e.g. '%test%') */
	var string ComparedValue;
};

/** Struct used to define a 'raw' game search parameter, which is sent to the Gamespy master server (or evaluated clientside, if the query limit is reached) */
struct native RawOnlineGameSearchParameter extends RawOnlineGameSearchParameterTemplate
{
	/** The string used as the (SQL like) comparison operator; operators supported by the clientside evaluation code: */
	/** !=, >=, <=, =, <, >, LIKE, NOT LIKE */
	/** NOTE: For the LIKE and NOT LIKE operators, you will need to add a space at the start of this string */
	var string ComparisonOperator;
};

/** Matches raw parameters using a series of OR comparisons */
struct native RawOnlineGameSearchOrClause
{
	/** The list of raw parameters to compare and use as an OR clause */
	var array<RawOnlineGameSearchParameter> OrParams;
};


/** A list of additional manually defined queries which are ANDed together */
var array<RawOnlineGameSearchOrClause> RawFilterQueries;

/** If 'FilterQuery'+'RawFilterQueries' exceeds Gamespy's query limit (512 bytes), the excess queries from 'RawFilterQueries' are put here for clientside filtering */
var const array<RawOnlineGameSearchOrClause> RemainingFilterQueries;



/** Clientside filters */

/** Struct used to define a clientside filter, which is based upon the 'raw' game search parameter */
struct native ClientOnlineGameSearchParameter extends RawOnlineGameSearchParameterTemplate
{
	/** The delegate which is used to compare the parameter values, this must be set when adding to 'ClientsideFilters' */
	var delegate<OnComparePropertyValue> ComparisonDelegate;
};

/** Matches parameters using a series of OR comparisions */
struct native ClientOnlineGameSearchOrClause
{
	/** The list of parameters to compare and use as an OR clause */
	var array<ClientOnlineGameSearchParameter> OrParams;
};


/** A list of clientside filters which are ANDed together */
var array<ClientOnlineGameSearchOrClause> ClientsideFilters;


/** Delegate template for comparing game search parameter values */
delegate bool OnComparePropertyValue(string PropertyValue, string ComparedValue)
{
	return False;
}




// Resets all queries that are modifed at runtime
function ResetFilters()
{
	AdditionalSearchCriteria = "";
	RawFilterQueries.Length = 0;
	ClientsideFilters.Length = 0;
}



defaultproperties
{
	// Override this with your game specific class so that metadata can properly
	// expose the game information to the UI
	GameSettingsClass=class'Engine.OnlineGameSettings'
	MaxSearchResults=25
	bShouldIncludeListenServers=true
}
