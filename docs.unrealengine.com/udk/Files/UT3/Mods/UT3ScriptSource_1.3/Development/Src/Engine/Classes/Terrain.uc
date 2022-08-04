/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class Terrain extends Info
	dependson(LightComponent)
	native(Terrain)
	showcategories(Movement,Collision)
	placeable;

// Structs that are mirrored properly in C++.

/**
 *	A height data entry that is stored in an array for the terrain.
 *	Full structure can be found in UnTerrain.h, FTerrainHeight.
 */
struct TerrainHeight
{
	// No UObject reference.
};

/**
 *	InfoData entries for each patch in the terrain.
 *	This includes information such as whether the patch is visible or not (holes).
 *	Full structure can be found in UnTerrain.h, FTerrainInfoData.
 */
struct TerrainInfoData
{
	// No UObject reference.
};

/**
 *	A weighted material used on the terrain.
 *	Full structure can be found in UnTerrain.h, FTerrainWeightedMaterial.
 */
struct TerrainWeightedMaterial
{
	// UObject references.
};

/**
 *	A layer that can be painted onto the terrain.
 */
struct TerrainLayer
{
	/**	The name of the layer, for UI display purposes.										*/
	var() string			Name;
	/**	The TerrainLayerSetup, which declares the material(s) used in the layer.			*/
	var() TerrainLayerSetup	Setup;
	/**	INTERNAL: The index of the alpha map that represents the application of this layer.	*/
	var int					AlphaMapIndex;
	/**	Whether the layer should be highlighted when rendered.								*/
	var() bool				Highlighted;
	/**	Whether the layer should be wireframe highlighted when rendered.
	 *	CURRENTLY NOT IMPLEMENTED 
	 */
	var() bool				WireframeHighlighted;
	/**	Whether the layer is hidden (not rendered).											*/
	var() bool				Hidden;
	/**	The color to highlight the layer with.												*/
	var() color				HighlightColor;
	/**	The color to wireframe highlight the layer with.									*/
	var() color				WireframeColor;
	/** 
	 *	Rectangle encompassing all the vertices this layer affects. 
	 *	TerrainLayerSetup::SetMaterial() uses this to avoid rebuilding
	 *	terrain that has not changed
	 */
	var int MinX, MinY, MaxX, MaxY;

	structdefaultproperties
	{
		AlphaMapIndex=-1
		HighlightColor=(R=255,G=255,B=255)
	}
};

/**
 *	A mapping used to apply a layer to the terrain.
 *	Full structure can be found in UnTerrain.h, FAlphaMap.
 */
struct AlphaMap
{
	// No UObject references.
};

/**
 *	A decoration instance applied to the terrain.
 *	Used internally to apply DecoLayers.
 */
struct TerrainDecorationInstance
{
	var PrimitiveComponent	Component;
	var float				X,
							Y,
							Scale;
	var int					Yaw;
};

/**
 *	A decoration source for terrain DecoLayers.
 */
struct TerrainDecoration
{
	/**	The factory used to generate the decoration mesh.					*/
	var() editinline	PrimitiveComponentFactory	Factory;
	/**	The min scale to apply to the source mesh.							*/
	var() float										MinScale;
	/**	The max scale to apply to the source mesh.							*/
	var() float										MaxScale;
	/**	The density to use when applying the mesh to the terrain.			*/
	var() float										Density;
	/**	
	 *	The amount to rotate the mesh to match the slope of the terrain 
	 *	where it is being placed. If 1.0, the mesh will match the slope
	 *	exactly.
	 */
	var() float										SlopeRotationBlend;
	/**	The value to use to seed the random number generator.				*/
	var() int										RandSeed;

	/**	
	 *	INTERNAL: An array of instances of the decoration applied to the 
	 *	terrain.
	 */
	var array<TerrainDecorationInstance>			Instances;

	structdefaultproperties
	{
		Density=0.01
		MinScale=1.0
		MaxScale=1.0
	}
};

/**
 *	A decoration layer - used to easily apply static meshes to the terrain
 */
struct TerrainDecoLayer
{
	/**	The name of the DecoLayer, for UI display purposes.									*/
	var() string					Name;
	/**	The decoration(s) to apply for this layer.											*/
	var() array<TerrainDecoration>	Decorations;
	/**	INTERNAL: The index of the alpha map that represents the application of this layer.	*/
	var int							AlphaMapIndex;

	structdefaultproperties
	{
		AlphaMapIndex=-1
	}
};

/**
 *	Terrain material resource - compiled terrain material used to render the terrain.
 *	Full structure can be found in UnTerrain.h, FTerrainMaterialResource.
 */
struct TerrainMaterialResource
{
	// UObject references.
};

/**	Array of the terrain heights												*/
var private const native array<TerrainHeight>	Heights;
/** Array of the terrain information data (visible, etc.)						*/
var private const native array<TerrainInfoData>	InfoData;
/** Array of the terrain layers applied to the terrain							*/
var() const array<TerrainLayer>					Layers;
/**
 *	The index of the layer that supplies the normal map for the whole terrain.
 *	If this is -1, the terrain will compile the normal property the old way
 *		(all normal maps blended together).
 *	If this is a valid index into the layer array, it will compile the normal
 *		property only for the material(s) contained in said layer.
 */
