/**
 *	ParticleModuleBeamModifier
 *
 *	This module implements a single modifier for a beam emitter.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class ParticleModuleBeamModifier extends ParticleModuleBeamBase
	native(Particle)
	editinlinenew
	dontcollapsecategories
	hidecategories(Object);

/**
 *	What to modify.
 */
enum BeamModifierType
{
	/** Modify the source of the beam.				*/
	PEB2MT_Source,
	/** Modify the target of the beam.				*/
	PEB2MT_Target
};

var(Modifier)		BeamModifierType				ModifierType;

struct native BeamModifierOptions
{
	/** If TRUE, modify the value associated with this grouping.	*/
	var()	bool	bModify;
	/** If TRUE, scale the associated value by the given value.		*/
	var()	bool	bScale;
	/** If TRUE, lock the modifier to the life of the particle.		*/
	var()	bool	bLock;
};

/** The options associated with the position.								*/
var(Position)	BeamModifierOptions		PositionOptions;

/** The value to use when modifying the position.							*/
var(Position)	rawdistributionvector	Position;

/** The options associated with the Tangent.								*/
var(Tangent)	BeamModifierOptions		TangentOptions;

/** The value to use when modifying the Tangent.							*/
var(Tangent)	rawdistributionvector	Tangent;

/** If TRUE, don't transform the tangent modifier into the tangent basis.	*/
var(Tangent)	bool					bAbsoluteTangent;

/** The options associated with the Strength.								*/
var(Strength)	BeamModifierOptions		StrengthOptions;

/** The value to use when modifying the Strength.							*/
var(Strength)	rawdistributionfloat	Strength;



defaultproperties
{
	ModifierType=PEB2MT_Source
	
	Begin Object Class=DistributionVectorConstant Name=DistributionPosition
		Constant=(X=0,Y=0,Z=0)
	End Object
	Position=(Distribution=DistributionPosition)

	Begin Object Class=DistributionVectorConstant Name=DistributionTangent
		Constant=(X=0,Y=0,Z=0)
	End Object
	Tangent=(Distribution=DistributionTangent)

	Begin Object Class=DistributionFloatConstant Name=DistributionStrength
		Constant=0.0
	End Object
	Strength=(Distribution=DistributionStrength)
}
