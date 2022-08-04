/**
 * Base class for all classes which provide data stores with data about specific instances of a particular data type.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIDataProvider extends UIRoot
	native(UIPrivate)
	transient
	abstract;



/**
 * Contains data about a single data field exposed by this data provider.
 */
struct native transient UIDataProviderField
{
	/** the tag used to access this field */
	var		name									FieldTag;

	/** the type of field this tag corresponds to */
	var		EUIDataProviderFieldType				FieldType;

	/**
	 * The list of providers associated with this field.  Only relevant if FieldType is DATATYPE_Provider or
	 * DATATYPE_ProviderCollection.  If FieldType is DATATYPE_Provider, the list should contain only one element.
	 */
	var	public{private}	array<UIDataProvider>		FieldProviders;


};


/**
 * Types of write access that data providers can specify.
 */
enum EProviderAccessType
{
	/** no fields are writeable - readonly */
	ACCESS_ReadOnly,

	/** write-access is controlled per field */
//	ACCESS_PerField,	// not yet implemented

	/** all fields are writeable */
	ACCESS_WriteAll,
};

/**
 * Determines whether/how subscribers to this data store are allowed to publish changes to property values.
 */
var	EProviderAccessType									WriteAccessType;

/**
 * The list of delegates to call when data exposed by this provider has been updated.
 *
 * @todo - change into a map of property name => delegate, so that when a property name is passed to NotifyPropertyChanged,
 *			only those delegates are called.
 */
var	array<delegate<OnDataProviderPropertyChange> >		ProviderChangedNotifies;

/**
 * Delegate that notifies that a property has changed  Intended only for use between data providers and their owning data stores.
 * For external notifications, use the callbacks in UIDataStore instead.
 *
 * @param	SourceProvider	the data provider that generated the notification
 * @param	PropTag			the property that changed
 */
delegate OnDataProviderPropertyChange(UIDataProvider SourceProvider, optional name PropTag);

/* == Natives == */

/* == Unrealscript == */
/**
 * Iterates over the list of subscribed delegates and fires off the event.  Called whenever the value of a field
 * managed by this data provider is modified.
 *
 * @param	PropTag			the name of the property that changed
 */
event NotifyPropertyChanged(optional name PropTag)
{
	local int Index;
	local delegate<OnDataProviderPropertyChange> Subscriber;
	
	// Loop through and notify all subscribed delegates
	for (Index = 0; Index < ProviderChangedNotifies.Length; Index++)
	{
		Subscriber = ProviderChangedNotifies[Index];
		Subscriber(Self, PropTag);
	}
}

/**
 * Subscribes a function for receiving notifications that a property in this data provider has changed.  Intended
 * only for use between data providers and their owning data stores.  For external notifications, use the callbacks
 * in UIDataStore instead.
 *
 * @param InDelegate the delegate to add to the notification list
 */
protected final function AddPropertyNotificationChangeRequest(delegate<OnDataProviderPropertyChange> InDelegate)
{
	local int NewIndex;
	NewIndex = ProviderChangedNotifies.Length;
	ProviderChangedNotifies.Length = NewIndex + 1;
	ProviderChangedNotifies[NewIndex] = InDelegate;
}

/**
 * Removes the delegate from the notification list
 *
 * @param InDelegate the delegate to remove from the list
 */
protected final function RemovePropertyNotificationChangeRequest(delegate<OnDataProviderPropertyChange> InDelegate)
{
	local int Index;
	Index = ProviderChangedNotifies.Find(InDelegate);
	if (Index != INDEX_NONE)
	{
		ProviderChangedNotifies.Remove(Index,1);
	}
}

/**
 * Callback to allow script-only child classes to add their own supported tags when GetSupportedDataFields is called.
 *
 * @param	out_Fields	the list of data tags supported by this data store.
 */
event GetSupportedScriptFields( out array<UIDataProviderField> out_Fields );

/**
 * Resolves the value of the data field specified and stores it in the output parameter.
 *
 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
 * @param	out_FieldValue	receives the resolved value for the property specified.
 *							@see ParseDataStoreReference for additional notes
 * @param	ArrayIndex		optional array index for use with data collections
 *
 * @return	TRUE to indicate that this value was processed by script.
 */
event bool GetFieldValue( string FieldName, out UIProviderScriptFieldValue FieldValue, optional int ArrayIndex=INDEX_NONE );

/**
 * Resolves the value of the data field specified and stores the value specified to the appropriate location for that field.
 *
 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
 * @param	FieldValue		the value to store for the property specified.
 * @param	ArrayIndex		optional array index for use with data collections
 *
 * @return	TRUE to indicate that this value was processed by script.
 */
event bool SetFieldValue( string FieldName, const out UIProviderScriptFieldValue FieldValue, optional int ArrayIndex=INDEX_NONE );

/**
 * Callback to allow script-only child classes to generate a markup string for their own data fields.  Called from
 * the native implementation of GenerateDataMarkupString if the tag specified doesn't correspond to any tags in the data store.
 *
 * @param	DataTag		the data field tag to generate the markup string for
 *
 * @return	a datastore markup string which resolves to the datastore field associated with DataTag, in the format:
 *			<DataStoreTag:DataFieldTag>
 */
event string GenerateScriptMarkupString( Name DataTag );

/**
 * Callback to allow script-only child classes to return filler data for their own data fields.
 *
 * @param		DataTag		the tag corresponding to the data field that we want filler data for
 *
 * @return		a string of made-up data which is indicative of the typical values for the specified field.
 */
event string GenerateFillerData( string DataTag );

DefaultProperties
{
	WriteAccessType=ACCESS_ReadOnly
}
