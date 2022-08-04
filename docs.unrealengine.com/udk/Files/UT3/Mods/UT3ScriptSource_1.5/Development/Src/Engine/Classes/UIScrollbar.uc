/**
 * This component when integrated into a widget allows for scrolling the contents of the widget, i.e. UIList.
 * UIScrollbar has built-in functionality to autoposition itself within the owner widget depending on its orientation
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIScrollbar extends UIObject
	native(UIPrivate)
	hidecategories(Object,UIScreenObject,UIObject,Focus,Presentation,Splitscreen,States)
	notplaceable;



/** Component for rendering the background image */
var(Image)	editinline	const	noclear		UIComp_DrawImage		BackgroundImageComponent;

/**
 * Buttons that can be used to increment and decrement the marker of the scrollbar.
 */
var	private		const						UIScrollbarButton		IncrementButton;
var	private		const						UIScrollbarButton		DecrementButton;

/**
 * The marker which can be manipulated to change the value of the scrollbar
 */
var	private		const					UIScrollbarMarkerButton		MarkerButton;

/**
 * The styles used for the increment, decrement and marker buttons
 */
var		private								UIStyleReference		IncrementStyle;
var		private								UIStyleReference		DecrementStyle;
var		private								UIStyleReference		MarkerStyle;

/**
 * The nudge value indicates how much marker movement will cause one position update "tick",
 * value is stored in pixels.  It can be set to 1 as is the case with the UIScrollframe, or it can be evaluated
 * based on some percentage of the total available size as is the case with the UIList
 */
var		private{private} transient			float					NudgeValue;

/**
 * The NudgeMultiplier value indicates by how many NudgeValues will the marker move when the increment or decrement button is pressed,
 * NudgeValue is multiplied by NudgeMultiplier to obtain final pixel amount
 */
var()										float					NudgeMultiplier;

/**
 * Values which store current state of the scrollbar's marker
 */
var		private{private} transient			float					NudgePercent;
var		private{private} transient			float					MarkerPosPercent;
var		private{private} transient			float					MarkerSizePercent;

/**
 * Determines scrollbar's thickness
 */
var()										UIScreenValue_Extent	BarWidth;

/**
 * Specifies the minimum size for the scrollbar marker.  Useful to prevent the marker from becoming too small if there are lots of items in the list.
 */
var()										UIScreenValue_Extent	MinimumMarkerSize;

/**
 * Determines the length of the Increment/Decrement buttons
 */
var()										UIScreenValue_Extent	ButtonsExtent;

/**
 * Controls whether this scrollbar is vertical or horizontal
 */
var()										EUIOrientation			ScrollbarOrientation;

/**
 * Specifies wheather to leave extra space between the bottom/right corner of the scrollbar and its owner widget.
 * Extra space prevents ovelapping if both horizontal and vertical scrollbars exist within one widget
 */
var()										bool					bAddCornerPadding;

/** The current position of the mouse cursor, used in dragging handling */
var		transient							UIScreenValue_Position	MousePosition;

/**
 * The accumulated mouse position delta during dragging. The change in mouse position is accumulated until it is greater than the nudge
 * value, at which point it will then call the OnScrollActivity delegate to move the content.
 */
var		private transient					float					MousePositionDelta;

/** A private flag indicating that the marker needs to be repositioned and resized to the bounds of the uiscrollbar */
var		private	transient					bool					bInitializeMarker;

/* == Delegates == */
/**
 * Delegate invoked on scrolling activity
 *
 * @param	Sender			the scrollbar that generated the event.
 * @param	PositionChange	the number of nudge values by which the marker was moved
 * @param	bPositionMaxed	indicates that the scrollbar's marker has reached its farthest available position,
 *                          used to obtain pixel exact scrolling
 *
 * @return	currently unused.
 */
delegate bool OnScrollActivity( UIScrollbar Sender, float PositionChange, optional bool bPositionMaxed=false );

/**
 * Called when the user clicks anywhere in the scrollbar other than on one of the buttons.
 *
 * @param	Sender			the scrollbar that was clicked.
 * @param	PositionPerc	a value from 0.0 - 1.0, representing the location of the click within the region between the increment
 *							and decrement buttons.  Values closer to 0.0 means that the user clicked near the decrement button; values closer
 *							to 1.0 are nearer the increment button.
 * @param	PlayerIndex		Player that performed the action that issued the event.
 */
delegate OnClickedScrollZone( UIScrollbar Sender, float PositionPerc, int PlayerIndex );

/* == Natives == */
/**
 * Returns the position of this scrollbar's top face (if orientation is vertical) or left face (for horizontal), in pixels.
 */
native final function float GetMarkerButtonPosition() const;

/**
 * Returns the size of the scroll-zone (the region between the decrement and increment buttons), along the same orientation as the scrollbar.
 *
 * @param	ScrollZoneStart	receives the value of the location of the beginning of the scroll zone, in pixels relative to the scrollbar.
 *
 * @return	the height (if the scrollbar's orientation is vertical) or width (if horizontal) of the region between the
 *			increment and decrement buttons, in pixels.
 *
 * @note: noexport so that the native implementation can declare the optional out as a * will default value of NULL.
 */
native final noexport function float GetScrollZoneExtent( optional out float ScrollZoneStart ) const;

/**
 * Returns the size of the scroll-zone (the region between the decrement and increment buttons), for the orientation opposite that of the scrollbar.
 *
 * @return	the height (if the scrollbar's orientation is vertical) or width (if horizontal) of the region between the
 *			increment and decrement buttons, in pixels.
 */
