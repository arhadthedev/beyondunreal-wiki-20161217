/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * This thumbnail renderer holds some commonly shared properties
 */
class DefaultSizedThumbnailRenderer extends ThumbnailRenderer
	native
	abstract
	config(Editor);

/**
 * The default width of this thumbnail
 */
var config int DefaultSizeX;

/**
 * The default height of this thumbnail
 */
var config int DefaultSizeY;


