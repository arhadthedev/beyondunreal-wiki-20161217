/**
 *	ParticleModuleBeamTarget
 *
 *	This module implements a single target for a beam emitter.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class ParticleModuleBeamTarget extends ParticleModuleBeamBase
	native(Particle)
	editinlinenew
	dontcollapsecategories
	hidecategories(Object);

/** The method flag																			*/
var(Target)									Beam2SourceTargetMethod			TargetMethod;

/** The target point sources of each beam, when using the end point method.					*/
var(Target)									name							TargetName;

/** Default target-point information to use if the beam method is endpoint					*/
var(Target)									rawdistributionvector			Target;

/** Whether to treat the as an absolute position in world space.							*/
var(Target)									bool							bTargetAbsolute;

/** Whether to lock the Target to the life of the particle									*/
var(Target)									bool							bLockTarget;

/** The method to use for the Target tangent.												*/
var(Target)									Beam2SourceTargetTangentMethod	TargetTangentMethod;

/** The tangent for the Target point for each beam											*/
var(Target)									rawdistributionvector			TargetTangent;

/** Whether to lock the Target to the life of the particle									*/
var(Target)									bool							bLockTargetTangent;

/** The strength of the tangent from the Target point for each beam							*/
var(Target)									rawdistributionfloat			TargetStrength;

/** Whether to lock the Target to the life of the particle									*/
var(Target)									bool							bLockTargetStength;

/** Default target-point information to use if the beam method is endpoint					*/
var(Target)									float							LockRadius;



defaultproperties
{
	TargetMethod=PEB2STM_Default
	
	TargetName="None"
	bTargetAbsolute=false

	Begin Object Class=DistributionVectorConstant Name=DistributionTarget
		Constant=(X=50,Y=50,Z=50)
	End Object
	Target=(Distribution=DistributionTarget)
	
	TargetTangentMethod=PEB2STTM_Direct

	Begin Object Class=DistributionVectorConstant Name=DistributionTargetTangent
		Constant=(X=1,Y=0,Z=0)
	End Object
	TargetTangent=(Distribution=DistributionTargetTangent)

	Begin Object Class=DistributionFloatConstant Name=DistributionTargetStrength
		Constant=25.0
	End Object
	TargetStrength=(Distribution=DistributionTargetStrength)

	LockRadius=10.0
}
