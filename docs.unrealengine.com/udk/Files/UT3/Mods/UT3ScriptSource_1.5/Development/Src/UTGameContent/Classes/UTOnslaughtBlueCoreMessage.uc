/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtBlueCoreMessage extends UTLocalMessage;

var(Message) localized string PowerCoreAttackedString;
var(Message) localized string PowerCoreDestroyedString;
var(Message) localized string PowerCoreCriticalString;
var(Message) localized string PowerCoreVulnerableString;
var(Message) localized string PowerCoreDamagedString;
var(Message) localized string PowerCoreNoHealString;
var(Message) localized string PowerCoreSecureString;

var SoundNodeWave MessageAnnouncements[7];
var SoundCue ErrorSound;

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local UTHUD HUD;
	
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (UTOnslaughtObjective(OptionalObject) != None)
	{
		if ( (UTOnslaughtObjective(OptionalObject).LastAttackSwitch == Switch)
			&& (P.WorldInfo.TimeSeconds < UTOnslaughtObjective(OptionalObject).LastAttackAnnouncementTime + 10) )
		{
			return;
		}
		else
		{
			UTOnslaughtObjective(OptionalObject).LastAttackAnnouncementTime = P.WorldInfo.TimeSeconds;
			UTOnslaughtObjective(OptionalObject).LastAttackSwitch = Switch;
		}
	}
	
	if ( Switch == 5 )
		P.ClientPlaySound(default.ErrorSound);
	else if (default.MessageAnnouncements[Switch] != None)
	{
		HUD = UTHUD(P.myHUD);
		if ( (HUD != None) && HUD.bIsSplitScreen && !HUD.bIsFirstPlayer )
		{
			return;
		}
		UTPlayerController(P).PlayAnnouncement(default.class, Switch);
	}
}

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return default.MessageAnnouncements[MessageIndex];
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0:
			return Default.PowerCoreAttackedString;
			break;

		case 1:
			return Default.PowerCoreDestroyedString;
			break;

		case 2:
			return Default.PowerCoreCriticalString;
			break;

		case 3:
			return Default.PowerCoreVulnerableString;
			break;

		case 4:
			return Default.PowerCoreDamagedString;
			break;

		case 5:
			return Default.PowerCoreNoHealString;
			break;

		case 6:
			return Default.PowerCoreSecureString;
			break;
	}
	return "";
}


static function bool IsConsoleMessage(int Switch)
{
	return (Switch != 5);
}

static function bool IsKeyObjectiveMessage( int Switch )
{
	return (Switch != 5);
}

static function float GetPos( int Switch, HUD myHUD  )
{
	if ( UTHUD(myHUD) == None )
	{
		return 0.5;
	}
	if ( Switch != 5 )
	{
		return UTHUD(myHUD).MessageOffset[Default.MessageArea];
	}
	else
	{
		return UTHUD(myHUD).MessageOffset[3];
	}
}

static function int GetFontSize( int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer )
{
	if (Switch != 5)
	{
	    return default.FontSize;
	}
	else
	{
	    return 2;
	}
}

/**
  * kill all queued messages and play immediately if end of round message
  */
static function bool AddAnnouncement(UTAnnouncer Announcer, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	local UTQueuedAnnouncement RemovedAnnouncement;

	if ( MessageIndex == 1 )
	{
		while ( Announcer.Queue != None )
		{
			RemovedAnnouncement = Announcer.Queue;
			Announcer.Queue = Announcer.Queue.nextAnnouncement;
			RemovedAnnouncement.Destroy();
		}
		super.AddAnnouncement(Announcer, MessageIndex, PRI, OptionalObject);
		return true;
	}
	else
	{
		return super.AddAnnouncement(Announcer, MessageIndex, PRI, OptionalObject);
	}
}

static function bool KilledByVictoryMessage(int AnnouncementIndex)
{
	return (AnnouncementIndex != 1);
}

DefaultProperties
{
	Lifetime=5
	MessageArea=6
	MessageAnnouncements[0]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueCoreIsUnderAttack'
	MessageAnnouncements[1]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueCoreDestroyed'
	MessageAnnouncements[2]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueCoreIsCritical'
	MessageAnnouncements[3]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueCoreIsVulnerable'
	MessageAnnouncements[4]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueCoreIsHeavilyDamaged'
	MessageAnnouncements[6]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueCoreIsSecure'
	ErrorSound=soundcue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue'

	bIsUnique=true
	bBeep=false
	DrawColor=(R=0,G=192,B=255,A=255)
	FontSize=1
}
