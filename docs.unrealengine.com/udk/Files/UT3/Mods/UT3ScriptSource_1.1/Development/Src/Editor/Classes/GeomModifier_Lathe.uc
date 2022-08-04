/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Lathes selected objects around the widget.
 */
class GeomModifier_Lathe
	extends GeomModifier_Edit
	native;
	
var(Settings) int	TotalSegments;
var(Settings) int	Segments;
var(Settings) EAxis	Axis;


	
defaultproperties
{
	Description="Lathe"
	TotalSegments=16
	Segments=4
	Axis=AXIS_Z
}
