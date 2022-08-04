/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_StealthBender extends UTVehicleFactory;

// this class ended up being removed from all maps - removing the content references here fixes a bunch of errors
// when compiling script in the shipping game that were due to the content no longer being used in the final build
/*
defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_StealthBender.Mesh.SK_VH_StealthBender'
		Translation=(X=0.0,Y=0.0,Z=-70.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=100.0
		CollisionRadius=140.0
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_StealthBender_Content"
	DrawScale=1.4
}
*/
