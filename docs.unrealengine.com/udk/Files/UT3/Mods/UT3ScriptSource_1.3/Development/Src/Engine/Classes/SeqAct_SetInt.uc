/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_SetInt extends SeqAct_SetSequenceVariable
	native(Sequence);

;

/** Target property use to write to */
var int Target;

/** Value to apply */
var() int Value;

defaultproperties
{
	ObjName="Int"
	ObjClassVersion=2

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Target",bWriteable=true,PropertyName=Target)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Value",PropertyName=Value)
}
