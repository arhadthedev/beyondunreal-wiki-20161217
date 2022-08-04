/**
 * Base class for all widgets which act as containers or grouping boxes for other widgets.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIContainer extends UIObject
	notplaceable
	HideDropDown
	native(UIPrivate);



/** optional component for auto-aligning children of this panel */
var(Presentation)							UIComp_AutoAlignment	AutoAlignment;

/* === Unrealscript === */


DefaultProperties
{
	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
}
