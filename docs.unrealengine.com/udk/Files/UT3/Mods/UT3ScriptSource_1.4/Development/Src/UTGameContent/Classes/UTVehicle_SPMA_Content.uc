/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_SPMA_Content extends UTVehicle_SPMA;

/** The Template of the Beam to use */
var ParticleSystem BeamTemplate;
/** sound of the moving turret while deployed*/
var SoundCue TurretMovementSound;

var MaterialInterface BurnOutMaterialTread[2];

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local ParticleSystemComponent ShockBeam;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	// Handle Beam Effects for the shock beam

	if (SeatIndex==0 && !IsZero(HitLocation))
	{
		ShockBeam = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, GetEffectLocation(SeatIndex));
		ShockBeam.SetVectorParameter('ShockBeamEnd', HitLocation);
	}
}

simulated function CauseMuzzleFlashLight(int SeatIndex)
{
	Super.CauseMuzzleFlashLight(SeatIndex);
	if (SeatIndex==1)
	{
		PlayAnim('Fire');
		VehicleEvent('DriverGun');
	}
	else if (SeatIndex==0)
	{
		VehicleEvent('PassengerGun');
	}
}

simulated function SitDriver( UTPawn UTP, int SeatIndex)
{
	Super.SitDriver(UTP,SeatIndex);
	if (SeatIndex == 0 && DeployedState == EDS_Undeployed )
	{
		PlayAnim( 'GetIn' );
	}
}

function PassengerLeave(int SeatIndex)
{
	Super.PassengerLeave(SeatIndex);
	if (SeatIndex == 0 && DeployedState == EDS_Undeployed)
	{
		PlayAnim( 'GetOut' );
	}
}

simulated function SetVehicleDeployed()
{
	Super.SetVehicleDeployed();

	// add turret motion sound
	if (WorldInfo.NetMode != NM_DedicatedServer && Seats[0].SeatMotionAudio == None && TurretMovementSound != None)
	{
		Seats[1].SeatMotionAudio = CreateAudioComponent(TurretMovementSound, false, true);
	}
}

simulated function SetVehicleUndeployed()
{
	Super.SetVehicleUndeployed();

	// remove turret motion sound/stop sound
	if (Seats[0].SeatMotionAudio != None)
	{
		Seats[0].SeatMotionAudio.Stop();
		Seats[0].SeatMotionAudio = None;
	}
}


simulated function SetBurnOut()
{
	local int TeamNum;

	TeamNum = GetTeamNum();

	if( TeamNum > 1 )
	{
		TeamNum = 0;
	}

	if (BurnOutMaterialTread[TeamNum] != None)
	{
		Mesh.SetMaterial( 1, BurnOutMaterialTread[TeamNum] );
	}

	// sets the MIC
	super.SetBurnOut();
}

