/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTVehicleFactory_Nemesis extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Nemesis.Mesh.SK_VH_Nemesis'
		Translation=(X=-64.0,Y=0.0,Z=-100.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=260.000000
		CollisionHeight=100.0
	End Object

	SpawnZOffset=10.0

	VehicleClassPath="UTGameContent.UTVehicle_Nemesis"
}
