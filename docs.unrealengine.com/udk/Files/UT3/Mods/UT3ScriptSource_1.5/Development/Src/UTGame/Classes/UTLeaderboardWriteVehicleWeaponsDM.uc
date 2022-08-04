﻿
/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/** The class that writes the DM stats */

class UTLeaderboardWriteVehicleWeaponsDM extends UTLeaderboardWriteBase;

`include(UTStats.uci)

//Copies all relevant PRI game stats into the Properties struct of the OnlineStatsWrite
//There can be many more stats in the PRI than what is in the Properties table (on Xbox for example)
//If the Properties table does not contain the entry, the data is not written
function CopyAllStats(UTPlayerReplicationInfo PRI)
{
	local IntStat tempIntStat;

	//Kill stats
	foreach PRI.KillStats(tempIntStat)
	{
		SetIntStatFromMapping(tempIntStat.StatName, tempIntStat.StatValue);
	}

	//Death stats
	foreach PRI.DeathStats(tempIntStat)
	{
		SetIntStatFromMapping(tempIntStat.StatName, tempIntStat.StatValue);
	}

	//Suicide stats
	foreach PRI.SuicideStats(tempIntStat)
	{
		SetIntStatFromMapping(tempIntStat.StatName, tempIntStat.StatValue);
	}

	Super.CopyAllStats(PRI);
}

defaultproperties
{

	// Sort the leaderboard by this property
RatingId=PROPERTY_LEADERBOARDRATING

	// Views being written to depending on type of match (ranked or player)
ViewIds=(STATS_VIEW_DM_VEHICLEWEAPONS_ALLTIME)
PureViewIds=(STATS_VIEW_DM_VEHICLEWEAPONS_RANKED_ALLTIME)
ArbitratedViewIds=(STATS_VIEW_DM_VEHICLEWEAPONS_RANKED_ALLTIME)

	   //All properties for the given table and their types

Properties.Add((PropertyId=`PROPERTY_DEATHS_CICADAROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_CICADATURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_DARKWALKERPASSGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_DARKWALKERTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_FURYGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_GOLIATHMACHINEGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_GOLIATHTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_HELLBENDERPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_LEVIATHANEXPLOSION,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_LEVIATHANPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_LEVIATHANTURRETBEAM,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_LEVIATHANTURRETROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_LEVIATHANTURRETSHOCK,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_LEVIATHANTURRETSTINGER,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_MANTAGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_NEMESISTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_NIGHTSHADEGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_PALADINEXPLOSION,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_PALADINGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_RAPTORGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_RAPTORROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_SCAVENGERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_SCAVENGERSTABBED,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_SCORPIONBLADE,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_SCORPIONGLOB,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_SCORPIONSELFDESTRUCT,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_SPMACAMERACRUSH,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_SPMACANNON,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_SPMATURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_STEALTHBENDERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_TURRETPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_TURRETROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_TURRETSHOCK,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_TURRETSTINGER,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_VIPERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_DEATHS_VIPERSELFDESTRUCT,Data=(Type=SDT_Int32,Value1=0)))

