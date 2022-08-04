/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTShapedCharge extends UTDeployedActor
	abstract;

/** Countdown to explosion */
var int Count;

var vector FloorNormal;

/** Explosion effect */
var ParticleSystem ShapedChargeExplosion;

/** Class of ExplosionLight */
var class<UTExplosionLight> ExplosionLightClass;

/** The sound that is played when it explodes */
var SoundCue	ExplosionSound;

/** When the deployable has landed this system starts running*/
var ParticleSystemComponent	LandEffects;

var class<UTDamageType> ChargeDamageType;

/** explosion damage properties */
var int Damage;
var float DamageRadius, DamageMomentum;

var float ChargeColourBlend;

/** MIC for ramping colour */
var MaterialInstanceConstant	ChargeMI;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	ChargeMI = Mesh.CreateAndSetMaterialInstanceConstant(0);
}

event Landed(vector HitNormal, Actor HitActor)
{
	if(Role == ROLE_Authority)
	{
		FloorNormal = HitNormal;
		settimer(1.0, true, 'CountDown');
		SetPhysics(PHYS_None);
		PerformDeploy();
	}
}

simulated function PerformDeploy()
{
	bDeployed = true;
	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		if(LandEffects != none && !LandEffects.bIsActive)
		{
			LandEffects.SetActive(true);
		}
	}
}

function CountDown()
{
	Count--;

	if ( Count <= 0 )
	{
		// blow up
		Destroy();
	}
}

simulated function Tick(float DeltaTime)
{
	if( bDeployed )
	{
		ChargeColourBlend += (DeltaTime * 0.5);
		ChargeColourBlend = FClamp(ChargeColourBlend, 0.0, 1.0);
		ChargeMI.SetScalarParameterValue('SC_Fill', ChargeColourBlend);
	}
}

simulated function Destroyed()
{
	local rotator Dir;

	if ( Role == ROLE_Authority )
	{
		HurtRadius(Damage,DamageRadius, ChargeDamageType, DamageMomentum, Location);
	}
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		// spawn client side explosion effect
		if ( EffectIsRelevant(Location, false) )
		{
			Dir = rotator(FloorNormal);
			WorldInfo.MyEmitterPool.SpawnEmitter(ShapedChargeExplosion, Location, Dir);
			UTEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight( ExplosionLightClass,
						Location + (0.25 * ExplosionLightClass.default.TimeShift[0].Radius * (vect(1,0,0) >> Dir)) );
		}
		PlaySound(ExplosionSound, true);
	}

	super.Destroyed();
}

defaultproperties
{
	Damage=1200
	DamageRadius=500.0
	DamageMomentum=200000.0
	bOrientOnSlope=true

	Count=5.0
	LifeSpan=10.0
	ShapedChargeExplosion=ParticleSystem'VH_Goliath.Effects.PS_Goliath_Cannon_Impact_MID'
	ExplosionLightClass=class'UTGame.UTTankShellExplosionLight'
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	ChargeDamageType=class'UTDmgType_ShapedCharge'

	Begin Object Class=SkeletalMeshComponent Name=DeployableMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_ShapeCharge_1P'
		CollideActors=false
		BlockRigidBody=false
		BlockActors=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		Translation=(Z=0)
		Rotation=(Yaw=32768)
		bUseAsOccluder=false
		LightEnvironment=DeployedLightEnvironment
	End Object
	Mesh=DeployableMesh
	Components.Add(DeployableMesh)

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=0
		CollisionHeight=0
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

}
