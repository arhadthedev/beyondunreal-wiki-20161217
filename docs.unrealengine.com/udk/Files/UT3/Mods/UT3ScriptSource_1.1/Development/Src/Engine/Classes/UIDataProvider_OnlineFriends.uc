/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the friends list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataProvider_OnlineFriends extends UIDataProvider_OnlinePlayerDataBase
	native(inherit)
	implements(UIListElementCellProvider)
	dependson(OnlineSubsystem)
	transient;

/** Gets a copy of the friends data from the online subsystem */
var array<OnlineFriend> FriendsList;

/** The column name to display in the UI */
var localized string NickNameCol;

/** The column name to display in the UI */
var localized string PresenceInfoCol;

/** The column name to display in the UI */
var localized string bIsOnlineCol;

/** The column name to display in the UI */
var localized string bIsPlayingCol;

/** The column name to display in the UI */
var localized string bIsPlayingThisGameCol;

/** The column name to display in the UI */
var localized string bIsJoinableCol;

/** The column name to display in the UI */
var localized string bHasVoiceSupportCol;



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
				// Register that we are interested in any sign in change for this player
				PlayerInterface.AddLoginChangeDelegate(OnLoginChange,Player.ControllerId);
				// Set our callback function per player
				PlayerInterface.AddReadFriendsCompleteDelegate(Player.ControllerId,OnFriendsReadComplete);
				// Start the async task
				if (PlayerInterface.ReadFriendsList(Player.ControllerId) == false)
				{
					`warn("Can't retrieve friends for player ("$Player.ControllerId$")");
				}
			}
			else
			{
				`warn("OnlineSubsystem does not support the player interface. Can't retrieve friends for player ("$
					Player.ControllerId$")");
			}
		}
		else
		{
			`warn("No OnlineSubsystem present. Can't retrieve friends for player ("$
				Player.ControllerId$")");
		}
	}
}

/**
 * Clears our delegate for getting login change notifications
 */
event OnUnregister()
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
			// Set our callback function per player
			PlayerInterface.ClearReadFriendsCompleteDelegate(Player.ControllerId,OnFriendsReadComplete);
			// Clear our delegate
			PlayerInterface.ClearLoginChangeDelegate(OnLoginChange,Player.ControllerId);
		}
	}
	Super.OnUnregister();
}

/**
 * Handles the notification that the async read of the friends data is done
 *
 * @param bWasSuccessful whether the call completed ok or not
 */
function OnFriendsReadComplete(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	if (bWasSuccessful == true)
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Make a copy of the friends data for the UI
				PlayerInterface.GetFriendsList(Player.ControllerId,FriendsList);
			}
		}
		// Notify any subscribers that we have new data
		NotifyPropertyChanged();
	}
	else
	{
		`Log("Failed to read friends list");
	}
}

/**
 * Executes a refetching of the friends data when the login for this player
 * changes
 */
function OnLoginChange()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	FriendsList.Length = 0;
	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			// Start the async task
			if (PlayerInterface.ReadFriendsList(Player.ControllerId) == false)
			{
				`warn("Can't retrieve friends for player ("$Player.ControllerId$")");
				// Notify any subscribers that we have changed data
				NotifyPropertyChanged();
			}
		}
	}
}

/** Re-reads the friends list to freshen any cached data */
event RefreshFriendsList()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

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
				// Start the async task
				PlayerInterface.ReadFriendsList(Player.ControllerId);
				`log("Refreshing friends list");
			}
		}
	}
	else
	{
		`warn("No player to refresh the friends list for");
	}
}