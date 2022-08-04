/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionFontSampleParameter extends MaterialExpressionFontSample
	native(Material)
	collapsecategories
	hidecategories(Object);

/** name to be referenced when we want to find and set thsi parameter */
var() name ParameterName;

/** GUID that should be unique within the material, this is used for parameter renaming. */
var const guid ExpressionGUID;



defaultproperties
{
	bIsParameterExpression=true
}