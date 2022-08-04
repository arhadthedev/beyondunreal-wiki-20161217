/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_MusicTrackBank extends SeqVar_Object
	native(Sequence);


/**
 * The bank of tracks
 **/
var() array<MusicTrackStruct> MusicTrackBank;







defaultproperties
{
	ObjName="Music Track Bank"
	ObjCategory="Sound"
	ObjColor=(R=255,G=0,B=255,A=255)
}
