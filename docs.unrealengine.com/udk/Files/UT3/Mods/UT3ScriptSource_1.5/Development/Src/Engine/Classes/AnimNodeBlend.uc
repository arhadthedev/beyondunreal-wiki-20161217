﻿
/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class AnimNodeBlend extends AnimNodeBlendBase
	native(Anim)
	hidecategories(Object);

var		float		Child2Weight;

var		float		Child2WeightTarget;
var		float		BlendTimeToGo; // Seconds



/**
 * Set desired balance of this blend.
 *
 * @param BlendTarget	Target amount of weight to put on Children(1) (second child). Between 0.0 and 1.0.
 *						1.0 means take all animation from second child.
 * @param BlendTime		How long to take to get to BlendTarget.
 */
native final function SetBlendTarget( float BlendTarget, float BlendTime );

defaultproperties
{
	Children(0)=(Name="Child1",Weight=1.0)
	Children(1)=(Name="Child2")
	bFixNumChildren=true
}
