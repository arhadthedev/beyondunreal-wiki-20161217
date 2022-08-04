/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for mapping properties in an OnlineGameSettings
 * object to something that the UI system can consume.
 */
class UIDataProvider_OnlineProfileSettings extends UIDataProvider_OnlinePlayerDataBase
	native(inherit)
	dependson(OnlineSubsystem)
	transient;

/** The profile settings that are used to load/save with the online subsystem */
var OnlineProfileSettings Profile;

/** For displaying in the provider tree */
var const name ProviderName;

/**
 * If there was an error, it was possible the read was already in progress. This
 * indicates to re-read upon a good completion
 */
var bool bWasErrorLastRead;

/** Keeps a list of providers for each profile settings id */
struct native ProfileSettingsArrayProvider
{
	/** The profile settings id that this provider is for */
	var int ProfileSettingsId;
	/** Cached to avoid extra look ups */
	var name ProfileSettingsName;
	/** The provider object to expose the data with */
	var UIDataProvider_OnlineProfileSettingsArray Provider;
};

/** The list of mappings from settings id to their provider */
var array<ProfileSettingsArrayProvider> ProfileSettingsArrayProviders;



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
				PlayerInterface.AddReadProfileSettingsCompleteDelegate(Player.ControllerId,OnReadProfileComplete);
				// Start the async task
				if (PlayerInterface.ReadProfileSettings(Player.ControllerId,Profile) == false)
				{
					bWasErrorLastRead = true;
					`warn("Can't retrieve profile for player ("$Player.ControllerId$")");
				}
			}
			else
			{
				`warn("OnlineSubsystem does not support the player interface. Can't retrieve profile for player ("$
					Player.ControllerId$")");
			}
		}
		else
		{
			`warn("No OnlineSubsystem present. Can't retrieve profile for player ("$
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
			// Clear our delegate
			PlayerInterface.ClearLoginChangeDelegate(OnLoginChange,Player.ControllerId);
			// Clear our callback function per player
			PlayerInterface.ClearReadProfileSettingsCompleteDelegate(Player.ControllerId,OnReadProfileComplete);
		}
	}
	Super.OnUnregister();
}

/**
 * Handles the notification that the async read of the profile data is done
 *
 * @param bWasSuccessful whether the call succeeded or not
 */
function OnReadProfileComplete(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	if (bWasSuccessful == true)
	{
		if (!bWasErrorLastRead)
		{
			// Notify any subscribers that we have new data
			NotifyPropertyChanged();
		}
		else
		{
			// Figure out if we have an online subsystem registered
			OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
			if (OnlineSub != None)
			{
				// Grab the player interface to verify the subsystem supports it
				PlayerInterface = OnlineSub.PlayerInterface;
				if (PlayerInterface != None)
				{
					bWasErrorLastRead = false;
					// Read again to copy any data from a read in progress
					if (PlayerInterface.ReadProfileSettings(Player.ControllerId,Profile) == false)
					{
						bWasErrorLastRead = true;
						`warn("Can't retrieve profile for player ("$Player.ControllerId$")");
					}
				}
			}
		}
	}
	else
	{
		bWasErrorLastRead = true;
		`Log("Failed to read online profile data");
	}
}

/**
 * Executes a refetching of the profile data when the login for this player
 * changes
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
			`Log("Login change...requerying profile data");
			// Start the async task
			if (PlayerInterface.ReadProfileSettings(Player.ControllerId,Profile) == false)
			{
				`warn("Can't retrieve profile data for player ("$Player.ControllerId$")");
				// Notify any owner data stores that we have changed data
				NotifyPropertyChanged();
			}
		}
	}
}

/**
 * Writes the profile data to the online subsystem for this user
 */
event bool SaveProfileData()
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
			// Start the async task
			return PlayerInterface.WriteProfileSettings(Player.ControllerId,Profile);
		}
	}
	return false;
}

defaultproperties
{
	ProviderName=ProfileData
	WriteAccessType=ACCESS_WriteAll
}
