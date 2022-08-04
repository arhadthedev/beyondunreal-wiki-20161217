/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_MultiplyInt extends SeqAct_SetSequenceVariable
	native(Sequence);

;

var() int ValueA;
var() int ValueB;
var float FloatResult;
var int IntResult;

defaultproperties
{
	ObjName="Multiply Int"
	ObjCategory="Math"

	InputLinks(0)=(LinkDesc="In")
	
	OutputLinks(0)=(LinkDesc="Out")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="A",PropertyName=ValueA)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="B",PropertyName=ValueB)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Int',LinkDesc="IntResult",bWriteable=true,PropertyName=IntResult)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Float',LinkDesc="FloatResult",bWriteable=true,PropertyName=FloatResult)
}
