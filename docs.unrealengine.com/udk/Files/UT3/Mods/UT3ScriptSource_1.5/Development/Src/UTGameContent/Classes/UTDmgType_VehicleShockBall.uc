/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_VehicleShockBall extends UTDamageType;


defaultproperties
{
	KillStatsName=KILLS_TURRETSHOCK
	DeathStatsName=DEATHS_TURRETSHOCK
	SuicideStatsName=SUICIDES_TURRETSHOCK
	DamageWeaponClass=class'UTVWeap_ShockTurret'
	DamageWeaponFireMode=1
	KDamageImpulse=2000
	bKRadialImpulse=true
}
