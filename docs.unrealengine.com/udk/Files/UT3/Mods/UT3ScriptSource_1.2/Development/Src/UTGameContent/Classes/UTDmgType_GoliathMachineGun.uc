/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_GoliathMachineGun extends UTDamageType
	abstract;

defaultproperties
{
    KDamageImpulse=700
    VehicleDamageScaling=0.5
	NodeDamageScaling=0.5
    KillStatsName=KILLS_GOLIATHMACHINEGUN
    DeathStatsName=DEATHS_GOLIATHMACHINEGUN
	SuicideStatsName=SUICIDES_GOLIATHMACHINEGUN
	DamageWeaponClass=class'UTVWeap_GoliathMachineGun'
    DamageWeaponFireMode=0
    bBulletHit=True
	bCausesBloodSplatterDecals=TRUE
}
