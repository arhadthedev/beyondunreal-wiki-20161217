/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSubUV extends ParticleModuleSubUVBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	The index of the sub-image that should be used for the particle.
 *	The value is retrieved using the RelativeTime of the particles.
 */
var(SubUV) rawdistributionfloat	SubImageIndex;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true

	Begin Object Class=DistributionFloatConstant Name=DistributionSubImage
	End Object
	SubImageIndex=(Distribution=DistributionSubImage)
}
