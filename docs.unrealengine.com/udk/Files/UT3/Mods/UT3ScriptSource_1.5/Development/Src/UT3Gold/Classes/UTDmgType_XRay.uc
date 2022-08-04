/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_XRay extends UTDamageType
	abstract;



static function bool ShouldGib(UTPawn DeadPawn)
{
	// Don't gib!
	return false;
}

defaultproperties
{
	DamageWeaponFireMode=1

	DamageBodyMatColor=(R=50,G=50,B=50)
	DamageOverlayTime=0.0
	DeathOverlayTime=1.0

	bCausesBlood=false
	bLeaveBodyEffect=true
	bArmorStops=false
	bIgnoreDriverDamageMult=true
	VehicleDamageScaling=0.2
	VehicleMomentumScaling=0.1

	KDamageImpulse=100

	DamageCameraAnim=CameraAnim'Camera_FX.LinkGun.C_WP_Link_Beam_Hit'
}
