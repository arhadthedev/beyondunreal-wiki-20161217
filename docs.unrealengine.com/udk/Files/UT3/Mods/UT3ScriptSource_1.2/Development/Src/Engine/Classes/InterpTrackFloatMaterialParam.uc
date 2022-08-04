class InterpTrackFloatMaterialParam extends InterpTrackFloatBase
	native(Interpolation);

/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */



/** Name of parameter in the MaterialInstnace which this track mill modify over time. */
var()	name		ParamName;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstFloatMaterialParam'
	TrackTitle="Float Material Param"
}
