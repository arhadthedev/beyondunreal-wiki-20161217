/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the friends list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataStore_OnlinePlayerData extends UIDataStore_Remote
	native(inherit)
	implements(UIListElementProvider)
	config(Engine)
	transient;

/** Provides access to the player's online friends list */
var UIDataProvider_OnlineFriends FriendsProvider;

/** Provides access to the player's recent online players list */
var UIDataProvider_OnlinePlayers PlayersProvider;

/** Provides access to the player's clan members list */
var UIDataProvider_OnlineClanMates ClanMatesProvider;

/** Holds the player that this provider is getting friends for */
var LocalPlayer Player;

/** The online nick name for the player */
var string PlayerNick;

/** The number of new downloads for this player */
var int NumNewDownloads;

/** The total number of downloads for this player */
var int NumTotalDownloads;

/** The name of the OnlineProfileSettings class to use as the default */
var config string ProfileSettingsClassName;

/** The class that should be created when a player is bound to this data store */
var class<OnlineProfileSettings> ProfileSettingsClass;

/** Provides access to the player's profile data */
var UIDataProvider_OnlineProfileSettings ProfileProvider;

/** Provides access to any friend messages */
var UIDataProvider_OnlineFriendMessages FriendMessagesProvider;

/** The name of the data provider class to use as the default for friends */
var config string FriendsProviderClassName;

/** The class that should be created when a player is bound to this data store */
var class<UIDataProvider_OnlineFriends> FriendsProviderClass;

/** The name of the data provider class to use as the default for recent players list */
var config string PlayersProviderClassName;

/** The class that should be created when a player is bound to this data store */
var class<UIDataProvider_OnlinePlayers> PlayersProviderClass;

/** The name of the data provider class to use as the default for clan mates */
var config string ClanMatesProviderClassName;

/** The class that should be created when a player is bound to this data store */
var class<UIDataProvider_OnlineClanMates> ClanMatesProviderClass;

/** The name of the data provider class to use as the default for messages */
var config string FriendMessagesProviderClassName;

/** The class that should be created when a player is bound to this data store */
var class<UIDataProvider_OnlineFriendMessages> FriendMessagesProviderClass;



/**
 * Binds the player to this provider. Starts the async friends list gathering
 *
 * @param InPlayer the player that we are retrieving friends for
 */
event OnRegister(LocalPlayer InPlayer)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Player = InPlayer;
	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			// We need to know when the player's login changes
			PlayerInterface.AddLoginChangeDelegate(OnLoginChange,Player.ControllerId);
		}
		if (OnlineSub.PlayerInterfaceEx != None)
		{
			// We need to know when the player changes data (change nick name, etc)
			OnlineSub.PlayerInterfaceEx.AddProfileDataChangedDelegate(Player.ControllerId,OnPlayerDataChange);
		}
		if (OnlineSub.ContentInterface != None)
		{
			// Set the delegate for updating the downloadable content info
			OnlineSub.ContentInterface.AddQueryAvailableDownloadsComplete(Player.ControllerId,OnDownloadableContentQueryDone);
		}
	}
	// Force a refresh
	OnLoginChange();
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
			// Clear our delegate
			PlayerInterface.ClearLoginChangeDelegate(OnLoginChange,Player.ControllerId);
		}
		if (OnlineSub.PlayerInterfaceEx != None)
		{
			// Clear for GC reasons
			OnlineSub.PlayerInterfaceEx.ClearProfileDataChangedDelegate(Player.ControllerId,OnPlayerDataChange);
		}
		if (OnlineSub.ContentInterface != None)
		{
			// Clear the delegate for updating the downloadable content info
			OnlineSub.ContentInterface.ClearQueryAvailableDownloadsComplete(Player.ControllerId,OnDownloadableContentQueryDone);
		}
	}
}

/**
 * Refetches the player's nick name from the online subsystem
 */
function OnLoginChange()
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
			// Start a query for downloadable content...
			if(OnlineSub.ContentInterface != None)
			{
				OnlineSub.ContentInterface.QueryAvailableDownloads(Player.ControllerId);
			}
			// Get the name and force a refresh
			PlayerNick = PlayerInterface.GetPlayerNickname(Player.ControllerId);
			RefreshSubscribers();
		}
	}
}

/**
 * Refetches the player's nick name from the online subsystem
 */
function OnPlayerDataChange()
{
	local OnlineSubsystem OnlineSub;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		if (OnlineSub.PlayerInterface != None)
		{
			// Get the name and force a refresh
			PlayerNick = OnlineSub.PlayerInterface.GetPlayerNickname(Player.ControllerId);
			RefreshSubscribers();
		}
	}
}

/**
 * Registers the delegates with the providers so we can know when async data changes
 */
event RegisterDelegates()
{
	FriendsProvider.AddPropertyNotificationChangeRequest(OnProviderChanged);
	FriendMessagesProvider.AddPropertyNotificationChangeRequest(OnProviderChanged);
	PlayersProvider.AddPropertyNotificationChangeRequest(OnProviderChanged);
	ClanMatesProvider.AddPropertyNotificationChangeRequest(OnProviderChanged);
	ProfileProvider.AddPropertyNotificationChangeRequest(OnProviderChanged);
}

/**
 * Handles notification that one of our providers has changed and in turn
 * notifies the UI system
 *
 * @param	SourceProvider	the data provider that generated the notification
 * @param	PropTag			the property that changed
 */
function OnProviderChanged(UIDataProvider SourceProvider, optional name PropTag)
{
	RefreshSubscribers(PropTag, true, SourceProvider);
}

/**
 * Caches the downloadable content info for the player we're bound to
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnDownloadableContentQueryDone(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None && OnlineSub.ContentInterface != None)
	{
		if (bWasSuccessful == true)
		{
			// Read the data and tell the UI to refresh
			OnlineSub.ContentInterface.GetAvailableDownloadCounts(Player.ControllerId,
				NumNewDownloads,NumTotalDownloads);
			RefreshSubscribers();
		}
		else
		{
			`Log("Failed to query for downloaded content");
		}
	}
}

/** Forwards the call to the provider */
event bool SaveProfileData()
{
	if (ProfileProvider != None)
	{
		return ProfileProvider.SaveProfileData();
	}
	return false;
}

defaultproperties
{
	Tag=OnlinePlayerData
	// So something shows up in the editor
	PlayerNick="PlayerNickNameHere"
}
