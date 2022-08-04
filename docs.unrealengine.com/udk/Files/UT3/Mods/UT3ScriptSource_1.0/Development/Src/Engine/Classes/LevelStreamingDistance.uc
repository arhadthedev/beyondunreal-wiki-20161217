/**
 * LevelStreamingDistance
 *
 * Distance based streaming implementation.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class LevelStreamingDistance extends LevelStreaming
	native;


/** Origin of level used for distance calculation to viewer				*/
var()	vector	Origin;
/** Maximum distance to viewer at which the level still is streamed in	*/
var()	float	MaxDistance;


