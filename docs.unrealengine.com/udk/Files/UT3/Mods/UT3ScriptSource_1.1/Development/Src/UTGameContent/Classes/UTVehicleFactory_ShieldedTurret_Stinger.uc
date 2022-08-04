/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTVehicleFactory_ShieldedTurret_Stinger extends UTVehicleFactory_TrackTurretBase;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Turret.Mesh.SK_VH_TurretSmall'
		Translation=(X=0.0,Y=0.0,Z=-55.0)
		Scale=3.5
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=100.000000
		CollisionHeight=80.0
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_ShieldedTurret_Stinger"
	SpawnRotationOffset=(Yaw=16384)
}
