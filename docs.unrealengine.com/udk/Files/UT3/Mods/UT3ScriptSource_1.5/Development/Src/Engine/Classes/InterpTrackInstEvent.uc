/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackInstEvent extends InterpTrackInst
	native(Interpolation);




/** 
 *	Position we were in last time we evaluated Events. 
 *	During UpdateTrack, events between this time and the current time will be fired. 
 */
var	float LastUpdatePosition; 

defaultproperties
{
}
