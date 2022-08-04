class InterpTrackEvent extends InterpTrack
	native(Interpolation);

/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * 
 *	A track containing discrete events that are triggered as its played back. 
 *	Events correspond to Outputs of the SeqAct_Interp in Kismet.
 *	There is no PreviewUpdateTrack function for this type - events are not triggered in editor.
 */



/** Information for one event in the track. */
struct native EventTrackKey
{
	var		float	Time;
	var()	name	EventName;
};	

/** Array of events to fire off. */
var	array<EventTrackKey>	EventTrack;

/** If events should be fired when passed playing the sequence forwards. */
var() bool	bFireEventsWhenForwards;

/** If events should be fired when passed playing the sequence backwards. */
var() bool	bFireEventsWhenBackwards;

/** If true, events on this track are fired even when jumping forwads through a sequence - for example, skipping a cinematic. */
var() bool	bFireEventsWhenJumpingForwards;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstEvent'
	TrackTitle="Event"
	bFireEventsWhenForwards=true
	bFireEventsWhenBackwards=true
}
