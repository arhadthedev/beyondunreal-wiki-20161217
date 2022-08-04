/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionTransformPosition extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** input expression for this transform */
var ExpressionInput	Input;

/** type of transform to apply to the input expression */
var() const enum EMaterialPositionTransform
{
	// transform from post projection to world space
	TRANSFORMPOS_World

} TransformType;


