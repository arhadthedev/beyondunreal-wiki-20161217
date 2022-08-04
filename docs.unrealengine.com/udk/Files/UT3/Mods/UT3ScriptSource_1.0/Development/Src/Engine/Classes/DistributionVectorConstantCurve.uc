/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class DistributionVectorConstantCurve extends DistributionVector
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** Keyframe data for each component (X,Y,Z) over time. */
var()	InterpCurveVector	ConstantCurve;

/** If true, X == Y == Z ie. only one degree of freedom. If false, each axis is picked independently. */ 
var		bool							bLockAxes;
var()	EDistributionVectorLockFlags	LockedAxes;


