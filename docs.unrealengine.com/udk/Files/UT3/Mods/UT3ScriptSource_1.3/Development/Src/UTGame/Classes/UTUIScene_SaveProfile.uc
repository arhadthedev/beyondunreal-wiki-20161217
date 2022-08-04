/**
 * Copyright � 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_SaveProfile extends UTUIScene
	native(UI);

var transient float OnScreenTime;
var transient int PlayerIndexToSave;
var transient bool bProfileSaved;
var transient bool bShutdown;

var transient float MinOnScreenTime;

/** If true, then use the elapsed time to close the save message */
var transient bool bUseTimedClose;



delegate OnSaveFinished();

event PostInitialize()
{
	OnRawInputKey = KillInput;
}

function bool KillInput( const out InputEventParameters EventParms )
{
	return true;
}

event PerformSave()
{
	local OnlineSubsystem OnlineSub;

	if (!bProfileSaved)
	{
		// Don't use the timed close on consoles as they are event driven
		bUseTimedClose = !IsConsole(CONSOLE_PS3);
		if (!bUseTimedClose)
		{
			OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
			if (OnlineSub != None && OnlineSub.PlayerInterface != None)
			{
				// Register the call back so we can shut down the scene upon completion
				OnlineSub.PlayerInterface.AddWriteProfileSettingsCompleteDelegate(PlayerIndexToSave,OnSaveProfileComplete);
			}
			else
			{
				// Use the timed method
				bUseTimedClose = true;
			}
		}
		SavePlayerProfile(PlayerIndexToSave);
		bProfileSaved = true;
	}
}

/**
 * Called when the save has completed the async operation
 *
 * @param bWasSuccessful whether the save worked ok or not
 */
function OnSaveProfileComplete(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None && OnlineSub.PlayerInterface != None)
	{
		// Register the call back so we can shut down the scene upon completion
		OnlineSub.PlayerInterface.ClearWriteProfileSettingsCompleteDelegate(PlayerIndexToSave,OnSaveProfileComplete);
	}
//@todo Amitt/JoeW -- show an error when failing to save
	ShutDown();
}

event ShutDown()
{
	CloseScene(Self);
	OnSaveFinished();
	OnSaveFinished = None;
}

defaultproperties
{
	bCloseOnLevelChange=true
	SceneInputMode=INPUTMODE_Simultaneous
	SceneRenderMode=SPLITRENDER_Fullscreen
	MinOnScreenTime=1.5
}
