/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Extrudes selected objects.
 */
class GeomModifier_Extrude
	extends GeomModifier_Edit
	native;
	
var(Settings)	int		Length;
var(Settings)	int		Segments;


	
defaultproperties
{
	Description="Extrude"
	Length=16
	Segments=1
}
