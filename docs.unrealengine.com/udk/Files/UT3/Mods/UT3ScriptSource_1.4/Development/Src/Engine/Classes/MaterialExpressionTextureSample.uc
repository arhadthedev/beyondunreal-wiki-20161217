/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionTextureSample extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

var() Texture		Texture;
var ExpressionInput	Coordinates;



defaultproperties
{
	bRealtimePreview=True
}
