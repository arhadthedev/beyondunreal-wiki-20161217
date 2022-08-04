/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_SPMA extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_SPMA.Mesh.SK_VH_SPMA'
		Translation=(X=40.0,Y=0.0,Z=-90.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=100.0
		CollisionRadius=260.0
		Translation=(X=-10.0,Y=0.0,Z=-20.0)
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_SPMA_Content"
	DrawScale=1.3
}
