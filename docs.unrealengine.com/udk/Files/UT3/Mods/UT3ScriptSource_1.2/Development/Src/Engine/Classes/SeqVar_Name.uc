/**
 * Sequence variable for holding a name value.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class SeqVar_Name extends SequenceVariable
	native(inherit);



/** the value of this variable */
var() 	name			NameValue;

defaultproperties
{
	ObjName="Name"
	ObjColor=(R=128,G=255,B=255,A=255)		// aqua
}
