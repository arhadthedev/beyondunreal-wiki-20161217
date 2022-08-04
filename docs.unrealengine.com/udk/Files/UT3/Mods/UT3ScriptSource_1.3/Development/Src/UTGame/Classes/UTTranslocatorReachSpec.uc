/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTTranslocatorReachSpec extends UTTrajectoryReachSpec
	native;

var vector CachedVelocity;		// used for rendering paths
/** required jump Z velocity to reach this path without a translocator, or 0 if it is impossible to reach without one */
var float RequiredJumpZ;
/** Gravity at the time RequiredJumpZ was calculated, to adjust it for gravity changes (lowgrav mutator, etc) */
var float OriginalGravityZ;

/**	when a bot wants to traverse this path,
	if the bot can fly, it simply flies across it (no special checks are made)
	otherwise, if the UTBot's bCanDoSpecial is false or it is in a vehicle, it will not use this path
	if it's MaxSpecialJumpZ < RequiredJumpZ, UTBot::SpecialJumpTo() is called,
	otherwise if the bot can use a translocator, UTBot::TranslocateTo() is called, and if both are false the bot will not use this path
*/



