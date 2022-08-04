/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_ViperGun extends UTVehicleWeapon
		HideDropDown;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_None
	WeaponProjectiles(0)=class'UTProj_ViperBolt'
	WeaponFireSnd[0]=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_PrimaryFireCue'

	// ~45 degrees - since this vehicle's gun doesn't move by itself, we give some more leeway
	MaxFinalAimAdjustment=0.7
	FireInterval(0)=+0.2
	ShotCost(0)=0
	ShotCost(1)=0
	FireTriggerTags=(MantaWeapon01,MantaWeapon02)
	VehicleClass=class'UTVehicle_Viper_Content'
	bIgnoreDownwardPitch=true
	bFastRepeater=true
	AimError=750
}

