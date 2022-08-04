/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionFontSample extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** font resource that will be sampled */
var() Font Font;
/** allow access to the various font pages */
var() int FontTexturePage;



defaultproperties
{
	bRealtimePreview=True
}
