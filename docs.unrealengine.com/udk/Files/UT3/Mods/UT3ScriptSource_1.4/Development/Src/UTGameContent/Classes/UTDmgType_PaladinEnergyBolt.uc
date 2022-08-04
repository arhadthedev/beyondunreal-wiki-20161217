/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_PaladinEnergyBolt extends UTDamageType
	abstract;

static function ScoreKill(UTPlayerReplicationInfo KillerPRI, UTPlayerReplicationInfo KilledPRI, Pawn KilledPawn)
{
	super.ScoreKill(KillerPRI, KilledPRI, KilledPawn);
	if ( KilledPRI != None && KillerPRI != KilledPRI && UTVehicle(KilledPawn) != None && UTVehicle(KilledPawn).EagleEyeTarget() )
	{
		KillerPRI.IncrementEventStat('EVENT_EAGLEEYE');
		if (UTPlayerController(KillerPRI.Owner) != None)
			UTPlayerController(KillerPRI.Owner).ReceiveLocalizedMessage(class'UTVehicleKillMessage', 5);
	}
}

defaultproperties
{
	KillStatsName=KILLS_PALADINGUN
	DeathStatsName=DEATHS_PALADINGUN
	SuicideStatsName=SUICIDES_PALADINGUN
	DamageWeaponClass=class'UTVWeap_PaladinGun'
	VehicleMomentumScaling=2.5
	bThrowRagdoll=true
}
