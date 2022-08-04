/**
 * Toggleable version of DirectionalLight.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class DirectionalLightToggleable extends DirectionalLight
	native
	placeable;





defaultproperties
{
	// Visual things should be ticked in parallel with physics
	TickGroup=TG_DuringAsyncWork

	Begin Object Name=Sprite
		Sprite=Texture2D'EngineResources.LightIcons.Light_Directional_Toggleable_DynamicsAndStatics'
	End Object

	// Light component.
	Begin Object Name=DirectionalLightComponent0
	    LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING

	    CastShadows=TRUE
	    CastStaticShadows=TRUE
	    CastDynamicShadows=TRUE
	    bForceDynamicLight=FALSE
	    UseDirectLightMap=FALSE

	    LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
	End Object


	bMovable=FALSE
	bStatic=FALSE
	bHardAttach=TRUE
}
