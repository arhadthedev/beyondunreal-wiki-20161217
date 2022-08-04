/**
 * Contains information about how to present and format text
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIStyle_Text extends UIStyle_Data
	native(inherit);

/** the font associated with this text style */
var						Font				StyleFont;

/** attributes to apply to this style's font */
var						UITextAttributes	Attributes;

/** text alignment within the bounding region */
var						EUIAlignment		Alignment[EUIOrientation.UIORIENT_MAX];

/**
 * Determines what happens when the text doesn't fit into the bounding region.
 */
var 					ETextClipMode		ClipMode;

/** Determines how the nodes of this string are ordered when the string is being clipped */
var						EUIAlignment		ClipAlignment;

/** Allows text to be scaled to fit within the bounding region */
var						TextAutoScaleValue	AutoScaling;

/** the scale to use for rendering text */
var						Vector2D			Scale;

/** Horizontal spacing adjustment between characters and vertical spacing adjustment between lines of wrapped text */
var						Vector2D			SpacingAdjust;



DefaultProperties
{
	UIEditorControlClass="WxStyleTextPropertiesGroup"

	StyleFont=Font'EngineFonts.SmallFont'

	Alignment(UIORIENT_Horizontal)=UIALIGN_Left
	Alignment(UIORIENT_Vertical)=UIALIGN_Center
	ClipMode=CLIP_None
	Scale=(X=1.0,Y=1.0)
}
