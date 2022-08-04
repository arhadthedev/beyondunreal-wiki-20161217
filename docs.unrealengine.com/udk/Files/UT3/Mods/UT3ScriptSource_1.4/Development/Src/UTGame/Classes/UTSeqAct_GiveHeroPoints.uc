/**
* This is an op that gives hero points to the targeted pawn(s)
* Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
*/
class UTSeqAct_GiveHeroPoints extends SequenceAction;

/** Number of hero points to give out */
var() int HeroPoints;

defaultproperties
{
	bCallHandler=true
	ObjCategory="Pawn"
	ObjName="Give Hero Points"
	ObjColor=(R=255,G=0,B=255,A=255)
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Pawns",PropertyName=Targets)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Amount",PropertyName=HeroPoints)
}