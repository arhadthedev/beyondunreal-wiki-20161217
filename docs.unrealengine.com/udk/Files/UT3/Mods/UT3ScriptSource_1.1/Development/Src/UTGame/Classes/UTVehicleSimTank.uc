/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleSimTank extends SVehicleSimTank
	native(Vehicle);

/** When driving into something, reduce friction on the wheels. */
var()	float		FrontalCollisionGripFactor;

/** When no steering - How quickly to get tracks to same speed. */
var()	float		EqualiseTrackSpeed;



DefaultProperties
{
	FrontalCollisionGripFactor=1.0
}
