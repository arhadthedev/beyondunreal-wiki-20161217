/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_FuryBeam extends UTDmgType_Burning;

defaultproperties
{
	KillStatsName=KILLS_FURYGUN
	DeathStatsName=DEATHS_FURYGUN
	SuicideStatsName=SUICIDES_FURYGUN
	DamageWeaponClass=class'UTVWeap_FuryGun'
	DamageWeaponFireMode=1
	bKRadialImpulse=true
	KDamageImpulse=12000 //@note: per second, see UTVWeap_FuryGun::DealDamageTo()
	VehicleDamageScaling=1.0
	bAlwaysGibs=true
}
