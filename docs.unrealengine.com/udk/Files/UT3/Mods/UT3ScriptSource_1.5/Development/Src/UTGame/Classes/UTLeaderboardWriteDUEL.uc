
/**
* Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
*/

/** The class that writes the DUEL general stats */

class UTLeaderboardWriteDUEL extends UTLeaderboardWriteTDM;

`include(UTStats.uci)

//Copies all relevant PRI game stats into the Properties struct of the OnlineStatsWrite
//There can be many more stats in the PRI than what is in the Properties table (on Xbox for example)
//If the Properties table does not contain the entry, the data is not written
function CopyAllStats(UTPlayerReplicationInfo PRI)
{
	//Write out the stat signifying that this is a DUEL game
	SetIntStat(`PROPERTY_GAMETYPE_DUEL, 1);

	Super.CopyAllStats(PRI);
}

defaultproperties
{
	// Views being written to depending on type of match (ranked or player)
	//ViewIds=(STATS_VIEW_DUEL_PLAYER_ALLTIME)
	//ArbitratedViewIds=(STATS_VIEW_DUEL_RANKED_ALLTIME)

	Properties.Add((PropertyId=`PROPERTY_GAMETYPE_DUEL,Data=(Type=SDT_Int32,Value1=0)))
}
