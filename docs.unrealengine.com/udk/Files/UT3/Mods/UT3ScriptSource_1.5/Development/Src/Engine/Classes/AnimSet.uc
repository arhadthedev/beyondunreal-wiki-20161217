/** 
 * This is a set of AnimSequences
 * All sequence have the same number of tracks, and they relate to the same bone names.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class AnimSet extends Object
	native(Anim)
	hidecategories(Object);


/** This is a mapping table between each bone in a particular skeletal mesh and the tracks of this animation set. */
struct native AnimSetMeshLinkup
{
	/** GUID of SkeletalMesh that this linkup entry relates to. */
	var guid			SkelMeshLinkupGUID;

	/** 
	 * Mapping table. Size must be same as size of SkelMesh reference skeleton. 
	 * No index should be more than the number of tracks in this AnimSet.
	 * -1 indicates no track for this bone - will use reference pose instead.
	 */
	var array<INT>		BoneToTrackTable;

	/** 
	 *	Array of booleans that indicate whether or not to read the translation of a bone from animation or ref skeleton.
	 *	This is basically a cooked down version of UseTranslationBoneNames for speed.
	 *	Size must be the same as size of SkelMesh ref skeleton.
	 */
	var array<byte>		BoneUseAnimTranslation;

	
};

/** 
 *	Indicates that only the rotation should be taken from the animation sequence and the translation should come from the SkeletalMesh ref pose. 
 *	Note that the root bone always takes translation from the animation, even if this flag is set.
 *	You can use the UseTranslationBoneNames array to specify other bones that should use translation with this flag set.
 */
var() bool				bAnimRotationOnly;

/** Bone name that each track relates to. TrackBoneName.Num() == Number of tracks. */
var array<name>			TrackBoneNames;

/** Actual animation sequence information. */
var	array<AnimSequence>	Sequences;

/** Non-serialised cache of linkups between different skeletal meshes and this AnimSet. */
var transient array<AnimSetMeshLinkup>	LinkupCache;

/** Names of bones that should use translation from the animation, if bAnimRotationOnly is set. */
var() array<name>		UseTranslationBoneNames;

/** In the AnimSetEditor, when you switch to this AnimSet, it sees if this skeletal mesh is loaded and if so switches to it. */
var	name				PreviewSkelMeshName;



defaultproperties
{
	bAnimRotationOnly=true
}
