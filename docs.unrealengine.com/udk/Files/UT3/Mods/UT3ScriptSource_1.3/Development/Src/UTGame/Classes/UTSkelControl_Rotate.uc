/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTSkelControl_Rotate extends SkelControlSingleBone
	native(Animation);

/** Where we wish to get to */
var(Desired) rotator	DesiredBoneRotation;

/** The Rate we wish to rotate */
var(Desired) rotator	DesiredBoneRotationRate;



defaultproperties
{
	bApplyTranslation=false
	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_BoneSpace
}
