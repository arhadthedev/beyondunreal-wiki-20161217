/**
 * This button is identical to UIButton, with the exception that pressing this button toggles its pressed state, rather
 * than only remaining in the pressed state while the mouse/key is depressed.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIToggleButton extends UILabelButton
	native(inherit);

/** the data store that this togglebutton retrieves its checked/unchecked value from */
var(Data)	private					UIDataStoreBinding		ValueDataSource;

/**
 * Controls whether this button is considered checked.  When bIsChecked is TRUE, CheckedImage will be rendered over
 * the button background image, using the current style.
 */
var(Value)	private					bool					bIsChecked;

/** Renders the caption for this button when it is checked */
var(Data)	editinline	const noclear	UIComp_DrawString		CheckedStringRenderComponent;

/** Component for rendering the button background image when checked */
var(Image)	editinline	const	noclear	UIComp_DrawImage		CheckedBackgroundImageComponent;



/* === Natives === */

/**
 * Sets the caption for this button.
 *
 * @param	NewText			the new caption for the button
 */
native function SetCaption( string NewText );

/* === Unrealscript === */
/**
 * Returns TRUE if this button is in the checked state, FALSE if in the
 */
final function bool IsChecked()
{
	return bIsChecked;
}

/**
 * Changed the checked state of this checkbox and activates a checked event.
 *
 * @param	bShouldBeChecked	TRUE to turn the checkbox on, FALSE to turn it off
 * @param	PlayerIndex			the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *								UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
native final function SetValue( bool bShouldBeChecked, optional int PlayerIndex=INDEX_NONE );

/**
 * Default handler for the toggle button's OnClick
 */
function bool ButtonClicked( UIScreenObject Sender, int PlayerIndex )
{
	SetValue( !IsChecked() );
	return false;
}

/* === Kismet action handlers === */
final function OnSetBoolValue( UIAction_SetBoolValue Action )
{
	SetValue(Action.bNewValue);
}

DefaultProperties
{
	OnClicked=ButtonClicked

	Begin Object Class=UIComp_DrawString Name=CheckedLabelStringRenderer
		StringStyle=(DefaultStyleTag="DefaultToggleButtonStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
		StyleResolverTag="Caption Style (Checked)"
	End Object
	CheckedStringRenderComponent=CheckedLabelStringRenderer

	Begin Object class=UIComp_DrawImage Name=CheckedBackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultToggleButtonBackgroundStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style (Checked)"
	End Object
	CheckedBackgroundImageComponent=CheckedBackgroundImageTemplate

	ValueDataSource=(RequiredFieldType=DATATYPE_Property)
}
