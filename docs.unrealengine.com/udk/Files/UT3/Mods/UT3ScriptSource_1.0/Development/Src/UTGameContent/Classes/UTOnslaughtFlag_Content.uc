/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtFlag_Content extends UTOnslaughtFlag;


defaultproperties
{
	Physics=PHYS_None
	bHome=True
	bStatic=False
	NetPriority=+00003.000000
	bCollideActors=true
	bAlwaysRelevant=true
	GraceDist=5000.0
	MaxDropTime=15.0

	MessageClass=class'UTOnslaughtOrbMessage'
	GodBeamClass=class'UTOnslaughtGodBeam_Content'

	Begin Object class=PointLightComponent name=FlagLightComponent
		Brightness=5.0
		LightColor=(R=255,G=255,B=64)
		Radius=250.0
		CastShadows=true
		bEnabled=true
	End Object
	FlagLight=FlagLightComponent
	Components.Add(FlagLightComponent)

	Begin Object Class=DynamicLightEnvironmentComponent Name=OnslaughtFlagLightEnvironment
	    bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add(OnslaughtFlagLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'Pickups.PowerCell.Mesh.S_Pickups_PowerCell_Cell01'
		CollideActors=false
		BlockRigidBody=false
		CastShadow=false
		bAcceptsLights=true
		LightEnvironment=OnslaughtFlagLightEnvironment
		scale=1.35
		bUseAsOccluder=FALSE
	End Object
	Mesh=StaticMeshComponent0
 	Components.Add(StaticMeshComponent0)

	Begin Object Class=AudioComponent Name=AmbientSoundComponent
		SoundCue=SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_OrbAmbient'
		bAutoPlay=true
		bShouldRemainActiveIfDropped=true
	End Object
	Components.Add(AmbientSoundComponent)

	PickupSound=SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_OrbPickedUp'
	DroppedSound=SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_OrbDropped'
	ReturnedSound=SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_OrbDischarged'

	ReturnedEffectClasses[0]=class'UTEmit_OnslaughtOrbExplosion_Red'
	ReturnedEffectClasses[1]=class'UTEmit_OnslaughtOrbExplosion_Blue'

	FlagMaterials(0)=Material'Pickups.PowerCell.Materials.M_Pickups_Orb_Red'
	FlagMaterials(1)=Material'Pickups.PowerCell.Materials.M_Pickups_Orb_Blue'

	FlagEffect(0)=ParticleSystem'GP_Onslaught.Effects.P_Orb_Red'
	FlagEffect(1)=ParticleSystem'GP_Onslaught.Effects.P_Orb_Blue'

	Begin Object Class=ParticleSystemComponent Name=EffectComp
		SecondsBeforeInactive=1.0f
	End Object
	FlagEffectComp=EffectComp
	Components.Add(EffectComp)

	LightColors(0)=(R=255,G=64,B=0)
	LightColors(1)=(R=64,G=128,B=255)

	GameObjOffset3P=(X=-35,Y=30,Z=25)
	GameObjOffset1P=(X=-35,Y=30,Z=25)
	bHardAttach=true
	RotationRate=(Pitch=12000,Yaw=14000,Roll=10000)

	GameObjBone3P=None
	MaxSpringDistance=15.0
	NormalOrbScale=1.35
	HomeOrbScale=1.0
	HoverboardOrbScale=0.9

	PrebuildTime=0.025
	EnemyReturnPrebuildTime=5.0
	BuildTime=5.5

	NeedToPickUpAnnouncements[0]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_GrabYourOrb')
	NeedToPickUpAnnouncements[1]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_GrabYourOrb')
	IconCoords=(U=843,V=0,UL=50,VL=48)
	MapSize=0.75
}
