/**
 * TextureRenderTargetCube
 *
 * Cube render target texture resource. This can be used as a target
 * for rendering as well as rendered as a regular cube texture resource.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class TextureRenderTargetCube extends TextureRenderTarget
	native
	hidecategories(Object)
	hidecategories(Texture);

/** The width of the texture.												*/
var() int SizeX;

/** The format of the texture data.											*/
var const EPixelFormat Format;



defaultproperties
{
	// must be a supported format
	Format=PF_A8R8G8B8
}
