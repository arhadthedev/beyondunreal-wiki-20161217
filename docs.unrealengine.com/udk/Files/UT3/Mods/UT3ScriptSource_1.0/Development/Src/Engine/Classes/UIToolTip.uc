/**
 * This specialized label is used for rendering tooltips in the UI.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UIToolTip extends UILabel
	native(inherit)
	notplaceable
	HideDropDown;

/*
	@todo
	- override all methods which trigger full scene updates; these won't be necessary for UIToolTips
	- hide the tooltip when the console is being displayed
*/



/** Used to indicate that the position of this tool tip widget should be updated during the next tick */
var	const	transient	bool				bPendingPositionUpdate;

/** used to indicate that this tooltip's position has been updated and needs to be resolved into actual screen values */
var	const	transient	bool				bResolveToolTipPosition;

/**
 * The amount of time this tooltip has been active, in seconds.  Updated from TickToolTip().
 */
var	const	transient	float				SecondsActive;

/** Confguration variables */

/**
 * Indicates whether the tooltip will remain in the location where it was initially shown, or follow the cursor.
 */
var()				bool					bFollowCursor;

/**
 * Determines whether this tooltip will automatically deactivate if input is received by the UI system.
 */
var()				bool					bAutoHideOnInput;

/* == Delegates == */

/** Wrapper for BeginTracking which allows owning widgets to easily override the default behavior for tooltip activation */
delegate UIToolTip ActivateToolTip()
{
	return BeginTracking();
}

/** Wrapper for EndTracking which allows owning widgets to easily override the default behavior for tooltip de-activation */
delegate bool DeactivateToolTip()
{
	return EndTracking();
}

/* == Events == */

/* == Natives == */
/**
 * Initializes the timer used to determine when this tooltip should be shown.  Called when the a widet that supports a tooltip
 * becomes the scene client's ActiveControl.
 *
 * @return	returns the tooltip that began tracking, or None if no tooltips were activated.
 */
native final function UIToolTip BeginTracking();

/**
 * Hides the tooltip and resets all internal tracking variables.  Called when a widget that supports tooltips is no longer
 * the scene client's ActiveControl.
 *
 * @return	FALSE if the tooltip wishes to abort the deactivation and continue displaying the tooltip.  The return value
 * 			may be ignored if the UIInteraction needs to force the tooltip to disappear, for example if the scene is being
 *			closed or a context menu is being activated.
 */
native final function bool EndTracking();

/**
 * Repositions this tool-tip to appear below the mouse cursor (or above if too near the bottom of the screen), without
 * triggering a full scene update.
 */
native final function UpdateToolTipPosition();

/* == UnrealScript == */


DefaultProperties
{
	bPendingPositionUpdate=true
	bFollowCursor=false
	bAutoHideOnInput=true

	Position=(ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner)

	//PRIVATE_NotDockable|PRIVATE_NotRotatable|PRIVATE_TreeHiddenRecursive|PRIVATE_Protected
	PrivateFlags=0x3DA
	DataSource=(RequiredFieldType=DATATYPE_Property)

	EventProvider=None
	Begin Object Name=LabelStringRenderer
		StyleResolverTag="ToolTip String Style"
		StringStyle=(DefaultStyleTag="DefaultToolTipStringStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')

		// tool-tips wrap by default
		TextStyleCustomization=(ClipMode=CLIP_Normal,bOverrideClipMode=true)
		AutoSizeParameters(UIORIENT_Horizontal)={(
			bAutoSizeEnabled=true,
			Extent={(
					Value[EUIAutoSizeConstraintType.UIAUTOSIZEREGION_Maximum]=0.3,
					EvalType[EUIAutoSizeConstraintType.UIAUTOSIZEREGION_Maximum]=UIEXTENTEVAL_PercentScene
					)}
			)}

		AutoSizeParameters(UIORIENT_Vertical)=(bAutoSizeEnabled=true)
	End Object

	Begin Object Class=UIComp_DrawImage Name=TooltipBackgroundRenderer
		StyleResolverTag="ToolTip Background Style"
		ImageStyle=(DefaultStyleTag="DefaultToolTipBackgroundStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	End Object
	LabelBackground=TooltipBackgroundRenderer
}
