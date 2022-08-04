/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTVehicle_Paladin extends UTVehicle;

/** actor used for the shield */
var UTPaladinShield ShockShield;
/** indicates whether or not the shield is currently active */
var repnotify bool bShieldActive;
/** used for replicating shield hits to make it flash on clients */
var repnotify byte ShieldHitCount;
/** replicates shield health to non owning clients for effects (0 to 1 float compressed to byte)*/
var repnotify byte ShieldHealthPct;

/** time between combo proximity explosion shots */
var float ComboFireInterval;
var float LastComboTime;
/** combo explosion damage properties */
var int ComboExplosionDamage;
var float ComboExplosionRadius, ComboExplosionMomentum;
/** combo explosion effects */
var ParticleSystem ComboExplosionTemplate;
var SoundCue ComboExplosionSound;
/** used to trigger combo effects on clients */
var repnotify byte ComboFlashCount;
/** camera anim played when doing the combo (firing player only) */
var CameraAnim ComboShake;

replication
{
	if (bNetDirty)
		bShieldActive, ShieldHitCount, ComboFlashCount;
	if (bShieldActive && !bNetOwner)
		ShieldHealthPct;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	ShockShield = Spawn(class'UTPaladinShield', self);
	ShockShield.SetBase(self,, Mesh, 'Shield_Pitch');
}

function bool ImportantVehicle()
{
	return true;
}

function IncomingMissile(Projectile P)
{
	local AIController C;

	C = AIController(Controller);
	if (C != None && C.Skill >= 2.0)
	{
		UTVWeap_PaladinGun(Weapon).ShieldAgainstIncoming(P);
	}
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	UTVWeap_PaladinGun(Weapon).ShieldAgainstIncoming();
	return false;
}

simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local vector ShieldHitLocation, ShieldHitNormal;

	if ( Role < ROLE_Authority )
		return;

	// don't take damage if the shield is active and it hit the shield component or skipped it for some reason but should have hit it
	if ( ShockShield == None || !(bShieldActive && ShockShield.bFullyActive ) ||
		( HitInfo.HitComponent != ShockShield.CollisionComponent && ( IsZero(Momentum) || HitLocation == Location || DamageType == None
								|| !ClassIsChildOf(DamageType, class'UTDamageType')
								|| !TraceComponent(ShieldHitLocation, ShieldHitNormal, ShockShield.CollisionComponent, HitLocation, HitLocation - 2000.f * Normal(Momentum)) ) ) )
	{
		// Don't take self inflicted damage from proximity explosion
		if (DamageType != class'UTDmgType_PaladinProximityExplosion' || EventInstigator != Controller)
		{
			Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
		}
	}
	else if ( !WorldInfo.GRI.OnSameTeam(self, EventInstigator) )
	{
		UTVWeap_PaladinGun(Weapon).NotifyShieldHit(Damage);
		ShieldHit();
	}
}

simulated function SetShieldActive(int SeatIndex, bool bNowActive)
{
	if (SeatIndex == 0)
	{
		bShieldActive = bNowActive;
		if (ShockShield != None)
		{
			ShockShield.SetActive(bNowActive);
		}
		if (!bNowActive)
		{
			ComboFlashCount = 0;
		}
	}
}

simulated function ShieldHit()
{
	// FIXME: play effects
	ShieldHitCount++;
}

simulated function bool OverrideBeginFire(byte FireModeNum)
{
	if (bShieldActive && FireModeNum == 0)
	{
		if (Role == ROLE_Authority && WorldInfo.TimeSeconds - LastComboTime >= ComboFireInterval)
		{
			ComboExplosion();
		}
		return true;
	}
	else
	{
		return false;
	}
}

