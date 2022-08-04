/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 */
class UTDmgType_RanOver extends UTDamageType
	abstract;

var int NumMessages;

var ForceFeedbackWaveform RanOverWaveForm;

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	local int KillCount;

	KillCount = super.IncrementKills(KillerPRI);
	if ( (KillCount != Default.RewardCount)  && (UTPlayerController(KillerPRI.Owner) != None) )
	{
		SmallReward(UTPlayerController(KillerPRI.Owner), KillCount);
	}
	return KillCount;
}

static function SmallReward(UTPlayerController Killer, int KillCount)
{
	Killer.ReceiveLocalizedMessage(class'UTVehicleKillMessage', KillCount % 4);
}

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local UTPawn UTP;
	local UTConsolePlayerController UTPC;

	Super.SpawnHitEffect(P,Damage,Momentum,BoneName,HitLocation);

	UTP = UTPawn(P);
	if(UTP != none)
	{
		UTP.SoundGroupClass.Static.PlayCrushedSound(P);

		//Play some rumble
		UTPC = UTConsolePlayerController(UTP.Controller);
		if(UTPC != None)
	{
			UTPC.ClientPlayForceFeedbackWaveform(default.RanOverWaveForm);
		}
	}
}

defaultproperties
{
	KillStatsName=EVENT_RANOVERKILLS
	DeathStatsName=EVENT_RANOVERDEATHS
	SuicideStatsName=SUICIDES_ENVIRONMENT
	RewardCount=10
	RewardEvent=REWARD_ROADRAMPAGE
	RewardAnnouncementClass=class'UTVehicleKillMessage'
	RewardAnnouncementSwitch=7
	GibPerterbation=0.5
	GibModifier=2.0
	bLocationalHit=false
	bNeverGibs=true
	bUseTearOffMomentum=true
	bExtraMomentumZ=false
	bVehicleHit=true

	NumMessages=4

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformRanOver
	Samples(0)=(LeftAmplitude=90,RightAmplitude=90,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=1.0)
	End Object
	RanOverWaveForm=ForceFeedbackWaveformRanOver
}
