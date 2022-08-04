/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtPowernode_Content extends UTOnslaughtPowernode
	PerObjectLocalized;


simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	MITV_NecrisCapturePipesLarge = NecrisCapturePipesLarge.CreateAndSetMaterialInstanceTimeVarying(0);
	MITV_NecrisCapturePipesLarge.SetScalarCurveParameterValue( 'Nec_TubeFadeOut', NecrisCapturePipes_FadeOut_Fast );
	MITV_NecrisCapturePipesLarge.SetScalarStartTime( 'Nec_TubeFadeOut', 0.0f );

	MITV_NecrisCapturePipesSmall = NecrisCapturePipesSmall.CreateAndSetMaterialInstanceTimeVarying(0);
	MITV_NecrisCapturePipesSmall.SetScalarCurveParameterValue( 'Nec_TubeFadeOut', NecrisCapturePipes_FadeOut_Fast );
	MITV_NecrisCapturePipesSmall.SetScalarStartTime( 'Nec_TubeFadeOut', 0.0f );

	MITV_NecrisCaptureGoo = new(Outer) class'MaterialInstanceTimeVarying';
	MITV_NecrisCaptureGoo.SetParent( MaterialInstance'GP_Onslaught.Materials.M_GP_Ons_NecrisNode_GooAnimate' );
	PSC_NecrisGooPuddle.SetMaterialParameter( 'Nec_PuddleOpacity', MITV_NecrisCaptureGoo );
}


