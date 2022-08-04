/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for a user's stats.
 */
class UTUITabPage_StatsPage extends UTTabPage
	placeable;

/** Reference to the stats datastore. */
var transient UTDataStore_OnlineStats StatsDataStore;

/** Refreshing label. */
var transient UILabel RefreshingLabel;

/** Reference to the stats interface. */
var transient OnlineStatsInterface StatsInterface;

/** Reference to the stats list */
var transient UIList StatsList;

/** Callback for when the widget has finished initialized. */
event PostInitialize()
{
	local OnlineSubsystem OnlineSub;

	Super.PostInitialize();

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the game interface to verify the subsystem supports it
		StatsInterface = OnlineSub.StatsInterface;

		if(StatsInterface==None)
		{
			`Log("UTUITabPage_StatsPage::PostInitialize() - Stats Interface is None!");
		}
	}
	else
	{
		`Log("UTUITabPage_StatsPage::PostInitialize() - OnlineSub is None!");
	}

	StatsDataStore = UTDataStore_OnlineStats(UTUIScene(GetScene()).FindDataStore('UTLeaderboards'));

	RefreshingLabel = UILabel(FindChild('lblRefreshing',true));

	StatsList = UIList(FindChild('lstStats', true));
}

/**
* Causes this page to become (or no longer be) the tab control's currently active page.
*
* @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player that wishes to activate this page.
* @param	bActivate	TRUE if this page should become the tab control's active page; FALSE if it is losing the active status.
* @param	bTakeFocus	specify TRUE to give this panel focus once it's active (only relevant if bActivate = true)
*
* @return	TRUE if this page successfully changed its active state; FALSE otherwise.
*/
event bool ActivatePage( int PlayerIndex, bool bActivate, optional bool bTakeFocus=true )
{
	local bool bSuccess;
	
	bSuccess = Super.ActivatePage(PlayerIndex, bActivate, bTakeFocus);

	if (bSuccess && bActivate && bTakeFocus)
	{
		StatsList.SetFocus(none);
	}

	return bSuccess;
}

/**
* Called by the data store when the stats read has completed
*
* @param bWasSuccessful whether the stats read was successful or not
*/
function OnStatsReadComplete(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;

    //We can now remove the "Refreshing" label
	RefreshingLabel.SetVisibility(false);
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if ( OnlineSub != None )
	{
		// Clear the read complete delegate
		OnlineSub.StatsInterface.ClearReadOnlineStatsCompleteDelegate(OnStatsReadComplete);
	}
}

/** Starts the stats read for this page. */
function ReadStats();
