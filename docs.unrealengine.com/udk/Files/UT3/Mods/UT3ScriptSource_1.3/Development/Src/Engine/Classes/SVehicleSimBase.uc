﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SVehicleSimBase extends ActorComponent
	native(Physics);

// Wheel params
// For more information, see https://udn.epicgames.com/Three/VehicleGuide

var()	float				WheelSuspensionStiffness;
var()	float				WheelSuspensionDamping;
var()	float				WheelSuspensionBias;

var()	float				WheelLongExtremumSlip;
var()	float				WheelLongExtremumValue;
var()	float				WheelLongAsymptoteSlip;
var()	float				WheelLongAsymptoteValue;

var()	float				WheelLatExtremumSlip;
var()	float				WheelLatExtremumValue;
var()	float				WheelLatAsymptoteSlip;
var()	float				WheelLatAsymptoteValue;

var()	float				WheelInertia;

var()   bool                bWheelSpeedOverride; // Allows you to set the axle speed directly

/** Friction model that clamps the frictional force applied by the wheels. Should be more realistic. */
var()	bool				bClampedFrictionModel;

var()	bool				bAutoDrive;
var()	float				AutoDriveSteer;



defaultproperties
{
    // Force
    // ^		extremum
    // |    _*_
    // |   ~   \     asymptote
    // |  /     \~__*______________
    // | /
    // |/
    // ---------------------------> Slip

    // Longitudinal tire model based on 10% slip ratio peak
	WheelLongExtremumSlip=0.1
	WheelLongExtremumValue=1.0
	WheelLongAsymptoteSlip=2.0
	WheelLongAsymptoteValue=0.6

    // Lateral tire model based on slip angle (radians)
   	WheelLatExtremumSlip=0.35     // 20 degrees
	WheelLatExtremumValue=0.85
	WheelLatAsymptoteSlip=1.4     // 80 degrees
	WheelLatAsymptoteValue=0.7

	WheelInertia=1.0
}
