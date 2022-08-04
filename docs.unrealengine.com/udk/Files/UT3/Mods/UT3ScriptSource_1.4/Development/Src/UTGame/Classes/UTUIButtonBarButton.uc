/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Modified version of label button that doesn't accept focus on console.
 */
class UTUIButtonBarButton extends UILabelButton
	native(UI);



/** === Focus Handling === */
/**
 * Determines whether this widget can become the focused control.
 *
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player to check focus availability
 *
 * @return	TRUE if this widget (or any of its children) is capable of becoming the focused control.
 */
native function bool CanAcceptFocus( optional int PlayerIndex=0 ) const;

defaultproperties
{
	Begin Object Class=UIComp_DrawString Name=ButtonBarStringRenderer
		StringStyle=(DefaultStyleTag="UTButtonBarButtonCaption",RequiredStyleClass=class'Engine.UIStyle_Combo')
		StyleResolverTag="Caption Style"
		AutoSizeParameters[0]=(bAutoSizeEnabled=true)
	End Object
	StringRenderComponent=ButtonBarStringRenderer


	Begin Object class=UIComp_DrawImage Name=ButtonBarBackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="UTButtonBarButtonBG",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=ButtonBarBackgroundImageTemplate
}