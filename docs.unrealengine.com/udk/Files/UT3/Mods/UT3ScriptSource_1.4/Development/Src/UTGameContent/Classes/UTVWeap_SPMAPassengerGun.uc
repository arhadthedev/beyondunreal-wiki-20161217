/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_SPMAPassengerGun extends UTVWeap_ShockTurretBase
		HideDropDown;

defaultproperties
{
	VehicleClass=class'UTVehicle_SPMA_Content'
	bFastRepeater=true

	WeaponProjectiles(0)=class'UTProj_SPMAShockBall'
	InstantHitDamageTypes(1)=class'UTDmgType_SPMAShockBeam'
}
