/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTWarfarePlayerStart extends PlayerStart;

/** if set, prioritize this start when the associated objective is under attack */
var() bool bPrioritizeWhenUnderAttack;

defaultproperties
{
	bPrioritizeWhenUnderAttack=true
}
