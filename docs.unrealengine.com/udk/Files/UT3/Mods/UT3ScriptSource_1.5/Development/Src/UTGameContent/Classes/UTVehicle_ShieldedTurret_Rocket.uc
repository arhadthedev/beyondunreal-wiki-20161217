/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_ShieldedTurret_Rocket extends UTVehicle_ShieldedTurret;

defaultproperties
{
	Seats(0)={(	GunClass=class'UTVWeap_RocketTurret',
			GunSocket=(GunLeft,GunRight),
			TurretVarPrefix="",
			TurretControls=(PitchControl,LeftYawControl,RightYawControl),
			CameraTag=CameraViewSocket,
			bSeatVisible=true,
			GunPivotPoints=(Seat),
			CameraEyeHeight=5,
			SeatBone=Seat,
			SeatOffset=(X=36,Z=23),
			SeatRotation=(Pitch=1820),
			SeatMotionAudio=TurretTwistSound,
			SeatIconPos=(X=0.47,Y=0.65),
			CameraBaseOffset=(Z=50.0),
			CameraOffset=-120,
			DriverDamageMult=0.4,
			WeaponEffects=((SocketName=GunLeft,Offset=(X=-35,Y=-3),Scale3D=(X=4.0,Y=4.5,Z=4.5)),(SocketName=GunRight,Offset=(X=-35,Y=-3),Scale3D=(X=4.0,Y=4.5,Z=4.5)))
	)}

	VehicleEffects(1)=(EffectStartTag=TurretFireLeft,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_TurretRocketMF',EffectSocket=GunLeft)
	VehicleEffects(2)=(EffectStartTag=TurretFireRight,EffectTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_TurretRocketMF',EffectSocket=GunRight)
}
