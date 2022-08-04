/**
 * SceneCaptureCubeMapComponent
 *
 * Allows a scene capture to up to 6 2D texture render targets
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SceneCaptureCubeMapComponent extends SceneCaptureComponent
	native;

/** texture targets for the six cubemap faces */
var(Capture) TextureRenderTargetCube TextureTarget;
/** near plane clip distance */
var(Capture) float NearPlane;
/** far plane clip distance */ 
var(Capture) float FarPlane;

/** world location based on parent transform */
var private const transient native Vector WorldLocation;



defaultproperties
{
	NearPlane=20
	FarPlane=500
}
