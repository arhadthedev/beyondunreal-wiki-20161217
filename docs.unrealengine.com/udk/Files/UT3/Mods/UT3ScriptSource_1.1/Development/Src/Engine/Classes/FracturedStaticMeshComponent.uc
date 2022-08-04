/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class FracturedStaticMeshComponent extends StaticMeshComponent
	native(Mesh);

/** 
 * An array of component resources, corresponding to FracturedStaticMesh's LODModels. 
 * Each element in the array is an index buffer containing only the indices marked visible by VisibleFragments.
 */
var private{private} native const IndirectArray_Mirror LODResources{TIndirectArray<FRawStaticIndexBuffer>};

/** An array of Fragments that are visible in this component. */
var private{private} const array<byte> VisibleFragments;

struct native FracturedElementRanges
{
	var int		BaseIndex;
	var int		NumPrimitives;
};

/** Ranges in the component's index buffer that each element uses for rendering. */
var private{private} const array<FracturedElementRanges> ElementRanges;

/** A fence used to track when the rendering thread has released the component's resources. */
var private{private} native const transient RenderCommandFence_Mirror ReleaseResourcesFence{FRenderCommandFence};

/** 
 *	If true, the only thing considered when calculating the bounds of this component are the graphics verts current visible.
 *	Using this and having simplified collision will cause unpredictable results. 
 */
var bool	bUseVisibleVertsForBounds;

/**  */
struct native FragmentGroup
{
	var array<int>	FragmentIndices;
	var bool		bGroupIsRooted;
};



/** 
 * Change the StaticMesh used by this instance, and resets VisibleFragments to all be visible if NewMesh is valid.
 * @param NewMesh - StaticMesh to set.  If this is not also a UFracturedStaticMesh, assignment will fail.
 * @return bool - TRUE if assignment succeeded.
 */
simulated native function bool SetStaticMesh( StaticMesh NewMesh );

/** Change the set of visible fragments. */
simulated native function SetVisibleFragments(array<byte> VisibilityFactors);

/** Returns array of currently visible fragments. */
simulated native function array<byte> GetVisibleFragments() const;

/** Returns whether the specified fragment is currently visible or not. */
simulated native function bool IsFragmentVisible(INT FragmentIndex) const;

/** Returns if this fragment is destroyable. */
simulated native function bool IsFragmentDestroyable(INT FragmentIndex) const;

/** Returns if this is a supporting 'root' fragment.  */
simulated native function bool IsRootFragment(INT FragmentIndex) const;

/** Get the bounding box of a specific chunk, in world space. */
native function box GetFragmentBox(int FragmentIndex) const;

/** Returns average exterior normal of a particular chunk. */
native function vector GetFragmentAverageExteriorNormal(int FragmentIndex) const;

/** Get the number of chunks in the assigned fractured mesh. */
native function int GetNumFragments() const;

/** Gets the index that is the 'core' of this mesh. */
native function int GetCoreFragmentIndex() const;

/** 
 *	Based on the hidden state of chunks, groups which are connected.  
 *	@param IgnoreFragments	Additional fragments to ignore when finding islands. These will not end up in any groups.
 */
simulated native function array<FragmentGroup> GetFragmentGroups(array<int> IgnoreFragments, float MinConnectionArea) const;

defaultproperties
{
}
