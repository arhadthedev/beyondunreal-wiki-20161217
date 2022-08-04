/**
 * Simple action that records the amount of time elapsed
 * between activating the first link "Start" and the second
 * link "Stop".
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_Timer extends SequenceAction
	native(Sequence);

;

/** World time at point of activation */
var transient float ActivationTime;

/** Amount of time this timer has been active */
var() float Time;

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
	ObjName="Timer"
	ObjCategory="Misc"

	bLatentExecution=TRUE

	InputLinks(0)=(LinkDesc="Start")
	InputLinks(1)=(LinkDesc="Stop")

	VariableLinks.Empty
	VariableLinks(0)=(LinkDesc="Time",ExpectedType=class'SeqVar_Float',PropertyName=Time)
}
