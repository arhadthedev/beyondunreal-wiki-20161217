/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MorphNodePose extends MorphNodeBase
	native(Anim)
	hidecategories(Object);



/** Cached pointer to actual MorphTarget object. */
var		transient MorphTarget	Target;

/** 
 *	Name of morph target to use for this pose node. 
 *	Actual MorphTarget is looked up by name in the MorphSets array in the SkeletalMeshComponent.
 */
var()	name					MorphName;
 
/** default weight is 1.f. But it can be scaled for tweaking. */
var()	float					Weight;
 
/** 
 *	Set the MorphTarget to use for this MorphNodePose by name. 
 *	Will find it in the owning SkeletalMeshComponent MorphSets array using FindMorphTarget.
 */
native final function SetMorphTarget(Name MorphTargetName);

defaultproperties
{
	Weight=1.f
}