/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UIComp_UTGlowString extends UIComp_DrawString
	native(UI);

/** Specifies the glowing style data to use for this widget */
var(Glow) UIStyleReference GlowStyle;



defaultproperties
{
	GlowStyle=(DefaultStyleTag="DefaultGlowStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
}
