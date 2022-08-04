
/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class AnimNodeScalePlayRate extends AnimNodeBlendBase
	native(Anim)
	hidecategories(Object);

var() float	ScaleByValue;


	
defaultproperties
{
	Children(0)=(Name="Input",Weight=1.0)
	bFixNumChildren=TRUE

	ScaleByValue=1
}
