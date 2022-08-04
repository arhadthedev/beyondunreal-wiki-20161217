`include(UIDev.uci)

/**
 * This  widget defines a region in which its child widgets can be placed. If any of its children lay outside of its
 * defined region then a scroll bar will be made visible to allow the region to be scrolled to the outside widgets.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 *
 */
class UIScrollFrame extends UIContainer
	placeable
	native(UIPrivate);

`include(Core/Globals.uci)

/**
 * Component for rendering the background image.  If given a value, this image will not move when the user scrolls, whereas
 * the background image for the client panel will.
 */
var(Image)	editinline	const				UIComp_DrawImage		StaticBackgroundImage;

/** A scrollbar widget that allows the entire RegionExtent to be scrolled to for the horizontal dimension. */
var duplicatetransient	const private 		UIScrollbar				ScrollbarHorizontal;

/** A scrollbar widget that allows the entire RegionExtent to be scrolled to for the horizontal dimension. */
var duplicatetransient	const private 		UIScrollbar				ScrollbarVertical;

/**
 * The horizontal extent of the region which contains this widget's children.  If this region is greater than the horizontal
 * extent of this scrollframe, the horizontal scrollbar will be made visible.
 */
var() editinline editconst private transient	UIScreenValue_Extent	HorizontalClientRegion;

/**
 * The vertical extent of the region which contains this widget's children.  If this region is greater than the vertical
 * extent of this scrollframe, the vertical scrollbar will be made visible.
 */
var()	editinline editconst private transient	UIScreenValue_Extent	VerticalClientRegion;

/**
 * Represents the position of the client region with respect to this scrollframe.  Values are from 0.0 - 1.0, where
 * 0,0 means that the top-left of the client region is at the top-left corner of this widget, and a value of 1,1 means
 * that the bottom-right of the client region is at the top-left corner of this widget.
 */
var private{private}	transient			Vector2D				ClientRegionPosition;

/** caches the value of the frame's bounding region extent (includes any rotation) */
var	private{private}	transient			float					FrameBounds[EUIWidgetFace.UIFACE_MAX];

/** indicates when the scrollbars need to be updated */
var	private const		transient			bool					bRefreshScrollbars;

/** indicates that the client region is out of date and needs to be recalculated */
var	private	const		transient			bool					bRecalculateClientRegion;




/* == Delegates == */

/* == Natives == */
/**
 * Sets the flag indicating that the scrollbars need to be re-resolved.  Does not necessarily trigger a scene update.
 *
 * @param	bImmediately	specify TRUE to resolve the scrollbars immediately instead of batching until the next scene
 *							update.
 */
native final function RefreshScrollbars( optional bool bImmediately );

/**
 * Sets the flag indicating that the client region needs to be recalculated.  Does not necessarily trigger a scene update.
 *
 * @param	bImmediately	specify TRUE to immediately recalculate the client region instead of batching up and waiting
 *							until the next scene update.
 */
native final function ReapplyFormatting( optional bool bImmediately );

/**
 * Scrolls all of the child widgets by the specified amount in the specified direction.
 *
 * @param	Sender			the scrollbar that generated the event.
 * @param	PositionChange	indicates the amount that the scrollbar has travelled.
 * @param	bPositionMaxed	indicates that the scrollbar's marker has reached its farthest available position,
 *                          used to achieve pixel exact scrolling
 */
native final function bool ScrollRegion( UIScrollbar Sender, float PositionChange, optional bool bPositionMaxed );

/**
 * Changes the position of the client region and synchronizes the scrollbars to the new position.
 *
 * @param	Orientation		specify UIORIENT_Horizontal to set the position of the left side; specify
 *							UIORIENT_Vertical to set the position of the top side.
 * @param	NewPosition		the position to move the client region to, in pixels.
 *
 * @return	TRUE if the client region was moved successfully.
 */
native final function bool SetClientRegionPosition( EUIOrientation Orientation, float NewPosition );

/**
 * Changes the position of the client region and synchronizes the scrollbars to the new position.
 *
 * @param	NewPosition		the position to move the client region to, in pixels.
 *
 * @return	TRUE if the client region was moved successfully.
 */
native final function bool SetClientRegionPositionVector( Vector2D NewPosition );

/**
 * Gets the position of either the left or top side of the client region.
 *
 * @param	Orientation		specify UIORIENT_Horizontal to retrieve the position of the left side; specify
 *							UIORIENT_Vertical to retrieve the position of the top side.
 *
 * @return	the position of the client region, in canvas coordinates relative to the top left corner of this widget.
 */
native final function float GetClientRegionPosition( EUIOrientation Orientation ) const;

/**
 * Returns the size of a single orientation of the client region, in pixels.
 *
 * @param	Orientation		specify UIORIENT_Horizontal to retrieve the width of the client region or UIORIENT_Vertical
 *							to get the height of the client region.
 *
 * @return	the width or height of the client region, in pixels.
 */
