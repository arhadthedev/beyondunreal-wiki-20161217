/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Base class of all geometry mode modifiers.
 */
class GeomModifier
	extends Object
	abstract
	hidecategories(Object,GeomModifier)
	native;

/** A human readable name for this modifier (appears on buttons, menus, etc) */
var(GeomModifier) string Description;

/** If true, this modifier should be displayed as a push button instead of a radio button */
var(GeomModifier) bool bPushButton;

/**
 * TRUE if the modifier has been initialized.
 * This is useful for interpreting user input and mouse drags correctly.
 */
var(GeomModifier) bool bInitialized;



defaultproperties
{
	Description="None"
	bPushButton=False
	bInitialized=False
}
