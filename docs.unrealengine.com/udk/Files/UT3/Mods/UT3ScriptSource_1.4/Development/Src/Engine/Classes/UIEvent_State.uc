/**
 * Abstract base class for events which are implemented by UIStates.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIEvent_State extends UIEvent
	native(inherit)
	abstract;



DefaultProperties
{
	ObjName="State Event"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="State",bWriteable=true)
	bPropagateEvent=false
}
