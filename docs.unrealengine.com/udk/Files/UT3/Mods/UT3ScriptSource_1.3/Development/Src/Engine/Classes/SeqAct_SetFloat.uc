/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_SetFloat extends SeqAct_SetSequenceVariable
	native(Sequence);

;

var float Target;

var() float Value;

defaultproperties
{
	ObjName="Float"
	ObjClassVersion=2

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Float',LinkDesc="Target",bWriteable=true,PropertyName=Target)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Value",PropertyName=Value)
}
