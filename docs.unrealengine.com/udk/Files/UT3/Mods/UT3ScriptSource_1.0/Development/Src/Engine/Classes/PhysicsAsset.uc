/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class PhysicsAsset extends Object
	hidecategories(Object)
	native(Physics);

/** 
 *	Default skeletal mesh to use when previewing this PhysicsAsset etc. 
 *	Is the one that was used as the basis for creating this Asset.
 */
var		const editoronly SkeletalMesh				DefaultSkelMesh;

/** 
 *	Array of RB_BodySetup objects. Stores information about collision shape etc. for each body.
 *	Does not include body position - those are taken from mesh.
 */
var		const instanced array<RB_BodySetup>			BodySetup;

/** 
 *	Array of RB_ConstraintSetup objects. 
 *	Stores information about a joint between two bodies, such as position relative to each body, joint limits etc.
 */
var		const instanced array<RB_ConstraintSetup>	ConstraintSetup;

/** Default per-instance paramters for this PhysicsAsset. */
var		const instanced PhysicsAssetInstance		DefaultInstance; 


