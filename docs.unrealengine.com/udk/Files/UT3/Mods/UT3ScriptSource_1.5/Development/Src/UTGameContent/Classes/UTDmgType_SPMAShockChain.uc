/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_SPMAShockChain extends UTDamageType;

defaultproperties
{
	KillStatsName=KILLS_SPMATURRET
	DeathStatsName=DEATHS_SPMATURRET
	SuicideStatsName=SUICIDES_SPMATURRET
	DamageWeaponClass=class'UTVWeap_SPMAPassengerGun'
	DamageWeaponFireMode=2
	KDamageImpulse=2000
	bKRadialImpulse=true
	VehicleMomentumScaling=1.5
}
