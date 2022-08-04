/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_ScavengerBallCollision extends UTDamageType
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

// no K impulse because this occurs during async tick, so we can add impulse to kactors
defaultproperties
{
	KDamageImpulse=0
	KImpulseRadius=0.0
	DamageOverlayTime=0.0
	bLocationalHit=false
	bArmorStops=false
	AlwaysGibDamageThreshold=80

	KillStatsName=EVENT_RANOVERKILLS
	deathStatsName=EVENT_RANOVERDEATHS
	SuicideStatsName=SUICIDES_ENVIRONMENT
	DamageWeaponClass=class'UTVWeap_ScavengerGun'
}
