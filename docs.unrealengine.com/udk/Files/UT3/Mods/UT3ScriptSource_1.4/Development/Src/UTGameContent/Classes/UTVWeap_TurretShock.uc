/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_TurretShock extends UTVehicleWeapon
		HideDropDown;


simulated function Projectile ProjectileFire()
{
	local UTProj_TurretShockBall ShockBall;

	ShockBall = UTProj_TurretShockBall(Super.ProjectileFire());
	if (ShockBall != None)
	{
		ShockBall.InstigatorWeapon = self;
		AimingTraceIgnoredActors[AimingTraceIgnoredActors.length] = ShockBall;
	}
	return ShockBall;
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_TurretShockBall'
	FireInterval(0)=0.5
	WeaponFireTypes(1)=EWFT_None
	bZoomedFireMode(1)=1
	ZoomedTargetFOV=20.0
	ZoomedRate=60.0
	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	FireTriggerTags=(TurretFireRight, TurretFireLeft)
	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_PrimeAltImpact',Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')
	VehicleClass=class'UTVehicle_ShieldedTurret_Shock'
}
