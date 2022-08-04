/**
 * Copyright � 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_TimedTutorialMessage extends UTUIScene
	native(UI);

var transient UILabel MessageText;
var transient bool bFinished;
var transient float OnTime;



event PostInitialize()
{

	Super.PostInitialize();
	MessageText = UILabel( FindChild('MessageText',true));

	OnTime = GetWorldInfo().TimeSeconds;
}

function SetValue(string Text)
{
	MessageText.SetValue(Text);
}


function AnimEnd(UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq)
{
	if ( AnimSeq.SeqName == 'FadeOut' )
	{
		CloseScene(self);
	}
}

defaultproperties
{
	SceneRenderMode=SPLITRENDER_Fullscreen
	bRenderParentScenes=false
	bPauseGameWhileActive=false
	bAlwaysRenderScene=true
	SceneInputMode=INPUTMODE_None
	bDisplayCursor=false
}
