/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleFactory_Paladin extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Paladin.Mesh.SK_VH_Paladin'
		Translation=(Z=-70.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=125.0
		CollisionRadius=260.0
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_Paladin"
	DrawScale=1.5
}
