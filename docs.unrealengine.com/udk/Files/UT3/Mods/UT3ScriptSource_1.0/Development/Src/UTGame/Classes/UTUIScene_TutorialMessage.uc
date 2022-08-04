/**
 * Copyright � 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_TutorialMessage extends UTUIScene
	native(UI);

var transient UILabel MessageText;
var transient bool bFinished;
var transient float OnTime;



event PostInitialize()
{

	Super.PostInitialize();
	MessageText = UILabel( FindChild('MessageText',true));

	// Setup a key handling delegate.
	OnRawInputKey=HandleInputKey;

	// NOTE: We use real-time seconds here because the game may be paused while this UI is up, and
	// we don't want that to affect our timing
	OnTime = GetWorldInfo().RealTimeSeconds;

}

function SetValue(string Text)
{
	MessageText.SetValue(Text);
}

function FlushInput()
{
	local UTPlayerController PC;
	local int PlayerIndex;

	PlayerIndex = 0;
	PC = GetUTPlayerOwner(PlayerIndex);

	while (PC != none )
	{
		UTPlayerInput(PC.PlayerInput).ForceFlushOfInput();
		PlayerIndex++;
		PC = GetUTPlayerOwner(PlayerIndex);
	}

}

function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local UISafeRegionPanel SP;
	local string Command;
	local UTPlayerController PC;

	if (!bFinished)
	{
		// NOTE: We use real-time seconds here because the game may be paused while this UI is up, and
		// we don't want that to affect our timing
		if (GetWorldInfo().RealTimeSeconds - OnTime > 0.5)
		{
			if ( EventParms.EventType == IE_Released )
			{
				PC = GetUTPlayerOwner(EventParms.PlayerIndex);
				if (PC != none )
				{
					Command = PC.PlayerInput.GetBind(EventParms.InputKeyName);
					if ( Command ~= "GBA_Fire" )
					{
						SP = UISafeRegionPanel(FindChild('SafeRegionPanel',true));
						if ( SP != none )
						{
							SP.PlayUIAnimation('FadeOut',,4.0);
							Findchild('Background',true).PlayUIAnimation('FadeOut',,4.0);
							bFinished = true;
						}
					}
				}
			}
		}
	}
	return !bFinished;
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
	SceneInputMode=INPUTMODE_Locked
	bDisplayCursor=false
}
