/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * This thumbnail renderer displays a given particle system
 */
class ParticleSystemThumbnailRenderer extends TextureThumbnailRenderer
	native
	config(Editor);

var		Texture2D			NoImage;
var		Texture2D			OutOfDate;



defaultproperties
{
	NoImage=Texture2D'EditorMaterials.ParticleSystems.PSysThumbnail_NoImage'
	OutOfDate=Texture2D'EditorMaterials.ParticleSystems.PSysThumbnail_OOD'
}
