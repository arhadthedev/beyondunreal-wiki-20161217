/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for finding a quick match.
 */

class UTUITabPage_FindQuickMatch extends UTUITabPage_ServerBrowser
	placeable;

`include(Core/Globals.uci)

const QUICKMATCH_MAX_RESULTS = 30;

/** Delegate for when a search has completed. */
delegate OnSearchComplete(bool bWasSuccessful);

/** PostInitialize event - Sets delegates for the page. */
event PostInitialize( )
{
	Super.PostInitialize();

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.JoinGame.Servers>");
}

/** Sets buttons for the scene. */
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	ButtonBar.Clear();
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.CancelSearch>", OnButtonBar_Back);
}

/** Refreshes the server list. */
function RefreshServerList(int InPlayerIndex, optional int MaxResults=1000)
{
	local OnlineGameSearch GameSearch;
	GameSearch = SearchDataStore.GetCurrentGameSearch();
	
	// Force no full, empty, or locked servers to be returned.
	GameSearch.SetStringSettingValue(CONTEXT_EMPTYSERVER, CONTEXT_EMPTYSERVER_NO, false);
	GameSearch.SetStringSettingValue(CONTEXT_FULLSERVER, CONTEXT_FULLSERVER_NO, false);
	GameSearch.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_NO, false);

	Super.RefreshServerList(InPlayerIndex, QUICKMATCH_MAX_RESULTS);
}

/**
 *  Find the best available server for this player given their rating
 *  Prefers a server with the smallest delta between ratings and then the server with the best ping
 *  If no suitable server is found by rating, the best ping server is found
 *  Failing that the first server in the list is returned as a fail safe
 */
function int FindBestServerIndexByRanking(int PlayerRanking)
{
	local int SearchIdx;
	local int BestPing, BestPingIndex;
	local int DeltaToPlayerRanking, BestDeltaIndex;
	local int MaxPing;
	local float CurrentScore, BestScore;
	local OnlineGameSearchResult GameToJoin;

	`log(`location@"Rating:"@PlayerRanking@ServerList.Items.length@"Servers available",,'DevOnline');
`if(`notdefined(FINAL_RELEASE))
	for(SearchIdx=0; SearchIdx<ServerList.Items.length; SearchIdx++)
	{
		if(SearchDataStore.GetSearchResultFromIndex(ServerList.Items[SearchIdx], GameToJoin))
		{
			`Log(GameToJoin.GameSettings.OwningPlayerName@"Ping ("$"LI:"$SearchIdx@"DSI:"$ServerList.Items[SearchIdx]$"): "$GameToJoin.GameSettings.PingInMs@"Skill"@GameToJoin.GameSettings.AverageSkillRating,,'DevOnline');
		}
	}
