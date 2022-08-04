/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_RaptorRocket extends UTDmgType_Burning
	abstract;

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
	KillStatsName=KILLS_RAPTORROCKET
	DeathStatsName=DEATHS_RAPTORROCKET
	SuicideStatsName=SUICIDES_RAPTORROCKET
	DamageWeaponClass=class'UTVWeap_RaptorGun'
	DamageWeaponFireMode=1
	KDamageImpulse=2000
	bKRadialImpulse=true
    VehicleDamageScaling=1.5
    VehicleMomentumScaling=0.75
}
