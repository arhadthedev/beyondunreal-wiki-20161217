/**
 * This scene is displayed while the user is waiting for a connection to finish.  It has code for handling connection
 * error notifications and routing those errors back to its parent scenes.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIScene_ConnectionStatus extends UTUIScene_MessageBox;

/**
 * Called when a user has chosen one of the possible options available to them.
 * Begins hiding the dialog and calls the On
 *
 * @param OptionIdx		Index of the selection option.
 * @param PlayerIndex	Index of the player that selected the option.
 */
function OptionSelected(int OptionIdx, int PlayerIndex)
{
	local OnlineSubsystem OnlineSub;

	Super.OptionSelected(OptionIdx, PlayerIndex);

	// Store a reference to the game interface
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	
	//Is an online session in progress?
	if (OnlineSub != None && OnlineSub.GameInterface != None && OnlineSub.GameInterface.GetOnlineGameState() != OGS_NoSession)
	{
		// Set the destroy delegate so we can know when that is complete
		OnlineSub.GameInterface.AddDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);
		// Now we can destroy the game
		`Log("UTUIScene_ConnectionStatus::OptionSelected() - Destroying Online Game");
		
		// kill the pending connection
		OnlineSub.GameInterface.DestroyOnlineGame();
	}

	ConsoleCommand("CANCEL");
}

function OnDestroyOnlineGameComplete(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;
	local UTPlayerController PC;

	ScriptTrace();

	// Store a reference to the game interface
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	`Log("UTUIScene_ConnectionStatus::OnDestroyOnlineGameComplete() bWasSuccesful:"@bWasSuccessful);
	if (OnlineSub != None && OnlineSub.GameInterface != None)
	{
		OnlineSub.GameInterface.ClearDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);
	}

	//Clear the cache
	PC = GetUTPlayerOwner();
	if (PC != None && PC.WorldInfo.Game != None)
	{
	   PC.WorldInfo.Game.GameSettings = None;
	}
}

DefaultProperties
{
	bExemptFromAutoClose=true
}
