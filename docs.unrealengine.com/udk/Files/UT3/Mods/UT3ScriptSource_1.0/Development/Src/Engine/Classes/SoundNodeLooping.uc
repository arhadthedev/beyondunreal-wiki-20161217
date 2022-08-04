/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SoundNodeLooping extends SoundNode
	native(Sound)
	collapsecategories
	hidecategories(Object)
	editinlinenew;

var()	bool					bLoopIndefinitely;
var()	rawdistributionfloat	LoopCount;




defaultproperties
{
	bLoopIndefinitely=TRUE
	Begin Object Class=DistributionFloatUniform Name=DistributionLoopCount
		Min=1000000
		Max=1000000
	End Object
	LoopCount=(Distribution=DistributionLoopCount)
}
