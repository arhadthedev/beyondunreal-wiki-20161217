/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackVectorBase extends InterpTrack
	native(Interpolation)
	abstract;



/** Actually track data containing keyframes of a vector as it varies over time. */
var		InterpCurveVector	VectorTrack;

/** Tension of curve, used for keypoints using automatic tangents. */
var()	float				CurveTension;

defaultproperties
{
	TrackTitle="Generic Vector Track"
	CurveTension=0.0
}
