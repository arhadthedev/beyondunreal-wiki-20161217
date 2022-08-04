/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqCond_IsSameTeam extends SequenceCondition
	native(Sequence);



defaultproperties
{
	ObjName="Same Team"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Players")
}
