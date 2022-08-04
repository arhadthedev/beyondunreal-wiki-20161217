/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_Fury extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Fury.Mesh.SK_VH_Fury'
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+240.0
		CollisionRadius=+384.0
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_Fury_Content"
}

