/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base configuration settings for an online game
 */
class OnlineGameSettings extends Settings
	native;

/** The number of publicly available connections advertised */
var databinding int NumPublicConnections;

/** The number of connections that are private (invite/password) only */
var databinding int NumPrivateConnections;

/** The number of publicly available connections that are available (read only) */
var databinding int NumOpenPublicConnections;

/** The number of private connections that are available (read only) */
var databinding int NumOpenPrivateConnections;

/** The server's nonce for this session */
var const byte ServerNonce[8];

/** Max number of queries returned by the match finding service */
var int MaxSearchResults;

/** Whether this match is publicly advertised on the online service */
var databinding bool bShouldAdvertise;

/** This game will be lan only and not be visible to external players */
var databinding bool bIsLanMatch;

/** Whether the match should gather stats or not */
var databinding bool bUsesStats;

/** Whether joining in progress is allowed or not */
var databinding bool bAllowJoinInProgress;

/** Whether the match allows invitations for this session or not */
var databinding bool bAllowInvites;

/** Whether to display user presence information or not */
var databinding bool bUsesPresence;

/** Whether joining via player presence is allowed or not */
var databinding bool bAllowJoinViaPresence;

/** Whether the session should use arbitration or not */
var databinding bool bUsesArbitration;

/** Whether the game is an invitation or searched for game */
var const bool bWasFromInvite;

/** The owner of the game */
var databinding string OwningPlayerName;

/** The unique net id of the player that owns this game */
var UniqueNetId OwningPlayerId;

/** The ping of the server in milliseconds */
var databinding int PingInMs;

/** Whether this server is a dedicated server or not */
var databinding bool bIsDedicated;

/** Whether this server is a list play server or not */
var databinding bool bIsListPlay;

/** The type of dedicated server (everyone, premium, etc) */
enum EDedicatedServerType
{
	/** Anyone that can play MP can join */
	DST_Standard,
	/** Anyone with a premium play account can join */
	DST_Premium1,
	/** Anyone with the next level of premium play can join */
	DST_Premium2
};

/** The type of server based upon player service restrictions */
var EDedicatedServerType DedicatedServerType;

/** The average of player skills currently playing in this game */
var databinding float AverageSkillRating;

/** The version of the engine the server is running */
var databinding const int EngineVersion;

/** The minimum network version that is compatibile with the server */
var databinding const int MinNetVersion;

/** The IP:Port of the server (set clientside when receiving server data) */
var databinding const string ServerIP;


struct native PlayerRecord
{
	/** The player name */
	var string name;
	/** The player's score */
	var int score;
	/** The ping of the player as known by the server */
	var int ping;
	/** the name of the team the player is on, or empty when there are no teams*/	
	var string team;
	/** number of times the player has died */
	var int deaths;
	/** the player id in the current game */
	var int pid;
};

/** Players currently playing on the server */
var array<PlayerRecord> Players;


/** Settings which can be safely omitted from the server details */

/** Compared against the raw property name */
var array<name> OptionalDataBindingSettings;

/** Compared against the localized settings 'ID' value */
var array<int> OptionalLocalizedSettings;

/** Compared against the properties 'PropertyID' value */
var array<int> OptionalPropertySettings;


/** Forces the removal of all optional settings (to test whether or not values are safe to remove) */
var bool bDebugRemoveOptionalSettings;


/**
 * If a databinding setting wont fit into the server details results, give the script a chance to trim the data
 * NOTE: Value will be in the format: ",Property=Value"
 *
 * @param PropertyName The name of the property to be trimmed
 * @param MaxLen The maximum length of the string
 * @param Value The modified string value
 *
 * @return Whether or not the value was successfully trimmed
 */
event bool TrimDataBindingValue(name PropertyName, int MaxLen, out string Value)
{
	return False;
}

/**
 * If a localized setting wont fit into the server details results, give the script a chance to trim the data
 * NOTE: Value will be in the format: ",Property=Value"
 *
 * @param ID The id of the localized value to be trimmed
 * @param MaxLen The maximum length of the string
 * @param Value The modified string value
 *
 * @return Whether or not the value was successfully trimmed
 */
event bool TrimLocalizedValue(int ID, int MaxLen, out string Value)
{
	return False;
}

/**
 * If a property setting wont fit into the server details results, give the script a chance to trim the data
 * NOTE: Value will be in the format: ",Property=Value"
 *
 * @param PropertyId The id of the property setting to be trimmed
 * @param MaxLen The maximum length of the string
 * @param Value The modified string value
 *
 * @return Whether or not the value was successfully trimmed
 */
event bool TrimPropertyValue(int PropertyID, int MaxLen, out string Value)
{
	return False;
}


defaultproperties
{
	bAllowJoinInProgress=true
	bUsesStats=true
	bShouldAdvertise=true
	bAllowInvites=true
	bUsesPresence=true
	bAllowJoinViaPresence=true
	AverageSkillRating=1000.0f
}