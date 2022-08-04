﻿/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class SeqCond_IsInCombat extends SequenceCondition
	native(Sequence);



defaultproperties
{
	ObjName="In Combat"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Players")
}