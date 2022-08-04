
/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class AnimNodeAimOffset extends AnimNodeBlendBase
	native(Anim)
	hidecategories(Object);

/**
 * 9 control points range:
 *
 * Left	Center	Right
 *
 * LU	CU		RU		Up
 * LC	CC		RC		Center
 * LD	CD		RD		Down
 */
struct native AimTransform
{
	var		Rotator	Rotation;
	var()	Quat	Quaternion;
	var()	Vector	Translation;
};


/**
 * definition of an AimComponent.
 */
struct native AimComponent
{
	/** Bone transformed */
	var()	Name			BoneName;

	/** Left column */
	var()	AimTransform	LU;
	var()	AimTransform	LC;
	var()	AimTransform	LD;

	/** Center */
	var()	AimTransform	CU;
	var()	AimTransform	CC;
	var()	AimTransform	CD;

	/** Right */
	var()	AimTransform	RU;
	var()	AimTransform	RC;
	var()	AimTransform	RD;
};



/** Handy enum for working with directions. */
enum EAnimAimDir
{
	ANIMAIM_LEFTUP,
	ANIMAIM_CENTERUP,
	ANIMAIM_RIGHTUP,
	ANIMAIM_LEFTCENTER,
	ANIMAIM_CENTERCENTER,
	ANIMAIM_RIGHTCENTER,
	ANIMAIM_LEFTDOWN,
	ANIMAIM_CENTERDOWN,
	ANIMAIM_RIGHTDOWN
};


/** Angle of aiming, between -1..+1 */
var()	Vector2d		Aim;

/** Angle offset applied to Aim before processing */
var()	Vector2d		AngleOffset;

/** If true, ignore Aim, and use the ForcedAimDir enum instead to determine which aim direction to draw. */
var()	bool			bForceAimDir;

/** If the LOD of this skeletal mesh is at or above this LOD, then this node will do nothing. */
var()	int				PassThroughAtOrAboveLOD;

/** If bForceAimDir is true, this is the direction to render the character aiming in. */
var()	EAnimAimDir		ForcedAimDir;

/** Internal, array of required bones. Selected bones and their parents for local to component space transformation. */
var	transient	Array<byte>	RequiredBones;
/** Bone Index to AimComponent Index look up table. */
var	transient	Array<INT> BoneToAimCpnt;

/** 
 *	Pointer to AimOffset node in package (AnimTreeTemplate), to avoid duplicating profile data. 
 *	Always NULL in AimOffset Editor (in ATE).
 */
var	transient AnimNodeAimOffset	TemplateNode;

/** Bake offsets from animations. */
var()	bool			bBakeFromAnimations;

//// ONLY FOR BACKWARD COMPATIBILITY (before VER_AIMOFFSET_PROFILES)
var		Vector2d			HorizontalRange;
var		Vector2d			VerticalRange;
var		Array<AimComponent>	AimComponents;
var		Name				AnimName_LU;
var		Name				AnimName_LC;
var		Name				AnimName_LD;
var		Name				AnimName_CU;
var		Name				AnimName_CC;
var		Name				AnimName_CD;
var		Name				AnimName_RU;
var		Name				AnimName_RC;
var		Name				AnimName_RD;
////

struct native AimOffsetProfile
{
	/** Name of this aim-offset profile. */
	var()	const editconst name	ProfileName;

	/** Maximum horizontal range (min, max) for horizontal aiming. */
	var()	Vector2d				HorizontalRange;

	/** Maximum horizontal range (min, max) for vertical aiming. */
	var()	Vector2d				VerticalRange;

	/**
	 * Array of AimComponents.
	 * Represents the selected bones and their transformations.
	 */
	var		Array<AimComponent>		AimComponents;

	/**
	 *	Names of animations to use when automatically generating offsets based animations for each direction.
	 *	Animations are not actually used in-game - just for editor.
	 */
	var()	Name	AnimName_LU;
	var()	Name	AnimName_LC;
	var()	Name	AnimName_LD;
	var()	Name	AnimName_CU;
	var()	Name	AnimName_CC;
	var()	Name	AnimName_CD;
	var()	Name	AnimName_RU;
	var()	Name	AnimName_RC;
	var()	Name	AnimName_RD;

	structdefaultproperties
	{
		ProfileName="Default"
		HorizontalRange=(X=-1,Y=+1)
		VerticalRange=(X=-1,Y=+1)
	}
};

/** Array of different aiming 'profiles' */
var()	editconst array<AimOffsetProfile>		Profiles;

/**
 *	Index of currently active Profile.
 *	Use the SetActiveProfileByName or SetActiveProfileByIndex function to change.
*/
var()	const editconst int			CurrentProfileIndex;



/**
 *	Change the currently active profile to the one with the supplied name.
 *	If a profile with that name does not exist, this does nothing.
 */
native function SetActiveProfileByName(name ProfileName);

/**
 *	Change the currently active profile to the one with the supplied index.
 *	If ProfileIndex is outside range, this does nothing.
 */
native function SetActiveProfileByIndex(int ProfileIndex);

defaultproperties
{
	Children(0)=(Name="Input",Weight=1.0)
	bFixNumChildren=TRUE

	HorizontalRange=(X=-1,Y=+1)
	VerticalRange=(X=-1,Y=+1)
	ForcedAimDir=ANIMAIM_CENTERCENTER
	PassThroughAtOrAboveLOD=1000
}
