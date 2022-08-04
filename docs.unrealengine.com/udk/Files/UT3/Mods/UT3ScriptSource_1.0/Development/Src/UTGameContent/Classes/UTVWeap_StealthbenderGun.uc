/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_StealthbenderGun extends UTVWeap_StealthGunContent
		HideDropDown;

defaultproperties
{
	InstantHitDamageTypes(0)=class'UTDmgType_StealthbenderBeam'
	VehicleClass=class'UTVehicle_Stealthbender_Content'

	VehicleHitEffect=(ParticleTemplate=ParticleSystem'VH_StealthBender.Effects.P_VH_StealthBender_Beam_Impact')
}
