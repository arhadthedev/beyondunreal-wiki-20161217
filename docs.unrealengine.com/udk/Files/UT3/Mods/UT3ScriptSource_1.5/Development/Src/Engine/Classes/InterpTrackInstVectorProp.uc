/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackInstVectorProp extends InterpTrackInstProperty
	native(Interpolation);




/** Pointer to vector property in TrackObject. */
var	pointer		VectorProp; 

/** Saved value for restoring state when exiting Matinee. */
var	vector		ResetVector;
