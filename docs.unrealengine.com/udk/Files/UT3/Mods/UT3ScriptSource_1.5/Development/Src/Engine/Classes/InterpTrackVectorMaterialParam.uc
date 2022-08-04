class InterpTrackVectorMaterialParam extends InterpTrackVectorBase
	native(Interpolation);

/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */



/** Name of parameter in the MaterialInstnace which this track mill modify over time. */
var()	name		ParamName;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstVectorMaterialParam'
	TrackTitle="Vector Material Param"
}
