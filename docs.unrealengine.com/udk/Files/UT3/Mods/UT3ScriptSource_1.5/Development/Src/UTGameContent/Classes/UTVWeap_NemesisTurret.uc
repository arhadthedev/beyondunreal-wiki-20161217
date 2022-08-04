/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_NemesisTurret extends UTVehicleWeapon
		HideDropDown;

defaultproperties
{
 	WeaponFireTypes(0)=EWFT_InstantHit
 	WeaponFireTypes(1)=EWFT_None

	InstantHitDamageTypes(0)=class'UTDmgType_NemesisBeam'
	WeaponFireSnd[0]=SoundCue'A_Vehicle_Nemesis.Cue.A_Vehicle_Nemesis_TurretFireCue'
	FireInterval(0)=+0.36
	Spread(0)=0.0
	InstantHitDamage(0)=50
	InstantHitMomentum(0)=75000.0
	ShotCost(0)=0
	bInstantHit=true
	ShotCost(1)=0
	bSniping=true
	bFastRepeater=true
	AimError=600

	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Nemesis.Effects.PS_Nemesis_Gun_Impact',Sound=SoundCue'A_Vehicle_Nemesis.Cue.A_Vehicle_Nemesis_TurretFireImpactCue')

	bZoomedFireMode(1)=1
	ZoomInSound=SoundCue'A_Vehicle_Nemesis.Cue.A_Vehicle_Nemesis_TurretZoomCue'
	ZoomOutSound=None

	ZoomedTargetFOV=33.0
	ZoomedRate=60.0
	BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'
	VehicleClass=class'UTVehicle_Nemesis'
}

