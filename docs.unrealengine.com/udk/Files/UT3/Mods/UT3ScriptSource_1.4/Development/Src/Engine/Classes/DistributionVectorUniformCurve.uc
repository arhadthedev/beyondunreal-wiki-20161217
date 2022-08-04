/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class DistributionVectorUniformCurve extends DistributionVector
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** Keyframe data for how output constant varies over time. */
var()	interpcurvetwovectors		ConstantCurve;

/** If true, X == Y == Z ie. only one degree of freedom. If false, each axis is picked independently. */ 
var		bool							bLockAxes1;
var		bool							bLockAxes2;
var()	EDistributionVectorLockFlags	LockedAxes[2];
var()	EDistributionVectorMirrorFlags	MirrorFlags[3];
var()	bool							bUseExtremes;



defaultproperties
{
	bLockAxes1		= false
	bLockAxes2		= false
	LockedAxes[0]	= EDVLF_None
	LockedAxes[1]	= EDVLF_None
	MirrorFlags[0]	= EDVMF_Different
	MirrorFlags[1]	= EDVMF_Different
	MirrorFlags[2]	= EDVMF_Different
	bUseExtremes	= false
}
