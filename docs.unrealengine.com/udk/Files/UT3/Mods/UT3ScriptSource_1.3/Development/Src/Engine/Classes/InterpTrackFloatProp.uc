class InterpTrackFloatProp extends InterpTrackFloatBase
	native(Interpolation);

/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */



/** Name of property in Group Actor which this track mill modify over time. */
var()	editconst	name		PropertyName;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstFloatProp'
	TrackTitle="Float Property"
}
