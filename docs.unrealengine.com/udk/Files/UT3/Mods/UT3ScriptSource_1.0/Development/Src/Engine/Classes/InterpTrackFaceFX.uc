class InterpTrackFaceFX extends InterpTrack
	native(Interpolation);
	
/** 
 * InterpTrackFaceFX
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
 
 


/** Structure used for holding information for one FaceFX animation played by the track. */
struct native FaceFXTrackKey
{
	/** Position in the Matinee sequence to start playing this FaceFX animation. */
	var		float	StartTime;

	/** Name of FaceFX group containing sequence to play. */
	var		string	FaceFXGroupName;

	/** Name of FaceFX sequence to play. */
	var		string	FaceFXSeqName;
};	

/** Extra sets of animation that you wish to use on this Group's Actor during the matinee sequence. */
var()	array<FaceFXAnimSet>	FaceFXAnimSets;

/** Track of different animations to play and when to start playing them. */
var	array<FaceFXTrackKey>	FaceFXSeqs;

/** In Matinee, cache a pointer to the Actor's FaceFXAsset, so we can get info like anim lengths. */
var transient FaceFXAsset	CachedActorFXAsset;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstFaceFX'
	TrackTitle="FaceFX"
	bOnePerGroup=true
}
