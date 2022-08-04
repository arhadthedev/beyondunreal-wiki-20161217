/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class Material extends MaterialInterface
	native
	hidecategories(object)
	collapsecategories;

enum EBlendMode
{
	BLEND_Opaque,
	BLEND_Masked,
	BLEND_Translucent,
	BLEND_Additive,
	BLEND_Modulate
};

enum EMaterialLightingModel
{
	MLM_Phong,
	MLM_NonDirectional,
	MLM_Unlit,
	MLM_SHPRT,
	MLM_Custom
};

// Material input structs.

struct MaterialInput
{
	var MaterialExpression	Expression;
	var int					Mask,
							MaskR,
							MaskG,
							MaskB,
							MaskA;
	var int					GCC64_Padding; // @todo 64: if the C++ didn't mismirror this structure (with ExpressionInput), we might not need this
};

struct ColorMaterialInput extends MaterialInput
{
	var bool				UseConstant;
	var color	Constant;
};

struct ScalarMaterialInput extends MaterialInput
{
	var bool				UseConstant;
	var float	Constant;
};

struct VectorMaterialInput extends MaterialInput
{
	var bool				UseConstant;
	var vector	Constant;
};

struct Vector2MaterialInput extends MaterialInput
{
	var bool				UseConstant;
	var float	ConstantX,
				ConstantY;
};

// Physics.

/** Physical material to use for this graphics material. Used for sounds, effects etc.*/
var() PhysicalMaterial		PhysMaterial;

/** For backwards compatibility only. */
var class<PhysicalMaterial>	PhysicalMaterial;

// Reflection.

//NOTE: If any additional inputs are added/removed WxMaterialEditor::GetVisibleMaterialParameters() must be updated
var ColorMaterialInput		DiffuseColor;
var ColorMaterialInput		SpecularColor;
var ScalarMaterialInput		SpecularPower;
var VectorMaterialInput		Normal;

// Emission.

var ColorMaterialInput		EmissiveColor;

// Transmission.

var ScalarMaterialInput		Opacity;
var ScalarMaterialInput		OpacityMask;

/** If BlendMode is BLEND_Masked, the surface is not rendered where OpacityMask < OpacityMaskClipValue. */
var() float OpacityMaskClipValue;

/** Allows the material to distort background color by offsetting each background pixel by the amount of the distortion input for that pixel. */
var Vector2MaterialInput	Distortion;

/** Determines how the material's color is blended with background colors. */
var() EBlendMode BlendMode;

/** Determines how inputs are combined to create the material's final color. */
var() EMaterialLightingModel LightingModel;

var ColorMaterialInput		CustomLighting;

/** Lerps between lighting color (diffuse * attenuation * Lambertian) and lighting without the Lambertian term color (diffuse * attenuation * TwoSidedLightingColor). */
var ScalarMaterialInput		TwoSidedLightingMask;

/** Modulates the lighting without the Lambertian term in two sided lighting. */
var ColorMaterialInput		TwoSidedLightingColor;

/** Indicates that the material should be rendered without backface culling and the normal should be flipped for backfaces. */
var() bool TwoSided;

/** 
 * Allows the material to disable depth tests, which is only meaningful with translucent blend modes.  
 * Disabling depth tests will make rendering significantly slower since no occluded pixels can get zculled.
 */
var() bool bDisableDepthTest;

var(Usage) const bool bUsedAsLightFunction;
var(Usage) const bool bUsedWithFogVolumes;
var(Usage) const bool bUsedAsSpecialEngineMaterial;
var(Usage) const bool bUsedWithSkeletalMesh;
var		   const bool bUsedWithParticleSystem;
var(Usage) const bool bUsedWithParticleSprites;
var(Usage) const bool bUsedWithBeamTrails;
var(Usage) const bool bUsedWithParticleSubUV;
var(Usage) const bool bUsedWithFoliage;
var(Usage) const bool bUsedWithSpeedTree;
var(Usage) const bool bUsedWithStaticLighting;
var(Usage) const bool bUsedWithLensFlare;
/** Adds an extra pow instruction to the shader using the current render target's gamma value */
var(Usage) const bool bUsedWithGammaCorrection;
var(Usage) const bool bUsedWithInstancedMeshParticles;

var() bool Wireframe;

/** Indicates that the material will be used as a fallback on sm2 platforms */
var(Usage) bool bIsFallbackMaterial;

/** The fallback material, which will be used on sm2 platforms */
var() Material FallbackMaterial;

// Two resources for sm3 and sm2, indexed by EMaterialShaderPlatform
var const native duplicatetransient pointer MaterialResources[2]{FMaterialResource};

var const native duplicatetransient pointer DefaultMaterialInstances[2]{class FDefaultMaterialInstance};

var int		EditorX,
			EditorY,
			EditorPitch,
			EditorYaw;

/** Array of material expressions, excluding Comments and Compounds.  Used by the material editor. */
var array<MaterialExpression>			Expressions;

/** Array of comments associated with this material; viewed in the material editor. */
var editoronly array<MaterialExpressionComment>	EditorComments;

/** Array of material expression compounds associated with this material; viewed in the material editor. */
var editoronly array<MaterialExpressionCompound> EditorCompounds;

var native map{FName, TArray<UMaterialExpression*>} EditorParameters;

/** TRUE if Material uses distortion */
var private bool						bUsesDistortion;

/** TRUE if Material uses a scene color exprssion */
var private bool						bUsesSceneColor;

/** TRUE if Material is masked and uses custom opacity */
var private bool						bIsMasked;

/** TRUE if Material is the preview material used in the material editor. */
var transient duplicatetransient private bool bIsPreviewMaterial;

/** 
 * Array of textures referenced, updated in PostLoad.  These are needed to keep the textures used by material resources 
 * from getting destroyed by realtime GC.
 */
var private const array<texture> ReferencedTextures;




/** returns the Referneced Textures so one may set flats on them  (e.g. bForceMiplevelsToBeResident ) **/
function array<texture> GetTextures()
{
	return ReferencedTextures;
}


defaultproperties
{
	BlendMode=BLEND_Opaque
	DiffuseColor=(Constant=(R=128,G=128,B=128))
	SpecularColor=(Constant=(R=128,G=128,B=128))
	SpecularPower=(Constant=15.0)
	Distortion=(ConstantX=0,ConstantY=0)
	Opacity=(Constant=1)
	OpacityMask=(Constant=1)
	OpacityMaskClipValue=0.3333
	TwoSidedLightingColor=(Constant=(R=255,G=255,B=255))
	bIsFallbackMaterial=False
	bUsedWithStaticLighting=TRUE
}
