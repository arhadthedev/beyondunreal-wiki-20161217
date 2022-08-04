/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class Texture2DComposite extends Texture
	native
	hidecategories(Object);

/**
 * Defines a source texture and UV region in that texture
 */
struct native SourceTexture2DRegion
{
	var int OffsetX;
	var int OffsetY;
	var int SizeX;
	var int SizeY;
	var Texture2D Texture2D;
};

/** list of source textures and UV regions for compositing */
var array<SourceTexture2DRegion> SourceRegions;

/** 
* Optional max texture size clamp for the composite texture. A value of 0 is ignored and 
* defaults to deriving the texture size using texture LOD bias settings from the source textures 
*/
var int	MaxTextureSize;

/** Utility that checks to see if all Texture2Ds specified in the SourceRegions array are fully streamed in. */
native final function bool SourceTexturesFullyStreamedIn();

/**
* Regenerates this composite texture using the list of source texture regions.
* The existing mips are reallocated and the RHI resource for the texture is updated
*
* @param NumMipsToGenerate - number of mips to generate. if 0 then all mips are created
*/
native final function UpdateCompositeTexture(int NumMipsToGenerate);

/** Utils to reset all source region info. */
native final function ResetSourceRegions();



defaultproperties
{
	// all mip levels will be resident in memory
	NeverStream=True
}
