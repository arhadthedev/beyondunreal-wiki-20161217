/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_DarkWalkerBolt extends UTDamageType
      abstract;

defaultproperties
{
	KillStatsName=KILLS_DARKWALKERPASSGUN
	DeathStatsName=DEATHS_DARKWALKERPASSGUN
	SuicideStatsName=SUICIDES_DARKWALKERPASSGUN
	DamageWeaponClass=class'UTVWeap_DarkWalkerPassGun'
	DamageWeaponFireMode=2

	NodeDamageScaling=0.7
	VehicleDamageScaling=0.7
}
