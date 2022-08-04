/**
 * Despite the name, seem to be activated anytime a pawn is killed in the game.
 * Originator: the pawn that owns this event
 * Instigator: the pawn that was killed
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqEvent_SeeDeath extends SequenceEvent
	native(Sequence);

;

defaultproperties
{
	ObjName="See Death"
	ObjCategory="Pawn"
	bPlayerOnly=false

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Victim",bWriteable=true)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Killer",bWriteable=true)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Witness",bWriteable=true)
}
