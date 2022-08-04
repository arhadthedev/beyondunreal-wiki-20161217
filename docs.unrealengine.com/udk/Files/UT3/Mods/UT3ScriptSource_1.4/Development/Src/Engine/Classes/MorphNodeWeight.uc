/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MorphNodeWeight extends MorphNodeWeightBase
	native(Anim)
	hidecategories(Object);


 
/** Weight to apply to all child nodes of this one. */
var		float	NodeWeight;


/** 
 *	Change the current NodeWeight of this MorphNodeWeight.
 */
native function		SetNodeWeight(float NewWeight);

defaultproperties
{
	bDrawSlider=true
	NodeConns(0)=(ConnName=In)
}
