/**
 * Provides data about a particular instance of an actor in the game.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIDynamicDataProvider extends UIPropertyDataProvider
	native(inherit)
	abstract;



/**
 * The metaclass for this data provider.  Each instance of this class (including instances of child classes) will have
 * a data provider that tells the UI which properties to provide for this class.  Classes indicate which properties are
 * available for use by dynamic data stores by marking the property with a keyword.
 */
var	const							class	DataClass;

/**
 * The object that this data provider is presenting data for.  Set by calling BindProviderInstance.
 */
var	const	transient	protected	Object	DataSource;


/* == Natives == */
/**
 * Associates this data provider with the specified instance.
 *
 * @param	DataSourceInstance	a pointer to the object instance that this data provider should present data for.  DataSourceInstance
 *								must be of type DataClass.
 *
 * @return	TRUE if the instance specified was successfully associated with this data provider.  FALSE if the object specified
 *			wasn't of the correct type or was otherwise invalid.
 */
native final function bool BindProviderInstance( Object DataSourceInstance );

/**
 * Clears the instance associated with this data provider.
 *
 * @return	TRUE if the instance reference was successfully cleared.
 */
native final function bool UnbindProviderInstance();

/* == Events == */

/**
 * Called once BindProviderInstance has successfully verified that DataSourceInstance is of the correct type.  Child classes
 * can override this function to handle storing the reference, for example.
 */
event ProviderInstanceBound( Object DataSourceInstance );

/**
 * Called immediately after this data provider's DataSource is disassociated from this data provider.
 */
event ProviderInstanceUnbound( Object DataSourceInstance );

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
 * Returns a reference to the data source associated with this data provider.
 */
final function Object GetDataSource()
{
	return DataSource;
}

/**
 * Allows the data provider to clear any references that would interfere with garbage collection.
 *
 * @return	TRUE if the instance reference was successfully cleared.
 */
function bool CleanupDataProvider()
{
	return UnbindProviderInstance();
}

DefaultProperties
{

}
