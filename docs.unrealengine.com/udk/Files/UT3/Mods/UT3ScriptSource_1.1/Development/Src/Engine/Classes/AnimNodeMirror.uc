/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class AnimNodeMirror extends AnimNodeBlendBase
	native(Anim)
	hidecategories(Object);

var()	bool	bEnableMirroring;
	

	
defaultproperties
{
	Children(0)=(Name="Child",Weight=1.0)
	bFixNumChildren=true
	
	bEnableMirroring=true
}
