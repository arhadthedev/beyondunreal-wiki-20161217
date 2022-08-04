/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_HeroRocket extends UTDmgType_Rocket
	abstract;

defaultproperties
{
	KillStatsName=KILLS_HEROROCKETLAUNCHER
	DeathStatsName=DEATHS_HEROROCKETLAUNCHER
	SuicideStatsName=SUICIDES_HEROROCKETLAUNCHER
	RewardCount=15
	RewardEvent=REWARD_ROCKETSCIENTIST
	RewardAnnouncementSwitch=10
	DamageWeaponClass=class'UTWeap_RocketLauncher'
	DamageWeaponFireMode=0
	KDamageImpulse=1000
	KDeathUpKick=200
	bKRadialImpulse=true
	VehicleMomentumScaling=4.0
	VehicleDamageScaling=0.8
	NodeDamageScaling=1.1
	bThrowRagdoll=true
	GibPerterbation=0.15
    AlwaysGibDamageThreshold=99
    CustomTauntIndex=7
}