defaultproperties
{
	InvulnerableRadius=1000.0
	CaptureReturnRadius=500.0
	InvEffectZOffset=16.0
	OrbHealingPerSecond=100
	OrbCaptureInvulnerabilityDuration=12.0

	YawRotationRate=20000
	LinkHealMult=1.0
	DamageCapacity=2000
	Score=5
	bDestinationOnly=false
	bPathColliding=false
	PanelHealthMax=60
	PanelBonePrefix="NodePanel"
	DestructionMessageIndex=16

	//ActiveSound=soundcue'ONSVehicleSounds-S.PwrNodeActive02'

	DestroyedEvent(0)="red_powernode_destroyed"
	DestroyedEvent(1)="blue_powernode_destroyed"
	DestroyedEvent(2)="red_constructing_powernode_destroyed"
	DestroyedEvent(3)="blue_constructing_powernode_destroyed"
	ConstructedEvent(0)="red_powernode_constructed"
	ConstructedEvent(1)="blue_powernode_constructed"


 	Begin Object Name=CollisionCylinder
		CollisionRadius=160.0
		CollisionHeight=30.0
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=PowerNodeLightEnvironment
	    bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add(PowerNodeLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Ons_Power_Node_Base'
		CollideActors=true
		BlockActors=true
		CastShadow=true
		bCastDynamicShadow=false
		LightEnvironment=PowerNodeLightEnvironment
		Translation=(X=0.0,Y=0.0,Z=-34.0)
		bUseAsOccluder=FALSE
	End Object
	NodeBase=StaticMeshComponent0
 	Components.Add(StaticMeshComponent0)

 	Begin Object Class=StaticMeshComponent Name=StaticMeshSpinner
 		StaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Ons_Power_Node_spinners'
 		CollideActors=false
 		BlockActors=false
 		CastShadow=false
		bCastDynamicShadow=false
		LightEnvironment=PowerNodeLightEnvironment
		Translation=(Z=-34.0)
		bUseAsOccluder=FALSE
 	End Object
 	NodeBaseSpinner=StaticMeshSpinner
 	Components.Add(StaticMeshSpinner)

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent1
		SkeletalMesh=SkeletalMesh'GP_Onslaught.Mesh.SK_GP_Ons_Power_Node_Panels'
		AnimTreeTemplate=AnimTree'GP_Onslaught.Anims.AT_GP_Ons_Power_Node_Panels'
		CollideActors=false
		BlockActors=false
		CastShadow=false
		bCastDynamicShadow=false
		LightEnvironment=PowerNodeLightEnvironment
		//BlockRigidBody=true
		//bHasPhysicsAssetInstance=true
		//bSkelCompFixed=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		Translation=(X=0.0,Y=0.0,Z=240.0)
		Scale3D=(X=1.5,Y=1.5,Z=1.25)
		bUseAsOccluder=FALSE
		bAcceptsDecals=false
	End Object
	EnergySphere=SkeletalMeshComponent1
	PanelMesh=SkeletalMeshComponent1
 	Components.Add(SkeletalMeshComponent1)

	Begin Object Class=CylinderComponent Name=CollisionCylinder2
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=false
		Translation=(X=0.0,Y=0.0,Z=400.0)
		CollisionRadius=90
		CollisionHeight=70
	End Object
	EnergySphereCollision=CollisionCylinder2
 	Components.Add(CollisionCylinder2)

	Begin Object Class=UTParticleSystemComponent Name=AmbientEffectComponent
		Translation=(X=0.0,Y=0.0,Z=128.0)
		SecondsBeforeInactive=1.0f
	End Object
	AmbientEffect=AmbientEffectComponent
	Components.Add(AmbientEffectComponent)

	//@fixme FIXME: should be UTParticleSystemComponent, but changing that breaks copies already saved in maps
	// because the old component is getting incorrectly saved even though it hasn't been edited
	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1
		Translation=(X=0.0,Y=0.0,Z=370.0)
		bAcceptsLights=false
		bOverrideLODMethod=true
		LODMethod=PARTICLESYSTEMLODMETHOD_DirectSet
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
	End Object
	ShieldedEffect=ParticleSystemComponent1
	Components.Add(ParticleSystemComponent1)

	HealEffectClasses[0]=class'UTOnslaughtNodeHealEffectRed'
	HealEffectClasses[1]=class'UTOnslaughtNodeHealEffectBlue'

	ActiveEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Center_Red'
	ActiveEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Center_Blue'
	ShieldedActiveEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Center_Red_Shielded'
	ShieldedActiveEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Center_Blue_Shielded'
	NeutralEffectTemplate=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Neutral'
	ConstructingEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Constructing_Red'
	ConstructingEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Constructing_Blue'
	ShieldedEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Shielded_Red'
	ShieldedEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Shielded_Blue'
	VulnerableEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Vulnerable_Red'
	VulnerableEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Vulnerable_Blue'
	DamagedEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Damaged_Red'
	DamagedEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Damaged_Blue'
	DestroyedEffectTemplate=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Destroyed'
	PanelHealEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Panel_Red'
	PanelHealEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Panel_Blue'
	FlagLinkEffectTemplates[0]=ParticleSystem'Pickups.PowerCell.Effects.P_LinkOrbAndNode_Red'
	FlagLinkEffectTemplates[1]=ParticleSystem'Pickups.PowerCell.Effects.P_LinkOrbAndNode_Blue'

	NeutralGlowColor=(R=7.0,G=7.0,B=4.5,A=1.0)
	TeamGlowColors[0]=(R=30.0,G=2.25,B=0.95,A=1.0)
	TeamGlowColors[1]=(R=0.9,G=3.75,B=40.0,A=1.0)

	AttackAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_AttackTheNode')
	DefendAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_DefendTheNode')

	PrimeAttackAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_AttackThePrimeNode')
	PrimeDefendAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_DefendThePrimeNode')
	EnemyPrimeAttackAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_AttackTheEnemyPrimeNode')
	EnemyPrimeDefendAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_DefendThePrimeNode')

	// A Panels currently take 3.0 seconds to go from spawn to mark.  I've set this travel
	// time to 4 seconds to ensure it completes before the node is done
	PanelTravelTime=4.0

	DestroyedSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerCoreExplode01Cue'
	ConstructedSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerNodeBuilt01Cue'
	StartConstructionSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerNodeBuild01Cue'
	ActiveSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerNodeNotActive01Cue'
	HealingSound=SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_ConduitAmbient'
	HealedSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerNodeBuilt01Cue'
	ShieldHitSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue'

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent9
	    StaticMesh=StaticMesh'Onslaught_Effects.Meshes.S_Onslaught_FX_GodBeam'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		CastShadow=false
		HiddenGame=false
		bAcceptsLights=false
		LightEnvironment=PowerNodeLightEnvironment
		Translation=(X=0.0,Y=0.0,Z=-1166.0)
		Scale3D=(X=.9394,Y=.9394,Z=3.317)
		bUseAsOccluder=FALSE
	End Object
	NodeBeamEffect=StaticMeshComponent9
	Components.Add(StaticMeshComponent9)

	PanelGibClass=class'UTPowerNodePanel'

	PanelExplosionTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Expl_Red01'
	PanelExplosionTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Expl_Blue01'

	Begin Object Class=AudioComponent name=OrbNearbySoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'A_Gameplay.ONS.OrbNearConduitCue'
	End Object
	OrbNearbySound=OrbNearbySoundComponent
	Components.Add(OrbNearbySoundComponent)

	MessageClass=class'UTOnslaughtMessage'
	Begin Object Class=ParticleSystemComponent Name=CaptureSystem
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
	End Object
	OrbCaptureComponent=CaptureSystem
	Components.Add(CaptureSystem)
	OrbCaptureTemplate[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Orb_Capture_Red'
	OrbCaptureTemplate[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Node_Orb_Capture_Blue'


	Begin Object Class=ParticleSystemComponent Name=InvulnerableSystem
		bAutoActivate=false
		HiddenGame=true
		//SecondsBeforeInactive=1.0f
	End Object
	InvulnerableToOrbEffect=InvulnerableSystem
	Components.Add(InvulnerableSystem)
	InvulnerableToOrbTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_GP_Ons_Powernode_OrbShield_Red'
	InvulnerableToOrbTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_GP_Ons_Powernode_OrbShield_Blue'

/*
	The Goo Puddle should start interpolating when the power node is at 50% (0-50%), and interpolate from 0-.75 in that portion of its health.
	When the Node reaches 100% health, interpolate the goo puddle from 0.75 - 1.0
	The Pipes should animate in when the node is at 100%, ramp through 0-6 in the same time it takes for the goo to come in (may need to tweak this rate)
	Wispies should animate the same as the puddle.

	When it is destroyed, the Pipe "fadeout" values to 0 (should be default of 1). All other values should be animated to 0
*/

    Begin Object Class=UTParticleSystemComponent Name=NecrisGoodPuddleComp
	    Template=ParticleSystem'GP_Onslaught.Effects.P_GP_Ons_PowerNode_NecrisPuddle'
		bAutoActivate=FALSE
		Translation=(X=0.0,Y=0.0,Z=-34.0)
		SecondsBeforeInactive=1.0f
		Scale=2.5f
	End Object
	PSC_NecrisGooPuddle=NecrisGoodPuddleComp
	Components.Add(NecrisGoodPuddleComp)



	Begin Object Class=UTParticleSystemComponent Name=NecrisCaptureComp
	    Template=ParticleSystem'GP_Onslaught.Effects.P_GP_Ons_NecrisNode_Wispy'
		bAutoActivate=FALSE
		Translation=(X=0.0,Y=0.0,Z=-34.0)
		SecondsBeforeInactive=1.0f
	End Object
	PSC_NecrisCapture=NecrisCaptureComp
	Components.Add(NecrisCaptureComp)

	Begin Object Class=StaticMeshComponent Name=NecrisCapturePipesLargeComp
	    StaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Ons_Power_Node_PipeTightLarge'
		CollideActors=false
		BlockActors=false
		CastShadow=false
		bCastDynamicShadow=false
		LightEnvironment=PowerNodeLightEnvironment
		bUseAsOccluder=FALSE
		Translation=(X=0.0,Y=0.0,Z=-34.0)
	End Object
	NecrisCapturePipesLarge=NecrisCapturePipesLargeComp
	Components.Add(NecrisCapturePipesLargeComp)


	Begin Object Class=StaticMeshComponent Name=NecrisCapturePipesSmallComp
	    StaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Ons_Power_Node_PipeTightSmall'
		CollideActors=false
		BlockActors=false
		CastShadow=false
		bCastDynamicShadow=false
		LightEnvironment=PowerNodeLightEnvironment
		bUseAsOccluder=FALSE
		Translation=(X=0.0,Y=0.0,Z=-34.0)
	End Object
	NecrisCapturePipesSmall=NecrisCapturePipesSmallComp
	Components.Add(NecrisCapturePipesSmallComp)


	NecrisCapturePipes_FadeOut_Fast=(Points=((InVal=0,OutVal=0.0),(InVal=0.1,OutVal=0.0)))

	MITV_NecrisCapturePipes_FadeIn=(Points=((InVal=0,OutVal=0.0),(InVal=4.0,OutVal=6.0)))
	MITV_NecrisCapturePipes_FadeIn2=(Points=((InVal=0,OutVal=0.0),(InVal=0.01,OutVal=1.0)))


	NecrisCapturePuddle_FadeIn50=(Points=((InVal=0,OutVal=0.0),(InVal=5.0,OutVal=0.75)))
	NecrisCapturePuddle_FadeIn100=(Points=((InVal=0,OutVal=0.75),(InVal=4.0,OutVal=1.0)))

	NecrisCapturePuddle_FadeOut=(Points=((InVal=0,OutVal=1.0),(InVal=4.0,OutVal=0.0)))

	LinkToSockets(0)=Link01
	LinkToSockets(1)=Link02

	bHasLocationSpeech=true
	HeadingPrimeSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingTowardPrimeNode'
	HeadingPrimeSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_HeadingTowardPrimeNode'
	HeadingPrimeSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_HeadingTowardPrimeNode'
	AttackingPrimeSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_AttackingPrimeNode'
	AttackingPrimeSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_AttackingPrimeNode'
	AttackingPrimeSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_AttackingPrimeNode'
	HeadingEnemyPrimeSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingTowardEnemyPrimeNode'
	HeadingEnemyPrimeSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_HeadingTowardEnemyPrimeNode'
	HeadingEnemyPrimeSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_HeadingTowardEnemyPrimeNode'
	AttackingEnemyPrimeSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_AttackingEnemyPrimeNode'
	AttackingEnemyPrimeSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_AttackingEnemyPrimeNode'
	AttackingEnemyPrimeSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_AttackingEnemyPrimeNode'
	CapturedPrimeSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_PrimeNodeCaptured'
	CapturedPrimeSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_PrimeNodeCaptured'
	CapturedPrimeSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_PrimeNodeCaptured'
	CapturedEnemyPrimeSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyPrimeNodeCaptured'
	CapturedEnemyPrimeSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyPrimeNodeCaptured'
	CapturedEnemyPrimeSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyPrimeNodeCaptured'
}
