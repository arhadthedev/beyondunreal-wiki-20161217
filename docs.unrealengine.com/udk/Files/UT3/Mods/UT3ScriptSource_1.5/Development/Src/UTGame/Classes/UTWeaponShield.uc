/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */


/** special actor that only blocks weapons fire */
class UTWeaponShield extends Actor
	native
	abstract;

/** If true, doesn't block projectiles flagged as bNotBlockedByShield */
var bool bIgnoreFlaggedProjectiles;



defaultproperties
{
	bProjTarget=true
	bCollideActors=true
}
