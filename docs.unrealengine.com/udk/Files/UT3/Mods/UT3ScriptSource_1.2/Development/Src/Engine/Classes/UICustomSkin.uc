/**
 * A UISkin that contains purely cosmetic style changes.  In addition to replacing styles inherited from base styles, this
 * class can also remap the styles for individual widgets to point to an entirely different style.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UICustomSkin extends UISkin
	native(inherit);

/**
 * Contains custom mappings for overriding widget styles.
 * @todo - should it be marked transient as well?
 */
var		const	native						Map{FWIDGET_ID,FSTYLE_ID}	WidgetStyleMap;



DefaultProperties
{

}
