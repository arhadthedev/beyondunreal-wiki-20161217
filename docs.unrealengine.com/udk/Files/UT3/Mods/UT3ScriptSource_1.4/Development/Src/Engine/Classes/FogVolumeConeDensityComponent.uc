/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class FogVolumeConeDensityComponent extends FogVolumeDensityComponent
	native(FogVolume)
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** This is the density at the center of the cone, which will be the maximum. */
var()	const	interp	float	MaxDensity;

/** The cone's vertex in world space. */
var()	const	interp	vector	ConeVertex;

/** The cone's radius. */
var()	const	interp	float	ConeRadius;

/** Direction of the cone */
var()	const	interp	vector	ConeAxis;

/** Angle from the axis that limits the cone's volume */
var()	const	interp	float	ConeMaxAngle;

/** A preview component for visualizing the cone in the editor. */
var const DrawLightConeComponent PreviewCone;



defaultproperties
{
	MaxDensity=0.002
	ConeVertex=(X=0.0,Y=0.0,Z=0.0)
	ConeRadius=600.0
	ConeAxis=(X=0.0,Y=0.0,Z=-1.0)
	ConeMaxAngle=30.0
}
