﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MusicTrackDataStructures extends Object
	native;


/**
 * These are the parameters we can control on a track that is being faded in / out
 **/
struct native MusicTrackParamStruct
{
	/** Time taken for sound to fade in when action is activated. */
	var() float FadeInTime;

	/** Volume the sound to should fade in to */
	var() float FadeInVolumeLevel;


	/** Amount of delay between playing the new track */
	var() float DelayBetweenOldAndNewTrack;


	/** Time take for sound to fade out when Stop input is fired. */
	var() float FadeOutTime;

	/** Volume the sound to should fade out to */
	var() float FadeOutVolumeLevel;

	

	structdefaultproperties
	{
		FadeInTime=5.0f
		FadeInVolumeLevel=1.0f
		DelayBetweenOldAndNewTrack = 0.0f
		FadeOutTime=5.0f
		FadeOutVolumeLevel=0.0f
	}

};


struct native MusicTrackStruct
{
	var() MusicTrackParamStruct Params;

	/** which type this track is **/
	var() name TrackType;

	/** The soundCue to play **/
	var() SoundCue TheSoundCue;

	/** Controls whether or not the track is auto-played when it is attached to the scene. */
	var() bool bAutoPlay;

	structdefaultproperties
	{
	}
};



defaultproperties
{
}