native final function float GetScrollZoneWidth() const;

/**
 * Sets marker's extent to a percentage of scrollbar size, the direction will be vertical or horizontal
 * depending scrollbar's orientation
 *
 *	@param	SizePercentage	determines the size of the marker, value needs to be in the range [ 0 , 1 ] and
 *                          should be equal to the ratio of viewing area to total widget scroll area
 */
native final function SetMarkerSize( float SizePercentage );

/**
 * Sets marker's top or left face position to start at some percentage of total scrollbar extent
 *
 * @param	PositionPercentage	determines where the marker should start, value needs to be in the range [ 0 , 1 ] and
 *                              should correspond to the position of the topmost or leftmost item in the viewing area
 */
native final function SetMarkerPosition( float PositionPercentage );

/**
 * Sets the amount by which the marker will move to cause one position tick
 *
 * @param	NudgePercentage 	percentage of total scrollbar area which will amount to one tick
 *                              value needs to be in the range [ 0 , 1 ]
 */
native final function SetNudgeSizePercent( float NudgePercentage );

/**
 * Sets the amount by which the marker will move to cause one position tick
 *
 * @param	NudgePixels 	Number of pixels by which the marker will need to be moved to cause one tick
 */
native final function SetNudgeSizePixels( float NudgePixels );

/**
 *	Sets the value of the bAddCornerPadding flag
 */
native final function EnableCornerPadding( bool FlagValue );

/**
 * Increments marker position by the amount of nudges specified in the NudgeMultiplier.  Increment direction is either down or right,
 * depending on scrollbar's orientation.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
native final function ScrollIncrement( UIScreenObject Sender, int PlayerIndex );

/**
 * Decrements marker position by the amount of nudges specified in the NudgeMultiplier.  Decrement direction is either up or left,
 * depending on marker's orientation
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
native final function ScrollDecrement( UIScreenObject Sender, int PlayerIndex );

/**
 * Initiates mouse drag scrolling. The scroll bar marker will slide on its axis with the mouse cursor
 * until DragScrollEnd is called.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
native final function DragScrollBegin( UIScreenObject Sender, int PlayerIndex );

/**
 * Terminates mouse drag scrolling.
 *
 * @param EventObject	Object that issued the event.
 * @param PlayerIndex	Player that performed the action that issued the event.
 *
 * @return	return TRUE to prevent the kismet OnClick event from firing.
 */
native final function DragScrollEnd( UIScreenObject Sender, int PlayerIndex );

/**
 *	Called during the dragging process
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
native final function DragScroll( UIScrollbarMarkerButton Sender, int PlayerIndex );

/* == Events == */
/**
 * Initializes the clicked delegates in the increment, decrement and marker buttons.
 */
event Initialized()
{
	Super.Initialized();

	IncrementButton.OnPressed = ScrollIncrement;
	IncrementButton.OnPressRepeat = ScrollIncrement;

	DecrementButton.OnPressed = ScrollDecrement;
	DecrementButton.OnPressRepeat = ScrollDecrement;

	MarkerButton.OnPressed = DragScrollBegin;
	MarkerButton.OnPressRelease = DragScrollEnd;

	MarkerButton.OnButtonDragged = DragScroll;
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

/* == UnrealScript == */
/** Simple accessors */
final function float GetNudgeValue()
{
	return NudgeValue;
}
final function float GetNudgePercent()
{
	return NudgePercent;
}
final function float GetMarkerPosPercent()
{
	return MarkerPosPercent;
}
final function float GetMarkerSizePercent()
{
	return MarkerSizePercent;
}

/* == SequenceAction handlers == */

DefaultProperties
{
	//PRIVATE_NotFocusable|PRIVATE_NotRotatable|PRIVATE_PropagateState
	PrivateFlags=0x414

	NudgeValue=1
	NudgeMultiplier=1.0f
	NudgePercent=0.0f
	MarkerPosPercent=0.0f
	MarkerSizePercent=1.0f
	bInitializeMarker=true
	ScrollbarOrientation=UIORIENT_Vertical

	BarWidth=(Value=16,ScaleType=UIEXTENTEVAL_Pixels,Orientation=UIORIENT_Horizontal)
	ButtonsExtent=(Value=16,ScaleType=UIEXTENTEVAL_Pixels,Orientation=UIORIENT_Vertical)
	MinimumMarkerSize=(Value=12,ScaleType=UIEXTENTEVAL_Pixels,Orientation=UIORIENT_Vertical)

	bAddCornerPadding=true

	// Styles
	PrimaryStyle=(DefaultStyleTag="DefaultScrollZoneStyle",RequiredStyleClass=class'UIStyle_Image')

	IncrementStyle=(DefaultStyleTag="DefaultIncrementButtonStyle",RequiredStyleClass=class'UIStyle_Image')
	DecrementStyle=(DefaultStyleTag="DefaultDecrementButtonStyle",RequiredStyleClass=class'UIStyle_Image')
	MarkerStyle=(DefaultStyleTag="DefaultScrollBarStyle",RequiredStyleClass=class'UIStyle_Image')
	bSupportsPrimaryStyle=false

	Begin Object Class=UIComp_DrawImage Name=ScrollBarBackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultScrollZoneStyle",RequiredStyleClass=class'UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=ScrollBarBackgroundImageTemplate

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Pressed')
	DefaultStates.Add(class'Engine.UIState_Active')
}
