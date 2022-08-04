//=============================================================================
// ReachSpec.
//
// A Reachspec describes the reachability requirements between two NavigationPoints
//
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class ReachSpec extends Object
	native;

const BLOCKEDPATHCOST = 10000000; // any path cost >= this value indicates the path is blocked to the pawn

/** pointer to object in navigation octree */
var native transient const editconst pointer NavOctreeObject{struct FNavigationOctreeObject};



var	int		Distance;
var Vector	Direction;	// only valid when both start/end are static
var() const editconst NavigationPoint	Start;		// navigationpoint at start of this path
var() const editconst NavReference		End;
var() const editconst int				CollisionRadius;
var() const editconst int				CollisionHeight;
var	int		reachFlags;					// see EReachSpecFlags definition in UnPath.h
var	int		MaxLandingVelocity;
var	byte	bPruned;
var byte	PathColorIndex;				// used to look up pathcolor, set when reachspec is created
/** whether or not this ReachSpec should be added to the navigation octree */
var const editconst bool bAddToNavigationOctree;
/** If true, pawns moving along this path can cut corners transitioning between this reachspec and adjacent reachspecs */
var bool bCanCutCorners;
/** whether AI should check for dynamic obstructions (Actors with bBlocksNavigation=true) when traversing this ReachSpec */
var bool bCheckForObstructions;
/** Prune paths should skip trying to prune along these */
var const bool	bSkipPrune;
/** Can always prune against these types of specs (even though class doesn't match) */
var const array< class<ReachSpec> > PruneSpecList;

/** Name of path size to use for forced reach spec */
var Name	ForcedPathSizeName;


/** Actor that is blocking this ReachSpec, making it temporarily unusable */
var Actor BlockedBy;

/** CostFor()
Returns the "cost" in unreal units
for Pawn P to travel from the start to the end of this reachspec
*/
native final noexport function int CostFor(Pawn P);

function bool IsBlockedFor(Pawn P)
{
	return (CostFor(P) >= BLOCKEDPATHCOST);
}

defaultproperties
{
	bAddToNavigationOctree=true
	bCanCutCorners=true
	ForcedPathSizeName=Common
	bCheckForObstructions=true
}
