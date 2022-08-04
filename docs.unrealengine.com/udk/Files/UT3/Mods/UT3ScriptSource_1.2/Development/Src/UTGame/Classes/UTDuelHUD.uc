/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDuelHUD extends UTTeamHUD;

/** left like this for binary compatibility */
function DrawGameHUD()
{
	Super.DrawGameHUD();
}

function DrawLivingHUD()
{
	local int i, TeamIndex;
	local float XL, YL;

	Super.DrawLivingHUD();

	if (bShowHUD && bShowScoring && !bShowScores && WorldInfo.GRI != None && (!bIsSplitScreen || bIsFirstPlayer) )
	{
		TeamIndex = UTPlayerOwner.GetTeamNum();
		if (TeamIndex == 255 || bIsSplitScreen)
		{
			// spectator
			TeamIndex = 0;
		}
		for (i = 0; i < WorldInfo.GRI.PRIArray.length; i++)
		{
			if (WorldInfo.GRI.PRIArray[i].Team != None)
			{
				Canvas.Font = GetFontSizeIndex(1);
				Canvas.DrawColor = WorldInfo.GRI.PRIArray[i].Team.GetTextColor();
				Canvas.StrLen(WorldInfo.GRI.PRIArray[i].GetPlayerAlias(), XL, YL);
				Canvas.SetPos( (WorldInfo.GRI.PRIArray[i].Team.TeamIndex == TeamIndex) ? (Canvas.ClipX * 0.45 - XL) : (Canvas.ClipX * 0.55),
						Canvas.ClipY * 0.10 );
				Canvas.DrawText(WorldInfo.GRI.PRIArray[i].GetPlayerAlias());
			}
		}
	}
}

function DisplayFragCount(vector2d POS) {}
function DisplayLeaderBoard(vector2d POS) {}

defaultproperties
{
	ScoreboardSceneTemplate=UTUIScene_Scoreboard'UI_Scenes_Scoreboards.sbDuel'
}
