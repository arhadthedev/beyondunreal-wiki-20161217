// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
class UTMutator_Instagib extends UTMutator;

function InitMutator(string Options, out string ErrorMessage)
{
	if ( UTGame(WorldInfo.Game) != None )
	{
		UTGame(WorldInfo.Game).DefaultInventory.Length = 0;
		UTGame(WorldInfo.Game).DefaultInventory[0] = class'UTGame.UTWeap_InstagibRifle';
		if ( UTTeamGame(WorldInfo.Game) != None )
		{
			UTTeamGame(WorldInfo.Game).TeammateBoost = 0.6;
		}
	}

	Super.InitMutator(Options, ErrorMessage);
}

function bool CheckReplacement(Actor Other)
{
	if (Other.IsA('UTWeapon') && !Other.IsA('UTVehicleWeapon') && !Other.IsA('UTWeap_InstagibRifle') && !Other.IsA('UTWeap_Translocator'))
	{
		return false;
	}
	else
	{
		return !Other.IsA('PickupFactory');
	}
}

defaultproperties
{
	GroupNames[0]="WEAPONMOD"
	GroupNames[1]="WEAPONRESPAWN"
	GroupNames[2]="HANDICAP"
	GroupNames[3]="POWERUPS"
}
