/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_NightShade extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_NightShade.Mesh.SK_VH_NightShade'
		Translation=(X=40.0,Y=0.0,Z=-50.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=80.0
		CollisionRadius=140.0
		Translation=(X=0.0,Y=0.0,Z=30)
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_NightShade_Content"
	DrawScale=1.4
}
