/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Allows clipping of BSP brushes against a plane.
 */
class GeomModifier_Clip
	extends GeomModifier_Edit
	native;

var(Settings)	bool	bFlipNormal;
var(Settings)	bool	bSplit;


	
defaultproperties
{
	Description="Clip"
}
