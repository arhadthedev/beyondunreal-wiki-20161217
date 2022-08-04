/**
 * Base class for all containers which need a background image.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIPanel extends UIContainer
	placeable
	native(UIPrivate);

/** Component for rendering the background image */
var(Image)	editinline	const	UIComp_DrawImage		BackgroundImageComponent;

/** If ture, this panel will clip anything that attempts to render outside of it's bounds */
var() bool bEnforceClipping;



/* === Unrealscript === */
/**
 * Changes the background image for this panel, creating the wrapper UITexture if necessary.
 *
 * @param	NewImage		the new surface to use for this UIImage
 */
final function SetBackgroundImage( Surface NewImage )
{
	if ( BackgroundImageComponent != None )
	{
		BackgroundImageComponent.SetImage(NewImage);
	}
}

DefaultProperties
{
	PrimaryStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
	bSupportsPrimaryStyle=false

	Begin Object class=UIComp_DrawImage Name=PanelBackgroundTemplate
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Panel Background Style"
	End Object
	BackgroundImageComponent=PanelBackgroundTemplate
}
