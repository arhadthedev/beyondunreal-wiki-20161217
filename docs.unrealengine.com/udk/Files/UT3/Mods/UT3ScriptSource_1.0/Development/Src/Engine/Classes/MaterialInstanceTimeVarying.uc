/**
 *  When adding new functionality to this you will sadly need to touch a number of places:
 *
 *  MaterialInstanceTimeVarying.uc  for the actual data that will be used in the game
 *  MaterialEditorInstanceTimeVarying.uc for the editor property dialog that will be used to edit the data you just added
 *  
 *  void UMaterialEditorInstanceTimeVarying::CopyToSourceInstance()
 *     template< typename MI_TYPE, typename ARRAY_TYPE >    (this copies
 *     void UpdateParameterValueOverTimeValues(
 *
 *  void UMaterialEditorInstanceTimeVarying::RegenerateArrays()
 *  
 *  the various void UMaterialInstanceTimeVarying::Set   (to set the defaul values)
 *
 *  static void UpdateMICResources(UMaterialInstanceTimeVarying* Instance)   (to send the data over to the rendering thread (if it needs it)
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class MaterialInstanceTimeVarying extends MaterialInstance
	native(Material);



struct native ParameterValueOverTime
{
	var guid ExpressionGUID;

	/** when this is parameter is to start "ticking" then this value will be set to the current game time **/
	var float StartTime;

	var() name	ParameterName;

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


struct native FontParameterValueOverTime extends ParameterValueOverTime
{
	var() Font		FontValue;
	var() int		FontPage;
};

struct native ScalarParameterValueOverTime extends ParameterValueOverTime
{
	/** This allows MITVs to have both single scalar and curve values **/
	var() float	ParameterValue;

	/** This will automatically be used if there are any values in this Curve **/
	var() InterpCurveFloat ParameterValueCurve;
};

struct native TextureParameterValueOverTime extends ParameterValueOverTime
{
	var() Texture	ParameterValue;
};

struct native VectorParameterValueOverTime extends ParameterValueOverTime
{
	var() LinearColor	ParameterValue;

	/** This will automatically be used if there are any values in this Curve **/
	var() InterpCurveVector ParameterValueCurve;
};


/** causes all parameters to start playing immediately **/
var() bool bAutoActivateAll;

var() const array<FontParameterValueOverTime>		FontParameterValues;
var() const array<ScalarParameterValueOverTime>		ScalarParameterValues;
var() const array<TextureParameterValueOverTime>	TextureParameterValues;
var() const array<VectorParameterValueOverTime>		VectorParameterValues;


;



// SetParent - Updates the parent.

native function SetParent(MaterialInterface NewParent);

// Set*ParameterValue - Updates the entry in ParameterValues for the named parameter, or adds a new entry.

/**
 * For MITVs you can utilize both single Scalar values and InterpCurve values.
 *
 * If there is any data in the InterpCurve, then the MITV will utilize that. Else it will utilize the Scalar value
 * of the same name.
 **/
native function SetScalarParameterValue(name ParameterName, float Value);
native function SetScalarCurveParameterValue(name ParameterName, InterpCurveFloat Value);

/** This sets how long after the MITV has been spawned to start "ticking" the named Scalar InterpCurve **/
native function SetScalarStartTime(name ParameterName, float Value);


native function SetTextureParameterValue(name ParameterName, Texture Value);
native function SetVectorParameterValue(name ParameterName, LinearColor Value);

native function SetVectorCurveParameterValue(name ParameterName, InterpCurveVector Value);

/** This sets how long after the MITV has been spawned to start "ticking" the named Scalar InterpCurve **/
native function SetVectorStartTime(name ParameterName, float Value);

/**
* Sets the value of the given font parameter.
*
* @param	ParameterName	The name of the font parameter
* @param	OutFontValue	New font value to set for this MIC
* @param	OutFontPage		New font page value to set for this MIC
*/
native function SetFontParameterValue(name ParameterName, Font FontValue, int FontPage);


/** Removes all parameter values */
native function ClearParameterValues();



defaultproperties
{
	bAutoActivateAll=FALSE
}
