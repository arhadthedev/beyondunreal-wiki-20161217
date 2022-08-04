/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_ViperBolt extends UTDamageType
	abstract;

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
	KillStatsName=KILLS_VIPERGUN
	DeathStatsName=DEATHS_VIPERGUN
	SuicideStatsName=SUICIDES_VIPERGUN
	DamageWeaponClass=class'UTVWeap_ViperGun'
	DamageWeaponFireMode=0
	bCausesBlood=false
	VehicleMomentumScaling=1.0
	NodeDamageScaling=0.7
	VehicleDamageScaling=0.7
}

