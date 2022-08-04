/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTBetrayalMessage extends UTLocalMessage
	abstract;

var localized string BetrayalMidString, BetrayalPrefix, BetrayalPostfix, BetrayalJoinTeam, RetributionString, PaybackString, RogueTimerExpiredString;
var SoundNodeWave BetrayalKillSound;
var SoundNodeWave RetributionSound;
var SoundNodeWave PaybackSound;
var SoundNodeWave JoinTeamSound;
var SoundNodeWave PaybackAvoidedSound;
var color BlueColor;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 1 )
		return default.BetrayalJoinTeam;
	else if ( Switch == 2 )
		return default.RetributionString;
	else if ( Switch == 3 )
		return default.PaybackString;
	else if ( (Switch == 4) || (Switch == 0) )
		return default.BetrayalPrefix$RelatedPRI_1.PlayerName$default.BetrayalMidString$RelatedPRI_2.PlayerName$default.BetrayalPostfix;
	else
		return default.RogueTimerExpiredString;
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if ( Switch == 1 )
	{
		UTPlayerController(P).PlayAnnouncement(Default.class,Switch );
	}
	else if ( Switch == 0 )
	{
		UTPlayerController(P).PlayAnnouncement(Default.class,Switch );
		UTPlayerController(P).ClientMusicEvent(10);
	}
	else if ( (Switch == 2) || (Switch == 3) )
	{
		UTPlayerController(P).PlayAnnouncement(Default.class,Switch );
		UTPlayerController(P).ClientMusicEvent(10);
	}
	else if ( Switch == 5 )
	{
		UTPlayerController(P).PlayAnnouncement(Default.class,Switch );
		UTPlayerController(P).ClientMusicEvent(14);
	}
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	if ( MessageIndex == 1 )
		return default.JoinTeamSound;
	else if ( MessageIndex == 2 )
		return default.RetributionSound;
	else if ( MessageIndex == 3 )
		return default.PaybackSound;
	else if ( MessageIndex == 5 )
		return default.PaybackAvoidedSound;
	else
		return default.BetrayalKillSound;
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( (Switch == 1) || (Switch == 5) )
	{
		return Default.BlueColor;
	}
	return Default.DrawColor;
}

static function int GetFontSize( int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer )
{
	if ( Switch == 4 )
		return 2;
	else
		return 3;
}

defaultproperties
{
	bIsUnique=True
	Lifetime=6
	DrawColor=(R=255,G=0,B=0,A=255)
	BlueColor=(R=0,G=160,B=255,A=255)
	FontSize=3
	bBeep=False
	BetrayalKillSound=SoundNodeWave'A_Announcer_UT3G.Rewards.A_RewardAnnouncer_Assassin'
	RetributionSound=SoundNodeWave'A_Announcer_UT3G.Rewards.A_RewardAnnouncer_Retribution'
	PaybackSound=SoundNodeWave'A_Announcer_UT3G.Rewards.A_RewardAnnouncer_Payback'
	JoinTeamSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_YouAreOnBlue'
	PaybackAvoidedSound=SoundNodeWave'A_Announcer_UT3G.Rewards.A_RewardAnnouncer_Excellent'
	MessageArea=3
	AnnouncementPriority=8
}
