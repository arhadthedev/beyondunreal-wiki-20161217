/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTHeroBerserk extends UTTimedPowerup;

/** Overlay material applied to owner */
var MaterialInterface OverlayMaterialInstance;
/** Multiplier applied to weapon fire rate */
var float FireRateMultiplier;

simulated static function AddWeaponOverlay(UTGameReplicationInfo GRI)
{
	GRI.WeaponOverlays[1] = default.OverlayMaterialInstance;
}


simulated function DisplayPowerup(Canvas Canvas, UTHud HUD, float ResolutionScale,out float YPos)
{
}

/** adds or removes our bonus from the given pawn */
simulated function AdjustPawn(UTPawn P, bool bRemoveBonus)
{
	if (P != None && Role == ROLE_Authority)
	{
		if (bRemoveBonus)
		{
			P.FireRateMultiplier *= FireRateMultiplier;
		}
		else
		{
			// halve firing time
			P.FireRateMultiplier *= 1.0/FireRateMultiplier;
		}
		P.FireRateChanged();
	}
}

function GivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	local UTPawn P;

	Super.GivenTo(NewOwner, bDoNotActivate);

	P = UTPawn(NewOwner);
	if (P != None)
	{
		// apply Berserk overlay
		P.SetWeaponOverlayFlag(1);
		AdjustPawn(P, false);
	}
}

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	Super.ClientGivenTo(NewOwner, bDoNotActivate);

	if (Role < ROLE_Authority)
	{
		AdjustPawn(UTPawn(NewOwner), false);
	}
}

function ItemRemovedFromInvManager()
{
	local UTPawn P;

	P = UTPawn(Owner);
	if ( P != None )
	{
		P.ClearWeaponOverlayFlag(1);
		AdjustPawn(P, true);
	}
}

simulated event Destroyed()
{
	if (Role < ROLE_Authority)
	{
		AdjustPawn(UTPawn(Owner), true);
	}

	Super.Destroyed();
}

defaultproperties
{
	bReceiveOwnerEvents=true
	bRenderOverlays=true
	OverlayMaterialInstance=Material'Pickups.Berserk.M_Berserk_Overlay'

	bDropOnDisrupt=false
	bDropOnDeath=false
	FireRateMultiplier=1.7
	PP_Scene_Highlights=(X=0,Y=0,Z=0)
}