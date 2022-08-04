/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * A font class that stores multiple font pages for different resolutions
 */

class MultiFont extends Font
	native;

/** Holds a list of resolutions that map to a given set of font pages */
var() editinline  array<float> ResolutionTestTable;



/**
 * Calulate the index into the ResolutionTestTable which is closest to the specified screen resolution.
 *
 * @param	HeightTest	the height (in pixels) of the viewport being rendered to.
 *
 * @return	the index [into the ResolutionTestTable array] of the resolution which is closest to the specified resolution.
 */
native function int GetResolutionTestTableIndex(float HeightTest) const;

defaultproperties
{
}
