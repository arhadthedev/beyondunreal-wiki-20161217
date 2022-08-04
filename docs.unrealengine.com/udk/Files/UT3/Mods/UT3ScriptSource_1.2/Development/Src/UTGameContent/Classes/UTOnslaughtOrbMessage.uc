/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTOnslaughtOrbMessage extends UTCarriedObjectMessage;

var SoundNodeWave EnemyIncoming;
var SoundNodeWave EnemyDropped;
var SoundNodeWave EnemyDestroyed;

var(Message) localized string EnemyIncomingString, EnemyDroppedString, EnemyDestroyedString, OrbAutoReturnedString, OrbNoPickupString;

var byte HighlightOrb[17];

static simulated function ClientReceive(
	PlayerController P,
	optional int SwitchIndex,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local UTTeamInfo OrbTeam;
	local UTOnslaughtFlag Orb;
	local int BaseSwitch;


	// if enemy orb, either switch to custom message or ignore, depending on whether in sensor range
	// not for "enemy orb carrier incoming" as in that case distance was already checked
	if ( SwitchIndex != 14 && SwitchIndex != 17 && SwitchIndex != 18 )
	{
		OrbTeam = UTTeamInfo(OptionalObject);
		if ( (OrbTeam != None) && (P.PlayerReplicationInfo.Team != OrbTeam) )
		{
			Orb = UTOnslaughtFlag(OrbTeam.TeamFlag);
			if ( Orb != None )
			{
				if ( !LocalPlayer(P.Player).GetActorVisibility(Orb) && (P.PlayerReplicationInfo != RelatedPRI_1) && (P.PlayerReplicationInfo != RelatedPRI_2)
					&& ((Orb.LastNearbyObjective == None)
					|| (VSize(Orb.Location - Orb.LastNearbyObjective.Location) > Orb.LastNearbyObjective.MaxSensorRange)) )
				{
					return;
				}

				BaseSwitch = (SwitchIndex<7) ? SwitchIndex : SwitchIndex-7;
				// switch to custom message
				if ( BaseSwitch == 2 )
				{
					// enemy dropped
					SwitchIndex = 15;
				}
				else if ( (BaseSwitch == 1) || (BaseSwitch == 3) || (BaseSwitch == 5) )
				{
					// enemy destroyed (returned)
					SwitchIndex = 16;
				}
			}
		}
	}
	Super.ClientReceive(P, SwitchIndex, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if ( RelatedPRI_1 == P.PlayerReplicationInfo )
	{
		if ( (SwitchIndex == 16) )
		{
			UTPlayerController(P).ClientMusicEvent(3);
		}
	}
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	if ( MessageIndex < 14 )
	{
		return super.AnnouncementSound(MessageIndex, OptionalObject, PC);
	}
	else if ( MessageIndex == 14 )
	{
		return Default.EnemyIncoming;
	}
	else if ( MessageIndex == 15 )
	{
		return Default.EnemyDropped;
	}
	else if ( MessageIndex == 16 )
	{
		return Default.EnemyDestroyed;
	}
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch < 14 )
	{
		return super.GetString(Switch, bPRI1HUD, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	else if ( Switch == 14 )
	{
		return Default.EnemyIncomingString;
	}
	else if ( Switch == 15 )
	{
		return Default.EnemyDroppedString;
	}
	else if ( Switch == 16 )
	{
		return Default.EnemyDestroyedString;
	}
	else if ( Switch == 17 )
	{
		return Default.OrbAutoReturnedString;
	}
	else if ( Switch == 18 )
	{
		return Default.OrbNoPickupString;
	}
}

/**
 * Don't let multiple messages for same flag stack up
 */
static function bool ShouldBeRemoved(UTQueuedAnnouncement MyAnnouncement, class<UTLocalMessage> NewAnnouncementClass, int NewMessageIndex)
{
	// check if message is not a flag status announcement
	if (default.Class != NewAnnouncementClass)
	{
		return false;
	}

	if ( (MyAnnouncement.MessageIndex>13) == (NewMessageIndex>13) )
	{
		return true;
	}
	return Super.ShouldBeRemoved(MyAnnouncement, NewAnnouncementClass, NewMessageIndex);
}

static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
    )
{
	local UTTeamInfo T;

	T = UTTeamInfo(OptionalObject);
	if ( (T == None) || (T.TeamIndex > 1) )
	{
		return class'UTOnslaughtMessage'.Default.GoldColor;
	}
	return (T.TeamIndex == 0) ? class'UTOnslaughtMessage'.Default.RedColor : class'UTOnslaughtMessage'.Default.DrawColor;
}

static function bool IsKeyObjectiveMessage( int Switch )
{
	return (Default.HighLightOrb[Switch] != 0);
}

static function int GetFontSize( int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer )
{
	return (Switch < 17) ? default.FontSize : 3;
}

static function float GetPos( int Switch, HUD myHUD )
{
	return UTHUD(myHUD).MessageOffset[(Switch < 17) ? default.MessageArea : 2];
}

defaultproperties
{
	MessageArea=6
	ReturnSounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedOrbDestroyed'
	ReturnSounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueOrbDestroyed'
	DroppedSounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedOrbDropped'
	DroppedSounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueOrbDropped'
	TakenSounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedOrbPickedUp'
	TakenSounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueOrbPickedUp'

	EnemyIncoming=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_EnemyOrbCarrierIncoming'
	EnemyDropped=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_EnemyOrbDropped'
	EnemyDestroyed=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_EnemyOrbDestroyed'


	HighlightOrb(2)=1
	HighlightOrb(9)=1
	HighlightOrb(14)=1
	HighlightOrb(15)=1
}

