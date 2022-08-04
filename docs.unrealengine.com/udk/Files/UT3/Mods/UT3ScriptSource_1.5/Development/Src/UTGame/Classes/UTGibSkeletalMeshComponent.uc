/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTGibSkeletalMeshComponent extends SkeletalMeshComponent;


defaultproperties
{
	CullDistance=8000
	BlockActors=FALSE
	CollideActors=TRUE
	BlockRigidBody=TRUE
	CastShadow=FALSE
	bCastDynamicShadow=FALSE
	bNotifyRigidBodyCollision=TRUE
	ScriptRigidBodyCollisionThreshold=5.0
	bUseCompartment=FALSE
	RBCollideWithChannels=(Default=TRUE,Pawn=TRUE,Vehicle=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
	bUseAsOccluder=FALSE
	bUpdateSkelWhenNotRendered=FALSE
	bHasPhysicsAssetInstance=FALSE
	PhysicsWeight=1.0
	bAcceptsDecals=FALSE
	Scale=1.0
	//bSkipAllUpdateWhenPhysicsAsleep=TRUE
}
