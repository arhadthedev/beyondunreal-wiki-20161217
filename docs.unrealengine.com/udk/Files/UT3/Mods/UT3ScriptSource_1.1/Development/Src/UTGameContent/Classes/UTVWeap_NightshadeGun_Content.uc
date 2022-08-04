/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_NightshadeGun_Content extends UTVWeap_StealthGunContent
		HideDropDown;

defaultproperties
{
	InstantHitDamageTypes(0)=class'UTDmgType_NightshadeBeam'
	VehicleClass=class'UTVehicle_Nightshade_Content'

	VehicleHitEffect=(ParticleTemplate=ParticleSystem'VH_Nightshade.Effects.P_VH_Nightshade_Beam_Impact')
}
