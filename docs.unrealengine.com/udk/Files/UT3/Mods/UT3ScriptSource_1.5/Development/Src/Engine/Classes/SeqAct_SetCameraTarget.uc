/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_SetCameraTarget extends SequenceAction
	native(Sequence);

;

/** Internal.  Holds a ref to the new desired camera target. */
var transient Actor		CameraTarget;

/** Parameters that define how the camera will transition to the new target. */
var() const Camera.ViewTargetTransitionParams	TransitionParams;

defaultproperties
{
	ObjName="Set Camera Target"
	ObjCategory="Camera"
	ObjClassVersion=2

	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Cam Target")
}
