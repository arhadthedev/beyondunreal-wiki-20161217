﻿/**
 * This specialized online game search data store provides the UI access to the search query and results for specific
 * servers that the player wishes to query.  It is aware of the main game search data store, and ensures that the main
 * search data store is not busy before allowing any action to take place.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTDataStore_GameSearchPersonal extends UTDataStore_GameSearchBase
	config(Game)
	abstract;

/**
 * reference to the main game search data store
 */
var	transient	UTDataStore_GameSearchDM	PrimaryGameSearchDataStore;

/** the maximum number of most recently visited servers that will be retained */
const MAX_PERSONALSERVERS=15;

struct native ServerEntry
{
	var string ServerUniqueId;
	var string ServerName;
};

/** the list of servers stored in this data store */
var	config ServerEntry ServerList[MAX_PERSONALSERVERS];

/**
 * @param	bRestrictCheckToSelf	if TRUE, will not check related game search data stores for outstanding queries.
 *
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries( optional bool bRestrictCheckToSelf )
{
	local bool bResult;

	bResult = Super.HasOutstandingQueries(bRestrictCheckToSelf);
	if ( !bResult && !bRestrictCheckToSelf && PrimaryGameSearchDataStore != None )
	{
		bResult = PrimaryGameSearchDataStore.HasOutstandingQueries(true);
	}

	return bResult;
}

/**
* Called by the online subsystem when the game search has completed
*
* @param bWasSuccessful true if the async action completed without error, false if there was an error
*/
function OnSearchComplete(bool bWasSuccessful)
{
	local GameSearchCfg Cfg;
	local OnlineGameSearchResult Result;
	local int i, Index;
	local string ServerId, ServerIP;
	local bool bSaveConfig;

	local ServerEntry AServer;
	local array<ServerEntry> OfflineServers;

	/*  
	 * We check the personal servers list against the returned
	 * array from the master server.  Any missing servers are added as placeholder. 
	 */
	if((ActiveSearchIndex != INDEX_NONE) && (HasOutstandingQueries()==false))
	{
		//Copy the list so we can work on it
		for (i=0; i<MAX_PERSONALSERVERS; i++)
		{
			if (GetServerUID(ServerList[i].ServerUniqueId) != "")
			{
				AServer.ServerUniqueId = ServerList[i].ServerUniqueId;
				AServer.ServerName = ServerList[i].ServerName;
				OfflineServers.AddItem(AServer);
			}
		}

		Cfg = GameSearchCfgList[ActiveSearchIndex];

		// Search the results for all servers found and remove them from 'offline list'
		for (Index = 0; Index < Cfg.Search.Results.length; Index++)
		{
			Result = Cfg.Search.Results[Index];
			ServerId = class'Engine.OnlineSubsystem'.static.UniqueNetIdToString(Result.GameSettings.OwningPlayerId);
			for (i = 0; i<OfflineServers.length; i++)
			{
				if (GetServerUID(OfflineServers[i].ServerUniqueId) == ServerId)
				{
					OfflineServers.Remove(i,1);
					break;
				}
			}

			// Update the server name (maybe it changed)
			for (i=0; i<MAX_PERSONALSERVERS; i++)
			{
				if (GetServerUID(ServerList[i].ServerUniqueId) == ServerId)
				{
					// If the server doesn't have an associated IP in the config file, then add it
					if (GetServerIP(ServerList[i].ServerUniqueID) == "")
					{
						ServerList[i].ServerUniqueID $= "-"$Result.GameSettings.ServerIP;
						bSaveConfig = True;
					}

					ServerList[i].ServerName = Result.GameSettings.OwningPlayerName;
					break;
				}
			}
		}

		if (bSaveConfig)
			SaveConfig();

		for (i = 0; i<OfflineServers.length; i++)
		{
			ServerIP = GetServerIP(OfflineServers[i].ServerUniqueID);

			if (ServerIP == "")
				AddOfflineServer(OfflineServers[i].ServerUniqueId, OfflineServers[i].ServerName);
			else
				AddJoinableOfflineServer(OfflineServers[i].ServerUniqueID, OfflineServers[i].ServerName, ServerIP);
		}
	}


	// Always return true, so that offline servers are always listed
	Super.OnSearchComplete(True);
}

