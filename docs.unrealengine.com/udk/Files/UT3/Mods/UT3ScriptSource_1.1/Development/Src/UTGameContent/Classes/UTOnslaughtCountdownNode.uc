/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtCountdownNode extends UTOnslaughtPowerNode_Content
	PerObjectLocalized;

/** how long in seconds the controlling team must hold the node to gain the benefit */
var() byte CountdownTime;
/** how much longer controlling team needs to hold the node */
var byte RemainingTime;
/** special announcements played for various situations
 * if there is only one element in the array, that is played regardless of team control
 * otherwise, the announcement that corresponds with the team that controls the node is played
 */
var(Announcements) array<ObjectiveAnnouncementInfo> BuiltAnnouncements, HalfTimeAnnouncements, TenSecondsLeftAnnouncements,
						SuccessAnnouncements, DestroyedAnnouncements;
/** whether the Kismet connected to this node succeeding will damage the core (so give higher priority for AI, etc) */
var() bool bDamagesCore;

replication
{
	if (bNetDirty)
		RemainingTime;
}

simulated event PreBeginPlay()
{
	if (bDamagesCore)
	{
		DefensePriority = Max(DefensePriority, 5);
	}

	Super.PreBeginPlay();
}

simulated state ActiveNode
{
	simulated event RenderMinimap( UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, float ColorPercent )
	{
		local float XL, YL;
		local Font OldFont;
		local string TimeStr;

		OldFont = Canvas.Font;
		Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(2);
		TimeStr = string(RemainingTime);
		Canvas.StrLen(TimeStr, XL, YL);
		Canvas.DrawColor = class'UTHUD'.default.BlackColor;
		Canvas.SetPos(HUDLocation.X + 1 - XL * 0.25, HUDLocation.Y + 1 - YL * 0.25);
		Canvas.DrawText(TimeStr);
		Canvas.DrawColor = class'UTHUD'.default.WhiteColor;
		Canvas.SetPos(HUDLocation.X - XL * 0.25, HUDLocation.Y - YL * 0.25);
		Canvas.DrawText(TimeStr);
		Canvas.Font = OldFont;
	}
	
	simulated function DrawBeaconIcon(Canvas Canvas, vector IconLocation, float IconWidth, float IconAlpha, float BeaconPulseScale, UTPlayerController PlayerOwner)
	{
		local float XL, YL;
		local Font OldFont;
		local string TimeStr;

		OldFont = Canvas.Font;
		Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(1);
		TimeStr = string(RemainingTime);
		Canvas.StrLen(TimeStr, XL, YL);
		Canvas.SetPos(IconLocation.X - XL * 0.5, IconLocation.Y - YL * 0.5);
		Canvas.DrawText(TimeStr,, BeaconPulseScale, BeaconPulseScale);
		Canvas.Font = OldFont;
	}

	function Countdown()
	{
		RemainingTime--;
		if (RemainingTime == 0)
		{
			TriggerEventClass(class'UTSeqEvent_CountdownNodeSucceeded', None);
			BroadcastLocalizedMessage(class'UTCountdownNodeMessage', 30 + DefenderTeamIndex,,, self);

			// go back to neutral
			LastDamagedBy = None;
			Scorers.length = 0;
			Global.UpdateCloseActors();
			DefenderTeamIndex = 2;
			UTGame(WorldInfo.Game).ObjectiveDisabled(self);
			FindNewObjectives();
			GotoState('NeutralNode');
		}
		else if (RemainingTime == CountdownTime / 2)
		{
			BroadcastLocalizedMessage(class'UTCountdownNodeMessage', 10 + DefenderTeamIndex,,, self);
		}
		else if (RemainingTime == 10)
		{
			BroadcastLocalizedMessage(class'UTCountdownNodeMessage', 20 + DefenderTeamIndex,,, self);
		}
	}

	function DisableObjective(Controller InstigatedBy)
	{
		BroadcastLocalizedMessage(class'UTCountdownNodeMessage', 40 + DefenderTeamIndex,,, self);

		Global.DisableObjective(InstigatedBy);
	}

	simulated event BeginState(name PreviousStateName)
	{
		bDrawBeaconIcon = true;
		bScriptRenderAdditionalMinimap = true;
		if (Role == ROLE_Authority)
		{
			RemainingTime = CountdownTime;
			SetTimer(1.0, true, 'Countdown');
			BroadcastLocalizedMessage(class'UTCountdownNodeMessage', DefenderTeamIndex,,, self);
		}

		Super.BeginState(PreviousStateName);
	}

	simulated event EndState(name NextStateName)
	{
		bDrawBeaconIcon = false;
		ClearTimer('Countdown');

		Super.EndState(NextStateName);
		bScriptRenderAdditionalMinimap = false;
	}
}

defaultproperties
{
	CountdownTime=60
	DefensePriority=4

	SupportedEvents.Add(class'UTSeqEvent_CountdownNodeSucceeded')

	BuiltAnnouncements[0]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedControlsTheCountdownNode')
	BuiltAnnouncements[1]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueControlsTheCountdownNode')
	DestroyedAnnouncements[0]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_CountdownNodeDestroyed')
}
