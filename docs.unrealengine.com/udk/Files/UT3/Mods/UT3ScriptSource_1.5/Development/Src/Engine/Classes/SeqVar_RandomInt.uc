/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_RandomInt extends SeqVar_Int
	native(Sequence);



/** Min value for randomness */
var() int Min;

/** Max value for randomness */
var() int Max;

defaultproperties
{
	ObjName="Random Int"
	ObjCategory="Int"

	Min=0
	Max=100
}
