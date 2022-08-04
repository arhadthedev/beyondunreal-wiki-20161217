/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleSimHoverTank extends SVehicleSimBase
	native(Vehicle);

var()	float				MaxThrustForce;
var()	float				MaxReverseForce;
var()	float				LongDamping;
var()	float				LatDamping;

var()	float				TurnTorqueMax;
var()	float				TurnDamping;
var		bool				bWasReversedSteering;

var()	float				StopThreshold;

//**************************************************************
// Wheel distance adjustment

/** Ground distance when driving */
var() float DrivingGroundDist;

/** Ground distance when parked */
var() float ParkedGroundDist;

/** current ground dist (smoothly interpolates to desired dist */
var	float	CurrentGroundDist;

var float	GroundDistAdjustSpeed;

var float	WheelAdjustFactor;

/** If bStabilizeStops=true, forces are applied to attempt to keep the vehicle from moving when it is stopped */
var()		bool	bStabilizeStops;

/** Stabilization force multiplier when bStabilizeStops=true */
var()		float	StabilizationForceMultiplier;

/** modified based on whether velocity is decreasing acceptably due to stabilization */
var			float	CurrentStabilizationMultiplier;

/** OldVelocity saved to monitor stabilization */
var			vector	OldVelocity;

/** When not driving, braking torque to apply to wheels. */
var			float	StoppedBrakeTorque;

/** If ForcedDirection heading has been initialized*/
var     bool                bHeadingInitialized;
var		float				TargetHeading;

/** If true, tank will turn in place when just steering is applied. */
var()	bool				bTurnInPlaceOnSteer;



defaultproperties
{
	DrivingGroundDist=60.0
	ParkedGroundDist=20.0
	CurrentGroundDist=20.0
	GroundDistAdjustSpeed=20.0
	bTurnInPlaceOnSteer=true
	StoppedBrakeTorque=5.0
}
