/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_External extends SequenceVariable
	native(Sequence);



/** */
var class<SequenceVariable> ExpectedType;

/** Name of the variable link to create on the parent sequence */
var() string VariableLabel;

defaultproperties
{
	ObjName="External Variable"
	VariableLabel="Default Var"
}
