/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Base class for a widget that wants to display a list of strings, one at a time, and to increment and decrement that list via buttons.
 */
class UIOptionListBase extends UIObject
	native(UIPrivate)
	notplaceable
	implements(UIDataStorePublisher)
	abstract;

/** UI Key Action Events */
const UIKEY_MoveCursorLeft = 'UIKEY_MoveCursorLeft';
const UIKEY_MoveCursorRight = 'UIKEY_MoveCursorRight';

/**
 * The styles used for the increment, decrement buttons
 */
var	private								UIStyleReference			DecrementStyle;
var	private								UIStyleReference			IncrementStyle;

/**
 * Increment and decrement buttons for this widget.
 * @todo - need script accessors for safely replacing the Buttons with a new type, since the var is const
 */
var 		private const				UIOptionListButton			DecrementButton;
var 		private const				UIOptionListButton			IncrementButton;

/**
 * The class to use for creating the buttons.  If more control of the creation is necessary, or to use an existing
 * button, subscribe to the CreateCustomComboButton delegate instead.
 */
var const 								class<UIOptionListButton>	OptionListButtonClass;

/** Spacing between buttons and text. */
//@fixme ronp - make UIScreenValue_Extent
var(Presentation) 						UIScreenValue_Extent		ButtonSpacing;

/** Component for rendering the label's background image */
var(Image)	editinline	const			UIComp_DrawImage			BackgroundImageComponent;

/** Renders the text displayed by this label */
var(Data)	editinline	const noclear	UIComp_DrawString			StringRenderComponent;

/** This sound is played when the index is incremented */
var(Sound)								name						IncrementCue;

/** This sound is played when the index is decremented */
var(Sound)								name						DecrementCue;

/** Whether we should wrap the options or not, meaning if the user hits the beginning or the end of the list, they will wrap to the other end of the list. */
var()									bool						bWrapOptions;

/** The data store that this list is bound to */
var(Data)								UIDataStoreBinding			DataSource;



/**
 * Provides a convenient way to override the creation of the OptionList's components.  Called when this UIOptionList is first initialized.
 *
 * @return	if a custom component is desired, a pointer to a fully configured instance of the desired component class.  You must use
 *			UIScreenObject.CreateWidget to create the widget instances.  The returned instance will be inserted into the combo box's
 *			Children array and initialized.
 */
delegate UIOptionListButton CreateCustomDecrementButton( UIOptionListBase ButtonOwner );
delegate UIOptionListButton CreateCustomIncrementButton( UIOptionListBase ButtonOwner );

/* === Natives === */

/* === UUIDataStoreSubscriber interface === */
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
native final virtual function ClearBoundDataStores();

/* === UUIDataStorePublisher interface === */
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

/* === UIOptionListBase interface === */
/**
 * @return	TRUE if the user is allowed to decrement the value of this widget
 */
native function bool HasPrevValue() const;

/**
 * @return	TRUE if the user is allowed to increment the value of this widget
 */
native function bool HasNextValue() const;

/** Moves the current selection to the left. */
native function OnMoveSelectionLeft(int PlayerIndex);

/** Moves the current selection to the right. */
native function OnMoveSelectionRight(int PlayerIndex);

/* === Events === */
/**
 * Called when this widget is created
 *
 * @param	CreatedWidget		the widget that was created
 * @param	CreatorContainer	the container that created the widget
 */
function Created( UIObject CreatedWidget, UIScreenObject CreatorContainer )
{
	if ( CreatedWidget == Self )
	{
		InitializeInternalControls();
	}
}

/** Called after the widget has been initialized, but before it's resolved its style or initialized its children */
event Initialized()
{
	Super.Initialized();
	InitializeInternalControls();
}

/* === Unrealscript === */
/**
 * Performs initialization for the increment and decrement buttons that cannot be handled in default properties.
 */
function InitializeInternalControls()
{
	if ( DecrementButton != None )
	{
		if ( DecrementButton.BackgroundImageComponent != None )
		{
			DecrementButton.BackgroundImageComponent.StyleResolverTag = 'DecrementStyle';
		}
		DecrementButton.SetDockTarget( UIFACE_Top, Self, UIFACE_Top );
		DecrementButton.SetDockTarget( UIFACE_Bottom, Self, UIFACE_Bottom );
		DecrementButton.SetDockTarget( UIFACE_Left, Self, UIFACE_Left );

		DecrementButton.OnClicked = OnButtonClicked;
	}

	if ( IncrementButton != None )
	{
		if ( IncrementButton.BackgroundImageComponent != None )
		{
			IncrementButton.BackgroundImageComponent.StyleResolverTag = 'IncrementStyle';
		}
		IncrementButton.SetDockTarget( UIFACE_Top, Self, UIFACE_Top );
		IncrementButton.SetDockTarget( UIFACE_Bottom, Self, UIFACE_Bottom );
		IncrementButton.SetDockTarget( UIFACE_Right, Self, UIFACE_Right );

		IncrementButton.OnClicked = OnButtonClicked;
	}
}

/**
 * Handler for the Increment/Decrement button's Onclick delegate.
 */
function bool OnButtonClicked(UIScreenObject Sender, int PlayerIndex)
{
	// since our buttons have the PRIVATE_NotFocusable flag set (so that they do not become part of the navigation
	// network), they will not automatically receive focus when pressed.  So, we need to do that here.
	if( IsFocused(PlayerIndex) || SetFocus(None) )
	{
		if ( Sender == DecrementButton )
		{
			OnMoveSelectionLeft(PlayerIndex);
		}
		else
		{
			OnMoveSelectionRight(PlayerIndex);
		}

		return true;
	}

	return false;
}

defaultproperties
{
	OnCreate=Created
	Position={(	Value[UIFACE_Left]=0,ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=256,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,
				Value[UIFACE_Top]=0,ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=32,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner	)}

	OptionListButtonClass=class'Engine.UIOptionListButton'

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	Begin Object class=UIComp_DrawImage Name=BackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="ButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=BackgroundImageTemplate

	Begin Object Class=UIComp_DrawString Name=LabelStringRenderer
		StringStyle=(DefaultStyleTag="DefaultLabelButtonStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
		StyleResolverTag="Caption Style"
	End Object
	StringRenderComponent=LabelStringRenderer

	Begin Object Class=UIOptionListButton Name=DecrementButtonTemplate
		Position=(Value[UIFACE_Right]=32.f,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner)
		TabIndex=0
		WidgetTag=DecrementButton
	End Object
	DecrementButton=DecrementButtonTemplate

	Begin Object Class=UIOptionListButton Name=IncrementButtonTemplate
		Position=(Value[UIFACE_Left]=224.f,ScaleType[UIFACE_Left]=EVALPOS_PixelOwner)
		TabIndex=1
		WidgetTag=IncrementButton
	End Object
	IncrementButton=IncrementButtonTemplate

	Children.Add(DecrementButtonTemplate)
	Children.Add(IncrementButtonTemplate)

	// children styles
	DecrementStyle=(DefaultStyleTag="DefaultIncrementButtonStyle",RequiredStyleClass=class'UIStyle_Image')
	IncrementStyle=(DefaultStyleTag="DefaultDecrementButtonStyle",RequiredStyleClass=class'UIStyle_Image')

	// Sounds
	IncrementCue=SliderIncrement
	DecrementCue=SliderDecrement

	DataSource=(RequiredFieldType=DATATYPE_Collection)
	bSupportsPrimaryStyle=false
	PrivateFlags=PRIVATE_PropagateState
}
