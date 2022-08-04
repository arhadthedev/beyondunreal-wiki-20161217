/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */


class AnimNodeBlendMultiBone extends AnimNodeBlendBase
	native(Anim)
	hidecategories(Object);

struct native ChildBoneBlendInfo
{
	/** Weight scaling for each bone of the skeleton. Must be same size as RefSkeleton of SkeletalMesh. If all 0.0, no animation can ever be drawn from Child2. */
	var		array<float>	TargetPerBoneWeight;

	/** Used in InitAnim, so you can set up partial blending in the defaultproperties. See SetTargetStartBone. */
	var()	name			InitTargetStartBone;

	/** Used in InitAnim, so you can set up partial blending in the defaultproperties.  See SetTargetStartBone. */
	var()	float			InitPerBoneIncrease;

	//
	// Internal variables
	//

	/** Old StartBone, to monitor changes */
	var	const	name		OldStartBone;
	/** Old OldBoneIncrease, to monitor changes */
	var const	float		OldBoneIncrease;

	/**
	*	Indices of bones required from Target (at LOD 0), if Target's weight is >0.0.
	*	Bones are only in this array if their per-bone weight is >0.0 (or they have a child in the array).
	*	Indices should be strictly increasing.
	*/
	var			transient array<byte>		TargetRequiredBones;

	structdefaultproperties
	{
		InitPerBoneIncrease=1.0
	}
};

/** List of blend targets - one per bone to blend */
var() array<ChildBoneBlendInfo>	BlendTargetList;

/**
*	Indices of bones required from Source (at LOD 0), if Target's weight is 1.0.
*	Bones are only in this array if their per-bone weight is <1.0 (or they have a child in the array).
*	Indices should be strictly increasing.
*/
var	transient array<byte>		SourceRequiredBones;




/** Updating the StartBoneName or PerBoneIncrease, will cause the TargetPerBoneWeight to be automatically re-updated, you'll loose custom values! */
//@todo - support opt. params
native noexport final function SetTargetStartBone( int TargetIdx, name StartBoneName, optional float PerBoneIncrease /* = 1.f */ );

defaultproperties
{
	Children(0)=(Name="Source",Weight=1.0)
	Children(1)=(Name="Target")
}
