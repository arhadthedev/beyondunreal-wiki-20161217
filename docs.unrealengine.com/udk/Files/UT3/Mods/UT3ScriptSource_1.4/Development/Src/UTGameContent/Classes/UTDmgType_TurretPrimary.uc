/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_TurretPrimary extends UTDamageType;

/** SpawnHitEffect()
 * Possibly spawn a custom hit effect
 */
static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local UTEmit_VehicleHit BF;

	if ( Vehicle(P) != None )
	{
		BF = P.spawn(class'UTEmit_VehicleHit',P,, HitLocation, rotator(Momentum));
		BF.AttachTo(P, BoneName);
	}
}

defaultproperties
{
	KillStatsName=KILLS_TURRETPRIMARY
	DeathStatsName=DEATHS_TURRETPRIMARY
	SuicideStatsName=SUICIDES_TURRETPRIMARY
	DamageWeaponClass=class'UTVWeap_TurretPrimary'
	DamageWeaponFireMode=0
	VehicleDamageScaling=0.7
	bCausesBlood=false
}