simulated function TakeRadiusDamage( Controller InstigatedBy, float BaseDamage, float DamageRadius, class<DamageType> DamageType,
				float Momentum, vector HurtOrigin, bool bFullDamage, Actor DamageCauser )
{
	if ( Role < ROLE_Authority )
		return;

	// don't take damage from own combos
	if (DamageType != class'UTDmgType_SPMAShockChain' || InstigatedBy != Controller)
	{
		Super.TakeRadiusDamage(InstigatedBy, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bFullDamage, DamageCauser);
	}
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=100.0
		CollisionRadius=260.000000
		Translation=(X=0.0,Y=0.0,Z=100.0)
	End Object
	CylinderComponent=CollisionCylinder


	Begin Object Name=SVehicleMesh
		AnimSets(0)=AnimSet'VH_SPMA.Anims.VH_SPMA_Anims'
		SkeletalMesh=SkeletalMesh'VH_SPMA.Mesh.SK_VH_SPMA'
		PhysicsAsset=PhysicsAsset'VH_SPMA.Mesh.SK_VH_SPMA_Physics'
		AnimTreeTemplate=AnimTree'VH_SPMA.Anims.AT_VH_SPMA'
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled4=TRUE)
	End Object

	DrawScale=1.3

	// turret twist sound.
	TurretMovementSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_CannonRotate'

	Seats(0)={(	GunClass=class'UTVWeap_SPMAPassengerGun',
				GunSocket=(GunnerFireSocket),
				GunPivotPoints=(SecondaryTurret_YawLift),
				TurretVarPrefix="Gunner",
				TurretControls=(GunnerConstraint,GunnerYawConstraint),
				CameraTag=DriverViewSocket,
				CameraOffset=-320,
				CameraBaseOffset=(Z=16.0),
				SeatIconPos=(X=0.45,Y=0.25),
				WeaponEffects=((SocketName=GunnerFireSocket,Offset=(X=-25),Scale3D=(X=3.0,Y=3.0,Z=3.0)))
				)}

	Seats(1)={(	GunClass=class'UTVWeap_SPMACannon_Content',
				GunSocket=(TurretFireSocket),
				GunPivotPoints=(MainTurret_Yaw),
				TurretControls=(TurretConstraint,TurretYawConstraint),
				CameraTag=DriverViewSocket,
				CameraOffset=-320,
				SeatIconPos=(X=0.45,Y=0.70),
				MuzzleFlashLightClass=class'UTTankMuzzleFlash',
				WeaponEffects=((SocketName=TurretFireSocket,Offset=(X=-105),Scale3D=(X=12.0,Y=12.0,Z=12.0)))
				)}

	VehicleEffects(0)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_SPMA',EffectSocket=DamageSmoke_01)

	VehicleEffects(1)=(EffectStartTag=Deployed,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Piston_Smoke',EffectSocket=BraceA)
	VehicleEffects(2)=(EffectStartTag=Deployed,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Piston_Smoke',EffectSocket=BraceB)
	VehicleEffects(3)=(EffectStartTag=Deployed,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Piston_Smoke',EffectSocket=BraceC)
	VehicleEffects(4)=(EffectStartTag=Deployed,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Piston_Smoke',EffectSocket=BraceD)
	VehicleEffects(5)=(EffectStartTag=Deployed,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Piston_Smoke',EffectSocket=BraceE)
	VehicleEffects(6)=(EffectStartTag=Deployed,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Piston_Smoke',EffectSocket=BraceF)

	// Muzzle Flashes
	VehicleEffects(7)=(EffectStartTag=CannonFire,EffectTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_PrimaryMuzzleFlash',EffectSocket=TurretFireSocket)
	VehicleEffects(8)=(EffectStartTag=CameraFire,EffectTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_AltMuzzleFlash',EffectSocket=TurretFireSocket)
	VehicleEffects(9)=(EffectStartTag=ShockTurretFire,EffectTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_SecondGin_MF',EffectSocket=GunnerFireSocket)
	VehicleEffects(10)=(EffectStartTag=ShockTurretAltFire,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_DriverAltMuzzleFlash',EffectSocket=GunnerFireSocket)

	VehicleAnims(0)=(AnimTag=CannonFire,AnimSeqs=(Fire),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	VehicleAnims(1)=(AnimTag=CameraFire,AnimSeqs=(Fire),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)


	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Paladin_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dirt_Effects.P_Hellbender_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Paladin_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Paladin_Wheel_Snow')


	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=SPMAEngineSound
		SoundCue=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_EngineIdle'
	End Object
	EngineSound=SPMAEngineSound
	Components.Add(SPMAEngineSound);

	CollisionSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_EngineRampUp'
	ExitVehicleSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_EngineRampDown'

	// Initialize sound parameters.
	SquealThreshold=250.0
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	BeamTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam'

	IdleAnim(0)=InActiveStill
	IdleAnim(1)=ActiveStill
	DeployAnim(0)=Deploying
	DeployAnim(1)=UnDeploying
	TreadSpeedParameterName=Veh_Tread_Speed

	IconCoords=(U=918,UL=18,V=0,VL=35)

	DeploySound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Deploy'
	UndeploySound=Soundcue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Deploy'

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGE_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGEL_Near')
	BigExplosionSocket=VH_Death
	ExplosionSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Explode'
	HoverBoardAttachSockets=(HoverAttach00)

	PassengerTeamBeaconOffset=(X=100.0f,Y=15.0f,Z=50.0f)
	bHasTurretExplosion=true
	DestroyedTurretTemplate=StaticMesh'VH_SPMA.Mesh.S_VH_SPMA_Top'

	TurretExplosiveForce=2000

	HudCoords=(U=493,V=103,UL=-77,VL=135)
	TeamMaterials[0]=MaterialInstanceConstant'VH_SPMA.Materials.MI_VH_SPMA_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_SPMA.Materials.MI_VH_SPMA_Blue'
	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_SPMA.Materials.MI_VH_SPMA_Spawn_Red',MaterialInterface'VH_SPMA.Materials.MI_VH_SPMA_Spawn_Treads_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_SPMA.Materials.MI_VH_SPMA_Spawn_Blue',MaterialInterface'VH_SPMA.Materials.MI_VH_SPMA_Spawn_Treads_Blue'))
	BurnOutMaterial[0]=MaterialInterface'VH_SPMA.Materials.MITV_VH_SPMA_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_SPMA.Materials.MITV_VH_SPMA_Blue_BO'

	BurnOutMaterialTread[0]=MaterialInterface'VH_SPMA.Materials.MITV_VH_SPMA_Treads_Red_BO'
	BurnOutMaterialTread[1]=MaterialInterface'VH_SPMA.Materials.MITV_VH_SPMA_Treads_Blue_BO'

	DamageMorphTargets(0)=(InfluenceBone=RtFrontBumper_Support,MorphNodeName=none,Health=230,DamagePropNames=(Damage2,))
	DamageMorphTargets(1)=(InfluenceBone=LtFrontLegLow,MorphNodeName=none,Health=230,DamagePropNames=(Damage1))
	DamageMorphTargets(2)=(InfluenceBone=LtFrontLegLow,MorphNodeName=none,Health=230,DamagePropNames=(Damage1))
	DamageMorphTargets(3)=(InfluenceBone=LtRearFoot,MorphNodeName=none,Health=230,DamagePropNames=(Damage3))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.5)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyHellfire'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyHellfire'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyHellfire'

	ToolTipIconCoords=(U=2,V=371,UL=124,VL=115)
}
