/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSizeMultiplyVelocity extends ParticleModuleSizeBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

var(Size)					rawdistributionvector	VelocityMultiplier;
var(Size)					bool					MultiplyX;
var(Size)					bool					MultiplyY;
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
