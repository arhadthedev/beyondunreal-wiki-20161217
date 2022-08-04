/**
 * Toggleable version of SpotLight.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SpotLightToggleable extends SpotLight
	native
	placeable;






defaultproperties
{
	// Visual things should be ticked in parallel with physics
	TickGroup=TG_DuringAsyncWork

	Begin Object Name=Sprite
		Sprite=Texture2D'EngineResources.LightIcons.Light_Spot_Toggleable_Statics'
	End Object

	// Light component.
	Begin Object Name=SpotLightComponent0
	    LightAffectsClassification=LAC_STATIC_AFFECTING
	    CastShadows=TRUE
	    CastStaticShadows=TRUE
	    CastDynamicShadows=FALSE
	    bForceDynamicLight=FALSE
	    UseDirectLightMap=FALSE
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=FALSE,bInitialized=TRUE)
	End Object


	bMovable=FALSE
	bStatic=FALSE
	bHardAttach=TRUE
}
