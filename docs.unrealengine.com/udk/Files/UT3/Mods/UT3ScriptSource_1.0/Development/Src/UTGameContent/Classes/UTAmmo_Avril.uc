/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTAmmo_AVRiL extends UTAmmoPickupFactory;

defaultproperties
{
	AmmoAmount=5
	TargetWeapon=class'UTWeap_Avril_Content'
	PickupSound=SoundCue'A_Pickups.Ammo.Cue.A_Pickup_Ammo_Flak_Cue'
	MaxDesireability=0.32

	Begin Object Name=AmmoMeshComp
		StaticMesh=StaticMesh'Pickups.Ammo_Avril.Mesh.S_Pickups_Ammo_Avril'
		Translation=(Z=4.0)
	End Object

	Begin Object Name=CollisionCylinder
		CollisionRadius=28
	End Object
}
