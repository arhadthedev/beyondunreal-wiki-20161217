/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_ViperSelfDestruct extends UTDmgType_Burning;

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	if ( UTPlayerController(KillerPRI.Owner) != None )
	{
		UTPlayerController(KillerPRI.Owner).BullseyeMessage();
	}
	return super.IncrementKills(KillerPRI);
}

defaultproperties
{
	KillStatsName=KILLS_VIPERSELFDESTRUCT
	DeathStatsName=DEATHS_VIPERSELFDESTRUCT
	SuicideStatsName=SUICIDES_VIPERSELFDESTRUCT
    KDamageImpulse=12000
	KImpulseRadius=500.0
	bKRadialImpulse=true
	bDontHurtInstigator=true
	bSelfDestructDamage=true
}
