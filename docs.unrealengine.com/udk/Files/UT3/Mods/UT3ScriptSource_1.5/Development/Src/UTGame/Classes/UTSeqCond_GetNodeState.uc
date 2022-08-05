﻿/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */


class UTSeqCond_GetNodeState extends SequenceCondition;

var() UTOnslaughtNodeObjective Node;

event Activated()
{
	if (Node == None)
	{
		ScriptLog("Invalid target specified for" @ self);
	}
	else
	{
		if (Node.IsActive())
		{
			OutputLinks[0].bHasImpulse = true;
		}
		else if (Node.bIsConstructing)
		{
			OutputLinks[1].bHasImpulse = true;
		}
		else
		{
			OutputLinks[2].bHasImpulse = true;
		}
	}
}

defaultproperties
{
	ObjName="Onslaught Node State"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Node",PropertyName=Node,MinVars=1,MaxVars=1)
	OutputLinks[0]=(LinkDesc="Active")
	OutputLinks[1]=(LinkDesc="Constructing")
	OutputLinks[2]=(LinkDesc="Neutral/Destroyed")
}
