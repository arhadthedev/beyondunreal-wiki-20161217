class InterpGroup extends Object
	native(Interpolation)
	collapsecategories
	inherits(FInterpEdInputInterface)
	hidecategories(Object);

/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * A group, associated with a particular Actor or set of Actors, which contains a set of InterpTracks for interpolating 
 * properties of the Actor over time.
 * The Outer of an InterpGroup is an InterpData.
 */



struct InterpEdSelKey
{
	var InterpGroup Group;
	var int			TrackIndex;
	var int			KeyIndex;
	var float		UnsnappedPosition;
};


var		export array<InterpTrack>		InterpTracks;

/** 
 *	Within an InterpData, all GroupNames must be unique. 
 *	Used for naming Variable connectors on the Action in Kismet and finding each groups object.
 */
var		name					GroupName; 

/** Colour used for drawing tracks etc. related to this group. */
var()	color					GroupColor;

/** 
 *	The AnimSets that are used by any AnimControl tracks. 
 *	These will be passed to the Actor when the cinematic begins, and sequences named in the tracks should be found in them. 
 */
var()	array<AnimSet>			GroupAnimSets;

/** Whether or not this group is folded away in the editor. */
var		bool					bCollapsed;

/** Whether or not this group is visible in the editor. */
var		transient	bool		bVisible;

/** When enabled, this group is treated like a folder in the editor, which should only be used for organization.  Folders are never associated with actors and don't have a presence in the Kismet graph. */
var		bool					bIsFolder;

/** When true, this group is considered a 'visual child' of another group.  This doesn't at all affect the behavior of the group, it's only for visual organization.  Also, it's implied that the parent is the next prior group in the array that doesn't have a parent. */
var		bool					bIsParented;

defaultproperties
{
	bVisible=true
	GroupName="InterpGroup"
	GroupColor=(R=100,G=80,B=200,A=255)
}
