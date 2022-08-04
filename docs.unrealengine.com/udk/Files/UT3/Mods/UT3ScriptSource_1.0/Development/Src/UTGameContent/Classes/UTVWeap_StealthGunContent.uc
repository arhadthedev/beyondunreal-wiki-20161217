/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_StealthGunContent extends UTVWeap_NightshadeGun
		HideDropDown;

defaultproperties
{

	//WeaponFireSnd(0)=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_AltFireQueue1_Cue'
	DeployedItemSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_DropItem_Cue'

	AltFireModeChangeSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_SwitchDeployables_Cue'

	DeployableList(0)=(DeployableClass=class'UTDeployableSpiderMineTrap',MaxCnt=2,DropOffset=(x=30))
	//This value better match UTDeployableSlowVolume::FireOffset
	DeployableList(1)=(DeployableClass=class'UTDeployableSlowVolume',MaxCnt=1,DropOffset=(X=500.0,Y=200.0,Z=100.0))	
	DeployableList(2)=(DeployableClass=class'UTDeployableEMPMine',MaxCnt=1,DropOffset=(x=30))
	DeployableList(3)=(DeployableClass=class'UTDeployableEnergyShield',MaxCnt=1,DropOffset=(x=30))

	LinkFlexibility=0.5 // determines how easy it is to maintain a link.
				// 1=must aim directly at linkee, 0=linkee can be 90 degrees to either side of you
	LinkBreakDelay=0.5   // link will stay established for this long extra when blocked (so you don't have to worry about every last tree getting in the way)

	IconCoords(0)=(U=930,V=582,UL=94,VL=119) //Spider Mine
	IconCoords(1)=(U=890,V=489,UL=103,VL=93) //Slow Volume
	IconCoords(2)=(U=774,V=582,UL=156,VL=135) //EMP Mine
	IconCoords(3)=(U=890,V=382,UL=94,VL=107) //Energy Shield
}
