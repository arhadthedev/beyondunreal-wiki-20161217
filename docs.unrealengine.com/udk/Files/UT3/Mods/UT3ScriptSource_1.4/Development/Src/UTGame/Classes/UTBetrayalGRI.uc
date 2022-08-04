/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTBetrayalGRI extends UTGameReplicationInfo
	config(Game)
	native;

/**
 * Checks to see if two actors are on the same team.
 *
 * @return	true if they are, false if they aren't
 */
simulated native function bool OnSameTeam(Actor A, Actor B);

/**
  * Returns the UTBetrayalPRI (if any) associated with Actor A
  */
native final function UTBetrayalPRI GetBetrayalPRIFor(Actor A);
