/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_ShockTurret extends UTVWeap_ShockTurretBase
	HideDropDown;

defaultproperties
{
	VehicleClass=class'UTVehicle_Hellbender_Content'
	bFastRepeater=true

	WeaponProjectiles(0)=class'UTProj_VehicleShockBall'
	InstantHitDamageTypes(1)=class'UTDmgType_VehicleShockBeam'
}
