/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_DelaySwitch extends SeqAct_Latent
	native(Sequence);

;

var() int							LinkCount;

var transient int					CurrentIdx;
var transient float					SwitchDelay;
var transient float					NextLinkTime;

defaultproperties
{
	ObjName="Delayed"
	ObjCategory="Switch"
	LinkCount=1
	OutputLinks(0)=(LinkDesc="Link 1")

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Float',LinkDesc="Delay")
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Active Link",MinVars=0)
}
