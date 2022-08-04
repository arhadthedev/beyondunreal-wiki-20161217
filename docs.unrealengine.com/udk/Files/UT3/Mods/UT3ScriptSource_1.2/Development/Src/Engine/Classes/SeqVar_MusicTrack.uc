/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_MusicTrack extends SeqVar_Object
	native(Sequence)
	DependsOn(MusicTrackDataStructures);




/**
 * This is the music track to play
 **/
var() MusicTrackStruct MusicTrack;







defaultproperties
{
	ObjName="Music Track"
	ObjCategory="Sound"
	ObjColor=(R=255,G=0,B=255,A=255)
}
