
/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/** The class that writes the WAR general stats */

class UTLeaderboardWriteWAR extends UTLeaderboardWriteTDM;

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

Properties.Add((PropertyId=`PROPERTY_EVENT_RETURNEDORB,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_NODE_DAMAGEDCORE,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_NODE_DESTROYEDCORE,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_NODE_DESTROYEDNODE,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_NODE_HEALEDNODE,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_NODE_NODEBUILT,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_NODE_NODEBUSTER,Data=(Type=SDT_Int32,Value1=0)))
StatNameToStatIdMapping.Add((StatName=EVENT_RETURNEDORB,Id=`PROPERTY_EVENT_RETURNEDORB))
StatNameToStatIdMapping.Add((StatName=NODE_DAMAGEDCORE,Id=`PROPERTY_NODE_DAMAGEDCORE))
StatNameToStatIdMapping.Add((StatName=NODE_DESTROYEDCORE,Id=`PROPERTY_NODE_DESTROYEDCORE))
StatNameToStatIdMapping.Add((StatName=NODE_DESTROYEDNODE,Id=`PROPERTY_NODE_DESTROYEDNODE))
StatNameToStatIdMapping.Add((StatName=NODE_HEALEDNODE,Id=`PROPERTY_NODE_HEALEDNODE))
StatNameToStatIdMapping.Add((StatName=NODE_NODEBUILT,Id=`PROPERTY_NODE_NODEBUILT))
StatNameToStatIdMapping.Add((StatName=NODE_NODEBUSTER,Id=`PROPERTY_NODE_NODEBUSTER))
}
