﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/** Common columns to be read from the DM tables */
class UTLeaderboardReadPureDM extends UTLeaderboardReadBase;

`include(UTStats.uci)

defaultproperties
{
	ViewId=STATS_VIEW_DM_RANKED_ALLTIME
	// UI meta data
	ViewName="Pure_PlayerDM"
	SortColumnId=`STATS_COLUMN_DM_RANKED_ALLTIME_PLACE

	//Column names for this leaderboard table view

ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PLACE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_KILLS)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_DEATHS)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_BULLSEYE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_DENIEDREDEEMER)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_EAGLEEYE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_ENDSPREE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_FIRSTBLOOD)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_HIJACKED)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_RANOVERKILLS)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_RANOVERDEATHS)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_TOPGUN)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_DOUBLEKILL)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_MEGAKILL)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_MONSTERKILL)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_MULTIKILL)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_ULTRAKILL)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_BERSERK)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_INVISIBILITY)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_INVULNERABILITY)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_JUMPBOOTS)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_SHIELDBELT)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_UDAMAGE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_ARMOR)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_HEALTH)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_POWERUPTIME_BERSERK)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_POWERUPTIME_INVISIBILITY)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_POWERUPTIME_INVULNERABILITY)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_POWERUPTIME_UDAMAGE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_BIGGAMEHUNTER)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_BIOHAZARD)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_BLUESTREAK)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_COMBOKING)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_FLAKMASTER)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_GUNSLINGER)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_HEADHUNTER)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_JACKHAMMER)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_ROADRAMPAGE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_ROCKETSCIENTIST)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_SHAFTMASTER)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_DOMINATING)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_GODLIKE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_KILLINGSPREE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_RAMPAGE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_MASSACRE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_UNSTOPPABLE)

ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_HATTRICK)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_LASTSECONDSAVE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_KILLEDFLAGCARRIER)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_RETURNEDFLAG)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_SCOREDFLAG)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_SCOREDORB)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_RETURNEDORB)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_DAMAGEDCORE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_DESTROYEDCORE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_DESTROYEDNODE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_HEALEDNODE)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_NODEBUILT)
ColumnIds.Add(`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_NODEBUSTER)


// The metadata for the columns
//The order here is important because it must match the localization .int file
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_KILLS,Name="EVENT_KILLS"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_DEATHS,Name="EVENT_DEATHS"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_BULLSEYE,Name="EVENT_BULLSEYE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_DENIEDREDEEMER,Name="EVENT_DENIEDREDEEMER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_EAGLEEYE,Name="EVENT_EAGLEEYE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_ENDSPREE,Name="EVENT_ENDSPREE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_FIRSTBLOOD,Name="EVENT_FIRSTBLOOD"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_HIJACKED,Name="EVENT_HIJACKED"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_RANOVERKILLS,Name="EVENT_RANOVERKILLS"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_RANOVERDEATHS,Name="EVENT_RANOVERDEATHS"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_TOPGUN,Name="EVENT_TOPGUN"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_DOUBLEKILL,Name="MULTIKILL_DOUBLEKILL"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_MEGAKILL,Name="MULTIKILL_MEGAKILL"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_MONSTERKILL,Name="MULTIKILL_MONSTERKILL"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_MULTIKILL,Name="MULTIKILL_MULTIKILL"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_MULTIKILL_ULTRAKILL,Name="MULTIKILL_ULTRAKILL"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_BERSERK,Name="PICKUPS_BERSERK"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_INVISIBILITY,Name="PICKUPS_INVISIBILITY"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_INVULNERABILITY,Name="PICKUPS_INVULNERABILITY"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_JUMPBOOTS,Name="PICKUPS_JUMPBOOTS"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_SHIELDBELT,Name="PICKUPS_SHIELDBELT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_UDAMAGE,Name="PICKUPS_UDAMAGE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_ARMOR,Name="PICKUPS_ARMOR"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PICKUPS_HEALTH,Name="PICKUPS_HEALTH"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_POWERUPTIME_BERSERK,Name="POWERUPTIME_BERSERK"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_POWERUPTIME_INVISIBILITY,Name="POWERUPTIME_INVISIBILITY"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_POWERUPTIME_INVULNERABILITY,Name="POWERUPTIME_INVULNERABILITY"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_POWERUPTIME_UDAMAGE,Name="POWERUPTIME_UDAMAGE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_BIGGAMEHUNTER,Name="REWARD_BIGGAMEHUNTER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_BIOHAZARD,Name="REWARD_BIOHAZARD"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_BLUESTREAK,Name="REWARD_BLUESTREAK"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_COMBOKING,Name="REWARD_COMBOKING"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_FLAKMASTER,Name="REWARD_FLAKMASTER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_GUNSLINGER,Name="REWARD_GUNSLINGER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_HEADHUNTER,Name="REWARD_HEADHUNTER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_JACKHAMMER,Name="REWARD_JACKHAMMER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_ROADRAMPAGE,Name="REWARD_ROADRAMPAGE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_ROCKETSCIENTIST,Name="REWARD_ROCKETSCIENTIST"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_REWARD_SHAFTMASTER,Name="REWARD_SHAFTMASTER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_DOMINATING,Name="SPREE_DOMINATING"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_GODLIKE,Name="SPREE_GODLIKE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_KILLINGSPREE,Name="SPREE_KILLINGSPREE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_RAMPAGE,Name="SPREE_RAMPAGE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_MASSACRE,Name="SPREE_MASSACRE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_SPREE_UNSTOPPABLE,Name="SPREE_UNSTOPPABLE"))

ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_HATTRICK,Name="EVENT_HATTRICK"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_KILLEDFLAGCARRIER,Name="EVENT_KILLEDFLAGCARRIER"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_RETURNEDFLAG,Name="EVENT_RETURNEDFLAG"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_SCOREDFLAG,Name="EVENT_SCOREDFLAG"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_LASTSECONDSAVE,Name="EVENT_LASTSECONDSAVE"))

ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_RETURNEDORB,Name="EVENT_RETURNEDORB"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_EVENT_SCOREDORB,Name="EVENT_SCOREDORB"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_DAMAGEDCORE,Name="NODE_DAMAGEDCORE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_DESTROYEDCORE,Name="NODE_DESTROYEDCORE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_DESTROYEDNODE,Name="NODE_DESTROYEDNODE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_HEALEDNODE,Name="NODE_HEALEDNODE"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_NODEBUILT,Name="NODE_NODEBUILT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_NODE_NODEBUSTER,Name="NODE_NODEBUSTER"))

ColumnMappings.Add((Id=`STATS_COLUMN_DM_RANKED_ALLTIME_PLACE,Name="ELO"))
}
