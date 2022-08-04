﻿/**
 *	ParticleModuleBeamSource
 *
 *	This module implements a single source for a beam emitter.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class ParticleModuleBeamSource extends ParticleModuleBeamBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** The method flag. */
var(Source)			Beam2SourceTargetMethod			SourceMethod;

/** The strength of the tangent from the source point for each beam. */
var(Source)			name							SourceName;

/** Whether to treat the as an absolute position in world space. */
var(Source)			bool							bSourceAbsolute;

/** Default source-point to use. */
var(Source)			rawdistributionvector			Source;

/** Whether to lock the source to the life of the particle. */
var(Source)			bool							bLockSource;

/** The method to use for the source tangent. */
var(Source)			Beam2SourceTargetTangentMethod	SourceTangentMethod;

/** The tangent for the source point for each beam. */
var(Source)			rawdistributionvector			SourceTangent;

/** Whether to lock the source to the life of the particle. */
var(Source)			bool							bLockSourceTangent;

/** The strength of the tangent from the source point for each beam. */
var(Source)			rawdistributionfloat			SourceStrength;

/** Whether to lock the source to the life of the particle. */
var(Source)			bool							bLockSourceStength;



defaultproperties
{
	SourceMethod=PEB2STM_Default
	
	SourceName="None"
	bSourceAbsolute=false

	Begin Object Class=DistributionVectorConstant Name=DistributionSource
		Constant=(X=50,Y=50,Z=50)
	End Object
	Source=(Distribution=DistributionSource)

	SourceTangentMethod=PEB2STTM_Direct

	Begin Object Class=DistributionVectorConstant Name=DistributionSourceTangent
		Constant=(X=1,Y=0,Z=0)
	End Object
	SourceTangent=(Distribution=DistributionSourceTangent)

	Begin Object Class=DistributionFloatConstant Name=DistributionSourceStrength
		Constant=25.0
	End Object
	SourceStrength=(Distribution=DistributionSourceStrength)
}
