﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleRotation extends ParticleModuleRotationBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

/** Initial rotation distribution, in degrees. */
var(Rotation) rawdistributionfloat	StartRotation;



defaultproperties
{
	bSpawnModule=true

	Begin Object Class=DistributionFloatUniform Name=DistributionStartRotation
		Min=0.0
		Max=1.0
	End Object
	StartRotation=(Distribution=DistributionStartRotation)
}

