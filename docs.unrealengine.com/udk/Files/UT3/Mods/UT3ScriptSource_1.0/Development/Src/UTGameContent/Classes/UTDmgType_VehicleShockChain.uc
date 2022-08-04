/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_VehicleShockChain extends UTDamageType;

defaultproperties
{
	KillStatsName=KILLS_TURRETSHOCK
	DeathStatsName=DEATHS_TURRETSHOCK
	SuicideStatsName=SUICIDES_TURRETSHOCK
	DamageWeaponClass=class'UTVWeap_ShockTurret'
	DamageWeaponFireMode=2
	KDamageImpulse=2000
	bKRadialImpulse=true
	VehicleMomentumScaling=1.5
}
