/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_HeroBomb extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=KILLS_HEROBOMB
	DeathStatsName=KILLS_HEROBOMB
	SuicideStatsName=KILLS_HEROBOMB
	DamageWeaponFireMode=2
	VehicleDamageScaling=1.5
	NodeDamageScaling=0.35
	bDestroysBarricades=true

	bKUseOwnDeathVel=true
	KDeathUpKick=700
	KDamageImpulse=20000
	KImpulseRadius=5000.0
	bComplainFriendlyFire=false
	bHeadGibCamera=false

	HeroPointsMultiplier=0.0

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform10
		Samples(0)=(LeftAmplitude=100,RightAmplitude=100,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=1.500)
	End Object
	DamagedFFWaveform=ForceFeedbackWaveform10
}
