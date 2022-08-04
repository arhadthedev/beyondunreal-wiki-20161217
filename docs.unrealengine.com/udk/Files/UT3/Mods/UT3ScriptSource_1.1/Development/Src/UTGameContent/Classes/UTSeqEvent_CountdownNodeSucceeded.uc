class UTSeqEvent_CountdownNodeSucceeded extends SequenceEvent;

var() UTOnslaughtPowerCore ControllingCore;

event Activated()
{
	local UTOnslaughtCountdownNode CountdownNode;

	CountdownNode = UTOnslaughtCountdownNode(Originator);
	if (CountdownNode != None)
	{
		ControllingCore = UTOnslaughtGame(CountdownNode.WorldInfo.Game).PowerCore[CountdownNode.GetTeamNum()];
	}
	else
	{
		ScriptLog("CountdownNodeSucceeded not connected to CountdownNode!");
	}
}

defaultproperties
{
	ObjName="Countdown Node Succeeded"
	ObjCategory="Objective"
	bPlayerOnly=false
	MaxTriggerCount=0
	VariableLinks.Empty()
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Node Team's PowerCore",bWriteable=true,PropertyName=ControllingCore)
}
