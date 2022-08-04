/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtMessage extends UTLocalMessage;

var(Message) localized string RedTeamDominatesString;
var(Message) localized string BlueTeamDominatesString;
var(Message) localized string RedTeamNodeConstructedString;
var(Message) localized string BlueTeamNodeConstructedString;

var(Message) localized string InvincibleCoreString;
var(Message) localized string UnattainableNodeString;
var(Message) localized string RedPowerNodeAttackedString;
var(Message) localized string BluePowerNodeAttackedString;
var(Message) localized string RedPrimeNodeAttackedString;
var(Message) localized string BluePrimeNodeAttackedString;

var(Message) localized string UnpoweredString;
var(Message) localized string RedPowerNodeDestroyedString;
var(Message) localized string BluePowerNodeDestroyedString;
var(Message) localized string RedPowerNodeUnderConstructionString;
var(Message) localized string BluePowerNodeUnderConstructionString;
var(Message) localized string RedPowerNodeSeveredString;
var(Message) localized string BluePowerNodeSeveredString;
var(Message) localized string PowerCoresAreDrainingString;
var(Message) localized string UnhealablePowerCoreString;
var(Message) localized string PowerNodeShieldedByOrbString;
var(Message) localized string PowerNodeTemporarilyShieldedString;
var(Message) localized string NoTeleportWithOrb;
var(Message) localized string DrawString;
var(Message) localized string NodeBusterString;
var localized string RegulationWin;
var localized string OverTimeWin;

var SoundNodeWave MessageAnnouncements[45];
var SoundCue ErrorSound;

var color RedColor;
var color GoldColor;

/** If 1, display this message in small font near minimap */
var byte MiniMapMessage[45];

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
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
	if (default.MessageAnnouncements[Switch] != None)
	{
		UTPlayerController(P).PlayAnnouncement(default.class, Switch);
	}

	if ( Switch == 6 )
		P.ClientPlaySound(default.ErrorSound);
}


static function byte AnnouncementLevel(byte MessageIndex)
{
	return 2;
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
			return Default.RedTeamDominatesString;
			break;

		case 1:
			return Default.BlueTeamDominatesString;
			break;

		case 2:
			return Default.RedTeamNodeConstructedString;
			break;

		case 3:
			return Default.BlueTeamNodeConstructedString;
			break;

		case 4:
		return Default.DrawString;
		break;

		case 5:
	    return Default.InvincibleCoreString;
	    break;

		case 6:
	    return Default.UnattainableNodeString;
	    break;

		case 7:
	    return Default.NodeBusterString;
	    break;

		case 9:
	    return Default.RedPrimeNodeAttackedString;
	    break;

		case 10:
	    return Default.BluePrimeNodeAttackedString;
	    break;

		case 11:
		return Default.RegulationWin;
		break;
		
		case 12:
		return Default.OverTimeWin;
		break;
		
		case 13:
			return Default.UnpoweredString;
			break;

		case 16:
			return Default.RedPowerNodeDestroyedString;
			break;

		case 17:
			return Default.BluePowerNodeDestroyedString;
			break;

		case 23:
			return Default.RedPowerNodeUnderConstructionString;
			break;
		case 24:
			return Default.BluePowerNodeUnderConstructionString;
			break;

		case 27:
			return Default.RedPowerNodeSeveredString;
			break;
		case 28:
			return Default.BluePowerNodeSeveredString;
			break;
		case 29:
			return Default.PowerCoresAreDrainingString;
			break;
		case 30:
			return Default.UnhealablePowerCoreString;
			break;
		case 42:
			return default.PowerNodeShieldedByOrbString;
			break;
		case 43:
			return default.PowerNodeTemporarilyShieldedString;
			break;
		case 44:
			return default.NoTeleportWithOrb;
			break;
	}
	return "";
}

static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
    )
{
	local UTGameObjective O;

	O = UTGameObjective(OptionalObject);
	if ( (O == None) || (O.DefenderTeamIndex > 1) )
	{
	        if ( (Switch == 0) || (Switch == 2) || (Switch == 9) || (Switch == 16) || (Switch == 23) || (Switch == 27) )
	        {
		        return Default.RedColor;
	        }
	        if ( (Switch == 1) || (Switch == 3) || (Switch == 10) || (Switch == 17) || (Switch == 24) || (Switch == 28) )
	        {
		        return Default.DrawColor;
	        }
		return Default.GoldColor;
	}
	return (O.DefenderTeamIndex == 0) ? Default.RedColor : Default.DrawColor;
}

static function float GetLifeTime(int Switch)
{
	if (Switch == 29)
		return 4.0;

	return (default.MiniMapMessage[switch] == 0) ? default.LifeTime : 2.0 * default.LifeTime;
}

static function bool IsConsoleMessage(int Switch)
{
 	if (Switch < 5 || (Switch > 12 && Switch < 18) || (Switch > 19 && Switch < 22) || (Switch > 25 && Switch < 41))
 		return true;

 	return false;
}

static function int GetFontSize( int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer )
{
	return (default.MiniMapMessage[Switch] == 0) ? default.FontSize : 1;
}

static function float GetPos( int Switch, HUD myHUD )
{
	if ( default.MiniMapMessage[Switch] == 0 ) 
	{
		if ( (Switch == 11) || (Switch == 12) )
		{
			return UTHUD(myHUD).MessageOffset[2];
		}
		return UTHUD(myHUD).MessageOffset[default.MessageArea];
	}

	return UTHUD(myHUD).MessageOffset[6];
}

static function bool IsKeyObjectiveMessage( int Switch )
{
	// no highlighting if under attack message
	return ( (Switch != 7) && (Switch != 9) && (Switch != 10) );
}


/**
  * RETURNS true if messages are similar enough to trigger "partially unique" check for HUD display
  */
static function bool PartiallyDuplicates(INT Switch1, INT Switch2, object OptionalObject1, object OptionalObject2 )
{
	return (Switch1 == Switch2) || (OptionalObject1 == OptionalObject2);
}

DefaultProperties
{
	MiniMapMessage(2)=1
	MiniMapMessage(3)=1
	MiniMapMessage(9)=1
	MiniMapMessage(10)=1
	MiniMapMessage(16)=1
	MiniMapMessage(17)=1
	MiniMapMessage(23)=1
	MiniMapMessage(24)=1
	MiniMapMessage(27)=1
	MiniMapMessage(28)=1

	Lifetime=2.5
	MessageArea=3
	MessageAnnouncements[6]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_YouCannotCaptureAnUnlinkedNode'
	MessageAnnouncements[7]=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_NodeBuster'
	//MessageAnnouncements[16]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedNodeDestroyed'
	//MessageAnnouncements[17]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueNodeDestroyed'
	//MessageAnnouncements[23]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedNodeUnderConstruction'
	//MessageAnnouncements[24]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueNodeUnderConstruction'
	MessageAnnouncements[29]=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Overtime'

	ErrorSound=soundcue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue'
	bIsUnique=false
	bIsPartiallyUnique=true
	bBeep=false
	DrawColor=(R=0,G=192,B=255,A=255)
	RedColor=(R=255,G=64,B=48,A=255)
	GoldColor=(R=255,G=255,B=128,A=255)
	FontSize=2
}
