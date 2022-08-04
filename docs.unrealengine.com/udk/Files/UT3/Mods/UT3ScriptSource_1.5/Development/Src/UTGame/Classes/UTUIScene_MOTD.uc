﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_MOTD extends UTUIScene_Hud
	native(UI);


var bool bFadingOut;
var transient UISafeRegionPanel Panel;
var transient UTDrawPanel DrawPanel;





event PostInitialize()
{
	local worldinfo WI;
	local UTGameReplicationInfo GRI;
	local class<UTGame> GC;
	local UILabel Lbl;
	Super.PostInitialize();

	Panel = UISafeRegionPanel(FindChild('SafePanel',true));
//	Panel.PlayUIAnimation('FadeIn',,0.5);

	WI = GetWorldInfo();
	if ( WI != none )
	{
		GC = class<UTGame>(WI.GetGameClass());
		GRI = UTGameReplicationInfo(WI.GRI);
		if (GRI != none && GC != none)
		{
		 	Lbl = UILabel(FindChild('ServerRules',true));
		 	if ( Lbl != none )
		 	{
		 		Lbl.SetDatastorebinding( GC.static.GetEndOfMatchRules(GRI.GoalScore, GRI.TimeLimit) );
		 	}
		}
	}
}

event Finish()
{
	bFadingOut = true;
	Panel.PlayUIAnimation('FadeOut',,0.5);
}

function AnimEnd(UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq)
{
	if (AnimSeq.SeqName == 'FadeOut')
	{
		SceneClient.CloseScene(Self);
	}
}

defaultproperties
{
}
