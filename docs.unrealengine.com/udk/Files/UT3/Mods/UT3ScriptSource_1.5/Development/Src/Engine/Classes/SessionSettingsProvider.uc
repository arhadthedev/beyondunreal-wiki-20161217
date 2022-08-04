/**
 * Provides the UI with read/write access to settings which affect gameplay, such as gameinfo, mutator, and maplist settings.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * @todo - make this class also expose a copy of all settings as an array called "Settings" so that the UI can autogenerate lists
 * of menu options, ala GUIMultiOptionList in UT2004.
 *
 * @fixme - not ready for use yet!
 */
class SessionSettingsProvider extends UISettingsProvider
	within UIDataStore_SessionSettings
	native(inherit)
	abstract;



/**
 * this is the UISettingsClient class that is used as the interface for retrieving metadata from data sources;  only used
 * by C++ to easily determine whether arbitrary classes implement the correct interface for use by this data provider
 */
var	const				private		class<UISettingsClient>		ProviderClientClass;

/**
 * The metaclass for this data provider.  Classes indicate which properties are available for use by settings data stores
 * by marking the property with a keyword.  Must implement the UISettingsClient interface.
 */
var	const							class						ProviderClientMetaClass;

/**
 * the class that will provide the properties and metadata for the settings exposed in this provider.  Set by calling
 * BindProviderInstance.
 */
var	const	transient				class						ProviderClient;

/* == Natives == */
/**
 * Associates this data provider with the specified class.
 *
 * @param	DataSourceClass	a pointer to the specific child of Dataclass that this data provider should present data for.
 *
 * @return	TRUE if the class specified was successfully associated with this data provider.  FALSE if the object specified
 *			wasn't of the correct type or was otherwise invalid.
 */
native final function bool BindProviderClient( class DataSourceClass );

/**
 * Clears the reference to the class associated with this data provider.
 *
 * @return	TRUE if the class reference was successfully cleared.
 */
native final function bool UnbindProviderClient();

/* == Events == */

/**
 * Called once BindProviderInstance has successfully verified that DataSourceInstance is of the correct type.  Child classes
 * can override this function to handle storing the reference, for example.
 */
event ProviderClientBound( class DataSourceClass );

/**
 * Called immediately after this data provider's DataSource is disassociated from this data provider.
 */
event ProviderClientUnbound( class DataSourceClass );

/**
 * Script hook for preventing a particular child of DataClass from being represented by this dynamic data provider.
 *
 * @param	PotentialDataSourceClass	a child class of DataClass that is being considered as a candidate for binding by this provider.
 *
 * @return	return FALSE to prevent PotentialDataSourceClass's properties from being added to the UI editor's list of bindable
 *			properties for this data provider; also prevents any instances of PotentialDataSourceClass from binding to this provider
 *			at runtime.
 */
event bool IsValidDataSourceClass( class PotentialDataSourceClass )
{
	return true;
}

/**
 * Allows the data provider to clear any references that would interfere with garbage collection.
 */
function bool CleanupDataProvider()
{
	if ( ProviderClient != None )
	{
		return UnbindProviderClient();
	}

	return false;
}

DefaultProperties
{
	ProviderTag=SessionSettingsProvider

	ProviderClientClass=class'Engine.UISettingsClient'
}

