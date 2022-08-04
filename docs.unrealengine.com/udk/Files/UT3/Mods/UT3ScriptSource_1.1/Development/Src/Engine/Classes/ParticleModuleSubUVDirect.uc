/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSubUVDirect extends ParticleModuleSubUVBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	The upper-left corner of the texture coordinates desired.
 *	Value is retrieved using RelativeTime of the particle.
 */
var(SubUV) rawdistributionvector	SubUVPosition;
/**
 *	The size of the texture sample desired.
 *	Value is retrieved using RelativeTime of the particle.
 */
var(SubUV) rawdistributionvector	SubUVSize;



defaultproperties
{
	bSpawnModule=false
	bUpdateModule=true

	Begin Object Class=DistributionVectorConstant Name=DistributionSubImagePosition
	End Object
	SubUVPosition=(Distribution=DistributionSubImagePosition)

	Begin Object Class=DistributionVectorConstant Name=DistributionSubImageSize
	End Object
	SubUVSize=(Distribution=DistributionSubImageSize)
}
