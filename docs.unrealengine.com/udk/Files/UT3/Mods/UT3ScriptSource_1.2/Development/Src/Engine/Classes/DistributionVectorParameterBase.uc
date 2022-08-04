/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class DistributionVectorParameterBase extends DistributionVectorConstant
	abstract
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;
	
var()	name	ParameterName;
var()	vector	MinInput;
var()	vector	MaxInput;
var()	vector	MinOutput;
var()	vector	MaxOutput;
var()	DistributionFloatParameterBase.DistributionParamMode ParamModes[3];



defaultproperties
{
	MaxInput=(X=1.0,Y=1.0,Z=1.0)
	MaxOutput=(X=1.0,Y=1.0,Z=1.0)
}
