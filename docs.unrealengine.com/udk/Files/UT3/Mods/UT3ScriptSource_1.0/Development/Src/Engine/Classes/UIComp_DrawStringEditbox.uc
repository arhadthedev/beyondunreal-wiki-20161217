/**
 * This specialized version of UIComp_DrawString handles rendering UIStrings for editboxes.  The responsibilities specific
 * to rendering text in editboxes are:
 *	1. A caret must be rendered at the appropriate location in the string
 *	2. Ensuring that the text surrounding the caret is always visible
 *	3. Tracking the text that was typed by the user independently from the data source that the owning widget is bound to.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * @todo - register this component with the data store for the caret image node so that it receives the refreshdatastore callback
 */
class UIComp_DrawStringEditbox extends UIComp_DrawString
	within UIEditBox
	native(inherit)
	config(UI);

/**
 * Defines a range of selected text in a UIString.
 */
struct native transient UIStringSelectionRegion
{
	var	int						SelectionStartCharIndex;
	var	int						SelectionEndCharIndex;

	// not yet implemented - will only be used if we later decide to go with using styles for the selection region.
//
//	var	float					SelectionStartLocation;
//	var	float					SelectionEndLocation;
//
//	var	bool					bRecalculateStartLocation, bRecalculateEndLocation;
//
//	var	UICombinedStyleData		SelectionStyleData;

	

	structdefaultproperties
	{
		SelectionStartCharIndex=INDEX_NONE
		SelectionEndCharIndex=INDEX_NONE
	}
};

/** Contains the text that the user has typed into the editbox */
var		private{protected}	transient	string					UserText;

/** Controls whether and how a caret is displayed */
var(Presentation)						UIStringCaretParameters	StringCaret;

/** the editbox's selected text */
var							transient	UIStringSelectionRegion	SelectionRegion;

/** the color to use for selected text */
var			config						LinearColor				SelectionTextColor;

/** the color to use for the background of a selected text block */
var			config						LinearColor				SelectionBackgroundColor;

/** the image node that is used for rendering the caret */
var	const	native	private	transient	pointer					CaretNode{struct FUIStringNode_Image};

/** the position of the first visible character in the editbox */
var	const			private	transient	int						FirstCharacterPosition;

/** indicates that the FirstCharacterPosition needs to be re-evaluated the next time the string is reformatted */
var	const					transient	bool					bRecalculateFirstCharacter;

/** the offset (in pixels) from the left edge of the editbox's bounding region for rendering the caret */
var	const					transient	float					CaretOffset;



/* == Delegates == */

/* == Natives == */
/**
 * Changes the value of UserText to the specified text without affecting the
 *
 * SetUserText should be used for modifying the "input text"; that is, the text that would potentially be published to
 * the data store this editbox is bound to.
 * SetValue should be used to change the raw string that will be parsed by the underlying UIString.  UserText will be
 * set to the resolved value of the parsed string.
 *
 * @param	NewText		the new text that should be displayed
 *
 * @return	TRUE if the value changed.
 */
native final function bool SetUserText( string NewValue );

/**
 * Returns the length of UserText
 */
native final function int GetUserTextLength() const;

/**
 * Change the range of selected characters in this editbox.
 *
 * @param	StartIndex	the index of the first character that should be selected.
 * @param	EndIndex	the index of the last character that should be selected.
 *
 * @return	TRUE if the selection was changed successfully.
 */
native final function bool SetSelectionRange( int StartIndex, int EndIndex );

/**
 * Sets the starting character for the selection region.
 *
 * @param	StartIndex	the index of the character that should become the start of the selection region.
 *
 * @return	TRUE if the selection's starting index was changed successfully.
 */
native final function bool SetSelectionStart( int StartIndex );

/**
 * Sets the ending character for the selection region.
 *
 * @param	EndIndex	the index of the character that should become the end of the selection region.
 *
 * @return	TRUE if the selection's ending index was changed successfully.
 */
native final function bool SetSelectionEnd( int EndIndex );

/**
 * Clears the current selection region.
 *
 * @return	TRUE if the selection was cleared successfully.
 */
native final function bool ClearSelection();

/**
 * Retrieves the indexes of start and end characters of the selection region.
 *
 * @param	out_startIndex	receives the index for the beginning of the selection region (guaranteed to be less than out_EndIndex)
 * @param	out_EndIndex	recieves the index for the end of the selection region.
 *
 * @return	TRUE if the selection region is valid.
 */
native final function bool GetSelectionRange( out int out_StartIndex, out int out_EndIndex ) const;

/**
 * @return	the string that is currently selected.
 */
native final function string GetSelectedText() const;

/* == Events == */

/* == UnrealScript == */

/* == SequenceAction handlers == */


DefaultProperties
{
	StringClass=class'Engine.UIEditboxString'
	StringStyle=(DefaultStyleTag="DefaultEditboxStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	TextStyleCustomization=(ClipMode=CLIP_Normal,bOverrideClipMode=true,ClipAlignment=UIALIGN_Right,bOverrideClipAlignment=true)
}
