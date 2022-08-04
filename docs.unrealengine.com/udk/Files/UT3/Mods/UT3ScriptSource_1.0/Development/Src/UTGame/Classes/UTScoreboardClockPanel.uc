/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTScoreboardClockPanel extends UTDrawPanel;

var() Texture2D Background;
var() TextureCoordinates BackCoords;
var() LinearColor BackColor;

var() font ClockFont;
var() vector2d ClockPos;

/** Cached reference to the HUDSceneOwner */
var UTUIScene_Hud UTHudSceneOwner;

event PostInitialize()
{
	Super.PostInitialize();
	UTHudSceneOwner = UTUIScene_Hud( GetScene() );
}


event DrawPanel()
{
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;
	local string Clock;

	WI = UTHudSceneOwner.GetWorldInfo();
	GRI = UTGameReplicationInfo(WI.GRI);
	if (GRI != None && !GRI.bMatchISOver)
	{
		if ( Background != none )
		{
			Canvas.DrawColorizedTile(Background, Canvas.ClipX, Canvas.ClipY, BackCoords.U,BackCoords.V,BackCoords.UL,BackCoords.VL, BackColor);
		}

		if ( ClockFont != none )
		{
			Clock = class'UTHUD'.static.FormatTime( GRI.TimeLimit != 0 ? GRI.RemainingTime : GRI.ElapsedTime );
			Canvas.Font = ClockFont;
			Canvas.SetDrawColor(255,255,255,255);
			Canvas.SetPos(Canvas.ClipX * ClockPos.X, Canvas.ClipY * ClockPos.Y);
			Canvas.DrawText(Clock);
		}
	}
}



defaultproperties
{
}
