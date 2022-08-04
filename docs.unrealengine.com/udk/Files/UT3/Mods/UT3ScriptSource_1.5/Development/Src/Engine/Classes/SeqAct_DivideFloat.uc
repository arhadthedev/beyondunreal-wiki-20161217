/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_DivideFloat extends SeqAct_SetSequenceVariable
	native(Sequence);

;

var() float ValueA;
var() float ValueB;
var float FloatResult;
var int IntResult;

defaultproperties
{
	ObjName="Divide Float"
	ObjCategory="Math"

	InputLinks(0)=(LinkDesc="In")
	
	OutputLinks(0)=(LinkDesc="Out")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Float',LinkDesc="A",PropertyName=ValueA)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="B",PropertyName=ValueB)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="FloatResult",bWriteable=true,PropertyName=FloatResult)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Int',LinkDesc="IntResult",bWriteable=true,PropertyName=IntResult)
}
