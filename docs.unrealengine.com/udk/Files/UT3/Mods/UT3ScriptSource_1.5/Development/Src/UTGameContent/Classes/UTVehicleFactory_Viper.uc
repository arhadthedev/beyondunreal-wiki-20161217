/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTVehicleFactory_Viper extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_NecrisManta.Mesh.SK_VH_NecrisManta'
		Translation=(X=0.0,Y=0.0,Z=-64.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=100.000000
		CollisionHeight=40.0
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_Viper_Content"
}

