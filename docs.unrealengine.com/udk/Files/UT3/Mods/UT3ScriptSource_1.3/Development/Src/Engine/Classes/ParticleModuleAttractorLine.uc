/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleAttractorLine extends ParticleModuleAttractorBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

// The endpoints of the line
var(Attractor) vector												EndPoint0;
var(Attractor) vector												EndPoint1;
// The range of the line attractor.
var(Attractor) rawdistributionfloat	Range;
// The strength of the line attractor.
var(Attractor) rawdistributionfloat	Strength;



defaultproperties
{
	bUpdateModule=true

	Begin Object Class=DistributionFloatConstant Name=DistributionStrength
	End Object
	Strength=(Distribution=DistributionStrength)

	Begin Object Class=DistributionFloatConstant Name=DistributionRange
	End Object
	Range=(Distribution=DistributionRange)

	bSupported3DDrawMode=true
}
