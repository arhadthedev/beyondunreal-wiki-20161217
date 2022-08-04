/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class SeqAct_ChangeCollision extends SequenceAction
	native(Sequence);

;

var() editconst const bool bCollideActors;
var() editconst const bool bBlockActors;
var() editconst const bool bIgnoreEncroachers;

var() Actor.ECollisionType CollisionType;

defaultproperties
{
	ObjClassVersion=5

	ObjName="Change Collision"
	ObjCategory="Actor"
}
