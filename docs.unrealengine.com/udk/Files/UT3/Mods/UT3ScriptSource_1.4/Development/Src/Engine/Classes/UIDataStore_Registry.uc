/**
 * Provides a general purpose global storage area for game or configuration data.
 */
class UIDataStore_Registry extends UIDataStore
	native(inherit);



/**
 * The data provider that contains the data fields which have been added to this data store.
 */
var	protected	UIDynamicFieldProvider		RegistryDataProvider;

/**
 * @return	the data provider which stores all registry data.
 */
final function UIDynamicFieldProvider GetDataProvider()
{
	return RegistryDataProvider;
}

DefaultProperties
{
	Tag=Registry
	WriteAccessType=ACCESS_WriteAll
}


