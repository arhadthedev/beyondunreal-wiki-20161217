﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSizeMultiplyVelocity extends ParticleModuleSizeBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	The amount the velocity should be scaled prior to scaling the size of the particle. 
 *	The value is retrieved using the RelativeTime of the particle during its update.
 */
var(Size)					rawdistributionvector	VelocityMultiplier;
/** 
 *	If true, the X-component of the scale factor will be applied to the particle size X-component.
 *	If false, the X-component is left unaltered.
 */
var(Size)					bool					MultiplyX;
/** 
 *	If true, the Y-component of the scale factor will be applied to the particle size Y-component.
 *	If false, the Y-component is left unaltered.
 */
var(Size)					bool					MultiplyY;
/** 
 *	If true, the Z-component of the scale factor will be applied to the particle size Z-component.
 *	If false, the Z-component is left unaltered.
 */
var(Size)					bool					MultiplyZ;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true

	MultiplyX=true
	MultiplyY=true
	MultiplyZ=true

	Begin Object Class=DistributionVectorConstant Name=DistributionVelocityMultiplier
	End Object
	VelocityMultiplier=(Distribution=DistributionVelocityMultiplier)
}
