/**
 * This class provides the UI with access to game session settings providers.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 *
 * @fixme - not ready for use yet!
 */
class UIDataStore_SessionSettings extends UIDataStore_Settings
	native(inherit);




/**
 * Array of SessionSettingsProvider derived class names to load and initialize
 */
var	const	config		array<string>							SessionSettingsProviderClassNames;

/**
 * Array of SessionSettingsProvider derived classes loaded from SessionSettingsProviderClassNames.  Filled in InitializeDataStore().
 */
var	const	transient	array<class<SessionSettingsProvider> >	SessionSettingsProviderClasses;

/**
 * The data providers for all session settings, such as game info settings, access control settings, etc.
 */
var			transient	array<SessionSettingsProvider>			SessionSettings;

/**
 * Clears all data provider references.
 */
final function ClearDataProviders()
{
	local int i;

	for ( i = 0; i < SessionSettings.Length; i++ )
	{
		//@todo - what to do if CleanupDataProvider return false?
		SessionSettings[i].CleanupDataProvider();
	}

	SessionSettings.Length = 0;
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
	Tag=GameSettings
}
