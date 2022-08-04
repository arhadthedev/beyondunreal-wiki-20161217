/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTSkelControl_RaptorTail extends SkelControlSingleBone
	hidecategories(Translation, Rotation, Adjustment)
	native(Animation);

var(Tail)	int	YawConstraint;
var(Tail)	int	Deadzone;

var int	  LastVehicleYaw;

var int   TailYaw;
var int	  DesiredTailYaw;

var bool bInitialized;



defaultproperties
{
	bApplyRotation=true
	BoneRotationSpace=BCS_ActorSpace
	ControlStrength=1.0
	YawConstraint=20
	DeadZone=50
	bIgnoreWhenNotRendered=true
}
