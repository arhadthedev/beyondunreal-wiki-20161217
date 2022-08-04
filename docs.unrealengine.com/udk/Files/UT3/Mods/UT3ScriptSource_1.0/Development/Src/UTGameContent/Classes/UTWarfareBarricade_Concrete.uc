/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTWarfareBarricade_Concrete extends UTWarfareBarricade;

defaultproperties
{
	ShieldHitSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue'

	Begin Object Name=CollisionCylinder
		CollisionRadius=100.0
	End Object

	Begin Object Class=StaticMeshComponent Name=Mesh0
		StaticMesh=StaticMesh'HU_Deco.SM.Mesh.S_HU_DECO_Barrier'
		Scale=2.0
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=FALSE)
		Translation=(X=0,Y=0,Z=-60.0)
	End Object
	CollisionComponent=Mesh0
	Components.Add(Mesh0)

	AttackAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_DestroyTheBarricade')
	DisabledAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BarricadeDestroyed')

}