var() int								NormalMapLayer;
/**	Array of the decoration layers applied										*/
var() const array<TerrainDecoLayer>		DecoLayers;
/**	Array of the alpha maps between layers										*/
var native const array<AlphaMap>		AlphaMaps;

/** The array of terrain components that are used by the terrain				*/
var const NonTransactional array<TerrainComponent>	TerrainComponents;

/**
 *	Internal values used to setup components
 *
 *	The number of sections is the number of terrain components along the
 *	X and Y of the 'grid'.
 */
var const int							NumSectionsX;
var const int							NumSectionsY;
var const int							SectionSize; // Legacy!

/**	INTERNAL - The weighted materials and blend maps							*/
var private native const array<TerrainWeightedMaterial>	WeightedMaterials;
var private const native array<TerrainWeightMapTexture>	WeightedTextureMaps;

/**	INTERNAL - Displacement related values										*/
var native const array<byte>	CachedDisplacements;
var native const float			MaxCollisionDisplacement;

/**
 *	The maximum number of quads in a single row/column of a tessellated patch.
 *  Must be a power of two, 1 <= MaxTesselationLevel <= 16
 */
var() int						MaxTesselationLevel;

/**
 *	The minimum number of quads in a tessellated patch.
 *	Must be a power of two, 1 <= MaxTesselationLevel
 */
var() int						MinTessellationLevel;

/**
 *	The scale factor to apply to the distance used in determining the tessellation
 *	level to utilize when rendering a patch.
 *		TessellationLevel = SomeFunction((Patch distance to camera) * TesselationDistanceScale)
 */
var() float						TesselationDistanceScale;

var deprecated int				TessellationCheckCount;

/**
 *	The radius from the view origin that terrain tessellation checks should be performed.
 *	If less than 0, the general setting from the engine configuration will be used.
 *	If 0.0, every component will be checked for tessellation changes each frame.
 */
var() float						TessellationCheckDistance;


/**
 *	The number of components to border around the current view position
 *	when checking for tessellations update.
 *	If -1, then use the general setting from the engine configuration.
 *	If 0, every component will be checked for tessellation changes each frame.
 */
var deprecated float			TessellationCheckBorder;

/**
 *	The tessellation level to utilize when performing collision checks with non-zero extents.
 */
var(Collision) int				CollisionTesselationLevel;

struct native CachedTerrainMaterialArray
{	
	var native const duplicatetransient array<pointer> CachedMaterials{FTerrainMaterialResource};
};
/** array of cached terrain materials for SM2,SM3 */
var native const CachedTerrainMaterialArray CachedTerrainMaterials[2];

/**
 * The number of vertices currently stored in a single row of height and alpha data.
 * Updated from NumPatchesX when Allocate is called(usually from PostEditChange).
 */
var const int					NumVerticesX;

/**
 * The number of vertices currently stored in a single column of height and alpha data.
 * Updated from NumPatchesY when Allocate is called(usually from PostEditChange).
 */
var const int					NumVerticesY;

/**
 *  The number of patches in a single row of the terrain's patch grid.
 *  PostEditChange clamps this to be >= 1.
 *	Note that if you make this and/or NumPatchesY smaller, it will destroy the height-map/alpha-map
 *	data which is no longer used by the patches.If you make the dimensions larger, it simply fills
 *	in the new height-map/alpha-map data with zero.
 */
var() int						NumPatchesX;

/**
 *	The number of patches in a single column of the terrain's patch grid.
 *  PostEditChange clamps this to be >= 1.
 */
var() int						NumPatchesY;

/**
 *	For rendering and collision, split the terrain into components with a maximum size of
 *		(MaxComponentSize,MaxComponentSize) patches.
 *	The terrain is split up into rectangular groups of patches called terrain components for rendering.
 *	MaxComponentSize is the maximum number of patches in a single row/column of a terrain component.
 *	Generally, all components will be MaxComponentSize patches square, but on terrains with a patch
 *	resolution which isn't a multiple of MaxComponentSize, there will be some components along the edges
 *	which are smaller.
 *
 *	This is limited by the MaxTesselationLevel, to prevent the vertex buffer for a fully tessellated
 *	component from being > 65536 vertices.
 *	For a MaxTesselationLevel of 16, MaxComponentSize is limited to <= 15.
 *	For a MaxTesselationLevel of 8, MaxComponentSize is limited to <= 31.
 *
 *	PostEditChange clamps this to be >= 1.
 */
var() int						MaxComponentSize;

/**
 *	The resolution to cache lighting at, in texels/patch.
 *	A separate shadow-map is used for each terrain component, which is up to
 *	(MaxComponentSize * StaticLightingResolution + 1) pixels on a side.
 *	Must be a power of two, 1 <= StaticLightingResolution <= MaxTesselationLevel.
 */
var(Lighting) int				StaticLightingResolution;

