﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_HellBender extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Hellbender.Mesh.SK_VH_Hellbender'
		Translation=(X=40.0,Y=0.0,Z=-50.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=100.0
		CollisionRadius=140.0
		Translation=(X=20.0,Y=0.0,Z=25.0)
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_HellBender_Content"
	DrawScale=1.4
}
