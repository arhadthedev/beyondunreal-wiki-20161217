/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class DistributionFloatParameterBase extends DistributionFloatConstant
	abstract
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;
	
var()	name	ParameterName;
var()	float	MinInput;
var()	float	MaxInput;
var()	float	MinOutput;
var()	float	MaxOutput;

enum DistributionParamMode
{
	DPM_Normal,
	DPM_Abs,
	DPM_Direct
};

var()	DistributionParamMode	ParamMode;



defaultproperties
{
	MaxInput=1.0
	MaxOutput=1.0
}
