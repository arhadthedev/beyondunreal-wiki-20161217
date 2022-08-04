/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SkyLightComponent extends LightComponent
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** The brightness for the lower hemisphere of the sky light. */
var() const float LowerBrightness;

/** The color of the lower hemisphere of the sky light. */
var() const color LowerColor;



defaultproperties
{
	CastShadows=False
	bCastCompositeShadow=TRUE
	LowerColor=(R=255,G=255,B=255)
}
