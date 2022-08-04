class InterpTrackToggle extends InterpTrack
	native(Interpolation);

/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * 
 *	A track containing toggle actions that are triggered as its played back. 
 */



/** Enumeration indicating toggle action	*/
enum ETrackToggleAction
{
	ETTA_Off,
	ETTA_On,
	ETTA_Toggle
};

/** Information for one toggle in the track. */
struct native ToggleTrackKey
{
	var		float				Time;
	var()	ETrackToggleAction	ToggleAction;
};	

/** Array of events to fire off. */
var	array<ToggleTrackKey>	ToggleTrack;

/** If true, events on this track are fired even when jumping forwads through a sequence - for example, skipping a cinematic. */
var() bool	bFireEventsWhenJumpingForwards;

/** 
 *	If true, the track will call ActivateSystem on the emitter each update (the old 'incorrect' behavior).
 *	If false (the default), the System will only be activated if it was previously inactive.
 */
var() bool	bActivateSystemEachUpdate;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstToggle'
	TrackTitle="Toggle"
	bFireEventsWhenJumpingForwards=true
	bActivateSystemEachUpdate=false
}
