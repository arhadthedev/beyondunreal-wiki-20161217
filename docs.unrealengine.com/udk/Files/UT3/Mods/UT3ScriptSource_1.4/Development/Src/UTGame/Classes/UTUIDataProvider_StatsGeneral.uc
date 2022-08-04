/**
 * Dataprovider that returns a row for each general stat for a user.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_StatsGeneral extends UTUIDataProvider_StatsElementProvider
	native(UI);

`include(UTStats.uci)



/** Struct that defines a reward stat row. */
struct native GeneralStatsRow
{
    //Name of the stat we're serving
	var const name StatName;
};
var transient array<GeneralStatsRow> Stats;

/** @return Returns the number of elements(rows) provided. */
native function int GetElementCount();

DefaultProperties
{
	Stats.Empty();

	//All possible stats for all game modes
	Stats.Add((StatName="EVENT_KILLS"))
	Stats.Add((StatName="EVENT_DEATHS"))
	Stats.Add((StatName="EVENT_RANOVERKILLS"))
    Stats.Add((StatName="EVENT_RANOVERDEATHS"))
	Stats.Add((StatName="EVENT_HIJACKED"))
	Stats.Add((StatName="PICKUPS_HEALTH"))
	Stats.Add((StatName="PICKUPS_ARMOR"))
	Stats.Add((StatName="PICKUPS_JUMPBOOTS"))
	Stats.Add((StatName="PICKUPS_SHIELDBELT"))
	Stats.Add((StatName="PICKUPS_BERSERK"))
	Stats.Add((StatName="POWERUPTIME_BERSERK"))
	Stats.Add((StatName="PICKUPS_INVISIBILITY"))
	Stats.Add((StatName="POWERUPTIME_INVISIBILITY"))
	Stats.Add((StatName="PICKUPS_INVULNERABILITY"))
	Stats.Add((StatName="POWERUPTIME_INVULNERABILITY"))
	Stats.Add((StatName="PICKUPS_UDAMAGE"))
	Stats.Add((StatName="POWERUPTIME_UDAMAGE"))

	//CTF/VCTF
	Stats.Add((StatName="EVENT_HATTRICK"))
	Stats.Add((StatName="EVENT_KILLEDFLAGCARRIER")
	Stats.Add((StatName="EVENT_RETURNEDFLAG"))
	Stats.Add((StatName="EVENT_SCOREDFLAG"))
	Stats.Add((StatName="EVENT_LASTSECONDSAVE"))

	//WAR
	Stats.Add((StatName="EVENT_RETURNEDORB"))
	Stats.Add((StatName="NODE_DAMAGEDCORE"))
	Stats.Add((StatName="NODE_DESTROYEDCORE"))
	Stats.Add((StatName="NODE_DESTROYEDNODE"))
	Stats.Add((StatName="NODE_HEALEDNODE"))
	Stats.Add((StatName="NODE_NODEBUILT"))
	Stats.Add((StatName="NODE_NODEBUSTER"))
}
