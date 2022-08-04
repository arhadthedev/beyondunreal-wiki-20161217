/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTActorFactoryVehicle extends ActorFactoryVehicle
	native;



/** whether the vehicle starts out locked and can only be used by the owning team */
var() bool bTeamLocked;
/** the number of the team that may use this vehicle */
var() byte TeamNum;
/** if set, force vehicle to be a key vehicle (displayed on map and considered more important by AI) */
var() bool bKeyVehicle;
/** if set, vehicle is on a track (so can only move between UTTrackTurretPathNodes) */
var() bool bIsOnTrack;

defaultproperties
{
	VehicleClass=class'UTVehicle'
	bTeamLocked=true
}
