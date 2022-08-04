/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTTeamHUD extends UTHUD;

var bool bShowDirectional;
var int LastScores[2];
var int ScoreTransitionTime[2];
var vector2D TeamIconCenterPoints[2];
var float LeftTeamPulseTime, RightTeamPulseTime;
var float OldLeftScore, OldRightScore;

/** The scaling modifier will be applied to the widget that coorsponds to the player's team */
var() float TeamScaleModifier;

var bool bScoreDebug;


exec function ToggleScoreDebug()
{
	bScoreDebug = !bScoreDebug;
}

function DisplayScoring()
{
	Super.DisplayScoring();

		DisplayTeamScore();
	}

function DisplayTeamScore()
{
	local float DestScale, W, H, POSX;
	local vector2d Logo;
	local byte TeamIndex;
	local LinearColor TeamLC;
	local color TextC;
	local int NewScore;
	local bool bShowIndicatorIcons;
	local int SavedOrgY;
	local float LeftTeamScale, RightTeamScale;

	// If in split screen, don't draw the indicators and team logos.  We only want the score.
	bShowIndicatorIcons = true;
	if ( bIsSplitScreen )
	{
		// only draw on first player, since it bridges the gap
		if (!bIsFirstPlayer)
		{
			return;
		}

		// move down to bridge the gap
		SavedOrgY = Canvas.OrgY;
		Canvas.OrgY += Canvas.ClipY - 30 * ResolutionScale;
	}

	Canvas.DrawColor = WhiteColor;
    	W = 214 * ResolutionScaleX;
    	H = 87 * ResolutionScale;

	// left side is player's team, and is full size
	LeftTeamScale = 1.0;
	RightTeamScale = TeamScaleModifier;

	// get player's team
	TeamIndex = UTPlayerOwner.GetTeamNum();

	// spectator or splitscreen (shared scores)
	if (TeamIndex == 255 || bIsSplitScreen)
	{
		TeamIndex = 0;
		RightTeamScale = 1.0;
	}

	// Draw the Left Team Indicator
	DestScale = LeftTeamScale;
	GetTeamColor(TeamIndex, TeamLC, TextC);
	POSX = Canvas.ClipX * 0.49 - W;

	Canvas.SetPos(POSX, 0);
	if ( bShowIndicatorIcons )
	{
		Canvas.DrawColorizedTile(IconHudTexture, W * DestScale, H * DestScale, 0, 491, 214, 87, TeamLC);
	}

	NewScore = GetTeamScore(TeamIndex);

	if ( NewScore != OldLeftScore )
	{
		LeftTeamPulseTime = WorldInfo.TimeSeconds;
	}
	OldLeftScore = NewScore;

	if (DestScale < 1.0)
	{
		DrawGlowText(string(NewScore), POSX + 97 * ResolutionScaleX, -2 * ResolutionScale, 50 * ResolutionScale, LeftTeamPulseTime, true);
	}
	else
	{
		DrawGlowText(string(NewScore), POSX + 124 * ResolutionScaleX, -2 * ResolutionScale, 60 * ResolutionScale, LeftTeamPulseTime, true);
	}

	if ( bShowIndicatorIcons )
	{
		Logo.X = POSX + ((TeamIconCenterPoints[0].X) * DestScale * ResolutionScaleX) + (30 * ResolutionScaleX);
		Logo.Y = ((TeamIconCenterPoints[0].Y) * DestScale * ResolutionScale) + (27.5 * ResolutionScale);
   		DisplayTeamLogos(TeamIndex,Logo, 1.5);
	}

	// Draw the Right Team Indicator
	DestScale = RightTeamScale;
	TeamIndex = 1 - TeamIndex;
	GetTeamColor(TeamIndex, TeamLC, TextC);
	POSX = Canvas.ClipX * 0.51;

	NewScore = GetTeamScore(TeamIndex);

	if ( NewScore != OldRightScore )
	{
		RightTeamPulseTime = WorldInfo.TimeSeconds;
	}
	OldRightScore = NewScore;

	Canvas.SetPos(POSX,0);
	if ( bShowIndicatorIcons )
	{
		Canvas.DrawColorizedTile(IconHudTexture, W * DestScale, H * DestScale, 0, 582, 214, 87, TeamLC);
	}
	Canvas.DrawColor = WhiteColor;
	if (DestScale < 1.0)
	{
		DrawGlowText(string(NewScore), POSX + 0.66*W, -4 * ResolutionScaleX, 50 * ResolutionScale, RightTeamPulseTime, true);
	}
	else
	{
		DrawGlowText(string(NewScore), POSX + 0.87*W, -2 * ResolutionScale, 60 * ResolutionScale, RightTeamPulseTime, true);
	}

	if ( bShowIndicatorIcons )
	{
		if (DestScale < 1.0)
		{
			Logo.X = (POSX + (TeamIconCenterPoints[1].X) * DestScale * ResolutionScaleX) + (30 * ResolutionScaleX);
			Logo.Y = ((TeamIconCenterPoints[1].Y) * DestScale * ResolutionScale) + (27.5 * ResolutionScale);
   			DisplayTeamLogos(TeamIndex,Logo, 1.0);
		}
		else
		{
			Logo.X = (POSX + 15 * DestScale * ResolutionScaleX) + (30 * ResolutionScaleX);
			Logo.Y = (27 * DestScale * ResolutionScale) + (27.5 * ResolutionScale);
	   		DisplayTeamLogos(TeamIndex, Logo, 1.5);
		}
	}

	if ( bIsSplitScreen )
	{
		Canvas.OrgY = SavedOrgY;
	}
}

function int GetTeamScore(byte TeamIndex)
{
	if( (TeamIndex == 0 || TeamIndex == 1) && (UTGRI != None) && (UTGRI.Teams[TeamIndex] != None) )
	{
		return INT(UTGRI.Teams[TeamIndex].Score);
	}
	else
	{
		return 0;
	}

}

function Actor GetDirectionalDest(byte TeamIndex)
{
	return none;
}

function DisplayTeamLogos(byte TeamIndex, vector2d POS, optional float DestScale=1.0)
{
	if ( bShowDirectional && !bIsSplitScreen )
	{
		DisplayDirectionIndicator(TeamIndex, POS, GetDirectionalDest(TeamIndex), DestScale );
	}
}

function DisplayDirectionIndicator(byte TeamIndex, vector2D POS, Actor DestActor, float DestScale)
{
	local rotator Dir,Angle;
	local vector start;

	if ( DestActor != none )
	{
		Start = (PawnOwner != none) ? PawnOwner.Location : UTPlayerOwner.Location;
		Dir  = Rotator(DestActor.Location - Start);
		Angle.Yaw = (Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535;


		// Boost the colors a bit to make them stand out
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(POS.X - (28.5 * DestScale * ResolutionScaleX), POS.Y - (26 * DestScale * ResolutionScale));
		Canvas.DrawRotatedTile( AltHudTexture, Angle, 57 * DestScale * ResolutionScaleX, 52 * DestScale * ResolutionScale, 897, 452, 43, 43);
	}
}

defaultproperties
{
	bHasLeaderboard=false
	bShowDirectional=false

	ScoreboardSceneTemplate=UTUIScene_TeamScoreboard'UI_Scenes_Scoreboards.sbTeamDM'
	TeamScaleModifier=0.75

	TeamIconCenterPoints(0)=(x=140.0,y=27.0)
	TeamIconCenterPoints(1)=(x=5,y=13)

}

