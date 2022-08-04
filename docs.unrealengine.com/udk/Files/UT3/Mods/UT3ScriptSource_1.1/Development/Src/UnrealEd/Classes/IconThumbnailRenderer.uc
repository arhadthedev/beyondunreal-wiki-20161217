/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * This is a simple thumbnail renderer that uses a specified icon as the
 * thumbnail view for a resource.
 */
class IconThumbnailRenderer extends ThumbnailRenderer
	native;

/**
 * Name of the texture to load and use as the icon
 */
var String IconName;

/**
 * This is the icon once it has been loaded
 */
var Texture2D Icon;


