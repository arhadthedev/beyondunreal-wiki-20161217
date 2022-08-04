/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleSimHover extends UTVehicleSimChopper
	native(Vehicle);

var		bool	bDisableWheelsWhenOff;
var		bool	bRepulsorCollisionEnabled;
var		bool	bCanClimbSlopes;
var		bool	bUnPoweredDriving;



defaultproperties
{
	bDisableWheelsWhenOff=true
	bRepulsorCollisionEnabled=true
}
