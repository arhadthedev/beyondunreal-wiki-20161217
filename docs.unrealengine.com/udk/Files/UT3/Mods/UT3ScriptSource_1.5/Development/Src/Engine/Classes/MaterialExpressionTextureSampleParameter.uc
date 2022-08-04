/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionTextureSampleParameter extends MaterialExpressionTextureSample
	native(Material)
	collapsecategories
	abstract
	hidecategories(Object);

var()	name		ParameterName;

/** GUID that should be unique within the material, this is used for parameter renaming. */
var	  const	guid	ExpressionGUID;



defaultproperties
{
	bIsParameterExpression=true
}