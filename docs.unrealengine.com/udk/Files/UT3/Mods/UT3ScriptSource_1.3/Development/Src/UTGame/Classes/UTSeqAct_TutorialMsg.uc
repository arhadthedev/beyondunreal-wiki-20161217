/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqAct_TutorialMsg extends SequenceAction
	native;


/** The Message to display.  You can enter it directly here or use markup */
var() string TutorialMessage;
var() surface TutorialImage;	// TODO: Add this to the custom scene

var transient UTUIScene_TutorialMessage Scene;
var transient bool bFinished;



/** Set the local player value on the scene. */
native final function LocalPlayer GetFirstLocalPlayer();

event Activated()
{
 	local GameUISceneClient SC;
 	local UIScene S;
	local String DisplayMessage;
	local LocalPlayer LP;
	local bool bHasScene;

	bHasScene = false;


	bFinished = false;
	if( len( TutorialMessage ) > 0 )
	{
 		SC = class'UIRoot'.static.GetSceneClient();
 		if (SC != none )
 		{
			LP = GetFirstLocalPlayer();
			SC.OpenScene(class'UTGameUISceneClient'.Default.TutorialTemplate,LP,S);
			Scene = UTUIScene_TutorialMessage(S);
			if ( Scene != none )
			{
				DisplayMessage = "<Strings:UTGameUI.Tutorials." $ TutorialMessage $ ">";
				Scene.SetValue(DisplayMessage);
				Scene.OnSceneDeactivated = OnSceneDeactivated;
				bHasScene = true;
			}
 		}
	}


	// We complete instantly unless we have a tutorial message UI scene to display
	if( !bHasScene )
	{
		bFinished = true;
		OutputLinks[0].bHasImpulse = true;
	}
}



function OnSceneDeactivated( UIScene DeactivatedScene )
{
	if ( DeactivatedScene == Scene )
	{
		bFinished = true;
		OutputLinks[0].bHasImpulse = true;
		Scene = none;
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
	ObjName="Set Tutorial Message"
	ObjCategory="Tutorials"
	bFinished=false;
	bLatentExecution=true;
}
