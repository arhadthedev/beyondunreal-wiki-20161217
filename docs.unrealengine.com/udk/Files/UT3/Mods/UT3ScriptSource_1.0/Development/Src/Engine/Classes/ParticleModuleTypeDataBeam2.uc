/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleTypeDataBeam2 extends ParticleModuleTypeDataBase
	native(Particle)
	editinlinenew
	dontcollapsecategories
	hidecategories(Object);

enum EBeam2Method
{
	PEB2M_Distance, 
    PEB2M_Target, 
	PEB2M_Branch
};

//*************************************************************************************************
// General Beam Variables
//*************************************************************************************************
/** The method with which to form the beam(s)												*/
var(Beam)									EBeam2Method				BeamMethod;

/** The number of times to tile the texture along each beam									*/
var(Beam)									int							TextureTile;

/** The distance per texture tile															*/
var(Beam)									float						TextureTileDistance;

/** The number of sheets to render															*/
var(Beam)									int							Sheets;

/** The number of live beams																*/
var(Beam)									int							MaxBeamCount;

/** The speed at which the beam should move from source to target when firing up.
 *	'0' indicates instantaneous
 */
var(Beam)									float						Speed;

/** 
 * Indicates whether the beam should be interpolated.
 *     <= 0 --> no
 *     >  0 --> yes (and is equal to the number of interpolation steps that should be taken.
 */
var(Beam)									int							InterpolationPoints;

/** If true, there will ALWAYS be a beam...													*/
var(Beam)									bool						bAlwaysOn;

//*************************************************************************************************
// Beam Branching Variables
//*************************************************************************************************
/** The name of the emitter to branch from (if mode is PEB2M_Branch)
 * MUST BE IN THE SAME PARTICLE SYSTEM!
 */
var(Branching)								name						BranchParentName;

//*************************************************************************************************
// Beam Distance Variables
//*************************************************************************************************
/** Distance is only used if BeamMethod is Distance											*/
var(Distance)								rawdistributionfloat			Distance;

//*************************************************************************************************
// Beam Multi-target Variables
//*************************************************************************************************
struct BeamTargetData
{
	/** Name of the target.																	*/
	var()	name		TargetName;
	/** Percentage chance the target will be selected (100 = always).						*/
	var()	float		TargetPercentage;
};

//*************************************************************************************************
// Beam Tapering Variables
//*************************************************************************************************
enum EBeamTaperMethod
{
	/** No tapering is applied																*/
	PEBTM_None, 
	/** Taper the beam relative to source-->target, regardless of current beam length		*/
	PEBTM_Full,
	/** Taper the beam relative to source-->location, 0=source,1=endpoint					*/
	PEBTM_Partial
};

/** Tapering mode																			*/
var(Taper)									EBeamTaperMethod			TaperMethod;

/** Tapering factor, 0 = source of beam, 1 = target											*/
var(Taper)									rawdistributionfloat		TaperFactor;

/**
 *  Tapering scaling
 *	This is intended to be either a constant, uniform or a ParticleParam.
 *	If a curve is used, 0/1 mapping of source/target... which could be integrated into
 *	the taper factor itself, and therefore makes no sense.
 */
var(Taper)									rawdistributionfloat		TaperScale;


//*************************************************************************************************
// Beam Rendering Variables
//*************************************************************************************************
var(Rendering)								bool						RenderGeometry;
var(Rendering)								bool						RenderDirectLine;
var(Rendering)								bool						RenderLines;
var(Rendering)								bool						RenderTessellation;

//*************************************************************************************************
// C++ Text
//*************************************************************************************************


//*************************************************************************************************
// Default properties
//*************************************************************************************************
defaultproperties
{
	BeamMethod=PEB2M_Target
	TextureTile=1
	TextureTileDistance=0.0
	Sheets=1
	Speed=10
	InterpolationPoints=0
	bAlwaysOn=false
	
	BranchParentName="None"
	
	Begin Object Class=DistributionFloatConstant Name=DistributionDistance
		Constant=25.0
	End Object
	Distance=(Distribution=DistributionDistance)

	Begin Object Class=DistributionVectorConstant Name=DistributionNoiseSpeed
		Constant=(X=50,Y=50,Z=50)
	End Object

	TaperMethod=PEBTM_None
	Begin Object Class=DistributionFloatConstant Name=DistributionTaperFactor
		Constant=1.0
	End Object
	TaperFactor=(Distribution=DistributionTaperFactor)

	Begin Object Class=DistributionFloatConstant Name=DistributionTaperScale
		Constant=1.0
	End Object
	TaperScale=(Distribution=DistributionTaperScale)

	RenderGeometry=true
	RenderDirectLine=false
	RenderLines=false
	RenderTessellation=false
}
