/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_LeviathanBolt extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=KILLS_LEVIATHANPRIMARY
	DeathStatsName=DEATHS_LEVIATHANPRIMARY
	SuicideStatsName=SUICIDES_LEVIATHANPRIMARY
	DamageWeaponClass=class'UTVWeap_LeviathanPrimary'
	DamageWeaponFireMode=2
	KDamageImpulse=1000
	VehicleMomentumScaling=1.5
	VehicleDamageScaling=0.5
	NodeDamageScaling=0.5
}
