/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SpotLightComponent extends PointLightComponent
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;

var() float	InnerConeAngle;
var() float OuterConeAngle;

var const DrawLightConeComponent PreviewInnerCone;
var const DrawLightConeComponent PreviewOuterCone;



defaultproperties
{
	InnerConeAngle=0
	OuterConeAngle=44
}
