/**
 * This basic widget allows the user to type text into an input field.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 *
 * @todo - auto-complete
 * @todo - multi-line support
 *
 *
 * @todo - add property to control whether change notifications are sent while the user is typing text (vs. only when the user presses enter or something).
 */
class UIEditBox extends UIObject
	native(UIPrivate)
	implements(UIDataStorePublisher);

enum EEditBoxCharacterSet
{
	/** Allows all charcters */
	CHARSET_All,
	/** Ignores special characters like !@# */
	CHARSET_NoSpecial,
	/** Allows only alphabetic characters */
	CHARSET_AlphaOnly,
	/** Allows only numeric characters */
	CHARSET_NumericOnly
};

/**
 * The name of the data source that this editbox's value will be associated with.
 * @todo - explain this a bit more
 */
var(Data)	private							UIDataStoreBinding		DataSource;

/** Renders the text for this editbox */
var(Data)	editinline	const	noclear	UIComp_DrawStringEditbox	StringRenderComponent;

/** Component for rendering the background image */
var(Image)	editinline	const			UIComp_DrawImage			BackgroundImageComponent;

/** The initial value to display in the editbox's text field */
var(Text)				localized			string					InitialValue<ToolTip=Initial value for editboxes that aren't bound to data stores>;

/** specifies whether the text in this editbox can be changed by user input */
var(Text)				private				bool					bReadOnly<ToolTip=Enable to prevent users from typing into this editbox>;

/** If enabled, the * character will be rendered instead of the actual text. */
var(Text)									bool					bPasswordMode<ToolTip=Displays asterisks instead of the characters typed into the editbox>;

/** the maximum number of characters that can be entered into the editbox */
var(Text)									int						MaxCharacters<ToolTip=The maximum number of character that can be entered; 0 means unlimited>;

var(Text)									EEditBoxCharacterSet	CharacterSet<ToolTip=Controls which type of characters are allowed in this editbox>;



/* == Delegates == */
/**
 * Called when the user presses enter (or any other action bound to UIKey_SubmitText) while this editbox has focus.
 *
 * @param	Sender	the editbox that is submitting text
 * @param	PlayerIndex		the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 *
 * @return	if TRUE, the editbox will clear the existing value of its textbox.
 */
delegate bool OnSubmitText( UIEditBox Sender, int PlayerIndex );

/* === Natives === */
/**
 * Changes the background image for this editbox.
 *
 * @param	NewImage		the new surface to use for this UIImage
 */
final function SetBackgroundImage( Surface NewImage )
{
	if ( BackgroundImageComponent != None )
	{
		BackgroundImageComponent.SetImage(NewImage);
	}
}

/**
 * Change the value of this editbox at runtime.
 *
 * @param	NewText				the new text that should be displayed in the label
 * @param	PlayerIndex			the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *								UIEvents
 * @param	bSkipNotification	specify TRUE to prevent the OnValueChanged delegate from being called.
 */
native final function SetValue( string NewText, optional int PlayerIndex=GetBestPlayerIndex(), optional bool bSkipNotification );

/**
 * Gets the text that is currently in this editbox
 *
 * @param	bReturnUserText		if TRUE, returns the text typed into the editbox by the user;  if FALSE, returns the resolved value
 *								of this editbox's data store binding.
 */
native final function string GetValue( optional bool bReturnUserText=true ) const;

/**
 * Calculates the character position for the point under the mouse or joystick cursor
 *
 * @param	PlayerIndex			the index of the player that generated the call to this method; if not specified,
 *								the value of GetBestPlayerIndex() is used instead.
 *
 * @return	the index into the editbox's value string for character under the mouse/joystick cursor.  If the cursor is within the
 *			"client region" of the editbox but not over a character (for example, if the string is very short and the mouse
 *			is hovering towards the right side of the region), then the length of the editbox's value string is returend.  Otherwise,
 *			returns INDEX_NONE,
 */
native function int CalculateCaretPositionFromCursorLocation( optional int PlayerIndex=GetBestPlayerIndex() ) const;

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
native virtual function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Notifies this subscriber to unbind itself from all bound data stores
 */
native final function ClearBoundDataStores();

/**
 * Resolves this subscriber's data store binding and publishes this subscriber's value to the appropriate data store.
 *
 * @param	out_BoundDataStores	contains the array of data stores that widgets have saved values to.  Each widget that
 *								implements this method should add its resolved data store to this array after data values have been
 *								published.  Once SaveSubscriberValue has been called on all widgets in a scene, OnCommit will be called
 *								on all data stores in this array.
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	TRUE if the value was successfully published to the data store.
 */
native virtual function bool SaveSubscriberValue( out array<UIDataStore> out_BoundDataStores, optional int BindingIndex=INDEX_NONE );

/* === Events === */
event Initialized()
{
	Super.Initialized();

	if ( bReadOnly && EventProvider != None )
	{
		EventProvider.DisabledEventAliases.AddItem('Consume');
	}
}

/* === Unrealscript === */
/**
 * @return	TRUE if this editbox is readonly
 */
final function bool IsReadOnly()
{
	return bReadOnly;
}

/**
 * Changes whether this editbox is read-only.
 *
 * @param	bShouldBeReadOnly	TRUE if the editbox should be read-only.
 */
function SetReadOnly( bool bShouldBeReadOnly )
{
	bReadOnly = bShouldBeReadOnly;
	if ( EventProvider != None )
	{
		if ( bReadOnly )
		{
			EventProvider.DisabledEventAliases.AddItem('Consume');
		}
		else
		{
			EventProvider.DisabledEventAliases.RemoveItem('Consume');

			//@todo ronp - if this editbox is already in the focused/enabled state, we'll need to re-register the input
			// keys for that state.
		}
	}
}

/**
 * Changes whether this editbox's string should process markup
 *
 * @param	bShouldIgnoreMarkup		if TRUE, markup will not be processed by this editbox's string
 *
 * @note: does not update any existing text contained by the editbox.
 */
final function IgnoreMarkup( bool bShouldIgnoreMarkup )
{
	StringRenderComponent.bIgnoreMarkup = bShouldIgnoreMarkup;
}

/** Kismet Action Handlers */
function OnSetLabelText( UIAction_SetLabelText Action )
{
	SetValue(Action.NewText, Action.PlayerIndex);
}

/**
 * Handler for GetTextValue action.
 */
function OnGetTextValue( UIAction_GetTextValue Action )
{
	Action.StringValue = GetValue(true);
}



DefaultProperties
{
	PrimaryStyle=(DefaultStyleTag="DefaultEditboxStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	DataSource=(RequiredFieldType=DATATYPE_Property)
	bSupportsPrimaryStyle=false

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	// Rendering
	Begin Object Class=UIComp_DrawStringEditbox Name=EditboxStringRenderer
		bIgnoreMarkup=true
		StringCaret=(bDisplayCaret=true)
	End Object
	StringRenderComponent=EditboxStringRenderer

	Begin Object class=UIComp_DrawImage Name=EditboxBackgroundTemplate
		ImageStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=EditboxBackgroundTemplate

	CharacterSet=CHARSET_All
}