Properties.Add((PropertyId=`PROPERTY_KILLS_CICADAROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_CICADATURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_DARKWALKERPASSGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_DARKWALKERTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_FURYGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_GOLIATHMACHINEGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_GOLIATHTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_HELLBENDERPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_LEVIATHANEXPLOSION,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_LEVIATHANPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_LEVIATHANTURRETBEAM,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_LEVIATHANTURRETROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_LEVIATHANTURRETSHOCK,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_LEVIATHANTURRETSTINGER,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_MANTAGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_NEMESISTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_NIGHTSHADEGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_PALADINEXPLOSION,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_PALADINGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_RAPTORGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_RAPTORROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_SCAVENGERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_SCAVENGERSTABBED,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_SCORPIONBLADE,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_SCORPIONGLOB,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_SCORPIONSELFDESTRUCT,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_SPMACAMERACRUSH,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_SPMACANNON,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_SPMATURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_STEALTHBENDERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_TURRETPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_TURRETROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_TURRETSHOCK,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_TURRETSTINGER,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_VIPERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_KILLS_VIPERSELFDESTRUCT,Data=(Type=SDT_Int32,Value1=0)))

Properties.Add((PropertyId=`PROPERTY_SUICIDES_CICADAROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_CICADATURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_DARKWALKERPASSGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_DARKWALKERTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_FURYGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_GOLIATHMACHINEGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_GOLIATHTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_HELLBENDERPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_LEVIATHANEXPLOSION,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_LEVIATHANPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_LEVIATHANTURRETBEAM,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_LEVIATHANTURRETROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_LEVIATHANTURRETSHOCK,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_LEVIATHANTURRETSTINGER,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_MANTAGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_NEMESISTURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_NIGHTSHADEGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_PALADINEXPLOSION,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_PALADINGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_RAPTORGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_RAPTORROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_SCAVENGERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_SCAVENGERSTABBED,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_SCORPIONBLADE,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_SCORPIONGLOB,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_SCORPIONSELFDESTRUCT,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_SPMACAMERACRUSH,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_SPMACANNON,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_SPMATURRET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_STEALTHBENDERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_TURRETPRIMARY,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_TURRETROCKET,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_TURRETSHOCK,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_TURRETSTINGER,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_VIPERGUN,Data=(Type=SDT_Int32,Value1=0)))
Properties.Add((PropertyId=`PROPERTY_SUICIDES_VIPERSELFDESTRUCT,Data=(Type=SDT_Int32,Value1=0)))

	//The mappings for every PRI in game stat to every Online stat regardless 
	//of whether or not we're writing it out this session

StatNameToStatIdMapping.Add((StatName=DEATHS_CICADAROCKET,Id=`PROPERTY_DEATHS_CICADAROCKET))
StatNameToStatIdMapping.Add((StatName=DEATHS_CICADATURRET,Id=`PROPERTY_DEATHS_CICADATURRET))
StatNameToStatIdMapping.Add((StatName=DEATHS_DARKWALKERPASSGUN,Id=`PROPERTY_DEATHS_DARKWALKERPASSGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_DARKWALKERTURRET,Id=`PROPERTY_DEATHS_DARKWALKERTURRET))
StatNameToStatIdMapping.Add((StatName=DEATHS_FURYGUN,Id=`PROPERTY_DEATHS_FURYGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_GOLIATHMACHINEGUN,Id=`PROPERTY_DEATHS_GOLIATHMACHINEGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_GOLIATHTURRET,Id=`PROPERTY_DEATHS_GOLIATHTURRET))
StatNameToStatIdMapping.Add((StatName=DEATHS_HELLBENDERPRIMARY,Id=`PROPERTY_DEATHS_HELLBENDERPRIMARY))
StatNameToStatIdMapping.Add((StatName=DEATHS_LEVIATHANEXPLOSION,Id=`PROPERTY_DEATHS_LEVIATHANEXPLOSION))
StatNameToStatIdMapping.Add((StatName=DEATHS_LEVIATHANPRIMARY,Id=`PROPERTY_DEATHS_LEVIATHANPRIMARY))
StatNameToStatIdMapping.Add((StatName=DEATHS_LEVIATHANTURRETBEAM,Id=`PROPERTY_DEATHS_LEVIATHANTURRETBEAM))
StatNameToStatIdMapping.Add((StatName=DEATHS_LEVIATHANTURRETROCKET,Id=`PROPERTY_DEATHS_LEVIATHANTURRETROCKET))
StatNameToStatIdMapping.Add((StatName=DEATHS_LEVIATHANTURRETSHOCK,Id=`PROPERTY_DEATHS_LEVIATHANTURRETSHOCK))
StatNameToStatIdMapping.Add((StatName=DEATHS_LEVIATHANTURRETSTINGER,Id=`PROPERTY_DEATHS_LEVIATHANTURRETSTINGER))
StatNameToStatIdMapping.Add((StatName=DEATHS_MANTAGUN,Id=`PROPERTY_DEATHS_MANTAGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_NEMESISTURRET,Id=`PROPERTY_DEATHS_NEMESISTURRET))
StatNameToStatIdMapping.Add((StatName=DEATHS_NIGHTSHADEGUN,Id=`PROPERTY_DEATHS_NIGHTSHADEGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_PALADINEXPLOSION,Id=`PROPERTY_DEATHS_PALADINEXPLOSION))
StatNameToStatIdMapping.Add((StatName=DEATHS_PALADINGUN,Id=`PROPERTY_DEATHS_PALADINGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_RAPTORGUN,Id=`PROPERTY_DEATHS_RAPTORGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_RAPTORROCKET,Id=`PROPERTY_DEATHS_RAPTORROCKET))
StatNameToStatIdMapping.Add((StatName=DEATHS_SCAVENGERGUN,Id=`PROPERTY_DEATHS_SCAVENGERGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_SCAVENGERSTABBED,Id=`PROPERTY_DEATHS_SCAVENGERSTABBED))
StatNameToStatIdMapping.Add((StatName=DEATHS_SCORPIONBLADE,Id=`PROPERTY_DEATHS_SCORPIONBLADE))
StatNameToStatIdMapping.Add((StatName=DEATHS_SCORPIONGLOB,Id=`PROPERTY_DEATHS_SCORPIONGLOB))
StatNameToStatIdMapping.Add((StatName=DEATHS_SCORPIONSELFDESTRUCT,Id=`PROPERTY_DEATHS_SCORPIONSELFDESTRUCT))
StatNameToStatIdMapping.Add((StatName=DEATHS_SPMACAMERACRUSH,Id=`PROPERTY_DEATHS_SPMACAMERACRUSH))
StatNameToStatIdMapping.Add((StatName=DEATHS_SPMACANNON,Id=`PROPERTY_DEATHS_SPMACANNON))
StatNameToStatIdMapping.Add((StatName=DEATHS_SPMATURRET,Id=`PROPERTY_DEATHS_SPMATURRET))
StatNameToStatIdMapping.Add((StatName=DEATHS_STEALTHBENDERGUN,Id=`PROPERTY_DEATHS_STEALTHBENDERGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_TURRETPRIMARY,Id=`PROPERTY_DEATHS_TURRETPRIMARY))
StatNameToStatIdMapping.Add((StatName=DEATHS_TURRETROCKET,Id=`PROPERTY_DEATHS_TURRETROCKET))
StatNameToStatIdMapping.Add((StatName=DEATHS_TURRETSHOCK,Id=`PROPERTY_DEATHS_TURRETSHOCK))
StatNameToStatIdMapping.Add((StatName=DEATHS_TURRETSTINGER,Id=`PROPERTY_DEATHS_TURRETSTINGER))
StatNameToStatIdMapping.Add((StatName=DEATHS_VIPERGUN,Id=`PROPERTY_DEATHS_VIPERGUN))
StatNameToStatIdMapping.Add((StatName=DEATHS_VIPERSELFDESTRUCT,Id=`PROPERTY_DEATHS_VIPERSELFDESTRUCT))

StatNameToStatIdMapping.Add((StatName=KILLS_CICADAROCKET,Id=`PROPERTY_KILLS_CICADAROCKET))
StatNameToStatIdMapping.Add((StatName=KILLS_CICADATURRET,Id=`PROPERTY_KILLS_CICADATURRET))
StatNameToStatIdMapping.Add((StatName=KILLS_DARKWALKERPASSGUN,Id=`PROPERTY_KILLS_DARKWALKERPASSGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_DARKWALKERTURRET,Id=`PROPERTY_KILLS_DARKWALKERTURRET))
StatNameToStatIdMapping.Add((StatName=KILLS_FURYGUN,Id=`PROPERTY_KILLS_FURYGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_GOLIATHMACHINEGUN,Id=`PROPERTY_KILLS_GOLIATHMACHINEGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_GOLIATHTURRET,Id=`PROPERTY_KILLS_GOLIATHTURRET))
StatNameToStatIdMapping.Add((StatName=KILLS_HELLBENDERPRIMARY,Id=`PROPERTY_KILLS_HELLBENDERPRIMARY))
StatNameToStatIdMapping.Add((StatName=KILLS_LEVIATHANEXPLOSION,Id=`PROPERTY_KILLS_LEVIATHANEXPLOSION))
StatNameToStatIdMapping.Add((StatName=KILLS_LEVIATHANPRIMARY,Id=`PROPERTY_KILLS_LEVIATHANPRIMARY))
StatNameToStatIdMapping.Add((StatName=KILLS_LEVIATHANTURRETBEAM,Id=`PROPERTY_KILLS_LEVIATHANTURRETBEAM))
StatNameToStatIdMapping.Add((StatName=KILLS_LEVIATHANTURRETROCKET,Id=`PROPERTY_KILLS_LEVIATHANTURRETROCKET))
StatNameToStatIdMapping.Add((StatName=KILLS_LEVIATHANTURRETSHOCK,Id=`PROPERTY_KILLS_LEVIATHANTURRETSHOCK))
StatNameToStatIdMapping.Add((StatName=KILLS_LEVIATHANTURRETSTINGER,Id=`PROPERTY_KILLS_LEVIATHANTURRETSTINGER))
StatNameToStatIdMapping.Add((StatName=KILLS_MANTAGUN,Id=`PROPERTY_KILLS_MANTAGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_NEMESISTURRET,Id=`PROPERTY_KILLS_NEMESISTURRET))
StatNameToStatIdMapping.Add((StatName=KILLS_NIGHTSHADEGUN,Id=`PROPERTY_KILLS_NIGHTSHADEGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_PALADINEXPLOSION,Id=`PROPERTY_KILLS_PALADINEXPLOSION))
StatNameToStatIdMapping.Add((StatName=KILLS_PALADINGUN,Id=`PROPERTY_KILLS_PALADINGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_RAPTORGUN,Id=`PROPERTY_KILLS_RAPTORGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_RAPTORROCKET,Id=`PROPERTY_KILLS_RAPTORROCKET))
StatNameToStatIdMapping.Add((StatName=KILLS_SCAVENGERGUN,Id=`PROPERTY_KILLS_SCAVENGERGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_SCAVENGERSTABBED,Id=`PROPERTY_KILLS_SCAVENGERSTABBED))
StatNameToStatIdMapping.Add((StatName=KILLS_SCORPIONBLADE,Id=`PROPERTY_KILLS_SCORPIONBLADE))
StatNameToStatIdMapping.Add((StatName=KILLS_SCORPIONGLOB,Id=`PROPERTY_KILLS_SCORPIONGLOB))
StatNameToStatIdMapping.Add((StatName=KILLS_SCORPIONSELFDESTRUCT,Id=`PROPERTY_KILLS_SCORPIONSELFDESTRUCT))
StatNameToStatIdMapping.Add((StatName=KILLS_SPMACAMERACRUSH,Id=`PROPERTY_KILLS_SPMACAMERACRUSH))
StatNameToStatIdMapping.Add((StatName=KILLS_SPMACANNON,Id=`PROPERTY_KILLS_SPMACANNON))
StatNameToStatIdMapping.Add((StatName=KILLS_SPMATURRET,Id=`PROPERTY_KILLS_SPMATURRET))
StatNameToStatIdMapping.Add((StatName=KILLS_STEALTHBENDERGUN,Id=`PROPERTY_KILLS_STEALTHBENDERGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_TURRETPRIMARY,Id=`PROPERTY_KILLS_TURRETPRIMARY))
StatNameToStatIdMapping.Add((StatName=KILLS_TURRETROCKET,Id=`PROPERTY_KILLS_TURRETROCKET))
StatNameToStatIdMapping.Add((StatName=KILLS_TURRETSHOCK,Id=`PROPERTY_KILLS_TURRETSHOCK))
StatNameToStatIdMapping.Add((StatName=KILLS_TURRETSTINGER,Id=`PROPERTY_KILLS_TURRETSTINGER))
StatNameToStatIdMapping.Add((StatName=KILLS_VIPERGUN,Id=`PROPERTY_KILLS_VIPERGUN))
StatNameToStatIdMapping.Add((StatName=KILLS_VIPERSELFDESTRUCT,Id=`PROPERTY_KILLS_VIPERSELFDESTRUCT))

StatNameToStatIdMapping.Add((StatName=SUICIDES_CICADAROCKET,Id=`PROPERTY_SUICIDES_CICADAROCKET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_CICADATURRET,Id=`PROPERTY_SUICIDES_CICADATURRET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_DARKWALKERPASSGUN,Id=`PROPERTY_SUICIDES_DARKWALKERPASSGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_DARKWALKERTURRET,Id=`PROPERTY_SUICIDES_DARKWALKERTURRET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_FURYGUN,Id=`PROPERTY_SUICIDES_FURYGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_GOLIATHMACHINEGUN,Id=`PROPERTY_SUICIDES_GOLIATHMACHINEGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_GOLIATHTURRET,Id=`PROPERTY_SUICIDES_GOLIATHTURRET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_HELLBENDERPRIMARY,Id=`PROPERTY_SUICIDES_HELLBENDERPRIMARY))
StatNameToStatIdMapping.Add((StatName=SUICIDES_LEVIATHANEXPLOSION,Id=`PROPERTY_SUICIDES_LEVIATHANEXPLOSION))
StatNameToStatIdMapping.Add((StatName=SUICIDES_LEVIATHANPRIMARY,Id=`PROPERTY_SUICIDES_LEVIATHANPRIMARY))
StatNameToStatIdMapping.Add((StatName=SUICIDES_LEVIATHANTURRETBEAM,Id=`PROPERTY_SUICIDES_LEVIATHANTURRETBEAM))
StatNameToStatIdMapping.Add((StatName=SUICIDES_LEVIATHANTURRETROCKET,Id=`PROPERTY_SUICIDES_LEVIATHANTURRETROCKET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_LEVIATHANTURRETSHOCK,Id=`PROPERTY_SUICIDES_LEVIATHANTURRETSHOCK))
StatNameToStatIdMapping.Add((StatName=SUICIDES_LEVIATHANTURRETSTINGER,Id=`PROPERTY_SUICIDES_LEVIATHANTURRETSTINGER))
StatNameToStatIdMapping.Add((StatName=SUICIDES_MANTAGUN,Id=`PROPERTY_SUICIDES_MANTAGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_NEMESISTURRET,Id=`PROPERTY_SUICIDES_NEMESISTURRET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_NIGHTSHADEGUN,Id=`PROPERTY_SUICIDES_NIGHTSHADEGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_PALADINEXPLOSION,Id=`PROPERTY_SUICIDES_PALADINEXPLOSION))
StatNameToStatIdMapping.Add((StatName=SUICIDES_PALADINGUN,Id=`PROPERTY_SUICIDES_PALADINGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_RAPTORGUN,Id=`PROPERTY_SUICIDES_RAPTORGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_RAPTORROCKET,Id=`PROPERTY_SUICIDES_RAPTORROCKET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_SCAVENGERGUN,Id=`PROPERTY_SUICIDES_SCAVENGERGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_SCAVENGERSTABBED,Id=`PROPERTY_SUICIDES_SCAVENGERSTABBED))
StatNameToStatIdMapping.Add((StatName=SUICIDES_SCORPIONBLADE,Id=`PROPERTY_SUICIDES_SCORPIONBLADE))
StatNameToStatIdMapping.Add((StatName=SUICIDES_SCORPIONGLOB,Id=`PROPERTY_SUICIDES_SCORPIONGLOB))
StatNameToStatIdMapping.Add((StatName=SUICIDES_SCORPIONSELFDESTRUCT,Id=`PROPERTY_SUICIDES_SCORPIONSELFDESTRUCT))
StatNameToStatIdMapping.Add((StatName=SUICIDES_SPMACAMERACRUSH,Id=`PROPERTY_SUICIDES_SPMACAMERACRUSH))
StatNameToStatIdMapping.Add((StatName=SUICIDES_SPMACANNON,Id=`PROPERTY_SUICIDES_SPMACANNON))
StatNameToStatIdMapping.Add((StatName=SUICIDES_SPMATURRET,Id=`PROPERTY_SUICIDES_SPMATURRET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_STEALTHBENDERGUN,Id=`PROPERTY_SUICIDES_STEALTHBENDERGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_TURRETPRIMARY,Id=`PROPERTY_SUICIDES_TURRETPRIMARY))
StatNameToStatIdMapping.Add((StatName=SUICIDES_TURRETROCKET,Id=`PROPERTY_SUICIDES_TURRETROCKET))
StatNameToStatIdMapping.Add((StatName=SUICIDES_TURRETSHOCK,Id=`PROPERTY_SUICIDES_TURRETSHOCK))
StatNameToStatIdMapping.Add((StatName=SUICIDES_TURRETSTINGER,Id=`PROPERTY_SUICIDES_TURRETSTINGER))
StatNameToStatIdMapping.Add((StatName=SUICIDES_VIPERGUN,Id=`PROPERTY_SUICIDES_VIPERGUN))
StatNameToStatIdMapping.Add((StatName=SUICIDES_VIPERSELFDESTRUCT,Id=`PROPERTY_SUICIDES_VIPERSELFDESTRUCT))

}