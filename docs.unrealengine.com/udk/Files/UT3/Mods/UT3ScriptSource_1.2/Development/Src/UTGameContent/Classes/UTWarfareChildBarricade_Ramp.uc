/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTWarfareChildBarricade_Ramp extends UTWarfareChildBarricade;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=Mesh0
		StaticMesh=StaticMesh'HU_Floor2.SM.Mesh.S_HU_Floor_SM_WalkwaySetA_256'
		Scale=0.75
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=FALSE)
	End Object
	CollisionComponent=Mesh0
	Components.Add(Mesh0)
}


