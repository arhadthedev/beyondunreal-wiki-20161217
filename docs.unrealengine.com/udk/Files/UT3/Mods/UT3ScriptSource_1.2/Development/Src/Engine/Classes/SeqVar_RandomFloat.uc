/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_RandomFloat extends SeqVar_Float
	native(Sequence);



/** Min value for randomness */
var() float Min;

/** Max value for randomness */
var() float Max;

defaultproperties
{
	ObjName="Random Float"
	ObjCategory="Float"

	Min=0.f
	Max=1.f
}
