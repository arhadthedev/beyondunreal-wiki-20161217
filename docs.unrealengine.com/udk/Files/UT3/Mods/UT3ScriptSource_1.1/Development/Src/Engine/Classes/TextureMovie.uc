/** 
 * TextureMovie
 * Movie texture support base class.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class TextureMovie extends Texture
	native
	hidecategories(Object);

/** The width of the texture. */
var const int SizeX;

/** The height of the texture. */
var const int SizeY;

/** The format of the texture data. */
var const EPixelFormat Format;

/** The addressing mode to use for the X axis. */
var() TextureAddress AddressX;

/** The addressing mode to use for the Y axis. */
var() TextureAddress AddressY;

/** Class type of Decoder that will be used to decode Data. */
var	const class<CodecMovie> DecoderClass;
/** Instance of decoder. */
var	const transient	CodecMovie Decoder;

/** Whether the movie is currently paused. */
var const bool Paused;
/** Whether the movie is currently stopped. */
var const bool Stopped;
/** Whether the movie should loop when it reaches the end. */
var() bool Looping;
/** Whether the movie should automatically start playing when it is loaded. */
var() bool AutoPlay;

/** Raw compressed data as imported. */
var	native	const UntypedBulkData_Mirror	Data{FByteBulkData};

/** Set in order to synchronize codec access to this movie texture resource from the render thread */
var native const transient pointer ReleaseCodecFence{FRenderCommandFence};

/** Select streaming movie from memory or from file for playback */
var() enum EMovieStreamSource
{
	/** stream directly from file */
	MovieStream_File,
	/** load movie contents to memory */
	MovieStream_Memory,
} MovieStreamSource;

/** Plays the movie and also unpauses. */
native function Play();
/** Pauses the movie. */	
native function Pause();
/** Stops movie playback. */
native function Stop();



defaultproperties
{
	MovieStreamSource=MovieStream_File
	DecoderClass=class'CodecMovieFallback'
	Stopped=True
	Looping=True
	AutoPlay=True
	NeverStream=True
}
