/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtTarydiumMine_Content extends UTOnslaughtTarydiumMine;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'UN_Cave.SM.Mesh.S_UN_Cave_SM_Crystal'
		CollideActors=true
		BlockActors=true
		CastShadow=true
		HiddenGame=false
		Translation=(X=0.0,Y=0.0,Z=-50.0)
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
		bUseAsOccluder=FALSE
	End Object
	CollisionComponent=StaticMeshComponent0
 	Components.Add(StaticMeshComponent0)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+50.0
		CollisionRadius=+250.0
	End Object

	bHidden=false
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
 	bDestinationOnly=true
	bMustTouchToReach=false
	MineColor=(R=0,G=255,B=255)
}
