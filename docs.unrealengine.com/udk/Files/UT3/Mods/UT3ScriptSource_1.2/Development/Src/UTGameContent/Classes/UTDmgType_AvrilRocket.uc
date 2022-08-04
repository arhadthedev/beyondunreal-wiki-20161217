/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_AvrilRocket extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=KILLS_AVRIL
	DeathStatsName=DEATHS_AVRIL
	SuicideStatsName=SUICIDES_AVRIL
	RewardCount=15
	RewardEvent=REWARD_BIGGAMEHUNTER
	RewardAnnouncementSwitch=8
	DamageWeaponClass=class'UTWeap_Avril'
	DamageWeaponFireMode=0

	VehicleDamageScaling=1.6
	VehicleMomentumScaling=5.0
	bKRadialImpulse=true
    KDamageImpulse=3000
	KImpulseRadius=100.0

	GibPerterbation=0.15
    AlwaysGibDamageThreshold=99
}
