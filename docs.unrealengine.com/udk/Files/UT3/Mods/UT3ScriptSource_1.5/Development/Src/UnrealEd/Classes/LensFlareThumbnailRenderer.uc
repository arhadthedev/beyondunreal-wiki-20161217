﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * This thumbnail renderer displays a given lens flare system
 */
class LensFlareThumbnailRenderer extends TextureThumbnailRenderer
	native
	config(Editor);

var		Texture2D			NoImage;
var		Texture2D			OutOfDate;



defaultproperties
{
	NoImage=Texture2D'EditorMaterials.ParticleSystems.PSysThumbnail_NoImage'
	OutOfDate=Texture2D'EditorMaterials.ParticleSystems.PSysThumbnail_OOD'
}
