/**
* Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
*/

/** Stat read setup to retrieve just the player's current ELO rating in Pure */
class UTStatReadPlayerRatingPure extends UTLeaderboardReadBase;

`include(UTStats.uci)

defaultproperties
{
	ViewId=STATS_VIEW_DM_RANKED_ALLTIME
	// UI meta data
	ViewName="Pure_PlayerDM"
	SortColumnId=`STATS_COLUMN_DM_RANKED_ALLTIME_PLACE

	//Column names for this leaderboard table view
	ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PLACE)

	// The metadata for the columns
	//The order here is important because it must match the localization .int file
	ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PLACE,Name="ELO"))
}
