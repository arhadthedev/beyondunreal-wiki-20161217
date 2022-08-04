/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionSceneDepth extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** 
 * MaterialExpressionSceneDepth: 
 * samples the current scene texture depth target
 * for use in a material
 */

/** texture coordinate inputt expression for this node */
var ExpressionInput	Coordinates;

/** normalize the depth values to [near,far] -> [0,1] */
var() bool bNormalize;



defaultproperties
{
}
