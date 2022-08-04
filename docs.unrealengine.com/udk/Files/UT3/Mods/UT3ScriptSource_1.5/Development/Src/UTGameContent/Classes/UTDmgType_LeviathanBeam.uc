/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_LeviathanBeam extends UTDamageType;

defaultproperties
{
	KillStatsName=KILLS_LEVIATHANTURRETBEAM
	DeathStatsName=DEATHS_LEVIATHANTURRETBEAM
	SuicideStatsName=SUICIDES_LEVIATHANTURRETBEAM
	DamageWeaponClass=class'UTVWeap_LeviathanTurretBeam'
	DamageWeaponFireMode=0
    VehicleMomentumScaling=2.0
	VehicleDamageScaling=2.0
	KDamageImpulse=1500
}
