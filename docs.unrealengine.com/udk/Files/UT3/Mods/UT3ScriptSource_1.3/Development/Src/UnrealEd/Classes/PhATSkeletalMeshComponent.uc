/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class PhATSkeletalMeshComponent extends SkeletalMeshComponent
	native;



var transient native const pointer	PhATPtr;

/** Mesh-space matrices showing state of just animation (ie before physics) - useful for debugging! */
var transient native const array<matrix>	AnimationSpaceBases;

defaultproperties
{
	Begin Object Class=AnimNodeSequence Name=AnimNodeSeq0
		bLooping=true
	End Object
	Animations=AnimNodeSeq0

	bHasPhysicsAssetInstance=true
	bUpdateKinematicBonesFromAnimation=true
	bUpdateJointsFromAnimation=true
	ForcedLodModel=1
	PhysicsWeight=1.0

	RBCollideWithChannels=(Default=TRUE)
}
