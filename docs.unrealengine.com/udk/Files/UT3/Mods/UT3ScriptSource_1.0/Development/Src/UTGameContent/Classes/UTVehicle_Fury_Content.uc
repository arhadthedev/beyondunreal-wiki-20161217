/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Fury_Content extends UTVehicle_Fury;

/** dynamic light which moves around following primary fire beam impact point */
var UTFuryBeamLight BeamLight;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	AnimPlayer = UTAnimNodeSequence(Mesh.FindAnimNode('AnimPlayer'));
	BlendNode = AnimNodeBlend(Mesh.FindAnimNode('LandBlend'));

	ArmBlendNodes[0] = UTAnimBlendByCollision( Mesh.FindAnimNode('UpRtBlend') );
	ArmBlendNodes[1] = UTAnimBlendByCollision( Mesh.FindAnimNode('UpLtBlend') );
	ArmBlendNodes[2] = UTAnimBlendByCollision( Mesh.FindAnimNode('LwRtBlend') );
	ArmBlendNodes[3] = UTAnimBlendByCollision( Mesh.FindAnimNode('LwLtBlend') );
}

simulated event PlayLanding()
{
 	Mesh.bForceDiscardRootMotion = false;
	AnimPlayer.PlayAnimation('Land',1.0,false);
	BlendNode.SetBlendTarget(1.0, 0.25);
}

simulated event PlayTakeOff()
{
	AnimPlayer.PlayAnimation('TakeOff',1.0,false);
	BlendNode.SetBlendTarget(0.0,TakeOffRate);
}

event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	Super.OnAnimEnd(SeqNode, PlayedTime, ExcessTime);
	if (SeqNode.AnimSeqName == 'TakeOff')
	{
		Mesh.bForceDiscardRootMotion = true;
	}
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (BeamLight != None)
	{
		BeamLight.Destroy();
	}
}

simulated function KillBeamEmitter()
{
	Super.KillBeamEmitter();
	if (BeamLight != None)
	{
		BeamLight.Destroy();
	}
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	Super.SetBeamEmitterHidden(bHide);

	if (bHide && BeamLight != None)
	{
		BeamLight.AmbientSound.Stop();
		BeamLight.Destroy();
	}
}

simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
	Super.VehicleWeaponFired(bViaReplication,HitLocation,SeatIndex);

	if (WorldInfo.NetMode != NM_DedicatedServer && !IsZero(HitLocation))
	{
		if (BeamLight == None || BeamLight.bDeleteMe)
		{
			BeamLight = spawn(class'UTFuryBeamLight');
			BeamLight.AmbientSound.Play();
		}
		BeamLight.SetLocation(HitLocation + vect(0,0,128));
	}
}

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Fury.Mesh.SK_VH_Fury'
		PhysicsAsset=PhysicsAsset'VH_Fury.Mesh.SK_VH_Fury_Physics'
		AnimSets(0)=AnimSet'VH_Fury.Anims.K_VH_Fury'
		AnimTreeTemplate=AnimTree'VH_Fury.Anims.AT_VH_Fury'
		MorphSets[0]=MorphTargetSet'VH_Fury.Mesh.SK_VH_Fury_MorphTargets'
	End Object

	Seats(0)={(	GunClass=class'UTVWeap_FuryGun',
				GunSocket=(LeftCannonA,RightCannonA,LeftCannonB,RightCannonB,LeftCannonC,RightCannonC),
				TurretControls=(LeftTurretConstraint,RightTurretConstraint,LeftTentacleTurretConstraint,RightTentacleTurretConstraint),
				GunPivotPoints=(LeftCannon, RightCannon),
				SeatIconPos=(X=0.48,Y=0.5),
				CameraTag=None,
				CameraBaseOffset=(Z=100.0),
				CameraOffset=-400.0,
				WeaponEffects=((SocketName=ArmSocket0,Scale3D=(X=5.0,Y=8.0,Z=8.0)),(SocketName=ArmSocket1,Scale3D=(X=5.0,Y=8.0,Z=8.0)),(SocketName=ArmSocket2,Scale3D=(X=5.0,Y=8.0,Z=8.0)),(SocketName=ArmSocket3,Scale3D=(X=5.0,Y=8.0,Z=8.0)))
				)}

	// Engine sound.
	Begin Object Class=AudioComponent Name=FuryEngineSound
		SoundCue=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_EngineLoopCue'
	End Object
	EngineSound=FuryEngineSound
	Components.Add(FuryEngineSound);

	EnterVehicleSound=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_StartCue'
	ExitVehicleSound=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_StopCue'
	CollisionSound=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_Collide'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	DrawScale=1.3

	// Initialize sound parameters.
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	BoostCameraShake=CameraAnim'Camera_FX.VH_Fury.C_VH_Fury_Boost'

	GroundEffectIndices.Empty()

	BeamTemplate=particlesystem'VH_Fury.Effects.P_VH_Fury_AltBeam'
	BeamSockets(0)=ArmSocket0
	BeamSockets(1)=ArmSocket1
	BeamSockets(2)=ArmSocket2
	BeamSockets(3)=ArmSocket3
	EndPointParamName=LinkBeamEnd
	EndPointNormalParamName=FuryBeamTargetTangent
	EndPointNormalLength=-200.0

	Begin Object Class=AudioComponent name=BeamAmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	BeamAmbientSound=BeamAmbientSoundComponent
	Components.Add(BeamAmbientSoundComponent)

	Begin Object Class=AudioComponent name=BoostAmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	BoostComponent=BoostAmbientSoundComponent
	Components.Add(BoostAmbientSoundComponent)

	AfterburnerSound=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_ThrustCue'
	StrafeSound=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_StrafeCue'

	BeamFireSound=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_AltBeamCue'

	SpawnInSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeInNecris01Cue'
	SpawnOutSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeOutNecris01Cue'
	BeamStartSound=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_AltBeamStartCue'
	BeamStopSound=SoundCue'A_Vehicle_Fury.Cue.A_Vehicle_Fury_AltBeamStopCue'

	JetSFX(0)=(ExhaustTag=MainThrusters)
	JetSFX(1)=(ExhaustTag=LeftThrusters)
	JetSFX(2)=(ExhaustTag=RightThrusters)

	VehicleEffects(0)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Fury.Effects.P_VH_Fury_Exhaust',EffectTemplate_Blue=ParticleSystem'VH_Fury.Effects.P_VH_Fury_Exhaust_Blue',EffectSocket=ExhaustSocket)
	VehicleEffects(1)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Fury',EffectSocket=DamageSmoke_01)

	BoosterNames(0)=MainThrustersBoost
	BoosterNames(1)=LeftThrustersBoost
	BoosterNames(2)=RightThrustersBoost

	HoverBoardAttachSockets=(HoverAttach00,HoverAttach01)

	DrivingPhysicalMaterial=PhysicalMaterial'VH_Fury.materials.physmat_furydriving'
	DefaultPhysicalMaterial=PhysicalMaterial'VH_Fury.materials.physmat_fury'

	ReferenceMovementMesh=StaticMesh'Envy_Effects.Mesh.S_Air_Wind_Ball'

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Near')
	BigExplosionSocket=VH_Death

	DamageMorphTargets(0)=(InfluenceBone=Tail_Damage1,MorphNodeName=MorphNodeW_Bottom,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=Lt_Wing_Damage1,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
	DamageMorphTargets(2)=(InfluenceBone=Lt_Wing_Damage2,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
	DamageMorphTargets(3)=(InfluenceBone=Rt_Wing_Damage1,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
	DamageMorphTargets(4)=(InfluenceBone=Rt_Wing_Damage2,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
	DamageMorphTargets(5)=(InfluenceBone=Base_Animated,MorphNodeName=none,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage3))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=3.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=3.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=3.0)


	HudCoords=(U=543,V=0,UL=-147,VL=103)

	TeamMaterials[0]=MaterialInstanceConstant'VH_Fury.Materials.MI_VH_Fury_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Fury.Materials.MI_VH_Fury_Blue'

	BurnOutMaterial[0]=MaterialInterface'VH_Fury.Materials.MITV_VH_Fury_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Fury.Materials.MITV_VH_Fury_Blue_BO'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Fury.Materials.MI_VH_Fury_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Fury.Materials.MI_VH_Fury_Spawn_Blue'))

 	IconCoords=(U=858,UL=51,V=73,VL=20)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyFury'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyFury'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyFury'
}
