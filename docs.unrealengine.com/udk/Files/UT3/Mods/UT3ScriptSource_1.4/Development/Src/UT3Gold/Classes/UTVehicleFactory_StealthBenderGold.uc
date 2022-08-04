/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_StealthBenderGold extends UTVehicleFactory;

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

	VehicleClassPath="UT3Gold.UTVehicle_StealthBenderGold_Content"
	DrawScale=1.4
}					   
