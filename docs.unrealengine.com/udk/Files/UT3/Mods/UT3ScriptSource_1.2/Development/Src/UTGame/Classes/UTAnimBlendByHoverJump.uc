/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTAnimBlendByHoverJump extends UTAnimBlendByFall
	Native(Animation);

var const transient Pawn	OwnerP;
var const transient UTHoverVehicle OwnerHV;



defaultproperties
{
	bIgnoreDoubleJumps=true
}
