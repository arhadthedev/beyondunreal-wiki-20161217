/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_TurretShockBall extends UTProj_ShockBall;

/** Holds a link to the weapon that fired this gun */
var repnotify UTVehicleWeapon InstigatorWeapon;
/** cached cast of InstigatorController for replication test */
var PlayerController InstigatorPlayerController;

replication
{
	// replicate InstigatorWeapon only to the player that fired it
	if (bNetInitial && (InstigatorWeapon == None || WorldInfo.ReplicationViewers.Find('InViewer', InstigatorPlayerController) != INDEX_NONE))
		InstigatorWeapon;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	InstigatorPlayerController = PlayerController(InstigatorController);
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'InstigatorWeapon')
	{
		if (InstigatorWeapon != None)
		{
			InstigatorWeapon.AimingTraceIgnoredActors[InstigatorWeapon.AimingTraceIgnoredActors.Length] = self;
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (InstigatorWeapon != None)
	{
		InstigatorWeapon.AimingTraceIgnoredActors.RemoveItem(self);
	}
}

/**
 * Explode this Projectile
 */
simulated function Explode(vector HitLocation, vector HitNormal)
{
	ComboExplosion();
}

defaultproperties
{
	Speed=1500
	MaxSpeed=1500
	Damage=45
	DamageRadius=128
	MomentumTransfer=70000
	ComboDamageType=class'UTDmgType_TurretShockBall'
	MyDamageType=class'UTDmgType_TurretShockBall'
	CheckRadius=300.0
	ComboDamage=120
	bWideCheck=true

	ProjFlightTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_ShockBall'
	ProjExplosionTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_ShockBallImpact'
	ComboTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_ShockballCombo'

	Begin Object Name=CollisionCylinder
		CollisionRadius=10
		CollisionHeight=10
	End Object
}
