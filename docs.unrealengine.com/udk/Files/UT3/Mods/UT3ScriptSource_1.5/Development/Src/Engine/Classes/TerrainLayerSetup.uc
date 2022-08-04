/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class TerrainLayerSetup extends Object
	native(Terrain)
	hidecategories(Object)
	collapsecategories;

struct FilterLimit
{
	var() bool	Enabled;
	var() float	Base,
				NoiseScale,
				NoiseAmount;
};

struct TerrainFilteredMaterial
{
	var() bool			UseNoise;
	var() float			NoiseScale,
						NoisePercent;

	var() FilterLimit	MinHeight;
	var() FilterLimit	MaxHeight;

	var() FilterLimit	MinSlope;
	var() FilterLimit	MaxSlope;

	var() float				Alpha;
	var() TerrainMaterial	Material;

	structdefaultproperties
	{
		Alpha=1.0
	}
};

var() const array<TerrainFilteredMaterial> Materials;



/** Set the materials used for this layer
 * @note this function recaches the weight/displacement maps of affected terrain sections and is therefore slow, so use with caution
 * @param NewMaterials the new array of TerrainFilteredMaterials to replace the Materials array with
 */
native final function SetMaterials(array<TerrainFilteredMaterial> NewMaterials);

/** called from Terrain::PostBeginPlay() to allow the layer to initialize itself for gameplay
 * @note this function will be called once for each terrain the layer is part of
 */
simulated function PostBeginPlay();
