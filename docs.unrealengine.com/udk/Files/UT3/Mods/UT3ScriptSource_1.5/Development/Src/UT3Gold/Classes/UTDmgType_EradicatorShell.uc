/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_EradicatorShell extends UTDmgType_SPMAShell;

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	local UTPlayerController PC;

	// Increment "Eradication" achievement
	PC = UTPlayerController(KillerPRI.Owner);
	if ( PC != None )
	{
		PC.ClientUpdateAchievement(EUTA_UT3GOLD_Eradication, 1);
	}

	return Super.IncrementKills(KillerPRI);
}

defaultproperties
{
	DamageWeaponClass=class'UTVWeap_EradicatorCannon_Content'
}
