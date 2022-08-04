/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTCTFScoreboardPanel extends UTTDMScoreboardPanel;

var() Texture2D FlagTexture;
var() TextureCoordinates FlagCoords;

/** Sets the header strings using localized values */
function SetHeaderStrings()
{
	HeaderTitle_Name = Localize( "Scoreboards", "Name", "UTGameUI" );
	HeaderTitle_Score = Localize( "Scoreboards", "Score", "UTGameUI" );
}

/** Draw the panel headers. */
function DrawScoreHeader()
{
	local float xl,yl,columnWidth, numXL, numYL;

	if ( HeaderFont != none )
	{
		Canvas.SetDrawColor(255,255,255,255);

		Canvas.Font = Fonts[EFT_Large].Font;
		Canvas.StrLen("0000",numXL,numYL);

		Canvas.Font = HeaderFont;
		Canvas.SetPos(Canvas.ClipX * HeaderXPct,Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Name);

		Canvas.StrLen(HeaderTitle_Score,xl,yl);
		RightColumnWidth = xl;
		columnWidth = Max(xl+0.25f*numXL, numXL);
		RightColumnPosX = Canvas.ClipX - columnWidth;
		Canvas.SetPos(RightColumnPosX,Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Score);
	}
}

/**
* Draw the Player's Score
*/
function float DrawScore(UTPlayerReplicationInfo PRI, float YPos, int FontIndex, float FontScale)
{
	local string Spot;
	local float Width, Height;

	// Draw the player's Kills
	Spot = GetPlayerScore(PRI);
	Canvas.StrLen(Spot, Width, Height);
	DrawString( Spot, RightColumnPosX+RightColumnWidth-Width, YPos,FontIndex,FontScale);

	return RightColumnPosX;
}

simulated function DrawPlayerNum(UTPlayerReplicationInfo PRI, int PIndex, out float YPos, float FontIndex, float FontScale)
{
	local float W,H,Y;
	local float XL, YL;
	local color C;

	if ( FlagTexture != none && PRI.bHasFlag )
	{
		C = Canvas.DrawColor;

    	// Figure out how much space we have

		StrLen("00",XL,YL, FontIndex, FontScale);
		W = XL * 0.8;
		H = W * (FlagCoords.VL / FlagCoords.UL);

        Y = YPos + (YL * 0.5) - (H * 0.5);

		Canvas.SetPos(0, Y);
		Canvas.SetDrawColor(255,255,0,255);
		Canvas.DrawTile(FlagTexture, W, H, FlagCoords.U, FlagCoords.V, FlagCoords.UL, FlagCoords.VL);

		Canvas.DrawColor = C;

	}
}


function string GetRightMisc(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		if (RightMiscStr != "")
		{
			return UserString(RightMiscStr,PRI);
		}

		return "";

	}
	return "RMisc";
}


defaultproperties
{
	FlagTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseE'
	FlagCoords=(U=756,V=0,UL=67,VL=40)
	bDrawPlayerNum=true
	HeaderTitle_Score="Score"
}