/**
 * Worker for SubmitGameSeach; allows child classes to perform additional work before the query is submitted.
 *
 * @param	ControllerId	the index of the controller for the player to perform the search for.
 * @param	Search			the search object that will be used to generate the query.
 *
 * @return	TRUE to prevent SubmitGameSeach from submitting the search (such as when you do this step yourself).
 */
protected function bool OverrideQuerySubmission( byte ControllerId, OnlineGameSearch Search )
{
	local int i;
	local string QueryString;
	local UTGameSearchPersonal HistorySearch;
	local array<string> HistoryList;

	HistorySearch = UTGameSearchPersonal(Search);
	if ( HistorySearch != None )
	{
		GetServerStringList(HistoryList);

		// alter the query - remove all filters then add the list of the recently visited servers.
		for ( i = 0; i < HistoryList.Length; i++ )
		{
			if ( QueryString != "" )
			{
				QueryString $= "OR";
			}

			QueryString $= "(OwningPlayerId=" $ HistoryList[i] $ ")";
		}

		Search.AdditionalSearchCriteria = QueryString;
	}

	if ( QueryString == "" )
	{
		// if we don't have any servers in our history yet, just submit a query which is guaranteed to fail.
		Search.AdditionalSearchCriteria = "(OwningPlayerId=1)";
	}

	return false;
}

/**
 * Retrieve the name of the currently logged in profile.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 *
 * @return	the name of the currently logged in player.
 */
function string GetPlayerName( optional int ControllerId=0 )
{
	local string Result;
	local OnlinePlayerInterface PlayerInt;

	PlayerInt = OnlineSub.PlayerInterface;
	if ( PlayerInt != None )
	{
		Result = PlayerInt.GetPlayerNickname(ControllerId);
	}

	return Result;
}

/**
 * Retrieve the UniqueNetId for the currently logged in player.
 *
 * @param	out_PlayerId	receives the value of the logged in player's UniqueNetId
 * @param	ControllerId	the index of the controller associated with the logged in player.
 *
 * @return	TRUE if the logged in player's UniqueNetId was successfully retrieved.
 */
function bool GetPlayerNetId( out UniqueNetId out_PlayerId, optional int ControllerId=0  )
{
	local bool bResult;
	local OnlinePlayerInterface PlayerInt;

	PlayerInt = OnlineSub.PlayerInterface;
	if ( PlayerInt != None )
	{
		bResult = PlayerInt.GetUniquePlayerId(ControllerId, out_PlayerId);
	}

	return bResult;
}

/**
 * Find the index [into the server history list] of the specified server.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToFind		the UniqueNetId for the server to find
 *
 * @return	the index [into the server history list] for the specified server
 */
function int FindServerIndexByString( int ControllerId, string IdToFind )
{
	local int i, Result;

	Result = INDEX_NONE;
	for ( i = 0; i < MAX_PERSONALSERVERS; i++ )
	{
		if ( GetServerUID(ServerList[i].ServerUniqueId) == IdToFind )
		{
			Result = i;
			break;
		}
	}

	return Result;
}

/**
 * Find the index [into the server history list] of the specified server.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToFind		the UniqueNetId for the server to find
 *
 * @return	the index [into the server history list] for the specified server
 */
function int FindServerIndexById( int ControllerId, const out UniqueNetId IdToFind )
{
	return FindServerIndexByString(ControllerId, class'Engine.OnlineSubsystem'.static.UniqueNetIdToString(IdToFind));
}

/**
 * Add a server to the server history list.  Places the server at position 0; if the server already exists in the list
 * elsewhere, it is moved to position 0.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToFind		the UniqueNetId for the server to add
 */
function bool AddServer( int ControllerId, UniqueNetId IdToAdd, const string ServerNameToAdd )
{
	local int i, CurrentIndex;
	local string UniqueIdString;
	local bool bResult;

	// first, determine whether the server is already in our list
	UniqueIdString = class'Engine.OnlineSubsystem'.static.UniqueNetIdToString(IdToAdd);
	CurrentIndex = FindServerIndexByString(ControllerId, UniqueIdString);
	if ( CurrentIndex == INDEX_NONE )
	{
		CurrentIndex = MAX_PERSONALSERVERS - 1;
	}

	// if this server is already at position 0, leave it there
	if ( CurrentIndex != 0 )
	{
		for ( i = CurrentIndex; i > 0; i-- )
		{
			ServerList[i].ServerUniqueId = ServerList[i-1].ServerUniqueId;
			ServerList[i].ServerName = ServerList[i-1].ServerName;
		}

		ServerList[0].ServerUniqueId = UniqueIdString;
		ServerList[0].ServerName = ServerNameToAdd;
		SaveConfig();
		bResult = true;

		InvalidateCurrentSearchResults();
	}

	return bResult;
}

