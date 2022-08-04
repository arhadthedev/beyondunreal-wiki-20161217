//=============================================================================
// Scout used for path generation.
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class Scout extends Pawn
	native
	config(Game)
	notplaceable
	transient
	dependsOn(ReachSpec);

;

struct native PathSizeInfo
{
	var Name		Desc;
	var	float		Radius,
					Height,
					CrouchHeight;
	var byte		PathColor;
};
var array<PathSizeInfo>			PathSizes;		// dimensions of reach specs to test for
var float						TestJumpZ,
								TestGroundSpeed,
								TestMaxFallSpeed,
								TestFallSpeed;

var const float MaxLandingVelocity;

var int MinNumPlayerStarts;

/** Specifies the default class to use when constructing reachspecs connecting NavigationPoints */
var class<ReachSpec> DefaultReachSpecClass;

simulated event PreBeginPlay()
{
	// make sure this scout has all collision disabled
	if (bCollideActors)
	{
		SetCollision(FALSE,FALSE);
	}
}

defaultproperties
{
	Components.Remove(Sprite)
	Components.Remove(Arrow)

	RemoteRole=ROLE_None
	AccelRate=+00001.000000
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bProjTarget=false
	bPathColliding=true

	PathSizes(0)=(Desc=Human,Radius=48,Height=80)
	PathSizes(1)=(Desc=Common,Radius=72,Height=100)
	PathSizes(2)=(Desc=Max,Radius=120,Height=120)
	PathSizes(3)=(Desc=Vehicle,Radius=260,Height=120)

	TestJumpZ=420
	TestGroundSpeed=600
	TestMaxFallSpeed=2500
	TestFallSpeed=1200
	MinNumPlayerStarts=1
	DefaultReachSpecClass=class'Engine.Reachspec'
}
