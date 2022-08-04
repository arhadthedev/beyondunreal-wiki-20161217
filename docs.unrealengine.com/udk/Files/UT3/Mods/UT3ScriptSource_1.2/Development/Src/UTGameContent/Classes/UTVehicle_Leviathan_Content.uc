/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Leviathan_Content extends UTVehicle_Leviathan;

/** The set of all MIs for the Leviathan for both teams **/
var array<MaterialInterface> BurnOutMaterialLeviathan;


simulated function SetBurnOut()
{
	local int TeamNum;

	TeamNum = GetTeamNum();

	if( TeamNum > 1 )
	{
		TeamNum = 0;
	}

	if( TeamNum == 0 )
	{
		Mesh.SetMaterial( 0, BurnOutMaterialLeviathan[0] );
		Mesh.SetMaterial( 1, BurnOutMaterialLeviathan[1] );
		Mesh.SetMaterial( 2, BurnOutMaterialLeviathan[2] );
		Mesh.SetMaterial( 3, BurnOutMaterialLeviathan[3] );
		Mesh.SetMaterial( 4, BurnOutMaterialLeviathan[4] );
		Mesh.SetMaterial( 5, BurnOutMaterialLeviathan[5] );
	}
	else
	{
		Mesh.SetMaterial( 0, BurnOutMaterialLeviathan[6] );
		Mesh.SetMaterial( 1, BurnOutMaterialLeviathan[7] );
		Mesh.SetMaterial( 2, BurnOutMaterialLeviathan[8] );
		Mesh.SetMaterial( 3, BurnOutMaterialLeviathan[9] );
		Mesh.SetMaterial( 4, BurnOutMaterialLeviathan[10] );
		Mesh.SetMaterial( 5, BurnOutMaterialLeviathan[11] );
	}


	// call the super which will "Reset" the first material (which is okie as it is just setting the same thing
	// and then it will create all of the MICs which allow us to do our burnout effect
	super.SetBurnOut();
}

simulated function ApplyWeaponEffects(int OverlayFlags, optional int SeatIndex)
{
	Super.ApplyWeaponEffects(OverlayFlags, SeatIndex);

	if (SeatIndex == 0)
	{
		if (Seats[0].WeaponEffects[0].Effect != None)
		{
			Seats[0].WeaponEffects[0].Effect.SetHidden(DeployedState == EDS_Undeployed);
		}
		if (Seats[0].WeaponEffects[1].Effect != None)
		{
			Seats[0].WeaponEffects[1].Effect.SetHidden(DeployedState != EDS_Undeployed);
		}
		if (Seats[0].WeaponEffects[2].Effect != None)
		{
			Seats[0].WeaponEffects[2].Effect.SetHidden(DeployedState != EDS_Undeployed);
		}
	}
}

simulated function DeployedStateChanged()
{
	Super.DeployedStateChanged();

	if (Seats[0].WeaponEffects[0].Effect != None)
	{
		Seats[0].WeaponEffects[0].Effect.SetHidden(DeployedState != EDS_Undeployed);
	}
	if (Seats[0].WeaponEffects[1].Effect != None)
	{
		Seats[0].WeaponEffects[1].Effect.SetHidden(DeployedState == EDS_Undeployed);
	}
	if (Seats[0].WeaponEffects[2].Effect != None)
	{
		Seats[0].WeaponEffects[2].Effect.SetHidden(DeployedState == EDS_Undeployed);
	}
}


/** Stops the big beam from firing. */
simulated function AbortBigBeam()
{
	local UTVWeap_LeviathanPrimary LevGun;

	if(BigBeamEmitter != None)
	{
		BigBeamEmitter.DeactivateSystem();
		BigBeamEmitter.KillParticlesForced();
	}

	if(Role == ROLE_Authority && Seats[0].Gun != None)
	{
		LevGun = UTVWeap_LeviathanPrimary(Seats[0].Gun);
		LevGun.GotoState('WeaponRecharge');
		LevGun.ClientHasFired();
	}
}

simulated function BlowupVehicle()
{
	Super.BlowupVehicle();
	AbortBigBeam();
}

simulated function SetVehicleUndeploying()
{
	Super.SetVehicleUndeploying();
	AbortBigBeam();
}

