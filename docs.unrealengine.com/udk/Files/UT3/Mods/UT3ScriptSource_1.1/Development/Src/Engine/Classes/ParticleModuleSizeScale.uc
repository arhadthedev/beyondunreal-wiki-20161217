/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSizeScale extends ParticleModuleSizeBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	The amount the BaseSize should be scaled before being used as the size of the particle. 
 *	The value is retrieved using the RelativeTime of the particle during its update.
 *	NOTE: this module overrides any size adjustments made prior to this module in that frame.
 */
var()					rawdistributionvector	SizeScale;
/** Ignored */
var()					bool					EnableX;
/** Ignored */
var()					bool					EnableY;
/** Ignored */
var()					bool					EnableZ;



defaultproperties
{
	bSpawnModule=false
	bUpdateModule=true

	EnableX=true
	EnableY=true
	EnableZ=true

	Begin Object Class=DistributionVectorConstant Name=DistributionSizeScale
	End Object
	SizeScale=(Distribution=DistributionSizeScale)
}
