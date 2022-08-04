/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_HellBenderPrimary extends UTVehicleWeapon
	HideDropDown;

var float	LastFireTime;
var float   ReChargeTime;


/**
  * returns true if should pass trace through this hitactor
  * turret ignores shock balls fired by hellbender driver
  */
simulated function bool PassThroughDamage(Actor HitActor)
{
	return HitActor.IsA('UTProj_VehicleShockBall') || HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume');
}

simulated function InstantFire()
{
	Super.InstantFire();
	LastFireTime = WorldInfo.TimeSeconds;
}

simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact )
{
	local float DamageMod;

	DamageMod = FClamp( (WorldInfo.TimeSeconds - LastFireTime), 0, RechargeTime);
	DamageMod = FClamp( (DamageMod / 3), 0.05, 1.0);

	// cause damage to locally authoritative actors
	if (Impact.HitActor != None && Impact.HitActor.Role == ROLE_Authority)
	{
		Impact.HitActor.TakeDamage(	InstantHitDamage[CurrentFireMode] * DamageMod,
									Instigator.Controller,
									Impact.HitLocation,
									InstantHitMomentum[FiringMode] * Impact.RayDir,
									InstantHitDamageTypes[FiringMode],
									Impact.HitInfo,
									self );
	}
}

defaultproperties
{
 	WeaponFireTypes(0)=EWFT_InstantHit
 	WeaponFireTypes(1)=EWFT_None
	bInstantHit=true
	InstantHitDamageTypes(0)=class'UTDmgType_HellBenderPrimary'
	WeaponFireSnd[0]=SoundCue'A_Vehicle_Hellbender.SoundCues.A_Vehicle_Hellbender_TurretFire'
	FireInterval(0)=+0.5
	Spread(0)=0.00
	InstantHitDamage(0)=120
	ShotCost(0)=0
	bFastRepeater=true

	ShotCost(1)=0

	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_SecondImpact',Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')

	FireTriggerTags=(BackTurretFire)

	bZoomedFireMode(1)=1

	ZoomedTargetFOV=33.0
	ZoomedRate=60.0

	RechargeTime = 3.0;

	VehicleClass=class'UTVehicle_Hellbender_Content'
}

