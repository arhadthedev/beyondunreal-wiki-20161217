﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqCond_CompareBool extends SequenceCondition
	native(Sequence);

;

defaultproperties
{
	ObjName="Compare Bool"
	ObjCategory="Comparison"

	InputLinks(0)=(LinkDesc="In")
	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Bool")
}
