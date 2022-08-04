/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_StealthBenderGold_Content extends UTVWeap_NightshadeGun
		HideDropDown;


function byte BestMode()
{
	local UTBot B;
	local int SelectedDeployable;
	local UTGameObjective O;

//0 spider
//1 xray
//2 emp
//3 link
	SelectedDeployable = (FRand() < 0.5) ? 0 : 2;
	B = UTBot(Instigator.Controller);
	if ( B != None )
	{
		if ( (B.Squad.SquadObjective != None) && (FRand() < 0.5) )
		{
			if ( B.IsDefending() )
			{
				SelectedDeployable = (FRand() < 0.5) ? 1 : 3;
			}
			else
			{
				// consider dropping a deployable if near a relevant objective
				foreach WorldInfo.RadiusNavigationPoints(class'UTGameObjective', O, Location, 1500.0)
				{
					SelectedDeployable = (FRand() < 0.5) ? 1 : 3;
					if ( O.IsActive() && WorldInfo.GRI.OnSameTeam(B,O) && FastTrace(O.Location, Location) )
					{
						SelectedDeployable = (FRand() < 0.5) ? 1 : 3;
						break;
					}
				}
			}
		}
	}
	if ( !SelectWeapon(SelectedDeployable) )
	{
		if ( !SelectWeapon(0) )
			if ( !SelectWeapon(2) )
				if ( !SelectWeapon(1) )
					SelectWeapon(3);
	}

	return 0;
}

defaultproperties
{

	//WeaponFireSnd(0)=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_AltFireQueue1_Cue'
	DeployedItemSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_DropItem_Cue'

	AltFireModeChangeSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_SwitchDeployables_Cue'

	DeployableList(0)=(DeployableClass=class'UTDeployableSpiderMineTrap',MaxCnt=2,DropOffset=(x=30))
	DeployableList(1)=(DeployableClass=class'UTDeployableXRayVolume',MaxCnt=1,DropOffset=(x=30))	
	DeployableList(2)=(DeployableClass=class'UTDeployableEMPMine',MaxCnt=1,DropOffset=(x=30))
	DeployableList(3)=(DeployableClass=class'UTDeployableLinkGenerator',MaxCnt=1,DropOffset=(x=30))

	LinkFlexibility=0.5 // determines how easy it is to maintain a link.
				// 1=must aim directly at linkee, 0=linkee can be 90 degrees to either side of you
	LinkBreakDelay=0.5   // link will stay established for this long extra when blocked (so you don't have to worry about every last tree getting in the way)

	IconCoords(0)=(U=930,V=582,UL=94,VL=119) //Spider Mine
	IconCoords(1)=(U=5,V=147,UL=97,VL=94) //XRay Volume
	IconCoords(2)=(U=774,V=582,UL=156,VL=135) //EMP Mine
	IconCoords(3)=(U=5,V=241,UL=97,VL=139) //Link Generator

	//from UTVWeap_StealthbenderGun.uc in UTGameContent
	InstantHitDamageTypes(0)=class'UTDmgType_StealthbenderBeam'
	VehicleClass=class'UTVehicle_StealthbenderGold_Content'

	VehicleHitEffect=(ParticleTemplate=ParticleSystem'VH_StealthBender.Effects.P_VH_StealthBender_Beam_Impact')
}
