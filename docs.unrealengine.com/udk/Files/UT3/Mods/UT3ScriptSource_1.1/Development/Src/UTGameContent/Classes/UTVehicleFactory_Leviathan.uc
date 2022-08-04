/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_Leviathan extends UTVehicleFactory;

simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, LinearColor FinalColor);

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Leviathan.Mesh.SK_VH_Leviathan'
		Translation=(X=0.0,Y=0.0,Z=-100.0)
	End Object
	Components.Add(SVehicleMesh)
	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=450.000000
		CollisionHeight=150.0
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_Leviathan_Content"
	DrawScale=1.5
}
