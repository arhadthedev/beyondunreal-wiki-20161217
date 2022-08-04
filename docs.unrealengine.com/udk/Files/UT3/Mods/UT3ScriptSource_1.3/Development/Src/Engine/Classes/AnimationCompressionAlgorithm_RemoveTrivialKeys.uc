/**
 * Removes trivial frames -- frames of tracks when position or orientation is constant
 * over the entire animation -- from the raw animation data.  If both position and rotation
 * go down to a single frame, the time is stripped out as well.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class AnimationCompressionAlgorithm_RemoveTrivialKeys extends AnimationCompressionAlgorithm
	native(Anim);

var()	float	MaxPosDiff;
var()	float	MaxAngleDiff;



defaultproperties
{
	Description="Remove Trivial Keys"

	MaxPosDiff=0.0001
	MaxAngleDiff=0.0003
}
