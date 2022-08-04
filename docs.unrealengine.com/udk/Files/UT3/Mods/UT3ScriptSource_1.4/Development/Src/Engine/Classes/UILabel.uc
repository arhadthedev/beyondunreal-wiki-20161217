/**
 * A simple widget for displaying text in the UI.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UILabel extends UIObject
	native(UIPrivate)
	implements(UIDataStoreSubscriber,UIStringRenderer);

/** the text that will be rendered by this label */
var(Data)	private						UIDataStoreBinding		DataSource;

/** Renders the text displayed by this label */
var(Data)	editinline	const noclear	UIComp_DrawString		StringRenderComponent;

/** Optional component for rendering a background image for this UILabel */
var(Image)	editinline	const			UIComp_DrawImage		LabelBackground;



/**
 * Change the value of this label at runtime.
 *
 * @param	NewText		the new text that should be displayed in the label
 */
native final function SetValue( string NewText );

/** UIStringRenderer interface */

/**
 * Sets the text alignment for the string that the widget is rendering.
 *
 * @param	Horizontal		Horizontal alignment to use for text, UIALIGN_MAX means no change.
 * @param	Vertical		Vertical alignment to use for text, UIALIGN_MAX means no change.
 */
native final virtual function SetTextAlignment(EUIAlignment Horizontal, EUIAlignment Vertical);

/** UIDataSourceSubscriber interface */
/**
 * Sets the data store binding for this object to the text specified.
 *
 * @param	MarkupText			a markup string which resolves to data exposed by a data store.  The expected format is:
 *								<DataStoreTag:DataFieldTag>
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 */
native final virtual function SetDataStoreBinding( string MarkupText, optional int BindingIndex=INDEX_NONE );

/**
 * Retrieves the markup string corresponding to the data store that this object is bound to.
 *
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	a datastore markup string which resolves to the datastore field that this object is bound to, in the format:
 *			<DataStoreTag:DataFieldTag>
 */
native final virtual function string GetDataStoreBinding( optional int BindingIndex=INDEX_NONE ) const;

/**
 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
 *
 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
 */
native final virtual function bool RefreshSubscriberValue( optional int BindingIndex=INDEX_NONE );

/**
 * Handler for the UIDataStore.OnDataStoreValueUpdated delegate.  Used by data stores to indicate that some data provided by the data
 * has changed.  Subscribers should use this function to refresh any data store values being displayed with the updated value.
 * notify subscribers when they should refresh their values from this data store.
 *
 * @param	SourceDataStore		the data store that generated the refresh notification; useful for subscribers with multiple data store
 *								bindings, to tell which data store sent the notification.
 * @param	PropertyTag			the tag associated with the data field that was updated; Subscribers can use this tag to determine whether
 *								there is any need to refresh their data values.
 * @param	SourceProvider		for data stores which contain nested providers, the provider that contains the data which changed.
 * @param	ArrayIndex			for collection fields, indicates which element was changed.  value of INDEX_NONE indicates not an array
 *								or that the entire array was updated.
 */
native final virtual function NotifyDataStoreValueUpdated( UIDataStore SourceDataStore, bool bValuesInvalidated, name PropertyTag, UIDataProvider SourceProvider, int ArrayIndex );

/**
 * Retrieves the list of data stores bound by this subscriber.
 *
 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
 */
native final virtual function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Notifies this subscriber to unbind itself from all bound data stores
 */
native final function ClearBoundDataStores();


/** === Unrealscript === */
final function SetArrayValue( array<string> ValueArray )
{
	local string Str;

	JoinArray(ValueArray, Str, "\n", false);
	SetValue(Str);
}

/**
 * Retrieve the value of this label
 */
function string GetValue()
{
	return StringRenderComponent.GetValue();
}

/**
 * Changes whether this label's string should process markup
 *
 * @param	bShouldIgnoreMarkup		if TRUE, markup will not be processed by this label's string
 *
 * @note: does not update any existing text contained by the label.
 */
final function IgnoreMarkup( bool bShouldIgnoreMarkup )
{
	StringRenderComponent.bIgnoreMarkup = bShouldIgnoreMarkup;
}



/** === Kismet Action Handlers === */
function OnSetLabelText( UIAction_SetLabelText Action )
{
	SetValue(Action.NewText);
}

/**
 * Handler for GetTextValue action.
 */
function OnGetTextValue( UIAction_GetTextValue Action )
{
	Action.StringValue = GetValue();
}


DefaultProperties
{
	Position=(Value[UIFACE_Right]=100,Value[UIFACE_Bottom]=40,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner)
	PrimaryStyle=(DefaultStyleTag="DefaultComboStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	bSupportsPrimaryStyle=false

	DataSource=(MarkupString="Initial Label Text",RequiredFieldType=DATATYPE_Property)

	Begin Object Class=UIComp_DrawString Name=LabelStringRenderer
		StringStyle=(DefaultStyleTag="DefaultComboStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	End Object
	StringRenderComponent=LabelStringRenderer
}
