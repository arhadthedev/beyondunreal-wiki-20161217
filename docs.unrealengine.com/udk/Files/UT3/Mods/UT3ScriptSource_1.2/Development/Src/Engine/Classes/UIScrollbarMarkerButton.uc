/**
 * A special button used as the marker in the UIScrollbar class.  It processes input axis events while in the pressed state and
 * sends notifications to the owning scrollbar widget.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UIScrollbarMarkerButton extends UIScrollbarButton
	native(inherit)
	notplaceable;



/* == Delegates == */
/**
 * Called when the user presses the button and draggs it with a mouse
 * @param	Sender			the button that is submitting the event
 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
delegate OnButtonDragged( UIScrollbarMarkerButton Sender, int PlayerIndex );

defaultproperties
{
	// the StyleResolverTags must match the name of the property in the owning scrollbar control in order for SetWidgetStyle to work correctly.
	Begin Object Name=BackgroundImageTemplate
		StyleResolverTag="MarkerStyle"
	End Object
}

