/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionConstantClamp extends MaterialExpression
	native(Material);

var ExpressionInput	Input;

var() float Min;
var() float Max;



defaultproperties
{
	Min=0
	Max=1
}
