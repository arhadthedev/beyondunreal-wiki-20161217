/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 **/
class SoundNodeDelay extends SoundNode
	native(Sound)
	collapsecategories
	hidecategories(Object)
	editinlinenew;

var() rawdistributionfloat DelayDuration;



defaultproperties
{
	Begin Object Class=DistributionFloatUniform Name=DistributionDelayDuration
		Min=0
		Max=0
	End Object
	DelayDuration=(Distribution=DistributionDelayDuration)
}