native final function float GetClientRegionSize( EUIOrientation Orientation ) const;

/**
 * Gets the position of the upper-left corner of the client region.
 *
 * @return	the position of the client region, in canvas coordinates relative to the top left corner of this widget.
 */
native final function vector2D GetClientRegionPositionVector() const;

/**
 * Returns the size of the client region, in pixels.
 *
 * @return	the size of the client region, in pixels.
 */
native final function vector2D GetClientRegionSizeVector() const;

/**
 * Returns a vector containing the size of the region (in pixels) available for rendering inside this scrollframe,
 * taking account whether the scrollbars are visible.
 */
native function GetClipRegion( out float MinX, out float MinY, out float MaxX, out float MaxY ) const;

/**
 * Returns the percentage of the client region that is visible within the scrollframe's bounds.
 *
 * @param	Orientation		specifies whether to return the vertical or horizontal percentage.
 *
 * @return	a value from 0.0 to 1.0 representing the percentage of the client region that can be visible at once.
 */
native final function float GetVisibleRegionPercentage( EUIOrientation Orientation ) const;

/* == Events == */
/**
 * Called immediately after a child has been added to this screen object.  Sets up NotifyPositionChanged delegate in the added child
 *
 * @param	WidgetOwner		the screen object that the NewChild was added as a child for
 * @param	NewChild		the widget that was added
 */
event AddedChild( UIScreenObject WidgetOwner, UIObject NewChild )
{
	Super.AddedChild(WidgetOwner, NewChild);

	//@fixme ronp - after UT ships, we should keep an array of NotifyPositionChanged delegates and store any previously existing
	// value for the new child's NotifyPositionChanged delegate in there, so that it can be called as well.
	if ( NewChild != None && NewChild != ScrollbarVertical && NewChild != ScrollbarHorizontal )
	{
		NewChild.NotifyPositionChanged = OnChildRepositioned;
	}
}

/**
 * Called immediately after a child has been removed from this screen object.  Clears the NotifyPositionChanged delegate in the removed child
 *
 * @param	WidgetOwner		the screen object that the widget was removed from.
 * @param	OldChild		the widget that was removed
 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
 *							between the widgets being removed from being severed.
 *							NOTE: If a value is specified, OldChild will ALWAYS be part of the ExclusionSet, since it is being removed.
 */
event RemovedChild( UIScreenObject WidgetOwner, UIObject OldChild, optional array<UIObject> ExclusionSet )
{
	Super.RemovedChild(WidgetOwner, OldChild, ExclusionSet);

	if ( OldChild != None && OldChild.NotifyPositionChanged == OnChildRepositioned )
	{
		OldChild.NotifyPositionChanged = None;
	}
}

/* == UnrealScript == */
/**
 * Handler for NotifyPositionChanged delegate for children of this panel.  Sets the flag indicating that the panel
 * should recalculate the client region.
 *
 * @param	Sender	Child widget which has been repositioned
 */
final function OnChildRepositioned( UIScreenObject Sender )
{
	if ( Sender != None && Sender != ScrollbarVertical && Sender != ScrollbarHorizontal )
	{
		//@fixme - the problem here is that in some cases (such as a label which wraps and autosizes vertically), the label
		// needs to be reformatted after ResolveScrollbars is called from ResolveFacePosition, if the scrollframe previously didn't
		// have scrollbars but now it does.
		ReapplyFormatting(GetScene().bResolvingScenePositions);
//		ReapplyFormatting();
	}
}

/**
 * Handler for the scrollbars' OnClickedScrollZone delegate.  Scrolls the client region by a full page.
 *
 * @param	Sender			the scrollbar that was clicked.
 * @param	PositionPerc	a value from 0.0 - 1.0, representing the location of the click within the region between the increment
 *							and decrement buttons.  Values closer to 0.0 means that the user clicked near the decrement button; values closer
 *							to 1.0 are nearer the increment button.
 * @param	PlayerIndex		index of the player that generated the scrollzone click.
 */