/**
 *	If true, the light/shadow map size is no longer restricted...
 *	The size of the light map will be (per component):
 *		INT LightMapSizeX = Component->SectionSizeX * StaticLightingResolution + 1;
 *		INT LightMapSizeY = Component->SectionSizeY * StaticLightingResolution + 1;
 *
 *	So, the maximum size of a light/shadow map for a component will be:
 *		MaxMapSizeX = MaxComponentSize * StaticLightingResolution + 1
 *		MaxMapSizeY = MaxComponentSize * StaticLightingResolution + 1
 *
 *	Be careful with the setting of StaticLightingResolution when this mode is enabled.
 *	It will be quite easy to run up a massive texture requirement on terrain!
 */
var(Lighting) bool						bIsOverridingLightResolution;

/**
 *	If true, the lightmap generation will be performed using the bilinear filtering
 *	that all other lightmap generation in the engine uses.
 *
 */
var(Lighting) bool						bBilinearFilterLightmapGeneration;

/**
 * Whether terrain should cast shadows.
 *
 * Property is propagated to terrain components
 */
var(Lighting) bool						bCastShadow;

/**
 * If true, forces all static lights to use light-maps for direct lighting on the terrain, regardless of
 * the light's UseDirectLightMap property.
 *
 * Property is propagated to terrain components .
 */
var(Lighting) const bool				bForceDirectLightMap;

/**
 * If false, primitive does not cast dynamic shadows.
 *
 * Property is propagated to terrain components .
 */
var(Lighting) const bool				bCastDynamicShadow;

/**
 * If false, primitive does not block rigid body physics.
 *
 * Property is propagated to terrain components.
 */
var(Collision) const bool				bBlockRigidBody;

/** If true, this allows rigid bodies to go underneath visible areas of the terrain. This adds some physics cost. */
var(Collision) const bool				bAllowRigidBodyUnderneath;

/**
 * If false, primitive does not accept dynamic lights, aka lights with HasStaticShadowing() == FALSE
 *
 * Property is propagated to terrain components.
 */
var(Lighting) const bool				bAcceptsDynamicLights;

/**
 * Lighting channels controlling light/ primitive interaction. Only allows interaction if at least one channel is shared */
var(Lighting) const LightingChannelContainer	LightingChannels;

/**
 *	Whether to utilize morping terrain or not
 */
var()		bool				bMorphingEnabled;
/**
 *	Whether to utilize morping gradients or not (bMorphingEnabled must be true for this to matter)
 */
var()		bool				bMorphingGradientsEnabled;

/**	The terrain is locked - no editing can take place on it	*/
var			bool				bLocked;

/**	The terrain heightmap is locked - no editing can take place on it	*/
var			bool				bHeightmapLocked;

/** Command fence used to shut down properly */
var native const pointer		ReleaseResourcesFence{FRenderCommandFence};

/** Editor-viewing tessellation level						*/
var() transient	int				EditorTessellationLevel;

/** Viewing collision tessellation level					*/
var			bool				bShowingCollision;

/** Selected vertex structure - used for vertex editing		*/
struct SelectedTerrainVertex
{
	/** The position of the vertex.					*/
	var int		X, Y;
	/** The weight of the selection.				*/
	var int		Weight;
};

var transient	array<SelectedTerrainVertex>	SelectedVertices;

/** Tells the terrain to render in wireframe. */
var() 			bool				bShowWireframe;
/** The color to use when rendering the wireframe of the terrain. */
var() 			color				WireframeColor;



/** for each layer, calculate the rectangle encompassing all the vertices affected by it and store the result in
 * the layer's MinX, MinY, MaxX, and MaxY properties
 */
native final function CalcLayerBounds();

simulated event PostBeginPlay()
{
	local int i;

	CalcLayerBounds();

	// allow any layers to run startup actions
	for (i = 0; i < Layers.length; i++)
	{
		if (Layers[i].Setup != None)
		{
			Layers[i].Setup.PostBeginPlay();
		}
	}
}

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EngineResources.S_Terrain'
	End Object

	NormalMapLayer=-1
	NumPatchesX=1
	NumPatchesY=1
	MaxComponentSize=16

	DrawScale3D=(X=256.0,Y=256.0,Z=256.0)
	bEdShouldSnap=True
	bCollideActors=True
	bBlockActors=True
	bWorldGeometry=True
	bStatic=True
	bNoDelete=True
	bHidden=False
	MaxTesselationLevel=4
	MinTessellationLevel=1
	CollisionTesselationLevel=1
	TessellationCheckDistance=-1.0
	TesselationDistanceScale=1.0
	StaticLightingResolution=4
	bIsOverridingLightResolution=false
	bBilinearFilterLightmapGeneration=true
	bCastShadow=True
	bCastDynamicShadow=True
	bBlockRigidBody=True
	bAcceptsDynamicLights=True
	LightingChannels=(Static=TRUE,bInitialized=TRUE)
	bForceDirectLightMap=TRUE
	WireframeColor=(R=0,G=255,B=255)
}
