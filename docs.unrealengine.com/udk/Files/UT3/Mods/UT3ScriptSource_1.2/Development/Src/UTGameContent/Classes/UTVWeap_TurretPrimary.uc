/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_TurretPrimary extends UTVehicleWeapon
	HideDropDown;

var float ZoomStep;
var float ZoomMinFOV;

defaultproperties
{
 	WeaponFireTypes(0)=EWFT_InstantHit
 	WeaponFireTypes(1)=EWFT_None
	bInstantHit=true
	InstantHitDamageTypes(0)=class'UTDmgType_TurretPrimary'
	WeaponFireSnd[0]=SoundCue'A_Vehicle_Turret.Cue.AxonTurret_FireCue'
	FireInterval(0)=+0.22
	Spread(0)=0.0
	InstantHitDamage(0)=34
	InstantHitMomentum(0)=50000.0
	ShotCost(0)=0
	AimError=650

	ShotCost(1)=0
	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Turret.Effects.P_VH_Turret_Impact',Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')
	BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'

	FireTriggerTags=(FireUL,FireUR,FireLL,FireLR)

	bZoomedFireMode(1)=1

	ZoomedTargetFOV=12.0
	ZoomedRate=60.0

	bPlaySoundFromSocket=true
	bFastRepeater=true
	VehicleClass=class'UTVehicle_Turret'
}
