/**
 * Provides the UI with all data associated with the player which owns this viewport.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class PlayerOwnerDataStore extends UIDataStore_GameState
	native(inherit);



`include(Core/Globals.uci)

/**
 * Contains the classes which should be used for instancing data providers.
 */
struct native PlayerDataProviderTypes
{
	/**
	 * the class to use for the player owner data provider
	 */
	var const	class<PlayerOwnerDataProvider>		PlayerOwnerDataProviderClass;

	/**
	 * the class to use for the current weapon data provider
	 */
	var	const	class<CurrentWeaponDataProvider>	CurrentWeaponDataProviderClass;

	/**
	 * the class to use for the general weapon data providers
	 */
	var const	class<WeaponDataProvider>			WeaponDataProviderClass;

	/**
	 * the class to use for the power data provider.
	 */
	var	const	class<PowerupDataProvider>			PowerupDataProviderClass;
};

/**
 * The data provider types used by this PlayerOwnerDataStore
 */
var	const	PlayerDataProviderTypes			ProviderTypes;

/**
 * The PlayerDataProvider for the owning player.
 */
var	protected	PlayerOwnerDataProvider		PlayerData;

/**
 * The WeaponDataProvider associated with the currently selected weapon.
 * @todo - not yet implemented
 */
var	protected	CurrentWeaponDataProvider	CurrentWeapon;

/**
 * Weapon data providers for all weapons currently held by the player.
 * @todo - not yet implemented
 */
var	protected	array<WeaponDataProvider>	WeaponList;

/**
 * PowerupDataProvider for all powerups currently in the players inventory.
 * @todo - not yet implemented
 */
var	protected	array<PowerupDataProvider>	PowerupList;


/**
 * Links the PlayerDataProvider for the local player to this data store.
 *
 * @param	NewPlayerData	the new PlayerDataProvider to use for presenting this player's data to the UI.
 */
function SetPlayerDataProvider( PlayerDataProvider NewPlayerData )
{
	`log(">>" @ `location,,'DevDataStore');

	if ( NewPlayerData != None )
	{
		`log(`location@"creating new PlayerOwnerDataProvider for" @ NewPlayerData @ "and linking to 'PlayerOwner' data store" @ Self,,'DevDataStore');
		if ( PlayerData != None )
		{
			PlayerData.CleanupDataProvider();
		}

		PlayerData = new ProviderTypes.PlayerOwnerDataProviderClass;
	}

	if ( PlayerData != None )
	{
		PlayerData.SetPlayerDataProvider(NewPlayerData);
	}

	`log("<<" @ `location,,'DevDataStore');
}

/**
 * Clears all data provider references.
 */
final function ClearDataProviders()
{
	local int i;

	`log(">>" @ `location,,'DevDataStore');

	if ( PlayerData != None )
	{
		PlayerData.CleanupDataProvider();
	}

	if ( CurrentWeapon != None )
	{
		CurrentWeapon.CleanupDataProvider();
	}

	for ( i = 0; i < WeaponList.Length; i++ )
	{
		WeaponList[i].CleanupDataProvider();
	}

	for ( i = 0; i < PowerupList.Length; i++ )
	{
		PowerupList[i].CleanupDataProvider();
	}

	// now clear the references
	PlayerData = None;
	CurrentWeapon = None;
	WeaponList.Length = 0;
	PowerupList.Length = 0;

	`log("<<" @ `location,,'DevDataStore');
}

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 *
 * @return	TRUE indicates that this data store should be automatically unregistered when this game session ends.
 */
function bool NotifyGameSessionEnded()
{
	ClearDataProviders();

	return Super.NotifyGameSessionEnded();
}


DefaultProperties
{
	Tag=PlayerOwner

	ProviderTypes={(
		PlayerOwnerDataProviderClass=class'Engine.PlayerOwnerDataProvider',
		CurrentWeaponDataProviderClass=class'Engine.CurrentWeaponDataProvider',
		WeaponDataProviderClass=class'Engine.WeaponDataProvider',
		PowerupDataProviderClass=class'Engine.PowerupDataProvider'
	)}
}
