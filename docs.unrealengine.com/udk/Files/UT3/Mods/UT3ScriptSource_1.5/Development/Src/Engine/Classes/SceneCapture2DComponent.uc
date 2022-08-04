/**
 * SceneCapture2DComponent
 *
 * Allows a scene capture to a 2D texture render target
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SceneCapture2DComponent extends SceneCaptureComponent
	native;

/** render target resource to set as target for capture */
var(Capture) const TextureRenderTarget2D TextureTarget;
/** horizontal field of view */
var(Capture) const float FieldOfView;
/** near plane clip distance */
var(Capture) const float NearPlane;
/** far plane clip distance: <= 0 means no far plane */
var(Capture) const float FarPlane;
/** set to false to disable automatic updates of the view/proj matrices */
var bool bUpdateMatrices;

// transients
/** view matrix used for rendering */
var const transient matrix ViewMatrix;
/** projection matrix used for rendering */
var const transient matrix ProjMatrix;



/** interface for changing TextureTarget, FOV, and clip planes */
native noexport final function SetCaptureParameters( optional TextureRenderTarget2D NewTextureTarget = TextureTarget,
							optional float NewFOV = FieldOfView, optional float NewNearPlane = NearPlane,
							optional float NewFarPlane = FarPlane );

/** changes the view location and rotation
 * @note: unless bUpdateMatrices is false, this will get overwritten as soon as the component or its owner moves
 */
native final function SetView(vector NewLocation, rotator NewRotation);

defaultproperties
{
	NearPlane=20
	FarPlane=500
	FieldOfView=80
	bUpdateMatrices=true
}
