// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
class UTMutator_WeaponsRespawn extends UTMutator;

simulated function PostBeginPlay()
{
	local UTWeaponPickupFactory WPF;

	Super.PostBeginPlay();

	// set bweaponstay on clients
	ForEach DynamicActors(class'UTWeaponPickupFactory', WPF)
	{
		WPF.bWeaponStay = false;
	}
}

function InitMutator(string Options, out string ErrorMessage)
{
	UTGame(WorldInfo.Game).bWeaponStay = false;
	super.InitMutator(Options, ErrorMessage);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	GroupNames[0]="WEAPONRESPAWN"
}
