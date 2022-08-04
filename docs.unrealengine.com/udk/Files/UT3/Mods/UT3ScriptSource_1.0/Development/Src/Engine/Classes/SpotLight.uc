/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SpotLight extends Light
	native
	placeable;




defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EngineResources.LightIcons.Light_Spot_Stationary_Statics'
	End Object

	// Light radius visualization.
	Begin Object Class=DrawLightRadiusComponent Name=DrawLightRadius0
	End Object
	Components.Add(DrawLightRadius0)

	// Inner cone visualization.
	Begin Object Class=DrawLightConeComponent Name=DrawInnerCone0
		ConeColor=(R=150,G=200,B=255)
	End Object
	Components.Add(DrawInnerCone0)

	// Outer cone visualization.
	Begin Object Class=DrawLightConeComponent Name=DrawOuterCone0
		ConeColor=(R=200,G=255,B=255)
	End Object
	Components.Add(DrawOuterCone0)

	// Light component.
	Begin Object Class=SpotLightComponent Name=SpotLightComponent0
	    LightAffectsClassification=LAC_STATIC_AFFECTING
		CastShadows=TRUE
		CastStaticShadows=TRUE
		CastDynamicShadows=FALSE
		bForceDynamicLight=FALSE
		UseDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=FALSE,bInitialized=TRUE)
	    PreviewLightRadius=DrawLightRadius0
		PreviewInnerCone=DrawInnerCone0
		PreviewOuterCone=DrawOuterCone0
	End Object
	LightComponent=SpotLightComponent0
	Components.Add(SpotLightComponent0)

	Begin Object Class=ArrowComponent Name=ArrowComponent0
		ArrowColor=(R=150,G=200,B=255)
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(ArrowComponent0)

	Rotation=(Pitch=-16384,Yaw=0,Roll=0)
	DesiredRotation=(Pitch=-16384,Yaw=0,Roll=0)
}
