﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_InstagibRifle extends UTWeapon
	HideDropDown;

var array<MaterialInterface> TeamSkins;
var array<ParticleSystem> TeamMuzzleFlashes;

var bool bBetrayalMode;

//-----------------------------------------------------------------
// AI Interface

function float GetAIRating()
{
	return AIRating;
}

function float RangedAttackTime()
{
	return 0;
}

simulated function SetSkin(Material NewMaterial)
{
	local int TeamIndex;

	if ( NewMaterial == None ) 	// Clear the materials
	{
		if ( Instigator != None )
		{
			TeamIndex = Instigator.GetTeamNum();
		}
		if (TeamIndex > TeamSkins.length)
		{
			TeamIndex = 0;
		}
		Mesh.SetMaterial(0,TeamSkins[TeamIndex]);
	}
	else
	{
		Super.SetSkin(NewMaterial);
	}
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	local int TeamIndex;

	TeamIndex = Instigator.GetTeamNum();
	if (TeamIndex > TeamMuzzleFlashes.length)
	{
		TeamIndex = 0;
	}
	MuzzleFlashPSCTemplate = TeamMuzzleFlashes[TeamIndex];

	Super.AttachWeaponTo(MeshCpnt, SocketName);
}

simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact )
{
	local Pawn HitPawn;
	local UTBetrayalPRI HitPRI, InstigatorPRI;

	if ( bBetrayalMode && (Instigator != None) && (Role == ROLE_Authority) )
	{
		InstigatorPRI = UTBetrayalPRI(Instigator.PlayerReplicationInfo);
		if ( InstigatorPRI != None )
		{
			HitPawn = Pawn(Impact.HitActor);
			if ( HitPawn != None )
			{
				HitPRI = UTBetrayalPRI(HitPawn.PlayerReplicationInfo);
				if ( HitPRI != None )
				{
					if ( WorldInfo.GRI.OnSameTeam(InstigatorPRI, HitPRI) )
					{
						if ( FiringMode == 1 )
						{
							if ( UTGame(WorldInfo.Game) != None )
							{
								UTGame(WorldInfo.Game).ShotTeammate(InstigatorPRI, HitPRI, Instigator, HitPawn);
							}
							super.ProcessInstantHit(0, Impact);
						}
					}
					else if ( FiringMode == 0 )
					{
						super.ProcessInstantHit(0, Impact);
					}
				}
				return;
			}
			else
			{
				// bots don't like being shot at by teammates
				if ( (PlayerController(Instigator.Controller) != None) 
					&& (Instigator.Controller.ShotTarget != None)
					&& (UTBot(Instigator.Controller.ShotTarget.Controller) != None)
					&& WorldInfo.GRI.OnSameTeam(Instigator, Instigator.Controller.ShotTarget) 
					&& (UTBetrayalPRI(Instigator.PlayerReplicationInfo).CurrentTeam.TeamPot >= Min(6, WorldInfo.Game.GoalScore - Max(Instigator.PlayerReplicationInfo.Score, Instigator.Controller.ShotTarget.PlayerReplicationInfo.Score))) )
				{
					//`log(Instigator.Controller.ShotTarget.Controller.PlayerReplicationInfo.PlayerName$" betray shooter");
					UTBot(Instigator.Controller.ShotTarget.Controller).bBetrayTeam = true;
				}
			}
		}
	}
	super.ProcessInstantHit(FiringMode, Impact);
}

function byte BestMode()
{
	// if ( WorldInfo.GRI.OnSameTeam(Instigator.Controller.Enemy, Instigator) && !UTBot(Instigator.Controller).bBetrayTeam ) `log("Shooting teammate without betrayal");
	return WorldInfo.GRI.OnSameTeam(Instigator.Controller.Enemy, Instigator) ? 1 : 0;
}

defaultproperties
{
	MuzzleFlashSocket=MF
	MuzzleFlashDuration=0.33;

	WeaponColor=(R=160,G=0,B=255,A=255)
	FireInterval(0)=+1.1
	FireInterval(1)=+1.1
	InstantHitMomentum(0)=+100000.0
	FireOffset=(X=20,Y=5)
	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)
	bCanThrow=false
	bExportMenuData=false

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object
	AttachmentClass=class'UTGame.UTAttachment_InstagibRifle'

	InstantHitDamage(0)=1000
	InstantHitDamage(1)=1000

	InstantHitDamageTypes(0)=class'UTDmgType_Instagib'
	InstantHitDamageTypes(1)=class'UTDmgType_Instagib'

	WeaponFireAnim(0)=WeaponFireInstigib
	WeaponFireAnim(1)=WeaponFireInstigib

	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_InstagibFireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_InstagibFireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'

	AIRating=+1.0
	CurrentRating=+1.0
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	InventoryGroup=12
	GroupWeight=0.5

	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	ShotCost(0)=0
	ShotCost(1)=0

	IconX=400
	IconY=129
	IconWidth=22
	IconHeight=48
	IconCoordinates=(U=722,V=479,UL=166,VL=42)

	TeamSkins[0]=MaterialInterface'WP_ShockRifle.Materials.M_WP_ShockRifle_Instagib_Red'
	TeamSkins[1]=MaterialInterface'WP_ShockRifle.Materials.M_WP_ShockRifle_Instagib_Blue'
	TeamMuzzleFlashes[0]=ParticleSystem'WP_Shockrifle.Particles.P_Shockrifle_Instagib_MF_Red'
	TeamMuzzleFlashes[1]=ParticleSystem'WP_Shockrifle.Particles.P_Shockrifle_Instagib_MF_Blue'
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	AmmoDisplayType=EAWDS_None
}
