
/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/** The class that writes the Greed general stats */

class UTLeaderboardWriteGreed extends UTLeaderboardWriteTDM;

`include(UTStats.uci)

//Copies all relevant PRI game stats into the Properties struct of the OnlineStatsWrite
//There can be many more stats in the PRI than what is in the Properties table (on Xbox for example)
//If the Properties table does not contain the entry, the data is not written
function CopyAllStats(UTPlayerReplicationInfo PRI)
{
	Super.CopyAllStats(PRI);
}

defaultproperties
{

	WeaponsStatsClass=class'UTLeaderboardWriteWeaponsDM'
	VehicleStatsClass=class'UTLeaderboardWriteVehiclesDM'
	VehicleWeaponsStatsClass=class'UTLeaderboardWriteVehicleWeaponsDM'

	// Sort the leaderboard by this property
RatingId=PROPERTY_LEADERBOARDRATING

	// Views being written to depending on type of match (ranked or player)
//ViewIds=(STATS_VIEW_WAR_PLAYER_ALLTIME)
//ArbitratedViewIds=(STATS_VIEW_WAR_RANKED_ALLTIME)

/*   never implemented
Properties.Add((PropertyId=`PROPERTY_EVENT_SKULLSTOTAL,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_EVENT_SKULLSSCORED,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_EVENT_SKULLSMAX,Data=(Type=SDT_Int32,Value1=0)))
StatNameToStatIdMapping.Add((StatName=EVENT_SKULLSTOTAL,Id=`PROPERTY_EVENT_SKULLSTOTAL))
StatNameToStatIdMapping.Add((StatName=EVENT_SKULLSSCORED,Id=`PROPERTY_EVENT_SKULLSSCORED))
StatNameToStatIdMapping.Add((StatName=EVENT_SKULLSMAX,Id=`PROPERTY_EVENT_SKULLSMAX))
*/

}
