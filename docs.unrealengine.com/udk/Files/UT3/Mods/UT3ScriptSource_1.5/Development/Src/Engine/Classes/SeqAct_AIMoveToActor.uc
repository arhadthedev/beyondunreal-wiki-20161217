﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_AIMoveToActor extends SeqAct_Latent
	native(Sequence);



/** Should this move be interruptable? */
var() bool bInterruptable;

defaultproperties
{
	ObjName="Move To Actor (Latent)"
	ObjCategory="AI"
	ObjClassVersion=2

	OutputLinks(2)=(LinkDesc="Out")

	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Destination")
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Look At")
}
