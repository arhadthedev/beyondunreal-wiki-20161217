/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class PointLight extends Light
	native
	placeable;




defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EngineResources.LightIcons.Light_Point_Stationary_Statics'
	End Object

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightRadius0
	End Object
	Components.Add(DrawLightRadius0)

	Begin Object Class=PointLightComponent Name=PointLightComponent0
	    LightAffectsClassification=LAC_STATIC_AFFECTING
		CastShadows=TRUE
		CastStaticShadows=TRUE
		CastDynamicShadows=FALSE
		bForceDynamicLight=FALSE
		UseDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=FALSE,bInitialized=TRUE)
		PreviewLightRadius=DrawLightRadius0
	End Object
	LightComponent=PointLightComponent0
	Components.Add(PointLightComponent0)
}
