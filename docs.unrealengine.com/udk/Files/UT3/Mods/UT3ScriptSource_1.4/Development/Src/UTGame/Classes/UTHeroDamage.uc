/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTHeroDamage extends UTTimedPowerup;

/** sound played when our owner fires */
var SoundCue UDamageFireSound;
/** last time we played that sound, so it isn't too often */
var float LastUDamageSoundTime;
/** overlay material applied to owner */
var MaterialInterface OverlayMaterialInstance;
/** particle effect played on vehicle weapons */
var MeshEffect VehicleWeaponEffect;
/** ambient sound played while active*/
var SoundCue DamageAmbientSound;

simulated static function AddWeaponOverlay(UTGameReplicationInfo GRI)
{
	GRI.WeaponOverlays[0] = default.OverlayMaterialInstance;
	GRI.VehicleWeaponEffects[0] = default.VehicleWeaponEffect;
}

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	local UTPawn P;

	Super.GivenTo(NewOwner, bDoNotActivate);

	// boost damage
	NewOwner.DamageScaling *= 2.0;
	P = UTPawn(NewOwner);
	if (P != None)
	{
		// apply UDamage overlay
		P.SetWeaponOverlayFlag(0);
		P.SetPawnAmbientSound(DamageAmbientSound);
	}
}

function ItemRemovedFromInvManager()
{
	local UTPlayerReplicationInfo UTPRI;
	local UTPawn P;

	Pawn(Owner).DamageScaling *= 0.5;
	P = UTPawn(Owner);
	if (P != None)
	{
		P.ClearWeaponOverlayFlag( 0 );
		P.SetPawnAmbientSound(none);
		//Stop the timer on the powerup stat
		if (P.DrivenVehicle != None)
		{
			UTPRI = UTPlayerReplicationInfo(P.DrivenVehicle.PlayerReplicationInfo);
		}
		else
		{
			UTPRI = UTPlayerReplicationInfo(P.PlayerReplicationInfo);
		}
		if (UTPRI != None)
		{
			UTPRI.StopPowerupTimeStat(GetPowerupStatName());
		}
	}
	SetTimer(0.0, false, 'PlayUDamageFadingSound');
}

simulated function OwnerEvent(name EventName)
{
	if (EventName == 'FiredWeapon' && Instigator != None && WorldInfo.TimeSeconds - LastUDamageSoundTime > 0.25)
	{
		LastUDamageSoundTime = WorldInfo.TimeSeconds;
		Instigator.PlaySound(UDamageFireSound, false, true);
	}
}

function PlayUDamageFadingSound()
{
	// clear this timer
	SetTimer(0.0, false, 'PlayUDamageFadingSound');
}

simulated function DisplayPowerup(Canvas Canvas, UTHud HUD, float ResolutionScale,out float YPos)
{
}

defaultproperties
{
	bReceiveOwnerEvents=true
	bRenderOverlays=true
	UDamageFireSound=SoundCue'A_Titan_Extras.PowerUps.A_Powerup_UDamage_FireCue'
	DamageAmbientSound=SoundCue'A_Titan_Extras.PowerUps.A_Powerup_UDamage_PowerLoopCue'
	OverlayMaterialInstance=Material'Pickups.UDamage.M_UDamage_Overlay'
	VehicleWeaponEffect=(Mesh=StaticMesh'Envy_Effects.Mesh.S_VH_Powerups',Material=MaterialInterface'Envy_Effects.Energy.Materials.M_VH_UDamage')

	bDropOnDeath=false
	bDropOnDisrupt=false
	PP_Scene_Highlights=(X=0,Y=0,Z=0)
}