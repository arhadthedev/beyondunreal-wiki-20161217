/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_Switch extends SequenceAction
	native(Sequence);

;

/** Total number of links to expose */
var() int LinkCount;

/** Number to increment attached variables upon activation */
var() int IncrementAmount;

/** Loop index back to beginning to cycle */
var() bool bLooping;

/** List of links to activate */
var() array<int> Indices;

/** Automatically disable an output once its activated? */
var() bool bAutoDisableLinks;

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
	ObjName="Switch"
	ObjCategory="Switch"

	Indices(0)=1
	LinkCount=1
	IncrementAmount=1
	OutputLinks(0)=(LinkDesc="Link 1")
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Index",PropertyName=Indices)
}