private event ScrollZoneClicked( UIScrollbar Sender, float PositionPerc, int PlayerIndex )
{
	local float MarkerPosition, TargetValue;
	local float VisibleRegionPosition[EUIWidgetFace.UIFACE_MAX], VisibleRegionSize;

	// first, figure out if the user clicked above or below the marker button
	if ( Sender != None && (Sender == ScrollbarVertical || Sender == ScrollbarHorizontal) )
	{
		TargetValue = -1;

		// the pixel values for the 4 faces of the clipping region (the scrollframe's bounds minus the sizes of any
		// visible scrollbars)
		GetClipRegion(	VisibleRegionPosition[UIFACE_Left], VisibleRegionPosition[UIFACE_Top],
						VisibleRegionPosition[UIFACE_Right], VisibleRegionPosition[UIFACE_Bottom]);

		// we know that ClientRegionSize is larger than VisibleRegionSize because we wouldn't be displaying a scrollbar otherwise.
		VisibleRegionSize = Sender.ScrollbarOrientation == UIORIENT_Horizontal
			? VisibleRegionPosition[UIFACE_Right] - VisibleRegionPosition[UIFACE_Left]
			: VisibleRegionPosition[UIFACE_Bottom] - VisibleRegionPosition[UIFACE_Top];

		// this is the position of the marker button's top face, as a percentage of the total scrollzone size
		MarkerPosition = Sender.GetMarkerPosPercent();
		if ( PositionPerc > MarkerPosition )
		{
			// user clicked "below" the marker, which means increment
			TargetValue = GetClientRegionPosition(Sender.ScrollbarOrientation) - VisibleRegionSize;
		}
		else if ( PositionPerc < MarkerPosition )
		{
			// user clicked "above" the marker, which means increment
			TargetValue = GetClientRegionPosition(Sender.ScrollbarOrientation) + VisibleRegionSize;
		}

		if ( TargetValue != -1 )
		{
			SetClientRegionPosition(Sender.ScrollbarOrientation, TargetValue);
		}
	}
}

/* == SequenceAction handlers == */

/**
 * Handler for the ApplyScrolling action.
 */
function OnApplyScrolling( UIAction_ApplyScrolling Action )
{
	local bool bSuccess;
	local float MarkerPosition;

	if ( Action != None )
	{
		if ( Action.ScrollOrientation == UIORIENT_Horizontal )
		{
			if ( ScrollbarHorizontal != None )
			{
				if ( Action.bFullPage )
				{
					// page up/down
					MarkerPosition = ScrollbarHorizontal.GetMarkerPosPercent();
					ScrollZoneClicked(ScrollbarHorizontal, MarkerPosition + Action.bIncreaseScroll ? 1 : -1, Action.PlayerIndex);
				}
				else
				{
					// scroll down one line
					if ( Action.bIncreaseScroll )
					{
						ScrollbarHorizontal.ScrollIncrement(ScrollbarVertical, Action.PlayerIndex);
					}
					else
					{
						ScrollbarHorizontal.ScrollDecrement(ScrollbarVertical, Action.PlayerIndex);
					}
				}
				bSuccess = true;
			}
		}
		else if ( Action.ScrollOrientation == UIORIENT_Vertical )
		{
			if ( ScrollbarVertical != None )
			{
				if ( Action.bFullPage )
				{
					// page up/down
					MarkerPosition = ScrollbarVertical.GetMarkerPosPercent();
					ScrollZoneClicked(ScrollbarVertical, MarkerPosition + Action.bIncreaseScroll ? 1 : -1, Action.PlayerIndex);
				}
				else
				{
					// scroll down one line
					if ( Action.bIncreaseScroll )
					{
						ScrollbarVertical.ScrollIncrement(ScrollbarVertical, Action.PlayerIndex);
					}
					else
					{
						ScrollbarVertical.ScrollDecrement(ScrollbarVertical, Action.PlayerIndex);
					}
				}
				bSuccess = true;
			}
		}
	}

	if ( bSuccess )
	{
		Action.OutputLinks[0].bHasImpulse = true;
	}
	else
	{
		Action.OutputLinks[1].bHasImpulse = true;
	}
}

DefaultProperties
{
	PrimaryStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	bSupportsPrimaryStyle=false

	bRecalculateClientRegion=true
	bRefreshScrollbars=true

	HorizontalClientRegion=(ScaleType=UIEXTENTEVAL_Pixels,Orientation=UIORIENT_Horizontal)
	VerticalClientRegion=(ScaleType=UIEXTENTEVAL_Pixels,Orientation=UIORIENT_Vertical)

	// components
	// make sure that the NudgeValue for these scrollbars is 1 to allow smooth scrolling of the client region
	Begin Object Class=UIScrollbar Name=VertScrollbarTemplate
		ScrollbarOrientation=UIORIENT_Vertical
		bAddCornerPadding=true
		bHidden=true
		OnScrollActivity=UIScrollFrame.ScrollRegion
		OnClickedScrollZone=UIScrollFrame.ScrollZoneClicked
		PrivateFlags=0x3CA	// PRIVATE_NotDockable|PRIVATE_TreeHiddenRecursive|PRIVATE_Protected
	End Object
	ScrollbarVertical=VertScrollbarTemplate

	Begin Object Class=UIScrollbar Name=HorzScrollbarTemplate
		ScrollbarOrientation=UIORIENT_Horizontal
		bAddCornerPadding=true
		bHidden=true
		OnScrollActivity=UIScrollFrame.ScrollRegion
		OnClickedScrollZone=UIScrollFrame.ScrollZoneClicked
		PrivateFlags=0x3CA	// PRIVATE_NotDockable|PRIVATE_TreeHiddenRecursive|PRIVATE_Protected
	End Object
	ScrollbarHorizontal=HorzScrollbarTemplate
}
