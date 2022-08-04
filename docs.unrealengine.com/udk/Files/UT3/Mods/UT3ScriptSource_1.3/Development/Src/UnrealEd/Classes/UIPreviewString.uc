/**
 * This specialized version of UIString is used by preview panels in style editors.  Since those strings are created using
 * CDOs as their Outer, the menu state used to apply style data must be set manually.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIPreviewString extends UIString
	native(Private)
	transient;

var		private{private}	UIState			CurrentMenuState;

/**
 * The size of the preview window's viewport - set by the WxTextPreviewPanel that handles this string.
 */
var		const	private		Vector2D		PreviewViewportSize;



DefaultProperties
{

}
