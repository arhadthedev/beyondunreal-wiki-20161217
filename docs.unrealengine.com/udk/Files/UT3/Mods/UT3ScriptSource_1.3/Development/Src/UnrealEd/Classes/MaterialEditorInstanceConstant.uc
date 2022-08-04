/**
 * MaterialEditorInstanceConstant.uc: This class is used by the material instance editor to hold a set of inherited parameters which are then pushed to a material instance.
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialEditorInstanceConstant extends Object
	native
	hidecategories(Object)
	collapsecategories;

struct native EditorParameterValue
{
	var() bool			bOverride;
	var() name			ParameterName;
	var   Guid			ExpressionId;
};

struct native EditorVectorParameterValue extends EditorParameterValue
{
	var() LinearColor	ParameterValue;
};

struct native EditorScalarParameterValue extends EditorParameterValue
{
	var() float		ParameterValue;
};

struct native EditorTextureParameterValue extends EditorParameterValue
{
    var() Texture	ParameterValue;
};

struct native EditorFontParameterValue extends EditorParameterValue
{
    var() Font		FontValue;
	var() int		FontPage;
};

struct native EditorStaticSwitchParameterValue extends EditorParameterValue
{
    var() bool		ParameterValue;


};

struct native ComponentMaskParameter
{
	var() bool R;
	var() bool G;
	var() bool B;
	var() bool A;


};

struct native EditorStaticComponentMaskParameterValue extends EditorParameterValue
{
    var() ComponentMaskParameter		ParameterValue;


};

/** Physical material to use for this graphics material. Used for sounds, effects etc.*/
var() PhysicalMaterial									PhysMaterial;

var() MaterialInterface									Parent;
var() array<EditorVectorParameterValue>					VectorParameterValues;
var() array<EditorScalarParameterValue>					ScalarParameterValues;
var() array<EditorTextureParameterValue>				TextureParameterValues;
var() array<EditorFontParameterValue>					FontParameterValues;
var() array<EditorStaticSwitchParameterValue>			StaticSwitchParameterValues;
var() array<EditorStaticComponentMaskParameterValue>	StaticComponentMaskParameterValues;
var	  MaterialInstanceConstant							SourceInstance;
var const transient duplicatetransient	  array<Guid>										VisibleExpressions;