simulated function ComboExplosion()
{
	local ParticleSystemComponent ProjExplosion;
	local UTPlayerController PC;

	LastComboTime = WorldInfo.TimeSeconds;

	HurtRadius(ComboExplosionDamage, ComboExplosionRadius, class'UTDmgType_PaladinProximityExplosion', ComboExplosionMomentum, Location, self);

	// play explosion effects
	PlaySound(ComboExplosionSound, true);
	if (WorldInfo.NetMode != NM_DedicatedServer && ComboExplosionTemplate != None && EffectIsRelevant(Location, false))
	{
		ProjExplosion = WorldInfo.MyEmitterPool.SpawnEmitter(ComboExplosionTemplate, Location, Rotation);
		ProjExplosion.SetScale(3.25);
	}
	PC = UTPlayerController(Controller);
	if (PC != None && PC.IsLocalPlayerController())
	{
		PC.PlayCameraAnim(ComboShake);
	}

	if (Role == ROLE_Authority)
	{
		ComboFlashCount++;
	}
}

simulated function ShieldHealthUpdated()
{
	if (ShockShield != None)
	{
		ShockShield.ShieldEffectComponent.SetFloatParameter(ShockShield.ShieldStrengthParam, ByteToFloat(ShieldHealthPct));
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bShieldActive')
	{
		SetShieldActive(0, bShieldActive);
	}
	else if (VarName == 'ShieldHitCount')
	{
		ShieldHit();
	}
	else if (VarName == 'ComboFlashCount')
	{
		if (ComboFlashCount != 0)
		{
			ComboExplosion();
		}
	}
	else if (VarName == 'ShieldHealthPct')
	{
		ShieldHealthUpdated();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function BlowupVehicle()
{
	if (ShockShield != None)
	{
		ShockShield.Destroy();
	}

	Super.BlowupVehicle();
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (ShockShield != None)
	{
		ShockShield.Destroy();
	}
}

/** @return whether the shield should be forced off because there's a wall in the way */
function bool IsShieldObstructed()
{
	local vector SocketLocation;
	local rotator SocketRotation;

	// check if center of shield is on the other side of a wall
	Mesh.GetSocketWorldLocationAndRotation('ShieldGen', SocketLocation, SocketRotation);
	return !FastTrace(SocketLocation + vector(SocketRotation) * 500.0, SocketLocation,, true);
}

/**
 * No muzzle flashlight on shield
 */
simulated function CauseMuzzleFlashLight(int SeatIndex)
{
	if ( bShieldActive )
		return;

	Super.CauseMuzzleFlashLight(SeatIndex);
}

function bool TooCloseToAttack(Actor Other)
{
	// never too close to hit Pawns because we can use the proximity blast
	return (Pawn(Other) == None && Super.TooCloseToAttack(Other));
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=100.0
		CollisionRadius=260.0
		Translation=(Z=100.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Paladin.Mesh.SK_VH_Paladin'
		AnimTreeTemplate=AnimTree'VH_Paladin.Anims.AT_VH_Paladin'
		PhysicsAsset=PhysicsAsset'VH_Paladin.Mesh.SK_VH_Paladin_Physics'
		MorphSets[0]=MorphTargetSet'VH_Paladin.Mesh.VH_Paladin_MorphTargets'
		AnimSets.Add(AnimSet'VH_Paladin.Anims.VH_Paladin_Anims')
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled4=TRUE)
	End Object

	DrawScale=1.35

	Seats(0)={(	GunClass=class'UTVWeap_PaladinGun',
				CameraTag=ViewSocket,
				CameraOffset=-400,
				TurretControls=(Turret_Yaw,Turret_Pitch,Shield_Pitch),
				GunSocket=(GunSocket),
				SeatIconPos=(X=0.43,Y=0.48),
				GunPivotPoints=(Turret_Yaw),
				MuzzleFlashLightClass=class'UTGame.UTShockComboExplosionLight',
				WeaponEffects=((SocketName=GunSocket,Offset=(X=-80),Scale3D=(X=10.0,Y=11.0,Z=11.0)))
				)}


	VehicleEffects(0)=(EffectStartTag=PrimaryFire,EffectTemplate=ParticleSystem'VH_Paladin.Effects.P_VH_Paladin_Muzzleflash',EffectSocket=GunSocket)
	VehicleEffects(1)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Paladin',EffectSocket=DamageSmoke_01)

	Health=800

	DriverDamageMult=0.0
	MomentumMult=0.8

	GroundSpeed=700.0
	AirSpeed=1000.0
	MaxSpeed=1200
	BaseEyeheight=40
	Eyeheight=40
	MaxDesireability=0.6
	ObjectiveGetOutDist=1500.0
	bDriverHoldsFlag=false
	bSeparateTurretFocus=true

	bCanFlip=false

	COMOffset=(x=0.0,y=0.0,z=-100.0)

	Begin Object Class=UTVehicleSimCar Name=SimObject
		WheelSuspensionStiffness=500.0
		WheelSuspensionDamping=6.0
		WheelSuspensionBias=0.0
		ChassisTorqueScale=0.1
		WheelInertia=0.75
		LSDFactor=1.0
		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=20.0),(InVal=700.0,OutVal=15.0)))
		SteerSpeed=90
		MaxBrakeTorque=75.0
		StopThreshold=100
		TorqueVSpeedCurve=(Points=((InVal=-300.0,OutVal=0.0),(InVal=0.0,OutVal=100.0),(InVal=1000.0,OutVal=0.0)))
		EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=500.0),(InVal=599.0,OutVal=5000.0),(InVal=600.0,OutVal=3000.0),(InVal=949.0,OutVal=5000.0),(InVal=950.0,OutVal=3000.0),(InVal=1100.0,OutVal=5000.0)))
		EngineBrakeFactor=0.1
		FrontalCollisionGripFactor=0.18
		HardTurnMotorTorque=1.0
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	// Engine sound.
	Begin Object Class=AudioComponent Name=PaladinEngineSound
		SoundCue=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_EngineLoop'
	End Object
	EngineSound=PaladinEngineSound
	Components.Add(PaladinEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_Stop'

	Begin Object Class=UTVehicleWheel Name=RRWheel
		BoneName="RtTire04"
		BoneOffset=(X=0.0,Y=35,Z=0.0)
		WheelRadius=40.0
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=-1.0
		SkelControlName="RtTire04"
		Side=SIDE_Right
	End Object
	Wheels(0)=RRWheel

	Begin Object Class=UTVehicleWheel Name=RMRWheel
		BoneName="RtTire03"
		BoneOffset=(X=0.0,Y=35,Z=0.0)
		WheelRadius=40.0
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=-0.5
		SkelControlName="RtTire03"
		Side=SIDE_Right
	End Object
	Wheels(1)=RMRWheel

	Begin Object Class=UTVehicleWheel Name=RMFWheel
		BoneName="RtTire02"
		BoneOffset=(X=0.0,Y=35,Z=0.0)
		WheelRadius=40.0
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=0.5
		SkelControlName="RtTire02"
		Side=SIDE_Right
	End Object
	Wheels(2)=RMFWheel

	Begin Object Class=UTVehicleWheel Name=RFWheel
		BoneName="RtTire01"
		BoneOffset=(X=0.0,Y=35,Z=0.0)
		WheelRadius=40.0
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=1.0
		SkelControlName="RtTire01"
		Side=SIDE_Right
	End Object
	Wheels(3)=RFWheel

	Begin Object Class=UTVehicleWheel Name=LRWheel
		BoneName="LtTire04"
		BoneOffset=(X=0.0,Y=-35,Z=0.0)
		WheelRadius=40.0
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=-1.0
		SkelControlName="LtTire04"
		Side=SIDE_Left
	End Object
	Wheels(4)=LRWheel

	Begin Object Class=UTVehicleWheel Name=LMRWheel
		BoneName="LtTire03"
		BoneOffset=(X=0.0,Y=-35,Z=0.0)
		WheelRadius=40.0
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=-0.5
		SkelControlName="LtTire03"
		Side=SIDE_Left
	End Object
	Wheels(5)=LMRWheel

	Begin Object Class=UTVehicleWheel Name=LMFWheel
		BoneName="LtTire02"
		BoneOffset=(X=0.0,Y=-35,Z=0.0)
		WheelRadius=40.0
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=0.5
		SkelControlName="LtTire02"
		Side=SIDE_Left
	End Object
	Wheels(6)=LMFWheel

	Begin Object Class=UTVehicleWheel Name=LFWheel
		BoneName="LtTire01"
		BoneOffset=(X=0.0,Y=-35,Z=0.0)
		WheelRadius=40.0
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=1.0
		SkelControlName="LtTire01"
		Side=SIDE_Left
	End Object
	Wheels(7)=LFWheel

	TeamMaterials[0]=MaterialInstanceConstant'VH_Paladin.Materials.MI_VH_Paladin_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Paladin.Materials.MI_VH_Paladin_Blue'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Paladin.Materials.MI_VH_Paladin_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Paladin.Materials.MI_VH_Paladin_Spawn_Blue'))

	BurnOutMaterial[0]=MaterialInterface'VH_Paladin.Materials.MITV_VH_Paladin_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Paladin.Materials.MITV_VH_Paladin_Blue_BO'

	RespawnTime=45.0
	FlagBone=RtAntenna03
	FlagOffset=(Z=30.0)

	bStickDeflectionThrottle=true
	bLookSteerOnNormalControls=false
	bLookSteerOnSimpleControls=true
	LeftStickDirDeadZone=0.1
	ConsoleSteerScale=1.0

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGE_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGEL_Near')
	BigExplosionSocket=VH_Death
	ExplosionSound=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_Explode'
	HoverBoardAttachSockets=(HoverAttach00,HoverAttach01)

	DamageMorphTargets(0)=(InfluenceBone=LtFrontBumper,MorphNodeName=MorphNodeWPaladinFront,LinkedMorphNodeName=none,Health=310,DamagePropNames=(Damage2,Damage3))
	DamageMorphTargets(1)=(InfluenceBone=Body,MorphNodeName=MorphNodeWPaladinSide,LinkedMorphNodeName=none,Health=310,DamagePropNames=(Damage2,Damage1,Damage3))
	DamageMorphTargets(2)=(InfluenceBone=LtRearBumper,MorphNodeName=MorphNodeWPaladinRear,LinkedMorphNodeName=none,Health=310,DamagePropNames=(Damage2,Damage3))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.5)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.5)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=3.0)

	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Paladin_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dirt_Effects.P_Hellbender_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Paladin_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Paladin_Wheel_Snow')

	bHasTurretExplosion=true;
	DestroyedTurretTemplate=StaticMesh'VH_Paladin.Mesh.S_VH_Paladin_Top'

	HUDExtent=140.0
	TurretExplosiveForce=5000.0f

	HudCoords=(U=653,V=129,UL=-80,VL=126)

	ComboFireInterval=2.35
	ComboExplosionDamage=200
	ComboExplosionRadius=900
	ComboExplosionMomentum=150000
	ComboExplosionTemplate=ParticleSystem'VH_Paladin.Particles.P_VH_Paladin_ProximityExplosion'
	ComboExplosionSound=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_ComboExplosion'
	ComboShake=CameraAnim'VH_Paladin.Effects.PP_Paladin_Burst'

	IconCoords=(U=965,UL=22,V=0,VL=36)

	DrivingPhysicalMaterial=PhysicalMaterial'VH_Paladin.materials.physmat_Paladin_driving'
	DefaultPhysicalMaterial=PhysicalMaterial'VH_Paladin.materials.physmat_Paladin'

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyPaladin'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyPaladin'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyPaladin'

	AIPurpose=AIP_Any
	LookForwardDist=70.0
	NonPreferredVehiclePathMultiplier=3.0

	HornIndex=1
	VehicleIndex=15
}
