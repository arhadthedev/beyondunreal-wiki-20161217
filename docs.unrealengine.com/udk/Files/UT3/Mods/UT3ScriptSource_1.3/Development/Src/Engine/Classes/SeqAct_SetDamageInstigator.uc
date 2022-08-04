/** sets who gets credit for damage caused by the Target Actor */
class SeqAct_SetDamageInstigator extends SequenceAction;

var Actor DamageInstigator;

defaultproperties
{
	ObjCategory="Actor"
	ObjName="Set Damage Instigator"
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Damage Instigator",PropertyName=DamageInstigator,MinVars=1,MaxVars=1)
}
