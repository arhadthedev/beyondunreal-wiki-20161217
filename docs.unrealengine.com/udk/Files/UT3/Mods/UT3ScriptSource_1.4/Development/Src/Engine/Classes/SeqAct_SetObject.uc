/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_SetObject extends SeqAct_SetSequenceVariable
	native(Sequence);

;

/** Default value to use if no variables are linked */
var() Object DefaultValue;

var Object Value;

defaultproperties
{
	ObjName="Object"

	ObjClassVersion=2
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Value",PropertyName=Value)
}
