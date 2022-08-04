/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class TextureCube extends Texture
	native
	hidecategories(Object);

/** Cached width of the cubemap. */
var transient const int SizeX;

/** Cached height of the cubemap. */
var transient const int SizeY;

/** Cached format of the cubemap */
var transient const EPixelFormat Format;

/** Cached number of mips in the cubemap */
var transient const int NumMips;

/** Cached information on whether the cubemap is valid, aka all faces are non NULL and match in width, height and format. */
var transient const bool bIsCubemapValid;

var() const Texture2D FacePosX;
var() const Texture2D FaceNegX;
var() const Texture2D FacePosY;
var() const Texture2D FaceNegY;
var() const Texture2D FacePosZ;
var() const Texture2D FaceNegZ;

