/**
 * This data store class is used for providing access to data that should only have the lifetime of the current scene.
 * Each scene has its own SceneDataStore, which is capable of containing an arbitrary number of data elements, configurable
 * by the designer using the UI editor.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class SceneDataStore extends UIDataStore
	native(UIPrivate)
	implements(UIListElementProvider,UIListElementCellProvider)
	nontransient;

var	const	transient	UIScene				OwnerScene;

/**
 * The data provider that contains the data fields supported by this scene data store
 */
var	protected	UIDynamicFieldProvider		SceneDataProvider;



/* == Delegates == */

/* == Events == */

/* == Natives == */

/* == UnrealScript == */
/**
 * Adds a new data field to the list of supported fields.
 *
 * @param	FieldName			the name to give the new field
 * @param	FieldType			the type of data field being added
 * @param	bPersistent			specify TRUE to add the field to the PersistentDataFields array as well.
 * @param	out_InsertPosition	allows the caller to find out where the element was inserted
 *
 * @return	TRUE if the field was successfully added to the list; FALSE if the a field with that name already existed
 *			or the specified name was invalid.
 */
final function bool AddField( name FieldName, EUIDataProviderFieldType FieldType=DATATYPE_Property, optional bool bPersistent, optional out int out_InsertPosition )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.AddField(FieldName, FieldType, bPersistent, out_InsertPosition);
	}

	return false;
}

/**
 * Removes the data field that has the specified tag.
 *
 * @param	FieldName	the name of the data field to remove from this data provider.
 *
 * @return	TRUE if the field was successfully removed from the list of supported fields or the field name wasn't in the list
 *			to begin with; FALSE if the name specified was invalid or the field couldn't be removed for some reason
 */
final function bool RemoveField( name FieldName )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.RemoveField(FieldName);
	}

	return false;
}

/**
 * Finds the index into the DataFields array for the data field specified.
 *
 * @param	FieldName	the name of the data field to search for
 * @param	bSearchPersistentFields		if TRUE, searches the PersistentDataFields array for the specified field; otherwise,
 *										searches the RuntimeDataFields array
 *
 * @param	the index into the DataFields array for the data field specified, or INDEX_NONE if it isn't in the array.
 */
final function int FindFieldIndex( name FieldName, optional bool bSearchPersistentFields )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.FindFieldIndex(FieldName, bSearchPersistentFields);
	}

	return INDEX_NONE;
}

/**
 * Removes all data fields from this data provider.
 *
 * @param	bReinitializeRuntimeFields	specify TRUE to reset the elements of the RuntimeDataFields array to match the elements
 *										in the PersistentDataFields array.  Ignored in the editor.
 *
 * @return	TRUE indicates that all fields were removed successfully; FALSE otherwise.
 */
final function bool ClearFields( optional bool bReinitializeRuntimeFields=true )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.ClearFields(bReinitializeRuntimeFields);
	}

	return false;
}

/**
 * Gets the data value source array for the specified data field.
 *
 * @param	FieldName			the name of the data field the source data should be associated with.
 * @param	out_DataValueArray	receives the array of data values available for FieldName.
 * @param	bPersistent			specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *								wouldn't be.
 * @param	CellTag				optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the array containing possible values for the FieldName data field was successfully located and copied
 *			into the out_DataValueArray variable.
 */
final function bool GetCollectionValueArray( name FieldName, out array<string> out_DataValueArray, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.GetCollectionValueArray(FieldName, out_DataValueArray, bPersistent, CellTag);
	}

	return false;
}

/**
 * Sets the source data for a collection data field to the values specified.  It is not necessary to add the field first
 * (via AddField) in order to set the collection values.
 *
 * @param	FieldName			the name of the data field the source data should be associated with.
 * @param	CollectionValues	the actual values that will be associated with FieldName.
 * @param	bClearExisting		specify TRUE to clear the existing collection data before adding the new values
 * @param	InsertIndex			the position to insert the new values (only relevant if bClearExisting is FALSE)
 * @param	bPersistent			specify TRUE to ensure that the values will be added to PersistentCollectionData, even
 *								if they otherwise wouldn't be.
 * @param	CellTag				optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the collection data was applied successfully; FALSE if there was also already data for this collection
 *			data field [and bOverwriteExisting was FALSE] or the data couldn't otherwise
 */
