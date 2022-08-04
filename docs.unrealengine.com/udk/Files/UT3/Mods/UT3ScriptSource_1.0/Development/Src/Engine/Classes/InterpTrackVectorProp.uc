/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackVectorProp extends InterpTrackVectorBase
	native(Interpolation);



/** Name of property in Group Actor which this track mill modify over time. */
var()	editconst	name		PropertyName;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstVectorProp'
	TrackTitle="Vector Property"
}
