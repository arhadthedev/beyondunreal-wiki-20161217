/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_StealthbenderGun extends UTVWeap_StealthGunContent
		HideDropDown;

// this class ended up being removed from all maps - removing the content references here fixes a bunch of errors
// when compiling script in the shipping game that were due to the content no longer being used in the final build
/*
defaultproperties
{
	InstantHitDamageTypes(0)=class'UTDmgType_StealthbenderBeam'
	VehicleClass=class'UTVehicle_Stealthbender_Content'

	VehicleHitEffect=(ParticleTemplate=ParticleSystem'VH_StealthBender.Effects.P_VH_StealthBender_Beam_Impact')
}
*/
