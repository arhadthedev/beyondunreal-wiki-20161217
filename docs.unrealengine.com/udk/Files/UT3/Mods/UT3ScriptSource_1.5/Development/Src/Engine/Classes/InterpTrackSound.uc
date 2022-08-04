class InterpTrackSound extends InterpTrackVectorBase
	native(Interpolation);

/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * 
 *	A track that plays sounds on the groups Actor.
 */



/** Information for one sound in the track. */
struct native SoundTrackKey
{
	var		float		Time;
	var		float		Volume;
	var		float		Pitch;
	var()	SoundCue	Sound;

	structdefaultproperties
	{
		Volume=1.f
		Pitch=1.f
	}
};	

/** Array of sounds to play at specific times. */
var	array<SoundTrackKey>	Sounds;

/** If true, sounds on this track will not be forced to finish when the matinee sequence finishes. */
var()	bool			bContinueSoundOnMatineeEnd;

/** If TRUE, don't show subtitles for sounds played by this track. */
var()	bool			bSuppressSubtitles;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstSound'
	TrackTitle="Sound"
}
