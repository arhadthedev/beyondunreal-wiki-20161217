/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTWarfareChildBarricade_Concrete extends UTWarfareChildBarricade;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=Mesh0
		StaticMesh=StaticMesh'HU_Deco.SM.Mesh.S_HU_DECO_Barrier'
		Scale=2.0
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=FALSE)
	End Object
	CollisionComponent=Mesh0
	Components.Add(Mesh0)
}


