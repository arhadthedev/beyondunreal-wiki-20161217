﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTDuelQueueScoreboardPanel extends UTScoreboardPanel;

function GetPRIList(UTGameReplicationInfo GRI)
{
	local int i;
	local UTDuelPRI PRI;

	if (GRI != None)
	{
		for (i=0; i < GRI.PRIArray.Length; i++)
		{
			PRI = UTDuelPRI(GRI.PRIArray[i]);
			if (PRI != None && PRI.QueuePosition >= 0)
			{
				PRIList[PRI.QueuePosition] = PRI;
			}
		}
	}
}

/**
* Tests a PRI to see if we should display it on the scoreboard
*
* @Param PRI		The PRI to test
* @returns TRUE if we should display it, returns FALSE if we shouldn't
*/
function bool IsValidScoreboardPlayer( UTPlayerReplicationInfo PRI)
{
	return Super.IsValidScoreboardPlayer(PRI) && UTDuelPRI(PRI).QueuePosition >= 0;
}

function DrawScoreHeader()
{
	if ( HeaderFont != none )
	{
		Canvas.Font = HeaderFont;
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.SetPos(Canvas.ClipX * HeaderXPct,Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Name);
	}
}

function float DrawScore(UTPlayerReplicationInfo PRI, float YPos, int FontIndex, float FontScale)
{
	return Canvas.ClipX;
}

defaultproperties
{
	bMustDrawLocalPRI=false
}
