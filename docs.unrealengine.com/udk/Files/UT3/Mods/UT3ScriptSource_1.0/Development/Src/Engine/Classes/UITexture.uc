/**
 * Acts as the raw interface for providing a texture or material to the UI.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UITexture extends UIRoot
	native(UIPrivate)
	editinlinenew;



/**
 * Contains data for controlling or modifying how this image is displayed.  Set by the object which owns this texture/material.
 */
var private{private}	transient	UICombinedStyleData		ImageStyleData;

/**
 * The texture or material that will be rendered by this UITexture.  If not specified, will render the FallbackImage set
 * in the ImageStyleData instead.
 */
var									Surface					ImageTexture;

/**
 * Initializes ImageStyleData using the specified image style.
 *
 * @param	NewImageStyle	the image style to copy values from
 */
native final function SetImageStyle( UIStyle_Image NewImageStyle );

/**
 * Determines whether this UITexture has been assigned style data.
 *
 * @return	TRUE if ImageStyleData has been initialized; FALSE otherwise
 */
native final function bool HasValidStyleData() const;

/**
 * Returns the surface associated with this UITexture.
 */
final function Surface GetSurface()
{
	return ImageTexture;
}

DefaultProperties
{

}
