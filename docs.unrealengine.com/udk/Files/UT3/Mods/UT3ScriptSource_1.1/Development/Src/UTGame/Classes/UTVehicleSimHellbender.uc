class UTVehicleSimHellbender extends UTVehicleSimCar;

defaultproperties
{
	WheelSuspensionStiffness=90.0
	WheelSuspensionDamping=1.0
	WheelSuspensionBias=0.0
	WheelInertia=0.4
	ChassisTorqueScale=0.5
	LSDFactor=0.2
	TorqueVSpeedCurve=(Points=((InVal=-500.0,OutVal=0.0),(InVal=-300.0,OutVal=60.0),(InVal=0.0,OutVal=120.0),(InVal=400.0,OutVal=120.0),(InVal=800.0,OutVal=150.0),(InVal=920.0,OutVal=0.0)))
	EngineBrakeFactor=0.025
	EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=500.0),(InVal=599.0,OutVal=5000.0),(InVal=600.0,OutVal=3000.0),(InVal=849.0,OutVal=5000.0),(InVal=850.0,OutVal=3000.0),(InVal=1050.0,OutVal=5000.0)))
	MaxBrakeTorque=10.0
	MaxSteerAngleCurve=(Points=((InVal=0,OutVal=45.0),(InVal=300.0,OutVal=31.0),(InVal=900.0,OutVal=22.0)))
	SteerSpeed=140
	StopThreshold=200
	NumWheelsForFullSteering=4
	SteeringReductionFactor=0.25
	SteeringReductionMinSpeed=500.0
	SteeringReductionSpeed=800.0
	ThrottleSpeed=0.2
	HardTurnMotorTorque=1.0
	FrontalCollisionGripFactor=0.18

	SpeedBasedTurnDamping=5.0
	AirControlTurnTorque=60.0
	InAirUprightMaxTorque=12.0
	InAirUprightTorqueFactor=-25.0

	bClampedFrictionModel=true

	// Longitudinal tire model based on 10% slip ratio peak
	WheelLongExtremumSlip=0.1
	WheelLongExtremumValue=1.0
	WheelLongAsymptoteSlip=2.0
	WheelLongAsymptoteValue=0.6

	// Lateral tire model based on slip angle (radians)
	WheelLatExtremumSlip=0.35     // 20 degrees
	WheelLatExtremumValue=0.95
	WheelLatAsymptoteSlip=1.4     // 80 degrees
	WheelLatAsymptoteValue=0.85
}