﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/** Common columns to be read from the DM tables */
class UTLeaderboardReadWeaponsDM extends UTLeaderboardReadBase;

`include(UTStats.uci)

defaultproperties
{
	ViewId=STATS_VIEW_DM_WEAPONS_ALLTIME
	// UI meta data
	ViewName="WeaponsDM"
	SortColumnId=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_AVRIL

ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_AVRIL)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_BIORIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_ENFORCER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_ENVIRONMENT)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_FLAKCANNON)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_HEADSHOT)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_IMPACTHAMMER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_INSTAGIB)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_LINKGUN)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_REDEEMER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_ROCKETLAUNCHER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SHAPEDCHARGE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SHOCKCOMBO)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SHOCKRIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SNIPERRIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SPIDERMINE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_STINGER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_TRANSLOCATOR)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_AVRIL)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_BIORIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_ENFORCER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_ENVIRONMENT)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_FLAKCANNON)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_HEADSHOT)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_IMPACTHAMMER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_INSTAGIB)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_LINKGUN)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_REDEEMER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_ROCKETLAUNCHER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SHAPEDCHARGE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SHOCKCOMBO)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SHOCKRIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SNIPERRIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SPIDERMINE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_STINGER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_TRANSLOCATOR)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_AVRIL)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_BIORIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_ENFORCER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_ENVIRONMENT)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_FLAKCANNON)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_IMPACTHAMMER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_INSTAGIB)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_LINKGUN)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_REDEEMER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_ROCKETLAUNCHER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SHAPEDCHARGE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SHOCKCOMBO)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SHOCKRIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SNIPERRIFLE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SPIDERMINE)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_STINGER)
ColumnIds.Add(`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_TRANSLOCATOR)
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_AVRIL,Name="DEATHS_AVRIL"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_BIORIFLE,Name="DEATHS_BIORIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_ENFORCER,Name="DEATHS_ENFORCER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_ENVIRONMENT,Name="DEATHS_ENVIRONMENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_FLAKCANNON,Name="DEATHS_FLAKCANNON"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_HEADSHOT,Name="DEATHS_HEADSHOT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_IMPACTHAMMER,Name="DEATHS_IMPACTHAMMER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_INSTAGIB,Name="DEATHS_INSTAGIB"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_LINKGUN,Name="DEATHS_LINKGUN"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_REDEEMER,Name="DEATHS_REDEEMER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_ROCKETLAUNCHER,Name="DEATHS_ROCKETLAUNCHER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SHAPEDCHARGE,Name="DEATHS_SHAPEDCHARGE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SHOCKCOMBO,Name="DEATHS_SHOCKCOMBO"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SHOCKRIFLE,Name="DEATHS_SHOCKRIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SNIPERRIFLE,Name="DEATHS_SNIPERRIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_SPIDERMINE,Name="DEATHS_SPIDERMINE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_STINGER,Name="DEATHS_STINGER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_DEATHS_TRANSLOCATOR,Name="DEATHS_TRANSLOCATOR"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_AVRIL,Name="KILLS_AVRIL"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_BIORIFLE,Name="KILLS_BIORIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_ENFORCER,Name="KILLS_ENFORCER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_ENVIRONMENT,Name="KILLS_ENVIRONMENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_FLAKCANNON,Name="KILLS_FLAKCANNON"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_HEADSHOT,Name="KILLS_HEADSHOT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_IMPACTHAMMER,Name="KILLS_IMPACTHAMMER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_INSTAGIB,Name="KILLS_INSTAGIB"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_LINKGUN,Name="KILLS_LINKGUN"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_REDEEMER,Name="KILLS_REDEEMER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_ROCKETLAUNCHER,Name="KILLS_ROCKETLAUNCHER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SHAPEDCHARGE,Name="KILLS_SHAPEDCHARGE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SHOCKCOMBO,Name="KILLS_SHOCKCOMBO"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SHOCKRIFLE,Name="KILLS_SHOCKRIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SNIPERRIFLE,Name="KILLS_SNIPERRIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_SPIDERMINE,Name="KILLS_SPIDERMINE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_STINGER,Name="KILLS_STINGER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_KILLS_TRANSLOCATOR,Name="KILLS_TRANSLOCATOR"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_AVRIL,Name="SUICIDES_AVRIL"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_BIORIFLE,Name="SUICIDES_BIORIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_ENFORCER,Name="SUICIDES_ENFORCER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_ENVIRONMENT,Name="SUICIDES_ENVIRONMENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_FLAKCANNON,Name="SUICIDES_FLAKCANNON"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_IMPACTHAMMER,Name="SUICIDES_IMPACTHAMMER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_INSTAGIB,Name="SUICIDES_INSTAGIB"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_LINKGUN,Name="SUICIDES_LINKGUN"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_REDEEMER,Name="SUICIDES_REDEEMER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_ROCKETLAUNCHER,Name="SUICIDES_ROCKETLAUNCHER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SHAPEDCHARGE,Name="SUICIDES_SHAPEDCHARGE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SHOCKCOMBO,Name="SUICIDES_SHOCKCOMBO"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SHOCKRIFLE,Name="SUICIDES_SHOCKRIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SNIPERRIFLE,Name="SUICIDES_SNIPERRIFLE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_SPIDERMINE,Name="SUICIDES_SPIDERMINE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_STINGER,Name="SUICIDES_STINGER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_WEAPONS_ALLTIME_SUICIDES_TRANSLOCATOR,Name="SUICIDES_TRANSLOCATOR"))
}
