/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class InterpTrackMorphWeight extends InterpTrackFloatBase
	native(Interpolation);



/** Name of property in Group Actor which this track mill modify over time. */
var()	name	MorphNodeName;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstMorphWeight'
	TrackTitle="Morph Weight"
	bIsAnimControlTrack=true
}
