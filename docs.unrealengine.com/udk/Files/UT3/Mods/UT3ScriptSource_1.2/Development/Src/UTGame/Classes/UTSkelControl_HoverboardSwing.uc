/**
 *	Controller used by hoverboard for moving lower part in response to wheel movements.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTSkelControl_HoverboardSwing extends SkelControlSingleBone
	hidecategories(Translation,Rotation)
	native(Animation);



var()	int				SwingHistoryWindow;
var		int				SwingHistorySlot;
var		array<float>	SwingHistory;
var()	float	SwingScale;
var()	float	MaxSwing;
var()	float	MaxUseVel;
var		float	CurrentSwing;

defaultproperties
{
	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_BoneSpace
	SwingHistoryWindow=15
}