final function bool SetCollectionValueArray( name FieldName, out const array<string> CollectionValues,
	optional bool bClearExisting=true, optional int InsertIndex=INDEX_NONE, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.SetCollectionValueArray(FieldName, CollectionValues, bClearExisting, InsertIndex, bPersistent, CellTag);
	}

	return false;
}

/**
 * Inserts a new string into the list of values for the specified collection data field.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	NewValue		the value to insert
 * @param	InsertIndex		the index [into the array of values for FieldName] to insert the new value, or INDEX_NONE to
 *							append the value to the end of the list.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	bAllowDuplicateValues
 *							controls whether multiple elements containing the same value should be allowed in the data source
 *							collection.  If FALSE is specified, and NewValue already exists in the collection source array, method
 *							return TRUE but it does not modify the array.  If TRUE is specified, NewValue will be added anyway,
 *							resulting in multiple copies of NewValue existing in the array.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the new value was successfully inserted into the collection data source for the specified field.
 */
final function bool InsertCollectionValue( name FieldName, out const string NewValue, optional int InsertIndex=INDEX_NONE,
	optional bool bPersistent, optional bool bAllowDuplicateValues, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.InsertCollectionValue(FieldName, NewValue, InsertIndex, bPersistent, bAllowDuplicateValues, CellTag);
	}

	return false;
}

/**
 * Removes a value from the collection data source specified by FieldName.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueToRemove	the value that should be removed
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the value was successfully removed or didn't exist in the first place.
 */
final function bool RemoveCollectionValue( name FieldName, out const string ValueToRemove, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.RemoveCollectionValue(FieldName,ValueToRemove,bPersistent, CellTag);
	}

	return false;
}

/**
 * Removes the value from the collection data source specified by FieldName located at ValueIndex.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueIndex		the index [into the array of values for FieldName] of the value that should be removed.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the value was successfully removed; FALSE if ValueIndex wasn't valid or the value couldn't be removed.
 */
final function bool RemoveCollectionValueByIndex( name FieldName, int ValueIndex, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.RemoveCollectionValueByIndex(FieldName,ValueIndex,bPersistent, CellTag);
	}

	return false;
}

/**
 * Replaces the value in a collection data source with a different value.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	CurrentValue	the value that will be replaced.
 * @param	NewValue		the value that will replace CurrentValue
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the old value was successfully replaced with the new value.
 */
final function bool ReplaceCollectionValue( name FieldName, out const string CurrentValue, out const string NewValue, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.ReplaceCollectionValue(FieldName,CurrentValue,NewValue,bPersistent, CellTag);
	}

	return false;
}

/**
 * Replaces the value located at ValueIndex in a collection data source with a different value
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueIndex		the index [into the array of values for FieldName] of the value that should be replaced.
 * @param	NewValue		the value that should replace the old value.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the value was successfully replaced; FALSE if ValueIndex wasn't valid or the value couldn't be removed.
 */
final function bool ReplaceCollectionValueByIndex( name FieldName, int ValueIndex, out const string NewValue, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.ReplaceCollectionValueByIndex(FieldName,ValueIndex,NewValue,bPersistent, CellTag);
	}

	return false;
}

/**
 * Removes all data values for a single collection data field.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the data values were successfully cleared or didn't exist in the first place; FALSE if they couldn't be removed.
 */
final function bool ClearCollectionValueArray( name FieldName, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.ClearCollectionValueArray(FieldName,bPersistent, CellTag);
	}

	return false;
}

/**
 * Retrieves the value of an element in a collection data source array.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueIndex		the index [into the array of values for FieldName] of the value that should be retrieved.
 * @param	out_Value		receives the value of the collection data source element
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the value was successfully retrieved and copied to out_Value.
 */
final function bool GetCollectionValue( name FieldName, int ValueIndex, out string out_Value, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.GetCollectionValue(FieldName,ValueIndex,out_Value,bPersistent, CellTag);
	}

	return false;
}

/**
 * Finds the index [into the array of values for FieldName] for a specific value.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueToFind		the value that should be found.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	the index for the specified value, or INDEX_NONE if it couldn't be found.
 */
final function int FindCollectionValueIndex( name FieldName, out const string ValueToFind, optional bool bPersistent, optional name CellTag )
{
	if ( SceneDataProvider != None )
	{
		return SceneDataProvider.FindCollectionValueIndex(FieldName,ValueToFind,bPersistent, CellTag);
	}

	return INDEX_NONE;
}

/* == SequenceAction handlers == */


DefaultProperties
{
	Tag=SCENE_DATASTORE_TAG
}
