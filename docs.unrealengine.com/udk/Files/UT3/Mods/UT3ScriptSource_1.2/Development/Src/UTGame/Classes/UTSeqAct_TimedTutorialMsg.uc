/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqAct_TimedTutorialMsg extends SequenceAction
	native;


/** Markup tutorial message to display */
var() string TutorialMessage;

/** Number of seconds to display the tutorial message */
var() float Duration;

/** True if the sequence should complete instantly; otherwise it finishes after the number of seconds specified in Duration */
var() bool bFireAndForget;


var transient UTUIScene_TimedTutorialMessage Scene;
var transient bool bFinished;

/** Transient: Number of seconds we've been alive. */
var transient float TimeSinceCreated;




/** Set the local player value on the scene. */
native final function LocalPlayer GetFirstLocalPlayer();

event Activated()
{
 	local GameUISceneClient SC;
 	local UIScene S;
	local UIScene ExistingScene;
	local String DisplayMessage;
	local LocalPlayer LP;
	local bool bHasScene;
	local int CurSceneIndex;

	bHasScene = false;

	LP = GetFirstLocalPlayer();

	// Reset our state
	bFinished = false;
	TimeSinceCreated = 0.0f;

	SC = class'UIRoot'.static.GetSceneClient();
	if (SC != none )
	{
		// Delete any existing timed tutorial message scenes
		for( CurSceneIndex = 0; CurSceneIndex < SC.ActiveScenes.length; ++CurSceneIndex )
		{
			ExistingScene = SC.ActiveScenes[ CurSceneIndex ];
			if( ExistingScene.IsA( 'UTUIScene_TimedTutorialMessage' ) )
			{
				// Kill it!
				SC.CloseScene( ExistingScene );

				// Restart iteration, in case our list was modified
				CurSceneIndex = 0;
			}
		}

		// Spawn our scene!
		SC.OpenScene(class'UTGameUISceneClient'.Default.TimedTutorialTemplate,LP,S);
		Scene = UTUIScene_TimedTutorialMessage(S);
		if ( Scene != none )
		{
			DisplayMessage = "<Strings:UTGameUI.Tutorials." $ TutorialMessage $ ">";
			Scene.SetValue(DisplayMessage);
			Scene.OnSceneDeactivated = OnSceneDeactivated;
			bHasScene = true;
		}
	}

	// If we were created as 'fire and forget', then we complete instantly.
	if( bFireAndForget )
	{
		OutputLinks[0].bHasImpulse = true;

		// Also, we complete instantly unless we have a tutorial message UI scene to display.
		if( !bHasScene )
		{
			bFinished = true;
		}
	}
}



function OnSceneDeactivated( UIScene DeactivatedScene )
{
	if ( DeactivatedScene == Scene )
	{
		Scene = none;

		if( !bFinished )
		{
			// We only need to fire out output if we haven't already asked for that
			if( !bFireAndForget )
			{
				OutputLinks[0].bHasImpulse = true;
			}

			bFinished = true;
		}
	}
}


event CloseSceneAndDie()
{
	local UISafeRegionPanel SP;

	if( !bFinished )
	{
		// We only need to fire out output if we haven't already asked for that
		if( !bFireAndForget )
		{
			OutputLinks[0].bHasImpulse = true;
		}

		bFinished = true;
	}

	if( Scene != none )
	{
		// Start closing the scene (it will fade out, then call back into OnSceneDeactivated)
		SP = UISafeRegionPanel(Scene.FindChild('SafeRegionPanel',true));
		if ( SP != none )
		{
			SP.PlayUIAnimation('FadeOut',,4.0);
			Scene.Findchild('Background',true).PlayUIAnimation('FadeOut',,4.0);
		}
	}
}


/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return true;
}

DefaultProperties
{
	bAutoActivateOutputLinks=false
	bCallHandler=false
	OutputLinks(0)=(LinkDesc="Success")
	ObjName="Timed Tutorial Message"
	ObjCategory="Tutorials"
	bFinished=false;
	bLatentExecution=true;
	Duration=5.0
	bFireAndForget=true
}
