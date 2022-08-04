/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the clan mates list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataProvider_OnlineClanMates extends UIDataProvider_OnlinePlayerDataBase
	native(inherit)
	implements(UIListElementCellProvider)
	dependson(OnlineSubsystem)
	transient;

/** Gets a copy of the clan mates data from the online subsystem */
//var array<OnlineClanMate> ClanMatesList;



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
	// If the player is None, we are in the editor
	if (Player != None)
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Set our callback function per player
//				PlayerInterface.SetReadClanMatesComplete(Player.ControllerId,OnClanMatesReadComplete);
				// Start the async task
/*				if (PlayerInterface.ReadClanMatesList(Player.ControllerId) == false)
				{
					`warn("Can't retrieve clan mates for player ("$Player.ControllerId$")");
				}
*/
			}
			else
			{
				`warn("OnlineSubsystem does not support the player interface. Can't retrieve clan mates for player ("$
					Player.ControllerId$")");
			}
		}
		else
		{
			`warn("No OnlineSubsystem present. Can't retrieve clan mates for player ("$
				Player.ControllerId$")");
		}
	}
}

/**
 * Handles the notification that the async read of the clan mates data is done
 */
function OnClanMatesReadComplete()
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
			// Make a copy of the clan mates data for the UI
//			PlayerInterface.GetClanMatesList(Player.ControllerId,ClanMatesList);
		}
	}
}
