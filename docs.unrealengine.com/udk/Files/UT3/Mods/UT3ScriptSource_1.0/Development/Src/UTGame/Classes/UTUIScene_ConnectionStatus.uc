/**
 * This scene is displayed while the user is waiting for a connection to finish.  It has code for handling connection
 * error notifications and routing those errors back to its parent scenes.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIScene_ConnectionStatus extends UTUIScene_MessageBox;

function ConnectionStatus_OptionSelected(int SelectedOption, int PlayerIndex)
{
	local OnlineSubsystem OnlineSub;

	// Store a reference to the game interface
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if ( OnlineSub != None && OnlineSub.GameInterface != None )
	{
		// kill the pending connection
		OnlineSub.GameInterface.DestroyOnlineGame();
	}
	ConsoleCommand("CANCEL");
}

DefaultProperties
{
	bExemptFromAutoClose=true
}
