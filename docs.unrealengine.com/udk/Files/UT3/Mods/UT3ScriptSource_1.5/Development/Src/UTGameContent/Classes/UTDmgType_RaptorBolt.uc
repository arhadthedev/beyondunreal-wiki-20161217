/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_RaptorBolt extends UTDamageType
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

static function ScoreKill(UTPlayerReplicationInfo KillerPRI, UTPlayerReplicationInfo KilledPRI, Pawn KilledPawn)
{
	super.ScoreKill(KillerPRI, KilledPRI, KilledPawn);
	if (KilledPRI != None && KillerPRI != KilledPRI && Vehicle(KilledPawn) != None && Vehicle(KilledPawn).bCanFly)
	{
		KillerPRI.IncrementEventStat('EVENT_TOPGUN');
		if (UTPlayerController(KillerPRI.Owner) != None)
			UTPlayerController(KillerPRI.Owner).ReceiveLocalizedMessage(class'UTVehicleKillMessage', 6);
	}
}

defaultproperties
{
	KillStatsName=KILLS_RAPTORGUN
	DeathStatsName=DEATHS_RAPTORGUN
	SuicideStatsName=SUICIDES_RAPTORGUN
	DamageWeaponClass=class'UTVWeap_RaptorGun'
	DamageWeaponFireMode=2
	KDamageImpulse=1000
	bCausesBlood=false
}