`endif

	//Find the best server by ping
	BestPingIndex = 0;
	BestPing = 2500;
	for(SearchIdx=0; SearchIdx<ServerList.Items.length; SearchIdx++)
	{
		if(SearchDataStore.GetSearchResultFromIndex(ServerList.Items[SearchIdx], GameToJoin))
		{
			if (GameToJoin.GameSettings.PingInMs < BestPing)
			{
				BestPing = GameToJoin.GameSettings.PingInMs;
				BestPingIndex = SearchIdx;
			}
		}
	}

	//Create a max ping not to exceed looking for best ranking
	MaxPing = Max(100, BestPing + (Min(80, 1.2f * BestPing)));
	//`log("MaxPing allowed is"@MaxPing,,'DevOnline');

	//Search for the best server under max ping that is closest to the rating
	BestDeltaIndex = -1;
	BestScore = 9999;
	for(SearchIdx=0; SearchIdx<ServerList.Items.length; SearchIdx++)
	{
		if(SearchDataStore.GetSearchResultFromIndex(ServerList.Items[SearchIdx], GameToJoin))
		{
			if (GameToJoin.GameSettings.PingInMs <= MaxPing && GameToJoin.GameSettings.AverageSkillRating > 0.0f)
			{
				//Any server closest to the player's rating and has a better ping
				DeltaToPlayerRanking = Abs(GameToJoin.GameSettings.AverageSkillRating - PlayerRanking);
				CurrentScore = float(DeltaToPlayerRanking) + 0.5f * float(GameToJoin.GameSettings.PingInMs - BestPing);
				//`log(CurrentScore@DeltaToPlayerRanking@"BP:"@BestPing@"P:"@GameToJoin.GameSettings.PingInMs);
				if (CurrentScore < BestScore)
				{
					BestScore = CurrentScore;
					BestDeltaIndex = SearchIdx;
				}
			}
		}
	}

	//Chose the best delta rating over the best ping
	if (BestDeltaIndex >= 0)
	{
		`log("Found server"@BestDeltaIndex@"with best score"@BestScore,,'DevOnline');
		return BestDeltaIndex;
	}
	else if (BestPingIndex >=0)
	{
		`log("Found server"@BestPingIndex@"with best ping"@BestPing,,'DevOnline');
		return BestPingIndex;
	}

	//Fail safe just pick first one
	`log("Failed to find an appropriate server, returning 0",,'DevOnline');
	return 0;
}

/**
 * Delegate fired when the search for an online game has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnFindOnlineGamesComplete(bool bWasSuccessful)
{
	local int SearchIdx;
	local OnlineGameSearchResult GameToJoin;
	local Player APlayer;
	local PlayerController PC;

	// Join the game if we found one, otherwise pop up a error message.
	if(bWasSuccessful && SearchDataStore.GetSearchResultFromIndex(0,GameToJoin)==true && ServerList.Items.length>0)
	{
		// Only finish the search when we do not have any outstanding queries.
		if(SearchDataStore.HasOutstandingQueries()==false)
		{
/*
			`Log("Quick Match Available Servers Query Count:"@ServerList.Items.length);
			for(SearchIdx=0; SearchIdx<ServerList.Items.length; SearchIdx++)
			{
				if(SearchDataStore.GetSearchResultFromIndex(ServerList.Items[SearchIdx], GameToJoin))
				{
					`Log(GameToJoin.GameSettings.OwningPlayerName$"Ping ("$"LI:"$SearchIdx@"DSI:"$ServerList.Items[SearchIdx]$"): "$GameToJoin.GameSettings.PingInMs@"Skill"@GameToJoin.GameSettings.AverageSkillRating);
				}
			}
*/

			//Try to find the best server by rating then ping
			APlayer = GetPlayerOwner();
			if (APlayer != None)
			{
				PC = APlayer.Actor;
				if (PC != None && PC.OnlinePlayerData != None && PC.OnlinePlayerData.PlayerRanking > 0)
				{
					SearchIdx = FindBestServerIndexByRanking(PC.OnlinePlayerData.PlayerRanking);
					ServerList.SetIndex(SearchIdx, true, true);
				}
			}

			OnSearchComplete(true);
		}
	}
	else
	{
		OnSearchComplete(false);
	}
}

/** Callback for when the server list value changed. */
function OnServerList_ValueChanged(UIObject Sender, int PlayerIndex)
{
	local int CurrentIndex;
//	local int SearchIdx;
	local OnlineGameSearchResult GameToJoin;

	CurrentIndex=ServerList.GetCurrentItem();

	if(CurrentIndex != INDEX_NONE && SearchDataStore.GetSearchResultFromIndex(0,GameToJoin)==true && ServerList.Items.length>0)
	{
		// Only finish the search when we do not have any outstanding queries.
		if(SearchDataStore.HasOutstandingQueries()==false)
		{
/*
			`Log("Query Count:"@ServerList.Items.length);
			for(SearchIdx=0; SearchIdx<ServerList.Items.length; SearchIdx++)
			{
				if(SearchDataStore.GetSearchResultFromIndex(SearchIdx,GameToJoin))
				{
					`Log("Ping ("$SearchIdx$"): "$GameToJoin.GameSettings.PingInMs);
				}
			}
*/
			OnSearchComplete(true);
		}
	}
}

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;

	bResult=false;

	if(IsVisible() && EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
		{
			OnBack();
			bResult=true;
		}
	}

	return bResult;
}

