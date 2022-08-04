class InterpTrackFloatParticleParam extends InterpTrackFloatBase
	native(Interpolation);

/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */



/** Name of property in the Emitter which this track mill modify over time. */
var()	name		ParamName;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstFloatParticleParam'
	TrackTitle="Float Particle Param"
}
