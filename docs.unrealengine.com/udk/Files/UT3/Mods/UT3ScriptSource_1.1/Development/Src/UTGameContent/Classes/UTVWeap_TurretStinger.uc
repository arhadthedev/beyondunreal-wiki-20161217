/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_TurretStinger extends UTVehicleWeapon
		HideDropDown;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_TurretShard'
	FireInterval(0)=+0.1
	WeaponFireSnd[0]=SoundCue'A_Weapon_Stinger.Weapons.A_Weapon_Stinger_FireAltCue'
	WeaponFireTypes(1)=EWFT_None
	bZoomedFireMode(1)=1
	ZoomedTargetFOV=20.0
	ZoomedRate=60.0
	FireTriggerTags=(TurretFireRight, TurretFireLeft)
	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_PrimeAltImpact',Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')
	VehicleClass=class'UTVehicle_ShieldedTurret_Stinger'
}
