﻿class UTSeqEvent_TouchStatus extends SeqEvent_Touch
	native(Sequence)
	hidecategories(SeqEvent_Touch);

/** internal - set when checking activation; indicates whether it's a touch check or untouch check */
var const private transient bool bCheckingTouch;



defaultproperties
{
	ObjName="Touch Status"
	OutputLinks[0]=(LinkDesc="First Touch")
	OutputLinks[1]=(LinkDesc="All UnTouched")
	bForceOverlapping=false
	ReTriggerDelay=0.0
	MaxTriggerCount=0
	VariableLinks.Empty()
}
