/**
 * This specialized version of UIString is used in editboxes.  UIEditboxString is different from UIString in that it is
 * aware of the first character that should be visible in the editbox, and ensures that the string's nodes only contain
 * text that falls within the editboxes bounding region, without affecting the data store binding associated with each
 * individual node.
 *
 * @todo UIString is supposed to support persistence, so that designers can override the extents for individual nodes
 *	in the string, so this class should not be marked transient
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIEditboxString extends UIString
	within UIEditBox
	native(UIPrivate)
	transient;



DefaultProperties
{

}
