/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_Turret extends UTVehicleFactory_TrackTurretBase;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Turret.Mesh.SK_VH_Turret'
		Translation=(Z=-90.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=80.0
		CollisionRadius=100.0
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_Turret"
}
