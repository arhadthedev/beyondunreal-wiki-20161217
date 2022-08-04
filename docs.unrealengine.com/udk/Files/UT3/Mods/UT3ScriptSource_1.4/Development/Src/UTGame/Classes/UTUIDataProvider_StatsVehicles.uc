/**
 * Dataprovider that returns a row for each vehicle/vehicle weapons with kills/death/suicides given a user's stats results.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_StatsVehicles extends UTUIDataProvider_StatsElementProvider
	native(UI);

`include(UTStats.uci)



/** Struct that defines a vehicle row. */
struct native VehicleStatsRow
{
	var string VehicleName;

	var const name DrivingTimeName;
	var const name VehicleKillsName;
};
var transient array<VehicleStatsRow> Stats;

/** @return Returns the number of elements(rows) provided. */
native function int GetElementCount();

DefaultProperties
{
	Stats.Empty();

	Stats.Add((VehicleName="UTVehicle_Cicada", VehicleKillsName=VEHICLEKILL_UTVEHICLE_CICADA_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_CICADA_CONTENT))
	Stats.Add((VehicleName="UTVehicle_DarkWalker", VehicleKillsName=VEHICLEKILL_UTVEHICLE_DARKWALKER_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_DARKWALKER_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Fury", VehicleKillsName=VEHICLEKILL_UTVEHICLE_FURY_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_FURY_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Goliath", VehicleKillsName=VEHICLEKILL_UTVEHICLE_GOLIATH_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_GOLIATH_CONTENT))
	Stats.Add((VehicleName="UTVehicle_HellBender", VehicleKillsName=VEHICLEKILL_UTVEHICLE_HELLBENDER_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_HELLBENDER_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Hoverboard", VehicleKillsName=VEHICLEKILL_UTVEHICLE_HOVERBOARD, DrivingTimeName=DRIVING_UTVEHICLE_HOVERBOARD))
	Stats.Add((VehicleName="UTVehicle_Leviathan", VehicleKillsName=VEHICLEKILL_UTVEHICLE_LEVIATHAN_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_LEVIATHAN_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Manta", VehicleKillsName=VEHICLEKILL_UTVEHICLE_MANTA_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_MANTA_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Nemesis", VehicleKillsName=VEHICLEKILL_UTVEHICLE_NEMESIS, DrivingTimeName=DRIVING_UTVEHICLE_NEMESIS))
	Stats.Add((VehicleName="UTVehicle_NightShade", VehicleKillsName=VEHICLEKILL_UTVEHICLE_NIGHTSHADE_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_NIGHTSHADE_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Paladin", VehicleKillsName=VEHICLEKILL_UTVEHICLE_PALADIN, DrivingTimeName=DRIVING_UTVEHICLE_PALADIN))
	Stats.Add((VehicleName="UTVehicle_Raptor", VehicleKillsName=VEHICLEKILL_UTVEHICLE_RAPTOR_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_RAPTOR_CONTENT))
	Stats.Add((VehicleName="UTVehicle_SPMA", VehicleKillsName=VEHICLEKILL_UTVEHICLE_SPMA_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_SPMA_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Scavenger", VehicleKillsName=VEHICLEKILL_UTVEHICLE_SCAVENGER_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_SCAVENGER_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Scorpion", VehicleKillsName=VEHICLEKILL_UTVEHICLE_SCORPION_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_SCORPION_CONTENT))
	Stats.Add((VehicleName="UTVehicle_StealthBender", VehicleKillsName=VEHICLEKILL_UTVEHICLE_STEALTHBENDER_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_STEALTHBENDER_CONTENT))
	Stats.Add((VehicleName="UTVehicle_Turret", VehicleKillsName=VEHICLEKILL_UTVEHICLE_TURRET, DrivingTimeName=DRIVING_UTVEHICLE_TURRET))
	Stats.Add((VehicleName="UTVehicle_Viper", VehicleKillsName=VEHICLEKILL_UTVEHICLE_VIPER_CONTENT, DrivingTimeName=DRIVING_UTVEHICLE_VIPER_CONTENT))
}