/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleFactory_Raptor extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Raptor.Mesh.SK_VH_Raptor'
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+80.0
		CollisionRadius=+100.0
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_Raptor_Content"
	DrawScale=1.3
}
