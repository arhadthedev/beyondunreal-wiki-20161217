
/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class AnimNodeSequenceBlendByAim extends AnimNodeSequenceBlendBase
	native(Anim)
	hidecategories(Animations);

/** Angle of aiming, between -1..+1 */
var()	Vector2d	Aim;
var()	Vector2d	HorizontalRange;
var()	Vector2d	VerticalRange;

/** Angle offset applied to Aim before processing */
var()	Vector2d	AngleOffset;

//
// Animations
//

// Left
var()	Name	AnimName_LU;
var()	Name	AnimName_LC;
var()	Name	AnimName_LD;

// Center
var()	Name	AnimName_CU;
var()	Name	AnimName_CC;
var()	Name	AnimName_CD;

// Right
var()	Name	AnimName_RU;
var()	Name	AnimName_RC;
var()	Name	AnimName_RD;



defaultproperties
{
	HorizontalRange=(X=-1,Y=+1)
	VerticalRange=(X=-1,Y=+1)

	Anims(0)=(Weight=1.0)
	Anims(1)=()
	Anims(2)=()
	Anims(3)=()
	Anims(4)=()
	Anims(5)=()
	Anims(6)=()
	Anims(7)=()
	Anims(8)=()
}