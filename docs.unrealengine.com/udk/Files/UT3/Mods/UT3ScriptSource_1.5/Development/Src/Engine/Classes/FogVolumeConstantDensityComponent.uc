/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class FogVolumeConstantDensityComponent extends FogVolumeDensityComponent
	native(FogVolume)
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** The constant density coefficient */
var()	const	interp	float	Density;



defaultproperties
{
	Density=0.0005
}
