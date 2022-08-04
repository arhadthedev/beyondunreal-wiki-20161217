/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionTransform extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** input expression for this transform */
var ExpressionInput	Input;

/** type of transform to apply to the input expression */
var() const enum EMaterialVectorCoordTransform
{
	// transform from tangent space to world space
	TRANSFORM_World,
	// transform from tangent space to view space
	TRANSFORM_View,
	// transform from tangent space to local space
	TRANSFORM_Local
} TransformType;


