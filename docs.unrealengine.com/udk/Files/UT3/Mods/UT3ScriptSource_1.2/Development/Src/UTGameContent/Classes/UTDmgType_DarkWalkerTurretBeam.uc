/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_DarkWalkerTurretBeam extends UTDmgType_Burning
      abstract;

defaultproperties
{
	KillStatsName=KILLS_DARKWALKERTURRET
	DeathStatsName=DEATHS_DARKWALKERTURRET
	SuicideStatsName=SUICIDES_DARKWALKERTURRET
	DamageWeaponClass=class'UTVWeap_DarkWalkerTurret'
	DamageWeaponFireMode=0
	bKRadialImpulse=true
	KDamageImpulse=3000
	KImpulseRadius=100.0
	VehicleDamageScaling=1.0
	bAlwaysGibs=true
}
