/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_RandomSwitch extends SeqAct_Switch
	native(Sequence);

;

defaultproperties
{
	ObjName="Random"
	ObjCategory="Switch"
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Active Link",bWriteable=true,MinVars=0,PropertyName=Indices)
}
