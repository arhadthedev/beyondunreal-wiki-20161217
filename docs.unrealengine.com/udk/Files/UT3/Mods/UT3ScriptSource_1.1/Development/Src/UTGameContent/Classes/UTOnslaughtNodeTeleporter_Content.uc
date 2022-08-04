/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTOnslaughtNodeTeleporter_Content extends UTOnslaughtNodeTeleporter;

defaultproperties
{
	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	GoodSprite=None
	BadSprite=None


	Begin Object Class=DynamicLightEnvironmentComponent Name=OnslaughtNodeTeleporterLightEnvironment
		bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add(OnslaughtNodeTeleporterLightEnvironment)


	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Ons_Conduit'
		CollideActors=true
		BlockActors=true
		CastShadow=true
		bCastDynamicShadow=false
		LightEnvironment=OnslaughtNodeTeleporterLightEnvironment
		Translation=(X=0.0,Y=0.0,Z=-34.0)
		Scale=0.5
		bUseAsOccluder=false
	End Object
 	Components.Add(StaticMeshComponent0)
 	FloorMesh=StaticMeshComponent0

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
		Translation=(X=0.0,Y=0.0,Z=-40.0)
		SecondsBeforeInactive=1.0f
	End Object
	Components.Add(ParticleSystemComponent0)
	AmbientEffect=ParticleSystemComponent0

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1
	End Object
	Components.Add(ParticleSystemComponent1)
	PortalEffect=ParticleSystemComponent1
	PortalMaterial=MaterialInterface'Pickups.Base_Teleporter.Material.M_T_Pickups_Teleporter_Portal_Destination'

	Begin Object Class=SceneCapture2DComponent Name=SceneCapture2DComponent0
		FrameRate=15.0
		bSkipUpdateIfOwnerOccluded=true
		MaxUpdateDist=1000.0
		MaxStreamingUpdateDist=1000.0
		bUpdateMatrices=false
		NearPlane=10
		FarPlane=-1
	End Object
	PortalCaptureComponent=SceneCapture2DComponent0
	Components.Add(SceneCapture2DComponent0)

	ConstructedSound=SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_ConduitActivated'
	ActiveSound=SoundCue'A_Gameplay.Portal.Portal_Loop01Cue'

	Begin Object Class=AudioComponent Name=AmbientSoundComponent0
		bAutoPlay=true
		bStopWhenOwnerDestroyed=true
	End Object
	AmbientSoundComponent=AmbientSoundComponent0
	Components.Add(AmbientSoundComponent0)

	NeutralFloorColor=(R=9.0,G=8.0,B=4.0)
	TeamFloorColors[0]=(R=50.0,G=5.0,B=0.0)
	TeamFloorColors[1]=(R=0.0,G=5.0,B=50.0)

 	bStatic=false
 	bCollideActors=true
 	bBlockActors=true
 	bCanWalkOnToReach=true

 	Begin Object Name=CollisionCylinder
		CollisionRadius=50.0
		CollisionHeight=30.0
	End Object

	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=1.0
	bAlwaysRelevant=true

	TeamNum=255
	NeutralEffectTemplate=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Base_Idle'
	TeamEffectTemplates[0]=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Base_Idle_Red'
	TeamEffectTemplates[1]=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Base_Idle_Blue'

	TeamPortalEffectTemplates[0]=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Idle_Red'
	TeamPortalEffectTemplates[1]=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Idle_Blue'

	MessageClass=class'UTOnslaughtMessage'

}
