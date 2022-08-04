/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_ScavengerBoltBase extends UTProjectile
	native;

/** # of times they can bounce before blowing up */
var int Bounces;

/** Current target being tracked */
var Actor TargetActor;

/** How far away bolt can detect a target */
var float DetectionRange;

/** How fast to accelerate towards target being seeked */
var float SeekingAcceleration;

/** Range that target can be attacked (squared) */
var float AttackRangeSq;

/** Max range for attacking target.  If bolt further than this from instigator, it returns */
var float MaxAttackRangeSq;

/** Damage beam effect */
var ParticleSystem BeamEffect;
var ParticleSystemComponent BeamEmitter;

var float LastValidTargetTime;

var float MaxValidationInterval;

var float LastDamageTime;

var name BeamEndName;

var float DamageFrequency;

var float FastHomeAccel;
var float SlowHomeAccel;

var float LastOwnerBounce;

var float LastValidTargetUpdateTime;

/** Cue to play when the bolt/drone thing fires its beam */
var const protected SoundCue BeamFireCue;



replication
{
	if ( bNetDirty )
		TargetActor;
}

simulated function PostBeginPlay()
{
	local UTGameReplicationInfo GRI;

	Super.PostBeginPlay();

	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	if ( (GRI != None) && GRI.bConsoleServer )
	{
		SetCollisionSize(28, 28);
	}
}

simulated function Landed(vector HitNormal, Actor FloorActor)
{
	HitWall(HitNormal, FloorActor, None);
}

simulated function bool FullySpawned()
{
	return (WorldInfo.TimeSeconds - CreationTime) > 1.0;
}

event KillBolt()
{
	Destroy();
}

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	bBlockedByInstigator = true;
	Acceleration = vect(0,0,0);

	if ( TargetActor == Wall )
	{
		Velocity = Velocity - 2.0 * HitNormal * (Velocity dot HitNormal);
	}
	else if ( (Bounces > 0) || (TargetActor == None) )
	{
		LastValidTargetUpdateTime = -1000.0;

		if ( Wall == Instigator )
		{
			Bounces = Default.Bounces;
			LastOwnerBounce = WorldInfo.TimeSeconds;
			Velocity = 300 * HitNormal;
		}
		else
		{
			if ( TargetActor != None )
			{
				PlaySound(ExplosionSound, true);
				Bounces--;
			}
			else
			{
				Bounces = Default.Bounces;
			}
			Velocity = Velocity - 2.0 * HitNormal * (Velocity dot HitNormal);
		}
	}
	else
	{
		bBounce = false;
		SetPhysics(PHYS_None);
		Explode(Location, HitNormal);
	}
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector x;
	if ( WorldInfo.NetMode != NM_DedicatedServer && EffectIsRelevant(Location,false,MaxEffectDistance) )
	{
		x = normal(Velocity cross HitNormal);
		x = normal(HitNormal cross x);

		WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(x));
		bSuppressExplosionFX = true; // so we don't get called again
	}

	if (ExplosionSound != None)
	{
		PlaySound(ExplosionSound, true);
	}
}

simulated function SetTargetActor( actor HitActor )
{
	local pawn TargetPawn;

	LastValidTargetTime = WorldInfo.TimeSeconds;

	if ( UTOnslaughtObjective(HitActor) != None )
	{
		TargetActor = HitActor;
		return;
	}
	TargetPawn = Pawn(HitActor);
	if ( (TargetPawn != None) && (TargetPawn.Health > 0) && !WorldInfo.GRI.OnSameTeam(Instigator, TargetPawn) )
	{
		TargetActor = TargetPawn;
	}

}

simulated event SpawnBeam()
{
	if ( BeamEmitter == None )
	{
		BeamEmitter = new(Outer) class'UTParticleSystemComponent';
		BeamEmitter.SetTemplate(BeamEffect);
		BeamEmitter.SetTickGroup( TG_PostAsyncWork );
		AttachComponent(BeamEmitter);
	}
	BeamEmitter.SetHidden(false);

	PlaySound(BeamFireCue);
}


event DealDamage(vector HitLocation)
{
	local UTOnslaughtObjective TargetNode;

	if ( (Instigator == None) || !FastTrace(Location, Instigator.Location) )
	{
		TargetActor = None;
		return;
	}
	TargetNode = UTOnslaughtObjective(TargetActor);
	LastDamageTime = WorldInfo.TimeSeconds;
	if ( (TargetNode != None) && WorldInfo.GRI.OnSameTeam(Instigator, TargetNode) )
	{

		TargetNode.HealDamage( Damage, InstigatorController, MyDamageType);
		if ( TargetNode.Health >= TargetNode.DamageCapacity )
		{
			TargetActor = None;
		}
	}
	else
	{
		// damage the target
		TargetActor.TakeDamage( Damage, InstigatorController, HitLocation, vect(0,0,0), MyDamageType,, self);
	}
}

simulated function ProcessTouch(Actor Other, vector HitLocation, vector HitNormal)
{
	if ( (UTProjectile(Other) != None) && !WorldInfo.GRI.OnSameTeam(Instigator, UTProjectile(Other).InstigatorController) && (Role == ROLE_Authority) )
	{
		Super.ProcessTouch(Other, HitLocation, HitNormal);
	}
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if ( (class<UTDamageType>(DamageType) != None) && (class<UTDamageType>(DamageType).default.DamageWeaponClass != None)
		&& !WorldInfo.GRI.OnSameTeam(EventInstigator,Instigator) )
	{
		Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
}

defaultproperties
{
	Bounces=8
	bBounce=true
	bRotationFollowsVelocity=true

    Speed=80
    MaxSpeed=1400
    AccelRate=0.0
	MaxValidationInterval=0.5
	bProjTarget=true

    Damage=30
    DamageRadius=0
    MomentumTransfer=0
	CheckRadius=0.0
    LifeSpan=0.0
	DetectionRange=1000
	SeekingAcceleration=2000
	AttackRangeSq=90000.0
	MaxAttackRangeSq=36000000.0

    bCollideWorld=true
	bNetTemporary=false

	Begin Object Name=CollisionCylinder
		CollisionRadius=16
		CollisionHeight=16
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object

	BeamEndName=LinkBeamEnd

	DamageFrequency=+0.2
	FastHomeAccel=2400.0
	SlowHomeAccel=2000.0
	bBlockedByInstigator=true

	BeamFireCue=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_DroneFire_Cue'
}
