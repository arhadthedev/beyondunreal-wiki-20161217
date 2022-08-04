/**
 * Contains information about how to present and format a widget's appearance.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIStyle_Data extends UIRoot
	native(UIPrivate)
	abstract;

/** name of custom wxStaticBox class used to edit this style type */
var	const	editoronly		string			UIEditorControlClass;

/** Color for this style */
var							LinearColor		StyleColor;

/** The amount of padding to apply; values will be scaled based on the value of the DEFAULT_SIZE_Y const */
var							float			StylePadding[EUIOrientation.UIORIENT_MAX];

/** Controls whether this style data is enabled in the owning style for its associated state */
var							bool			bEnabled;

/** True if the style's data need to be reapplied to the widgets using this style */
var	transient				bool			bDirty;



DefaultProperties
{
	StyleColor=(R=1.f,G=1.f,B=1.f,A=1.f)
}
