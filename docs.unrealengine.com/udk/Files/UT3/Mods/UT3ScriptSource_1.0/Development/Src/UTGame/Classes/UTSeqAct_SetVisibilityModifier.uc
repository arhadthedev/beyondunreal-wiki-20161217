class UTSeqAct_SetVisibilityModifier extends SequenceAction;

var() float NewVisibilityModifier;

event Activated()
{
	local UTMapInfo MapInfo;

	MapInfo = UTMapInfo(GetWorldInfo().GetMapInfo());
	if (MapInfo == None)
	{
		ScriptLog("SetVisibilityModifier: Missing UTMapInfo!");
	}
	else
	{
		MapInfo.VisibilityModifier = NewVisibilityModifier;
	}
}

defaultproperties
{
	NewVisibilityModifier=1.0
	ObjName="Set Visibility Modifier"
	ObjCategory="AI"
	VariableLinks.Empty()
}
