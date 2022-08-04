/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

// GenericBrowserType
//
// This class provides a generic interface for extending the generic browsers
// base list of resource types.

class GenericBrowserType
	extends Object
	abstract
	hidecategories(Object,GenericBrowserType)
	native;

// A human readable name for this modifier
var string Description;

struct native GenericBrowserTypeInfo
{
	/** the class associated with this browser type */
	var const class				Class;

	/** the color to use for rendering objects of this type */
	var const color				BorderColor;

	/** if specified, only objects that have these flags will be considered */
	var native const qword		RequiredFlags;

	/** Pointer to a context menu object */
	var native const pointer	ContextMenu{class WxMBGenericBrowserContextBase};

	/** Pointer to the GenericBrowserType that should be called to handle events for this type. */
	var GenericBrowserType		BrowserType;

	/** Callback used to determine whether object is Supported*/
	var native pointer			IsSupportedCallback;


};

// A list of information that this type supports.
var native array<GenericBrowserTypeInfo> SupportInfo;

// The color of the border drawn around this type in the browser.
var color BorderColor;



defaultproperties
{
}
