
/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class AnimNode extends Object
	native(Anim)
	hidecategories(Object)
	abstract;

/** Bone Atom definition */
struct BoneAtom
{
	var	quat	Rotation;
	var	vector	Translation;
	var float	Scale;
};

/** Enumeration for slider types */
enum ESliderType
{
	ST_1D,
	ST_2D
};

/** SkeletalMeshComponent that this animation blend tree is feeding. */
var transient SkeletalMeshComponent		SkelComponent;

/** Parent node of this AnimNode in the blend tree. */
var transient array<AnimNodeBlendBase>	ParentNodes;

/** This is the name used to find an AnimNode by name from a tree. */
var() name								NodeName;

/** If a node is linked to more than once in the graph, this is a cache of the results, to avoid re-evaluating the results. */
var	transient array<BoneAtom>			CachedBoneAtoms;

/** Cached root motion delta, to avoid recalculating (see above). */
var transient BoneAtom					CachedRootMotionDelta;

/** Cached bool indicating if node supplies root motion, to avoid recalculating (see above). */
var transient int						bCachedHasRootMotion;

/** This node is considered 'relevant' - that is, has >0 weight in the final blend. */
var	transient const bool				bRelevant;
/** set to TRUE when this node became relevant this round of updates. Will be set to false on the next tick. */
var transient const bool				bJustBecameRelevant;
/** Allows for optimisiation. Tick is not called on this node if  */
var() bool								bSkipTickWhenZeroWeight;
/** If TRUE, this node will be ticked, even if bPauseAnims is TRUE on the SkelMeshComp. */
var() bool								bTickDuringPausedAnims;

/** Used to avoid ticking a node twice if it has multiple parents. */
var	transient const int					NodeTickTag;

/** Used to indicate whether the BoneAtom cache for this node is up-to-date or not. */
var transient const int					NodeCachedAtomsTag;

/** Total apparent weight this node has in the final blend of all animations. */
var	const float							NodeTotalWeight;

/** internal. Accumulator to calculate NodeTotalWeight */
var const transient	float				TotalWeightAccumulator;

/** For editor use. */
var	int									DrawWidth;

/** For editor use  */
var int									DrawHeight;

/** For editor use. */
var	int									NodePosX;

/** For editor use. */
var int									NodePosY;

/** For editor use. */
var int									OutDrawY;

/** Obsolete. Remove me sometime after VER_AIMOFFSET_ROT2QUAT has been long distributed. */
var	const INT							InstanceVersionNumber;

/** used when iterating over nodes via GetNodes() and related functions to skip nodes that have already been processed */
var const transient protected{protected} int SearchTag;



/** Called from InitAnim. Allows initialisation of script-side properties of this node. */
event OnInit();
/** Get notification that this node has become relevant for the final blend. ie TotalWeight is now > 0 */
event OnBecomeRelevant();
/** Get notification that this node is no longer relevant for the final blend. ie TotalWeight is now == 0 */
event OnCeaseRelevant();

/**
 * Find an Animation Node in the Animation Tree whose NodeName matches InNodeName.
 * Will search this node and all below it.
 * Warning: The search is O(n^2), so for large AnimTrees, cache result.
 */
native final function AnimNode FindAnimNode(name InNodeName);

native function PlayAnim(bool bLoop = false, float Rate = 1.0f, float StartTime = 0.0f);
native function StopAnim();
