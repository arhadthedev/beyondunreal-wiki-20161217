/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtPowerCore_Content extends UTOnslaughtPowerCore;

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0240.000000
		CollisionHeight=+0200.000000
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=PowerCoreLightEnvironment
	    bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add(PowerCoreLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=CoreBaseMesh
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
		RBChannel=RBCC_Nothing
		RBCollideWithChannels=(Default=true,Pawn=true,Vehicle=true,GameplayPhysics=true,EffectPhysics=true)
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=false
		bCastDynamicShadow=false
		LightEnvironment=PowerCoreLightEnvironment
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bHasPhysicsAssetInstance=true
		bSkelCompFixed=true
		SkeletalMesh=SkeletalMesh'GP_Onslaught.Mesh.SK_GP_Ons_Power_Core'
		AnimSets(0)=AnimSet'GP_Onslaught.Anims.K_GP_ONS_Power_Core'
		Translation=(X=0.0,Y=0.0,Z=-325.0)
		MorphSets(0)=MorphTargetSet'GP_Onslaught.Mesh.SK_GP_Ons_Power_Core_MorphTargets'
		PhysicsAsset=PhysicsAsset'GP_Onslaught.Mesh.SK_GP_Ons_Power_Core_Physics'
		AnimTreeTemplate=AnimTree'GP_Onslaught.Anims.AT_GP_Ons_Power_Core'
		bUseAsOccluder=FALSE
		bAcceptsDecals=false
	End Object
	CollisionComponent=CoreBaseMesh
	BaseMesh=CoreBaseMesh
	PanelMesh=CoreBaseMesh
	Components.Add(CoreBaseMesh)

	Begin Object Class=UTParticleSystemComponent Name=ParticleComponent3
		Template=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Center_Blue'
		Translation=(X=0.0,Y=0.0,Z=110.0)
		SecondsBeforeInactive=1.0f
	End Object
	InnerCoreEffect=ParticleComponent3
 	Components.Add(ParticleComponent3)

	DrawScale=+0.6
	bDestinationOnly=true
	MaxSensorRange=4000.0
	bMustTouchToReach=false
	CameraViewDistance=800.0
	bAllowOnlyShootable=true
	bAllowRemoteUse=true
	DamageCapacity=5000
	DefensePriority=10

	BaseMaterialColors[0]=(R=50.0,G=3.0,B=1.5,A=1.0)
	BaseMaterialColors[1]=(R=4.0,G=12.0,B=50.0,A=1.0)

	EnergyLightColors[0]=(R=247,G=64,B=32,A=255)
	EnergyLightColors[1]=(R=64,G=96,B=247,A=255)

	Begin Object Class=PointLightComponent Name=LightComponent0
		CastShadows=false
		bEnabled=true
		Brightness=20.0
		LightColor=(R=247,G=64,B=32,A=255)
		LightShadowMode=LightShadow_Modulate
		Radius=1024
		LightingChannels=(Dynamic=FALSE,CompositeDynamic=FALSE)
	End Object
	EnergyEffectLight=LightComponent0
	Components.Add(LightComponent0)

	InnerCoreEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Center_Red'
	InnerCoreEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Center_Blue'

	DestructionEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Death_Red01'
	DestructionEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Death_Blue01'
	DestroyedPhysicsAsset=PhysicsAsset'GP_Onslaught.Mesh.SK_GP_Ons_Power_Core_Destroyed_Physics'

	EnergyEndPointParameterNames[0]=Elec_End
	EnergyEndPointParameterNames[1]=Elec_End2
	MaxEnergyEffectDist=150.0
	EnergyEndPointBonePrefix="Column"
	EnergyEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Electricity_Red01'
	EnergyEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Electricity01'

	ShieldEffectTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Shielded_Red'
	ShieldEffectTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Shielded_Blue'

	DestroyedSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreExplodeCue'
	ShieldOffSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreShieldToUnshieldCue'
	ShieldOnSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreUnshieldToShieldCue'
	ShieldedAmbientSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreAmbientShieldedCue'
	UnshieldedAmbientSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreAmbientUnshieldedCue'
	DamageWarningSound=SoundCue'A_Gameplay.ONS.Cue.A_Gameplay_ONS_OnsCoreDamage_Cue'

	DefendAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_DefendYourCore')
	AttackAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_AttackTheEnemyCore')

	//DestroyedSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerCoreExplode01Cue'
	ConstructedSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerNodeBuilt01Cue'
	StartConstructionSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerNodeBuild01Cue'
	HealingSound=SoundCue'A_Gameplay.A_Gameplay_Onslaught_PowerNodeStartBuild01Cue'
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
		Translation=(X=0.0,Y=0.0,Z=-1166.0)
		Scale3D=(X=.9394,Y=.9394,Z=3.317)
		bUseAsOccluder=FALSE
	End Object
	NodeBeamEffect=StaticMeshComponent9
	Components.Add(StaticMeshComponent9)

	PanelGibClass=class'UTPowerCorePanel_Content'

	PanelExplosionTemplates[0]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Expl_Red01'
	PanelExplosionTemplates[1]=ParticleSystem'GP_Onslaught.Effects.P_Ons_Power_Core_Expl_Blue01'

	bNoCoreSwitch=true
	bNeverCalledPrimeNode=true

	MessageClass=class'UTOnslaughtMessage'
	RedMessageClass=class'UTOnslaughtRedCoreMessage'
	BlueMessageClass=class'UTOnslaughtBlueCoreMessage'
	SupportedEvents.Add(class'UTSeqEvent_PowerCoreDestructionEffect')
	IconCoords=(U=488,V=266,UL=48,VL=42)

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingTowardOurCore'
	LocationSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_HeadingTowardOurCore'
	LocationSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_HeadingTowardOurCore'
	EnemyLocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingTowardEnemyCore'
	EnemyLocationSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_HeadingTowardEnemyCore'
	EnemyLocationSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_HeadingTowardEnemyCore'
	DefendingLocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_DefendingOurCore'
	DefendingLocationSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_DefendingOurCore'
	DefendingLocationSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_DefendingOurCore'
	AttackingLocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_AttackingEnemyCore'
	AttackingLocationSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_AttackingEnemyCore'
	AttackingLocationSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_AttackingEnemyCore'
	DefendingEnemyCoreSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_DefendingEnemyCore'
	DefendingEnemyCoreSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_DefendingEnemyCore'
	DefendingEnemyCoreSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_DefendingEnemyCore'
	AttackingOurCoreSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_AttackingOurCore'
	AttackingOurCoreSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_AttackingOurCore'
	AttackingOurCoreSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_AttackingOurCore'

	AlternateTargetLocOffset=(Z=200.0)
}
