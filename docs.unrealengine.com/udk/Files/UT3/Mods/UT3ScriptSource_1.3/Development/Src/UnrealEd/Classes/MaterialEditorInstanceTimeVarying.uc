/**
 * MaterialEditorInstanceTimeVaryingTimeVarying.uc: This class is used by the material instance editor to hold a set of inherited parameters which are then pushed to a material instance.
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialEditorInstanceTimeVarying extends Object
	native
	hidecategories(Object)
	collapsecategories;

struct native EditorParameterValueOverTime
{
	var guid ExpressionId;

	var() bool bOverride;
	var() name ParameterName;

	/** if true, then the CycleTime is the loop time and time loops **/
	var() bool bLoop;

	/** This will auto activate this param **/
	var() bool bAutoActivate;

	/** this controls time normalization and the loop time **/
	var() float	CycleTime;

	/** if true, then the CycleTime is used to scale time so all keys are between zero and one **/
	var() bool bNormalizeTime;

	structdefaultproperties
	{
		bLoop=FALSE
		bAutoActivate=FALSE
		CycleTime=1.0f
		bNormalizeTime=FALSE
	}
};

struct native EditorVectorParameterValueOverTime extends EditorParameterValueOverTime
{
	/** This allows MITVs to have both single scalar and curve values **/
	var() LinearColor ParameterValue;

	/** This will automatically be used if there are any values in this Curve **/
	var() InterpCurveVector ParameterValueCurve; 
};

struct native EditorScalarParameterValueOverTime extends EditorParameterValueOverTime
{
	/** This allows MITVs to have both single scalar and curve values **/
	var() float ParameterValue;

	/** This will automatically be used if there are any values in this Curve **/
	var() InterpCurveFloat ParameterValueCurve;
};

struct native EditorTextureParameterValueOverTime extends EditorParameterValueOverTime
{
    var() Texture ParameterValue;
};

struct native EditorFontParameterValueOverTime extends EditorParameterValueOverTime
{
    var() Font FontValue;
	var() int FontPage;
};

struct native EditorStaticSwitchParameterValueOverTime extends EditorParameterValueOverTime
{
    var() bool ParameterValue;
};

struct native ComponentMaskParameterOverTime
{
	var() bool R;
	var() bool G;
	var() bool B;
	var() bool A;
};

struct native EditorStaticComponentMaskParameterValueOverTime extends EditorParameterValueOverTime
{
    var() ComponentMaskParameterOverTime ParameterValue;
};

/** Physical material to use for this graphics material. Used for sounds, effects etc.*/
var() PhysicalMaterial											PhysMaterial;

var() MaterialInterface											Parent;


/** causes all parameters to start playing immediately **/
var() bool bAutoActivateAll;


var() array<EditorVectorParameterValueOverTime>					VectorParameterValues;
var() array<EditorScalarParameterValueOverTime>					ScalarParameterValues;
var() array<EditorTextureParameterValueOverTime>				TextureParameterValues;
var() array<EditorFontParameterValueOverTime>					FontParameterValues;
var() array<EditorStaticSwitchParameterValueOverTime>			StaticSwitchParameterValues;
var() array<EditorStaticComponentMaskParameterValueOverTime>	StaticComponentMaskParameterValues;
var	  MaterialInstanceTimeVarying								SourceInstance;
var const transient duplicatetransient	  array<Guid>												VisibleExpressions;




defaultproperties
{

}
