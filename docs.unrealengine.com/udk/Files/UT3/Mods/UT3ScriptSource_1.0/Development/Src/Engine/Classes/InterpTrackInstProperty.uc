/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackInstProperty extends InterpTrackInst
	native(Interpolation);




/** Function to call after updating the value of the color property. */
var function	PropertyUpdateCallback;

/** Pointer to the UObject instance that is the outer of the color property we are interpolating on, this is used to process the property update callback. */
var object		PropertyOuterObjectInst;