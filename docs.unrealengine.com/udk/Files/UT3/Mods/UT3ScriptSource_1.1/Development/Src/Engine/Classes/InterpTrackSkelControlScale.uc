/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackSkelControlScale extends InterpTrackFloatBase
	native(Interpolation);



/** Name of property in Group Actor which this track mill modify over time. */
var()	name	SkelControlName;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstSkelControlScale'
	TrackTitle="SkelControl Scale"
	bIsAnimControlTrack=true
}
