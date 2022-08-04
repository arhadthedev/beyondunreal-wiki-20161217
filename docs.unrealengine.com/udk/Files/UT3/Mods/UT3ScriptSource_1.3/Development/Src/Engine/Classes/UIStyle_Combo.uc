/**
 * Contains a reference to style data from either existing style, or custom defined UIStyle_Data.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */

class UIStyle_Combo extends UIStyle_Data
	native(inherit);

struct native StyleDataReference
{
	/** Style which owns this reference */
	var private{private}				UIStyle			OwnerStyle;

	/** the style id for the style that this StyleDataReference is linked to */
	var	private{private}				STYLE_ID		SourceStyleID;

	/**
	 * the style that this refers to
	 */
	var	private{private}	transient	UIStyle			SourceStyle;

	/** the state corresponding to the style data that this refers to */
	var	private{private}				UIState			SourceState;

	/** the optional custom style data to be used instead of existing style reference */
	var private{private}				UIStyle_Data	CustomStyleData;


};

var		StyleDataReference			ImageStyle;
var		StyleDataReference			TextStyle;



DefaultProperties
{
	UIEditorControlClass="WxStyleComboPropertiesGroup"
}
