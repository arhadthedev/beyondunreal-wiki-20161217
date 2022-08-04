/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_Player extends SeqVar_Object
	native(Sequence);

;

/** Local list of players in the game */
var transient array<Object> Players;

/** Return all player references? */
var() bool bAllPlayers;

/** Individual player selection for multiplayer scripting */
var() int PlayerIdx;

/** @fixme - this is an invalid implementation, whoever wrote this needs to fix it */
function Object GetObjectValue()
{
	local PlayerController PC;

	PC = PlayerController(ObjValue);
	if (PC == None)
	{
		foreach GetWorldInfo().AllControllers(class'PlayerController', PC)
		{
			ObjValue = PC;
			break;
		}
	}

	// we usually want the pawn, so return that if possible
	return (PC.Pawn != None) ? PC.Pawn : PC;
}

defaultproperties
{
	ObjName="Player"
	ObjCategory="Object"
	bAllPlayers=TRUE
	SupportedClasses=(class'Controller',class'Pawn')
}