defaultproperties
{
	IconCoords=(U=936,UL=29,V=0,VL=47)
	MapSize=1.15

	Begin Object Name=CollisionCylinder
		// not even close to big enough, but this is as big as the path network supports
		CollisionHeight=+100.0
		CollisionRadius=+260.0
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Leviathan.Mesh.SK_VH_Leviathan'
		PhysicsAsset=PhysicsAsset'VH_Leviathan.Mesh.SK_VH_Leviathan_Physics'
		AnimTreeTemplate=AnimTree'VH_Leviathan.Anims.AT_VH_Leviathan'
		AnimSets.Add(AnimSet'VH_Leviathan.Anims.K_VH_Leviathan')
	//Needs to be turned on when deployed for BigBeamEmitter
		bForceUpdateAttachmentsInTick=FALSE;
	End Object

	Begin Object Class=UTVehicleWheel Name=RtRWheel
	    BoneName=Rt_Rear_Tire
		BoneOffset=(X=0.0,Y=40.0,Z=0.0)
		WheelRadius=90
		SuspensionTravel=40
		bPoweredWheel=true
		SteerFactor=0.0
		SkelControlName=Rt_Rear_Wheel
		WheelParticleSystem=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_Wheel_Snow'
		LongSlipFactor=12000
		bDisableWheelOnDeath=TRUE
	End Object
	Wheels(0)=RtRWheel

	Begin Object Class=UTVehicleWheel Name=LtRWheel
	    BoneName=Lt_Rear_Tire
		BoneOffset=(X=0.0,Y=-40.0,Z=0)
		WheelRadius=90
		SuspensionTravel=40
		bPoweredWheel=true
		SteerFactor=0.0
		SkelControlName=Lt_Rear_Wheel
		WheelParticleSystem=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_Wheel_Snow'
		LongSlipFactor=12000
		bDisableWheelOnDeath=TRUE
	End Object
	Wheels(1)=LtRWheel

	Begin Object Class=UTVehicleWheel Name=RtMWheel
    	BoneName=Rt_Mid_Tire
		BoneOffset=(X=0.0,Y=40.0,Z=0)
		WheelRadius=90
		SuspensionTravel=40
		bPoweredWheel=true
		SteerFactor=0.0
		SkelControlName=Rt_Mid_Wheel
		WheelParticleSystem=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_Wheel_Snow'
		LongSlipFactor=12000
		bDisableWheelOnDeath=TRUE
	End Object
	Wheels(2)=RtMWheel

	Begin Object Class=UTVehicleWheel Name=LtMWheel
    	BoneName=Lt_Mid_Tire
		BoneOffset=(X=0.0,Y=-40.0,Z=0)
		WheelRadius=90
		SuspensionTravel=40
		bPoweredWheel=true
		SteerFactor=0.0
		SkelControlName=Lt_Mid_Wheel
		WheelParticleSystem=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_Wheel_Snow'
		LongSlipFactor=12000
		bDisableWheelOnDeath=TRUE
	End Object
	Wheels(3)=LtMWheel

	Begin Object Class=UTVehicleWheel Name=RtFWheel
    	BoneName=Rt_Front_Tire
		BoneOffset=(X=0.0,Y=130.0,Z=-10.0)
		WheelRadius=100
		SuspensionTravel=40
		bPoweredWheel=true
		SteerFactor=1.0
		SkelControlName=Rt_Front_Wheel
		WheelParticleSystem=ParticleSystem'P_VH_Leviathan_Wheel_Snow'
		LongSlipFactor=12000
		bDisableWheelOnDeath=TRUE
	End Object
	Wheels(4)=RtFWheel

	Begin Object Class=UTVehicleWheel Name=LtFWheel
    	BoneName=Lt_Front_Tire
		BoneOffset=(X=0.0,Y=-130,Z=-10.0)
		WheelRadius=100
		SuspensionTravel=40
		bPoweredWheel=true
		SteerFactor=1.0
		SkelControlName=Lt_Front_Wheel
		WheelParticleSystem=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_Wheel_Snow'
		LongSlipFactor=12000
		bDisableWheelOnDeath=TRUE
	End Object
	Wheels(5)=LtFWheel

	Begin Object Class=UTVehicleWheel Name=CenterWheel //fake wheel to help prevent getting stuck
    	BoneName=Body
		SkelControlName=Body
		BoneOffset=(X=-30.0,Y=0.0,Z=-50.0)
		WheelRadius=75
		SuspensionTravel=200
		bPoweredWheel=true
		SteerFactor=0.0
		LongSlipFactor=12000
		bDisableWheelOnDeath=TRUE
	End Object
	Wheels(6) = Centerwheel;

	Begin Object Class=CylinderComponent Name=TurretCollisionCylinderLF
	    CollisionRadius=+0068.000000
		CollisionHeight=+0074.000000
		Translation=(Z=48)
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	TurretCollision(0)=TurretCollisionCylinderLF

	Begin Object Class=CylinderComponent Name=TurretCollisionCylinderRF
	    CollisionRadius=+0068.000000
		CollisionHeight=+0074.000000
		Translation=(Z=48)
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	TurretCollision(1)=TurretCollisionCylinderRF

	Begin Object Class=CylinderComponent Name=TurretCollisionCylinderLR
	    CollisionRadius=+0068.000000
		CollisionHeight=+0074.000000
		Translation=(Z=48)
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	TurretCollision(2)=TurretCollisionCylinderLR

	Begin Object Class=CylinderComponent Name=TurretCollisionCylinderRR
	    CollisionRadius=+0068.000000
		CollisionHeight=+0074.000000
		Translation=(Z=48)
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	TurretCollision(3)=TurretCollisionCylinderRR

	DrawScale=1.25

	Seats(0)={(	GunClass=class'UTVWeap_LeviathanPrimary',
				GunSocket=(Lt_DriverBarrel,Rt_DriverBarrel),
				TurretVarPrefix="",
				TurretControls=(DriverTurret_Yaw,DriverTurret_Pitch),
				GunPivotPoints=(DriverTurretYaw,MainTurretYaw),
				MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight',
				SeatIconPos=(X=0.445,Y=0.45),
				CameraTag=DriverCamera,
				CameraOffset=-800,
				CameraBaseOffset=(Z=35.0),
				WeaponEffects=((SocketName=BigGunBarrel,Offset=(X=-240),Scale3D=(X=30.0,Y=30.0,Z=30.0)),(SocketName=Lt_DriverBarrel,Offset=(X=-35,Y=-3),Scale3D=(X=6.0,Y=6.0,Z=6.0)),(SocketName=Rt_DriverBarrel,Offset=(X=-35,Y=-3),Scale3D=(X=6.0,Y=6.0,Z=6.0)))
				)}

	Seats(1)={( GunClass=class'UTVWeap_LeviathanTurretBeam',
				GunSocket=(LF_TurretBarrel_L,LF_TurretBarrel_R),
				CameraTag=LF_TurretCamera,
				TurretVarPrefix="LFTurret",
				CameraEyeHeight=50,
				CameraOffset=-25,
				CameraBaseOffset=(Z=-15),
				bSeatVisible=true,
				SeatOffset=(X=4,Z=72),
				SeatBone=LT_Front_TurretPitch,
				TurretControls=(LT_Front_TurretYaw,LT_Front_TurretPitch),
				GunPivotPoints=(Lt_Front_TurretYaw,Lt_Front_TurretYaw),
				MuzzleFlashLightClass=class'UTGame.UTTurretMuzzleFlashLight',
				SeatIconPos=(X=0.235,Y=0.15),
				ViewPitchMin=-10402,
				DriverDamageMult=0.1,
				WeaponEffects=((SocketName=LF_TurretBarrel_R,Offset=(X=-30,Y=-10,Z=3),Scale3D=(X=5.0,Y=8.0,Z=8.0)))
				)}

	Seats(2)={( GunClass=class'UTVWeap_LeviathanTurretRocket',
				GunSocket=(RF_TurretBarrel,RF_TurretBarrel,RF_TurretBarrel),
				TurretVarPrefix="RFTurret",
				SeatOffset=(X=4,Z=72),
				CameraEyeHeight=50,
				CameraOffset=-25,
				CameraBaseOffset=(Z=-15),
				bSeatVisible=true,
				SeatBone=RT_Front_TurretPitch,
				TurretControls=(RT_Front_TurretYaw,RT_Front_TurretPitch),
				GunPivotPoints=(Rt_Front_TurretYaw,Rt_Front_TurretYaw),
				CameraTag=RF_TurretCamera,
				MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight',
				ViewPitchMin=-10402,
				SeatIconPos=(X=0.635,Y=0.15),
				DriverDamageMult=0.1,
				WeaponEffects=((SocketName=RF_TurretBarrel,Offset=(X=-30),Scale3D=(X=5.0,Y=8.0,Z=8.0)))
				)}

	Seats(3)={( GunClass=class'UTVWeap_LeviathanTurretStinger',
				GunSocket=(LR_TurretBarrel),
				TurretVarPrefix="LRTurret",
				CameraEyeHeight=50,
				CameraOffset=-25,
				CameraBaseOffset=(Z=-15),
				bSeatVisible=true,
				SeatBone=LT_Rear_TurretPitch,
				SeatOffset=(X=4,Z=72),
				TurretControls=(LT_Rear_TurretYaw,LT_Rear_TurretPitch),
				GunPivotPoints=(Lt_Rear_TurretYaw,Lt_Rear_TurretYaw),
				CameraTag=LR_TurretCamera,
				MuzzleFlashLightClass=class'UTStingerTurretMuzzleFlashLight',
				SeatIconPos=(X=0.235,Y=0.75),
				ViewPitchMin=-10402,
				DriverDamageMult=0.1,
				WeaponEffects=((SocketName=LR_TurretBarrel,Offset=(X=-30),Scale3D=(X=5.0,Y=8.0,Z=8.0)))
				)}

	Seats(4)={( GunClass=class'UTVWeap_LeviathanTurretShock',
				GunSocket=(RR_TurretBarrel),
				TurretVarPrefix="RRTurret",
				TurretControls=(RT_Rear_TurretYaw,RT_Rear_TurretPitch),
				CameraEyeHeight=50,
				CameraOffset=-25,
				CameraBaseOffset=(Z=-15),
				bSeatVisible=true,
				SeatOffset=(X=4,Z=72),
				SeatIconPos=(X=0.635,Y=0.75),
				SeatBone=RT_Rear_TurretPitch,
				GunPivotPoints=(Rt_Rear_TurretPitch,Rt_Rear_TurretPitch),
				CameraTag=RR_TurretCamera,
				ViewPitchMin=-10402,
				DriverDamageMult=0.1,
				WeaponEffects=((SocketName=RR_TurretBarrel,Offset=(X=-30),Scale3D=(X=5.0,Y=8.0,Z=8.0)))
				)}

	LookForwardDist=120.0

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=EngineIdleSound
		SoundCue=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_EngineIdle'
	End Object
	EngineSound=EngineIdleSound
	Components.Add(EngineIdleSound);

	CollisionSound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_EngineStart'
	ExitVehicleSound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_EngineStop'

	// Initialize sound parameters.
	SquealThreshold=0.05
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	VehicleEffects(0)=(EffectStartTag=Damage0Smoke,EffectEndTag=NoDamage0Smoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=LF_TurretDamageSmoke)
	VehicleEffects(1)=(EffectStartTag=Damage1Smoke,EffectEndTag=NoDamage1Smoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=RF_TurretDamageSmoke)
	VehicleEffects(2)=(EffectStartTag=Damage2Smoke,EffectEndTag=NoDamage2Smoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=LR_TurretDamageSmoke)
	VehicleEffects(3)=(EffectStartTag=Damage3Smoke,EffectEndTag=NoDamage3Smoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=RR_TurretDamageSmoke)

	VehicleEffects(4)=(EffectStartTag=StartDeploy,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_Deploy',EffectSocket=DeployEffectSocket)

	VehicleEffects(5)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.PS_Leviathan_Exhaust_Smoke',EffectSocket=ExhaustSocket)
	VehicleEffects(6)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.PS_Leviathan_Exhaust_Smoke',EffectSocket=ExhaustSocketB)

	// Weapon Muzzle Flashes

	VehicleEffects(7)=(EffectStartTag=TurretBeamMF_L,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_TurretBeamMF',EffectSocket=LF_TurretBarrel_L)
	VehicleEffects(8)=(EffectStartTag=TurretBeamMF_R,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_TurretBeamMF',EffectSocket=LF_TurretBarrel_R)
	VehicleEffects(9)=(EffectStartTag=TurretRocketMF,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_TurretRocketMF',EffectSocket=RF_TurretBarrel)
	VehicleEffects(10)=(EffectStartTag=TurretStingerMF,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_TurretStingerMF',EffectSocket=LR_TurretBarrel)
	VehicleEffects(11)=(EffectStartTag=TurretShockMF,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_TurretShockMF',EffectSocket=RR_TurretBarrel)

	VehicleEffects(12)=(EffectStartTag=DriverMF_L,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.PS_VH_Leviathan_DriverMF',EffectSocket=Lt_DriverBarrel)
	VehicleEffects(13)=(EffectStartTag=DriverMF_R,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.PS_VH_Leviathan_DriverMF',EffectSocket=Rt_DriverBarrel)

	VehicleEffects(14)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Leviathan',EffectSocket=DamageSmoke_01)

	TurretExplosionTemplate=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_Leviathan_Guns'
	BigExplosionTemplates[0]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Far',MinDistance=2200.0)
	BigExplosionTemplates[1]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Mid',MinDistance=1500.0)
	BigExplosionTemplates[2]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Near',MinDistance=0.0)

	ExplosionDamage=150.0
	ExplosionRadius=1000.0
	ExplosionMomentum=125000

	TeamBeaconOffset=(z=300.0)

	IdleAnim(0)=InActiveStill
	IdleAnim(1)=ActiveStill
	GetInAnim(0)=none
	GetOutAnim(0)=none
	DeployAnim(0)=Deploying
	DeployAnim(1)=UnDeploying

	DeployTime = 8.3667;
	UnDeployTime = 6.5;

	BeamTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_LaserBeam'
	BeamEndpointVarName=ShockBeamEnd

	BigBeamTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_BigBeam'
	BigBeamSocket=BigGunBarrel
	BigBeamEndpointVarName=BigBeamDest

	DeploySound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_Deploy'
	UndeploySound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_Deploy'

	BigBeamFiresound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_CannonFire'

	MainTurretPivot=MainTurretPitch
	DriverTurretPivot=DriverTurretYaw

	TurretExplosionSound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_BlowSection'
	TurretActivate=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_TurretActivate'
	TurretDeactivate=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_TurretDeactivate'
	DrivingAnim=Leviathan_idle_sitting

	ExplosionSound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_Explode'

	RumbleCameraAnim=CameraAnim'Camera_FX.Leviathan.C_VH_Leviathan_Ground_Rumble'
	RumbleRange=900.0

	HoverBoardAttachSockets=(HoverAttach00,HoverAttach01)

	ShieldClass=class'UTLeviathanShield'

	HudCoords=(U=743,V=0,UL=-97,VL=129)

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Red_Turret',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Red_1',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Red_2',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Red_Turret',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Red_Turret',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Red_Turret'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Blue_Turret',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Blue_1',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Blue_2',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Blue_Turret',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Blue_Turret',MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Spawn_Blue_Turret'))

	DamageMorphTargets(0)=(InfluenceBone=Front_SuspensionAim,MorphNodeName=none,LinkedMorphNodeName=none,Health=4500,DamagePropNames=(Damage3))
	DamageMorphTargets(1)=(InfluenceBone=Rt_RearSuspension,MorphNodeName=none,LinkedMorphNodeName=none,Health=4500,DamagePropNames=(Damage1))
	DamageMorphTargets(2)=(InfluenceBone=Lt_Mid_Foot,MorphNodeName=none,LinkedMorphNodeName=none,Health=4500,DamagePropNames=(Damage2))
	DamageMorphTargets(3)=(InfluenceBone=Rt_Mid_Foot,MorphNodeName=none,LinkedMorphNodeName=none,Health=4500,DamagePropNames=(Damage2))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.0)

	// this has so many hp the default % don't give a good estimation given the amount of damage you can do
	DamageSmokeThreshold=0.90
	FireDamageThreshold=0.80

	TeamMaterials[0]=MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Red_1'
	TeamMaterials[1]=MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Blue_1'

	TeamMatSec[0]=MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Red_2'
	TeamMatSec[1]=MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Blue_2'

	TurretMaterial[0]=MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Red_Turret'
	TurretMaterial[1]=MaterialInterface'VH_Leviathan.Materials.MI_VH_Levi_Blue_Turret'

	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_ManTheLeviathan')


	//RED
	BurnOutMaterial(0)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Red_Turret_BO'
	BurnOutMaterialLeviathan(0)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Red_Turret_BO'
	BurnOutMaterialLeviathan(1)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Red_1_BO'
	BurnOutMaterialLeviathan(2)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Red_2_BO'
	BurnOutMaterialLeviathan(3)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Red_Turret_BO'
	BurnOutMaterialLeviathan(4)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Red_Turret_BO'
	BurnOutMaterialLeviathan(5)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Red_Turret_BO'


	// BLUE
	BurnOutMaterial(1)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Blue_Turret_BO'
	BurnOutMaterialLeviathan(6)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Blue_Turret_BO'
	BurnOutMaterialLeviathan(7)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Blue_1_BO'
	BurnOutMaterialLeviathan(8)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Blue_2_BO'
	BurnOutMaterialLeviathan(9)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Blue_Turret_BO'
	BurnOutMaterialLeviathan(10)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Blue_Turret_BO'
	BurnOutMaterialLeviathan(11)=MaterialInterface'VH_Leviathan.Materials.MITV_VH_Levi_Blue_Turret_BO'

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyLeviathan'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyLeviathan'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyLeviathan'
	VehicleDestroyedSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyLeviathanDestroyed'
	VehicleDestroyedSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyLeviathanDestroyed'
	VehicleDestroyedSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyLeviathanDestroyed'

	ToolTipIconCoords=(U=1,V=669,UL=152,VL=95)
}
