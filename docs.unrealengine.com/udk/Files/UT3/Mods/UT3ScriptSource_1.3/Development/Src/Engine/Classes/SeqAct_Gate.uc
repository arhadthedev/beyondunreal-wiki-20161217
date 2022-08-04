/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_Gate extends SequenceAction
	native(Sequence);



/** Is this gate currently open? */
var() bool bOpen<autocomment=true>;

/** Auto close after this many activations */
var() int AutoCloseCount<autocomment=true>;

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return true;
}

defaultproperties
{
	ObjName="Gate"
	ObjCategory="Misc"

	bOpen=TRUE
	bAutoActivateOutputLinks=false

	InputLinks(0)=(LinkDesc="In")
	InputLinks(1)=(LinkDesc="Open")
	InputLinks(2)=(LinkDesc="Close")
	InputLinks(3)=(LinkDesc="Toggle")

	VariableLinks.Empty

	bSuppressAutoComment=false
}
