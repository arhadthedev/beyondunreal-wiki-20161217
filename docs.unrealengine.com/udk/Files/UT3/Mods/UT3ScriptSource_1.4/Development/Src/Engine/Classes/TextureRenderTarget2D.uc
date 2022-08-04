/**
 * TextureRenderTarget2D
 *
 * 2D render target texture resource. This can be used as a target
 * for rendering as well as rendered as a regular 2D texture resource.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class TextureRenderTarget2D extends TextureRenderTarget
	native
	hidecategories(Object)
	hidecategories(Texture);

/** The width of the texture.												*/
var() const int SizeX;

/** The height of the texture.												*/
var() const int SizeY;

/** The format of the texture data.											*/
var const EPixelFormat Format;

/** the color the texture is cleared to */
var const LinearColor ClearColor;

/** The addressing mode to use for the X axis.								*/
var() TextureAddress AddressX;

/** The addressing mode to use for the Y axis.								*/
var() TextureAddress AddressY;



/** creates and initializes a new TextureRenderTarget2D with the requested settings */
static native noexport final function TextureRenderTarget2D Create(int InSizeX, int InSizeY, optional EPixelFormat InFormat = PF_A8R8G8B8, optional LinearColor InClearColor, optional bool bOnlyRenderOnce );

defaultproperties
{
	// must be a supported format
	Format=PF_A8R8G8B8

	ClearColor=(R=0.0,G=1.0,B=0.0,A=1.0)
}
