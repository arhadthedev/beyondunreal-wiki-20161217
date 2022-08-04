/**
 * This  widget allows the user to type numeric text into an input field.
 * The value of the text in the input field can be incremented and decremented through the buttons associated with this widget.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * @todo - selection highlight support
 */
class UINumericEditBox extends UIEditBox
	native(inherit);

/** the style to use for the editbox's increment button */
var(Style)									UIStyleReference		IncrementStyle;

/** the style to use for the editbox's decrement button */
var(Style)									UIStyleReference		DecrementStyle;

/** Buttons that can be used to increment and decrement the value stored in the input field. */
var		private								UINumericEditBoxButton	IncrementButton;
var		private								UINumericEditBoxButton	DecrementButton;

/**
 * The value and range parameters for this numeric editbox.
 */
var(Text)									UIRangeData				NumericValue;

/** The number of digits after the decimal point. */
var(Text)									int						DecimalPlaces;

/** The position of the faces of the increment button. */
var(Buttons)								UIScreenValue_Bounds	IncButton_Position;

/** The position of the faces of the Decrement button. */
var(Buttons)								UIScreenValue_Bounds	DecButton_Position;




/**
 * Increments the numeric editbox's value.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
native final function IncrementValue( UIScreenObject Sender, int PlayerIndex );

/**
 * Decrements the numeric editbox's value.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
native final function DecrementValue( UIScreenObject Sender, int PlayerIndex );

/**
 * Initializes the clicked delegates in the increment and decrement buttons to use the editbox's increment and decrement functions.
 * @todo - this is a fix for the issue where delegates don't seem to be getting set properly in defaultproperties blocks.
 */
event Initialized()
{
	local int ModifierFlags;

	Super.Initialized();

	IncrementButton.OnPressed = IncrementValue;
	IncrementButton.OnPressRepeat = IncrementValue;

	DecrementButton.OnPressed = DecrementValue;
	DecrementButton.OnPressRepeat = DecrementValue;

	ModifierFlags = PRIVATE_NotFocusable|PRIVATE_NotDockable|PRIVATE_TreeHidden|PRIVATE_NotEditorSelectable|PRIVATE_ManagedStyle;

	if ( !IncrementButton.IsPrivateBehaviorSet(ModifierFlags) )
	{
		IncrementButton.SetPrivateBehavior(ModifierFlags, true);
	}
	if ( !DecrementButton.IsPrivateBehaviorSet(ModifierFlags) )
	{
		DecrementButton.SetPrivateBehavior(ModifierFlags, true);
	}
}

/**
 * Propagate the enabled state of this widget.
 */
event PostInitialize()
{
	Super.PostInitialize();

	// when this widget is enabled/disabled, its children should be as well.
	ConditionalPropagateEnabledState(GetBestPlayerIndex());
}

/**
 * Change the value of this numeric editbox at runtime. Takes care of conversion from float to internal value string.
 *
 * @param	NewValue				the new value for the editbox.
 * @param	bForceRefreshString		Forces a refresh of the string component, normally the string is only refreshed when the value is different from the current value.
 *
 * @return	TRUE if the editbox's value was changed
 */
native final function bool SetNumericValue( float NewValue, optional bool bForceRefreshString=false );

/**
 * Gets the current value of this numeric editbox.
 */
native final function float GetNumericValue( ) const;


DefaultProperties
{
	DataSource=(MarkupString="Numeric Editbox Text",RequiredFieldType=DATATYPE_RangeProperty)
	PrivateFlags=PRIVATE_PropagateState

	PrimaryStyle=(DefaultStyleTag="DefaultEditboxStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')

	// Increment and Decrement Button Styles
	IncrementStyle=(DefaultStyleTag="ButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
	DecrementStyle=(DefaultStyleTag="ButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')

	// Restrict the acceptable character set just numbers.
	CharacterSet=CHARSET_NumericOnly

	NumericValue=(MinValue=0.f,MaxValue=100.f,NudgeValue=1.f)
	DecimalPlaces=4
}
