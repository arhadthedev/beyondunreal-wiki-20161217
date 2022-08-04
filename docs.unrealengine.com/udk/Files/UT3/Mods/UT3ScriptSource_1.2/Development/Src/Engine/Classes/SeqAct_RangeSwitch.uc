/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * @todo - this should be a conditional
 */
class SeqAct_RangeSwitch extends SequenceAction
	native(Sequence);

;

struct native SwitchRange
{
	var() int Min;
	var() int Max;
};

var() editinline array<SwitchRange> Ranges;

defaultproperties
{
	ObjName="Ranged"
	ObjCategory="Switch"
	OutputLinks.Empty
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Index")
}
