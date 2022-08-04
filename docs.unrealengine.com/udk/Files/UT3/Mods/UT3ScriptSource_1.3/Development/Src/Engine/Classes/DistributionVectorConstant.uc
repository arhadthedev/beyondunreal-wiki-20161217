/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class DistributionVectorConstant extends DistributionVector
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** This vector will be returned for all input times. */
var()	vector	Constant;

/** If true, X == Y == Z ie. only one degree of freedom. If false, each axis is picked independently. */ 
var		bool							bLockAxes;
var()	EDistributionVectorLockFlags	LockedAxes;


