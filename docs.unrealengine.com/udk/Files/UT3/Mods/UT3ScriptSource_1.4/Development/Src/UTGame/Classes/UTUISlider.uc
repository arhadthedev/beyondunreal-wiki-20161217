/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Extended version of the slider for UT3.
 */
class UTUISlider extends UISlider
	native(UI);



/** Updates the slider's caption render component. */
native virtual function UpdateCaption();

defaultproperties
{
	Begin Object Class=UIComp_DrawStringSlider Name=CaptionStringRenderer
		StringStyle=(DefaultStyleTag="UTButtonBarButtonCaption",RequiredStyleClass=class'Engine.UIStyle_Combo')
		StyleResolverTag="UTSliderText"
	End Object
	CaptionRenderComponent=CaptionStringRenderer

	BarSize=(Value=16.0)
	MarkerWidth=(Value=32.0)
	MarkerHeight=(Value=32.0)
}
