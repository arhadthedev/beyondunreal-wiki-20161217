/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MotionBlurEffect extends PostProcessEffect
	native;

/** Maximum blur velocity amount. This is a clamp on the amount of blur. */
var() float MaxVelocity;

/** This is a scale that could be considered as the "sensitivity" of the blur. */
var() float MotionBlurAmount;

/** Whether everything (static/dynamic objects) should motion blur or not. If disabled, only moving objects may blur. */
var() bool FullMotionBlur;

/** Threshhold for when to turn off motion blur when the camera rotates swiftly during a single frame (in degrees). */
var() float CameraRotationThreshold;

/** Threshhold for when to turn off motion blur when the camera translates swiftly during a single frame (in world units). */
var() float CameraTranslationThreshold;



defaultproperties
{
	MotionBlurAmount = 0.5f;
	MaxVelocity      = 1.0f;
	FullMotionBlur = true;
	CameraRotationThreshold = 90.0f;
	CameraTranslationThreshold = 10000.0f;
	bShowInEditor	 = false;
}
