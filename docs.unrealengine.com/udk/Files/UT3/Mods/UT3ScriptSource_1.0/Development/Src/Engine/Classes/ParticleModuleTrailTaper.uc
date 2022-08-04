/**
 *	ParticleModuleTrailTaper
 *	Trail taper module
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleTrailTaper extends ParticleModuleTrailBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

//*************************************************************************************************
// Trail Tapering Variables
//*************************************************************************************************
enum ETrailTaperMethod
{
	/** No tapering is applied																*/
	PETTM_None, 
	/** Taper the trail relative to source-->target, regardless of current beam length		*/
	PETTM_Full,
	/** Taper the trail relative to source-->location, 0=source,1=endpoint					*/
	PETTM_Partial
};

/** Tapering mode																			*/
var(Taper)									ETrailTaperMethod			TaperMethod;

/** Tapering factor, 0 = source of beam, 1 = target											*/
var(Taper)									rawdistributionfloat			TaperFactor;

//*************************************************************************************************
// C++ Text
//*************************************************************************************************


//*************************************************************************************************
// Default properties
//*************************************************************************************************
defaultproperties
{
	TaperMethod=PETTM_None

	Begin Object Class=DistributionFloatConstant Name=DistributionTaperFactor
		Constant=1.0
	End Object
	TaperFactor=(Distribution=DistributionTaperFactor)
}
