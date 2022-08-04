/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class DistributionVectorUniform extends DistributionVector
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** Upper end of vector magnitude range. */
var() vector	Max;
/** Lower end of vector magnitude range. */
var() vector	Min;

/** If true, X == Y == Z ie. only one degree of freedom. If false, each axis is picked independently. */ 
var		bool							bLockAxes;
var()	EDistributionVectorLockFlags	LockedAxes;
var()	EDistributionVectorMirrorFlags	MirrorFlags[3];
var()	bool							bUseExtremes;



defaultproperties
{
	MirrorFlags[0] = EDVMF_Different
	MirrorFlags[1] = EDVMF_Different
	MirrorFlags[2] = EDVMF_Different
	
	bUseExtremes = false
}
