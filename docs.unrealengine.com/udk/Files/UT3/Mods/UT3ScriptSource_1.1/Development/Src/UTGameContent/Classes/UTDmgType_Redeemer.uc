/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_Redeemer extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=KILLS_REDEEMER
	DeathStatsName=DEATHS_REDEEMER
	SuicideStatsName=SUICIDES_REDEEMER
	DamageWeaponClass=class'UTWeap_Redeemer_Content'
	DamageWeaponFireMode=2
	VehicleDamageScaling=1.5
	NodeDamageScaling=1.5
	bDestroysBarricades=true

	bKUseOwnDeathVel=true
	KDeathUpKick=700
	KDamageImpulse=20000
	KImpulseRadius=5000.0
	bComplainFriendlyFire=false

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform10
		Samples(0)=(LeftAmplitude=100,RightAmplitude=100,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=1.500)
	End Object
	DamagedFFWaveform=ForceFeedbackWaveform10
}