function bool AddServerPlusIP(int ControllerID, UniqueNetID IDToAdd, string ServerNameToAdd, string IPToAdd)
{
	local int i, CurrentIndex;
	local string UniqueIDString;
	local bool bResult;

	// First, determine whether the server is already in our list
	UniqueIDString = Class'Engine.OnlineSubsystem'.static.UniqueNetIDToString(IDToAdd);
	CurrentIndex = FindServerIndexByString(ControllerID, UniqueIDString);

	if (CurrentIndex == INDEX_None)
		CurrentIndex = MAX_PERSONALSERVERS - 1;

	// If this server is already at position 0, leave it there
	if (CurrentIndex != 0)
	{
		for (i=CurrentIndex; i>0; --i)
		{
			ServerList[i].ServerUniqueID = ServerList[i-1].ServerUniqueID;
			ServerList[i].ServerName = ServerList[i-1].ServerName;
		}

		if (IPToAdd == "")
			ServerList[0].ServerUniqueID = UniqueIDString;
		else
			ServerList[0].ServerUniqueID = UniqueIDString$"-"$IPToAdd;

		ServerList[0].ServerName = ServerNameToAdd;

		SaveConfig();
		bResult = True;

		InvalidateCurrentSearchResults();
	}

	return bResult;
}

/**
 * Removes the specified server from the server history list.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToRemove		the UniqueNetId for the server to remove
 */
function bool RemoveServer( int ControllerId, UniqueNetId IdToRemove )
{
	local int i, CurrentIndex;
	local bool bResult;

	// first, determine whether the server is already in our list
	CurrentIndex = FindServerIndexById(ControllerId, IdToRemove);
	if ( CurrentIndex != INDEX_NONE )
	{
		for ( i = CurrentIndex + 1; i < MAX_PERSONALSERVERS; i++ )
		{
			ServerList[i-1].ServerUniqueId = ServerList[i].ServerUniqueId;
			ServerList[i-1].ServerName = ServerList[i].ServerName;
		}

		// now clear the last element
		ServerList[MAX_PERSONALSERVERS-1].ServerUniqueId = "";
		ServerList[MAX_PERSONALSERVERS-1].ServerName = "";

		SaveConfig();
		bResult = true;

		InvalidateCurrentSearchResults();
	}

	return bResult;
}

/**
 * Retrieve the list of most recently visited servers.
 *
 * @param	out_ServerList	receives the list of UniqueNetIds for the most recently visited servers.
 */
function GetServerIdList( out array<UniqueNetId> out_ServerList )
{
	local int i;
	local UniqueNetId ServerNetId;

	out_ServerList.Length = MAX_PERSONALSERVERS;
	for ( i = 0; i < MAX_PERSONALSERVERS; i++ )
	{
		if ( ServerList[i].ServerUniqueId == ""
		||	!class'Engine.OnlineSubsystem'.static.StringToUniqueNetId(GetServerUID(ServerList[i].ServerUniqueId), ServerNetId) )
		{
			out_ServerList.Length = i;
			break;
		}

		out_ServerList[i] = ServerNetId;
	}
}
function GetServerStringList( out array<string> out_ServerList )
{
	local int i;

	out_ServerList.Length = MAX_PERSONALSERVERS;
	for ( i = 0; i < MAX_PERSONALSERVERS; i++ )
	{
		if ( ServerList[i].ServerUniqueId == "" )
		{
			out_ServerList.Length = i;
			break;
		}

		out_ServerList[i] = GetServerUID(ServerList[i].ServerUniqueId);
	}
}


// This data store was updated to store the IP along with the UID, so these now have to be separately parsed from the UID string

function string GetServerUID(out const string IDString)
{
	local int i;

	i = InStr(IDString, "-");

	if (i == INDEX_None)
		return IDString;


	return Left(IDString, i);
}

function string GetServerIP(out const string IDString)
{
	local int i;

	i = InStr(IDString, "-");

	if (i == INDEX_None)
		return "";


	return Mid(IDString, i+1);
}


DefaultProperties
{
	Tag=UTGameSearchPersonal

	GameSearchCfgList.Empty
}
