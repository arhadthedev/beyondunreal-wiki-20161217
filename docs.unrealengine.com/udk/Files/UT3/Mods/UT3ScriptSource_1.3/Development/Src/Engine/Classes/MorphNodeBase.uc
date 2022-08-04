/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MorphNodeBase extends Object
	native(Anim)
	hidecategories(Object)
	abstract;
 


/** User-defined name of morph node, used for identifying a particular by node for example. */
var()	name					NodeName;

/**	If true, draw a slider for this node in the AnimSetViewer. */
var		bool					bDrawSlider;

/** Keep a pointer to the SkeletalMeshComponent to which this MorphNode is attached. */
var		SkeletalMeshComponent	SkelComponent;


/** Used by editor. */
var				int				NodePosX;

/** Used by editor. */
var				int				NodePosY;

/** Used by editor. */
var				int				DrawWidth;

/** For editor use  */
var				int				DrawHeight;

/** For editor use. */
var				int				OutDrawY;
