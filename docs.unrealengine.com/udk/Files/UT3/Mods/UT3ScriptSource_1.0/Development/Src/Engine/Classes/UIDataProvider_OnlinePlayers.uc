/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the players list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataProvider_OnlinePlayers extends UIDataProvider_OnlinePlayerDataBase
	native(inherit)
	implements(UIListElementCellProvider)
	dependson(OnlineSubsystem)
	transient;

/** Gets a copy of the players data from the online subsystem */
//var array<OnlinePlayer> PlayersList;



/**
 * Binds the player to this provider. Starts the async friends list gathering
 *
 * @param InPlayer the player that we are retrieving friends for
 */
event OnRegister(LocalPlayer InPlayer)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Super.OnRegister(InPlayer);
	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	// If the player is None, we are in the editor
	if (Player != None)
	{
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Set our callback function per player
//				PlayerInterface.SetReadPlayersComplete(Player.ControllerId,OnPlayersReadComplete);
				// Start the async task
/*				if (PlayerInterface.ReadPlayersList(Player.ControllerId) == false)
				{
					`Warn("Can't retrieve recent players list for player ("$Player.ControllerId$")");
				}
*/
			}
			else
			{
				`Warn("OnlineSubsystem does not support the player interface. Can't retrieve recent players list for player ("$
					Player.ControllerId$")");
			}
		}
		else
		{
			`Warn("No OnlineSubsystem present. Can't retrieve recent players list for player ("$
				Player.ControllerId$")");
		}
	}
}

/**
 * Handles the notification that the async read of the players data is done
 */
function OnPlayersReadComplete()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			// Make a copy of the players data for the UI
//			PlayerInterface.GetPlayersList(Player.ControllerId,PlayersList);
		}
	}
}
