/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SoundNodeAmbientNonLoop extends SoundNodeAmbient
	native(Sound)
	collapsecategories
	hidecategories(Object)
	dependson(SoundNodeAttenuation)
	editinlinenew;


var()								rawdistributionfloat	DelayTime;

struct native AmbientSoundSlot
{
	var()	SoundNodeWave	Wave;
	var()	float			PitchScale;
	var()	float			VolumeScale;
	var()	float			Weight;

	structdefaultproperties
	{
		PitchScale=1.0
		VolumeScale=1.0
		Weight=1.0
	}
};

var()								array<AmbientSoundSlot>	SoundSlots;




defaultproperties
{
	Begin Object Class=DistributionFloatUniform Name=DistributionDelayTime
		Min=1
		Max=1
	End Object
	DelayTime=(Distribution=DistributionDelayTime)
}
