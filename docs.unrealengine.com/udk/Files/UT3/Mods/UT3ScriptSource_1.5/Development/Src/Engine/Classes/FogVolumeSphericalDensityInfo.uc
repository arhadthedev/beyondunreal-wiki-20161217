/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class FogVolumeSphericalDensityInfo extends FogVolumeDensityInfo
	showcategories(Movement)
	native(FogVolume)
	placeable;



defaultproperties
{
	Begin Object Class=DrawLightRadiusComponent Name=DrawSphereRadius0
	End Object
	Components.Add(DrawSphereRadius0)

	Begin Object Class=FogVolumeSphericalDensityComponent Name=FogVolumeComponent0
		PreviewSphereRadius=DrawSphereRadius0
	End Object
	DensityComponent=FogVolumeComponent0
	Components.Add(FogVolumeComponent0)
}
