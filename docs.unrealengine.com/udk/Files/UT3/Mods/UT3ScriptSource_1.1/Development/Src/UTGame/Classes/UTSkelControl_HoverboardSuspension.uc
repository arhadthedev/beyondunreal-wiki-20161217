/**
 *	Controller used by hoverboard for moving lower part in response to wheel movements.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTSkelControl_HoverboardSuspension extends SkelControlSingleBone
	hidecategories(Translation,Rotation)
	native(Animation);





var()	float	TransIgnore;
var()	float	TransScale;
var()	float	TransOffset;
var()	float	MaxTrans;
var()	float	MinTrans;
var()	float	RotScale;
var()	float	MaxRot;
var()	float	MaxRotRate;
var		float	CurrentRot;

defaultproperties
{
	bApplyTranslation=true
	bAddTranslation=true
	BoneTranslationSpace=BCS_BoneSpace

	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_BoneSpace

	MaxRotRate=0.5
}