/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_HellBender_Content extends UTVehicle_HellBender;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	PlayVehicleAnimation('Inactive');
}
simulated function TakeRadiusDamage( Controller InstigatedBy, float BaseDamage, float DamageRadius, class<DamageType> DamageType,
				float Momentum, vector HurtOrigin, bool bFullDamage, Actor DamageCauser )
{
	if ( Role < ROLE_Authority )
		return;

	// don't take damage from own combos
	if (DamageType != class'UTDmgType_VehicleShockChain' || InstigatedBy != Controller)
	{
		Super.TakeRadiusDamage(InstigatedBy, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bFullDamage, DamageCauser);
	}
}

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local ParticleSystemComponent ShockBeam;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	// Handle Beam Effects for the shock beam

	if (!IsZero(HitLocation))
	{
		ShockBeam = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, GetEffectLocation(SeatIndex));
		ShockBeam.SetVectorParameter('ShotEnd', HitLocation);
	}
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+65.0
		CollisionRadius=+140.0
		Translation=(Z=-15.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Hellbender.Mesh.SK_VH_Hellbender'
		PhysicsAsset=PhysicsAsset'VH_Hellbender.Mesh.SK_VH_Hellbender_Physics'
		AnimTreeTemplate=AnimTree'VH_Hellbender.Anims.AT_VH_Hellbender'
		AnimSets(0)=AnimSet'VH_Hellbender.Anims.K_VH_Hellbender'
		MorphSets[0]=MorphTargetSet'VH_Hellbender.Mesh.VH_Hellbender_MorphTargets'
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled4=TRUE)
	End Object

	DrawScale=1.2

	FlagOffset=(X=9.0,Y=-44,Z=80)

	Seats(0)={(	GunClass=class'UTVWeap_ShockTurret',
				GunSocket=(GunnerFireSocket),
				TurretControls=(GunnerConstraint,GunnerConstraintYaw),
				GunPivotPoints=(SecondaryTurretYaw),
				CameraTag=DriverViewSocket,
				CameraOffset=-300,
				CameraBaseOffset=(X=-50.0,Z=20.0),
				SeatIconPos=(X=0.44,Y=0.48),
				DriverDamageMult=0.0,
				MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight',
				WeaponEffects=((SocketName=GunnerFireSocket,Offset=(X=-35),Scale3D=(X=4.0,Y=6.5,Z=6.5)))
				)}
	Seats(1)={(	GunClass=class'UTVWeap_HellBenderPrimary',
				GunSocket=(TurretFireSocket),
				GunPivotPoints=(MainTurretYaw),
				TurretVarPrefix="Turret",
				TurretControls=(TurretConstraintPitch,TurretConstraintYaw),
				CameraEyeHeight=20,
				CameraOffset=-256,
				CameraTag=TurretViewSocket,
				DriverDamageMult=0.2,
				ImpactFlashLightClass=class'UTGame.UTShockMuzzleFlashLight',
				MuzzleFlashLightClass=class'UTGame.UTTurretMuzzleFlashLight',
				SeatIconPos=(X=0.44,Y=0.8),
				bSeatVisible=true,
				SeatBone=MainTurretYaw,
				SeatOffset=(X=37,Y=0,Z=-12),
				WeaponEffects=((SocketName=TurretFireSocket,Offset=(X=-36),Scale3D=(X=6.5,Y=8.0,Z=8.0)))
				)}

	DrivingAnim=Hellbender_Idle_Sitting

	// Sounds

	Begin Object Class=AudioComponent Name=ScorpionTireSound
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);

	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Hellbender_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dirt_Effects.P_Hellbender_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Hellbender_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Hellbender_Wheel_Snow')

	// Engine sound.
	Begin Object Class=AudioComponent Name=HellBenderEngineSound
		SoundCue=SoundCue'A_Vehicle_Hellbender.SoundCues.A_Vehicle_Hellbender_EngineIdle'
	End Object
	EngineSound=HellBenderEngineSound
	Components.Add(HellBenderEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Hellbender.SoundCues.A_Vehicle_Hellbender_Collide'

	// Wheel squealing sound.
	Begin Object Class=AudioComponent Name=HellbenderSquealSound
		SoundCue=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Slide'
	End Object
	SquealSound=HellbenderSquealSound
	Components.Add(HellbenderSquealSound);

	Begin Object Class=AudioComponent Name=HellbenderSusShift
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleCompressC_Cue'
	End Object
	SuspensionShiftSound=HellbenderSusShift
	Components.Add(HellbenderSusShift)

	EnterVehicleSound=SoundCue'A_Vehicle_Hellbender.SoundCues.A_Vehicle_Hellbender_EngineStart'
	ExitVehicleSound=SoundCue'A_Vehicle_Hellbender.SoundCues.A_Vehicle_Hellbender_EngineStop'

	// Initialize sound parameters.
	SquealThreshold=0.1
	SquealLatThreshold=0.02
	LatAngleVolumeMult = 30.0

	EngineStartOffsetSecs=0.5
	EngineStopOffsetSecs=1.0

	VehicleEffects(0)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Hellbender',EffectSocket=DamageSmoke01)
	VehicleEffects(1)=(EffectStartTag=ShockTurretFire,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_DriverPrimMuzzleFlash',EffectSocket=GunnerFireSocket)
	VehicleEffects(2)=(EffectStartTag=ShockTurretAltFire,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_DriverAltMuzzleFlash',EffectSocket=GunnerFireSocket)

	VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_GenericExhaust',EffectSocket=ExhaustLeft)
	VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_GenericExhaust',EffectSocket=ExhaustRight)

	VehicleEffects(5)=(EffectStartTag=BackTurretFire,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_SecondMuzzleFlash',EffectSocket=TurretFireSocket)

	VehicleAnims(0)=(AnimTag=EngineStart,AnimSeqs=(GetIn),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	VehicleAnims(1)=(AnimTag=Idle,AnimSeqs=(Idle),AnimRate=1.0,bAnimLoopLastSeq=true,AnimPlayerName=AnimPlayer)
	VehicleAnims(2)=(AnimTag=EngineStop,AnimSeqs=(GetOut),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	VehicleAnims(3)=(AnimTag=Inactive,AnimSeqs=(InactiveIdle),AnimRate=1.0,bAnimLoopLastSeq=true,AnimPlayerName=AnimPlayer)

	DamageMorphTargets(0)=(InfluenceBone=FrontBumper,MorphNodeName=MorphNodeW_Front,Health=200,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=Lt_Rear_Suspension,MorphNodeName=MorphNodeW_RearLt,Health=100,DamagePropNames=(Damage3))
	DamageMorphTargets(2)=(InfluenceBone=Rt_Rear_Suspension,MorphNodeName=MorphNodeW_RearRt,Health=100,DamagePropNames=(Damage3))
	DamageMorphTargets(3)=(InfluenceBone=Lt_Door,MorphNodeName=MorphNodeW_Left,Health=150,DamagePropNames=(Damage1))
	DamageMorphTargets(4)=(InfluenceBone=Rt_Door,MorphNodeName=MorphNodeW_Right,Health=150,DamagePropNames=(Damage1))
	DamageMorphTargets(5)=(InfluenceBone=Antenna1,MorphNodeName=MorphNodeW_Top,Health=200,DamagePropNames=(Damage6))
	DamageMorphTargets(6)=(InfluenceBone=Lt_Front_Suspension,MorphNodeName=MorphNodeW_LtFrontFender,Health=75,DamagePropNames=())
	DamageMorphTargets(7)=(InfluenceBone=Rt_Front_Suspension,MorphNodeName=MorphNodeW_RtFrontFender,Health=75,DamagePropNames=())

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=3.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=3.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=3.0)
	DamageParamScaleLevels(3)=(DamageParamName=Damage6,Scale=3.0)


	TeamBeaconOffset=(z=60.0)

	BeamTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_Prim_Altfire'
	ExplosionSound=SoundCue'A_Vehicle_Hellbender.SoundCues.A_Vehicle_Hellbender_Explode'
	ExhaustEffectName=ExhaustVel
	HoverBoardAttachSockets=(HoverAttach00,HoverAttach01)

	TeamMaterials[0]=MaterialInstanceConstant'VH_Hellbender.Materials.MI_VH_Hellbender_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Hellbender.Materials.MI_VH_Hellbender_Blue'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Hellbender.Materials.MI_VH_Hellbender_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Hellbender.Materials.MI_VH_Hellbender_Spawn_Blue'))

	BrakeLightParameterName=Brake_Light
	ReverseLightParameterName=Reverse_Light
	DrivingPhysicalMaterial=PhysicalMaterial'vh_hellbender.materials.physmat_hellbenderdriving'
	DefaultPhysicalMaterial=PhysicalMaterial'vh_hellbender.materials.physmat_hellbender'

	BurnOutMaterial[0]=MaterialInterface'VH_Hellbender.Materials.MITV_VH_Hellbender_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Hellbender.Materials.MITV_VH_Hellbender_Blue_BO'


	PlateTeamMaterials[0]=MaterialInterface'VH_Hellbender.Materials.MI_VH_Hellbender_LP_Red'
	PlateTeamMaterials[1]=MaterialInterface'VH_Hellbender.Materials.MI_VH_Hellbender_LP_Blue'
	PlateBO[0]=MaterialInterface'VH_Hellbender.Materials.MITV_VH_Hellbender_LP_BO'
	PlateBO[1]=MaterialInterface'VH_Hellbender.Materials.MITV_VH_Hellbender_LP_BO'

	PassengerTeamBeaconOffset=(X=-125.0f,Y=0.0f,Z=100.0f);

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGE_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGEL_Near')
	BigExplosionSocket=VH_Death

	HudCoords=(U=826,V=0,UL=-81,VL=115)
	IconCoords=(U=886,UL=19,V=35,VL=30)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyHellbender'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyHellbender'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyHellbender'
}
