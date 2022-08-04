/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSubUVDirect extends ParticleModuleSubUVBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

var(SubUV) rawdistributionvector	SubUVPosition;
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
