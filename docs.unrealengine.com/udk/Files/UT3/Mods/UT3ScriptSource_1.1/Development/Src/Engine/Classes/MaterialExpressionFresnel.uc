/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Allows the artists to quickly set up a Fresnel term. Returns:
 *
 *		pow(1 - max(Normal dot Camera,0),Exponent)
 */
class MaterialExpressionFresnel extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** The exponent to pass into the pow() function */
var() float Exponent;

/** The normal to dot with the camera vector */
var ExpressionInput	Normal;



defaultproperties
{
	Exponent=3.0
}