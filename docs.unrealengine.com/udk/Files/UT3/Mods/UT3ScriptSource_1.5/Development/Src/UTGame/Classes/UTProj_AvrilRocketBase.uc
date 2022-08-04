/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_AvrilRocketBase extends UTProjectile
	native;

/** Holds the vehicle this rocket is locked on to.  The vehicle will give us our Homing Target */
var Actor LockedTarget;

/** Holds a pointer back to the firing Avril - Only valid server side */
var UTWeap_Avril MyWeapon;
/** the AVRiL that is currently controlling the target lock (could be different if MyWeapon has no target) */
var UTWeap_Avril LockingWeapon;

/** Set to true if the lock for this rocket has been redirected */
var bool bRedirectedLock;

/** The last time a lock message was sent */
var float	LastLockWarningTime;

/** How long before re-sending the next Lock On message update */
var float	LockWarningInterval;

var float InitialPostRenderTime;

var Texture2D BeaconTexture;

/** Extended radius for raptor bolts destroying this avril */
var float RaptorBoltExtendedRadius;



replication
{
	if (bNetDirty && ROLE == ROLE_Authority)
		LockedTarget;
}

simulated event Destroyed()
{
	local PlayerController PC;

	if (Role==ROLE_Authority)
	{
		// Notify the launcher I'm dead
		if ( MyWeapon != None )
			MyWeapon.RocketDestroyed(self);
	}

	// remove from local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( UTHUD(PC.MyHUD) != None )
		{
			UTHUD(PC.MyHUD).RemovePostRenderedActor(self);
		}
	}

	super.Destroyed();
}

simulated function PostBeginPlay()
{
	local PlayerController PC;

	super.PostBeginPlay();

	// add to local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( UTHUD(PC.MyHUD) != None )
		{
			UTHUD(PC.MyHUD).AddPostRenderedActor(self);
		}
	}
}

function ForceLock(Actor ForcedLock)
{
	LockedTarget = ForcedLock;
// don't get any more target updates from weapon.
	MyWeapon.RocketDestroyed(self);
	if ( (UTVehicle_SPMA(ForcedLock) != None) && (PlayerController(InstigatorController) != None) )
		PlayerController(InstigatorController).ReceiveLocalizedMessage(class'UTLockWarningMessage', 3);
}

/**
 * Clean up
 */
simulated function Shutdown()
{
	local PlayerController PC;

	if (Role==ROLE_Authority)
	{
		// Notify the launcher I'm dead
		if ( MyWeapon != None )
		{
			MyWeapon.RocketDestroyed(self);
			MyWeapon = None;
		}
	}

	// remove from local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( UTHUD(PC.MyHUD) != None )
		{
			UTHUD(PC.MyHUD).RemovePostRenderedActor(self);
		}
	}
	Super.ShutDown();

	SetTimer(0.0,false);
}

/** sets the target we're locked on to. May fail (return false) if NewLockOwner isn't allowed to control me */
function bool SetTarget(Actor NewTarget, UTWeap_Avril NewLockOwner)
{
	// follow the lock if it's the shooter's target or the shooter doesn't have a target and a friendly player is giving one
	// short delay before accepting other players' targets to avoid rocket twisting through shooter's body, etc
	if ( NewLockOwner == MyWeapon ||
		( (LockingWeapon == None || LockingWeapon == NewLockOwner) && WorldInfo.TimeSeconds - CreationTime > 2.0 &&
			WorldInfo.GRI.OnSameTeam(NewLockOwner.Instigator, InstigatorController) ) )
	{
		LockedTarget = NewTarget;
		LockingWeapon = (LockedTarget != None) ? NewLockOwner : None;
		return true;
	}
	else
	{
		return false;
	}
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (Damage > 0 && (InstigatorController == None || !WorldInfo.GRI.OnSameTeam(EventInstigator, InstigatorController)))
	{
		Explode(HitLocation, vect(0,0,0));
	}
}

simulated native function NativePostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir);

/**
 * PostRenderFor() Hook to allow pawns to render HUD overlays for themselves.
 * Assumes that appropriate font has already been set
 *
 * @param	PC		The Player Controller who is rendering this pawn
 * @param	Canvas	The canvas to draw on
 */
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	local vector ScreenLoc;
	local float CrossScaler, CrossScaleTime;
	local LinearColor TeamColor;
	local color c;
	local float ResScale, XStart, XLen, YStart, YLen, OldY;
	local float width,height;

	screenLoc = Canvas.Project(Location);

	class'UTHud'.static.GetTeamColor( 1 - PC.GetTeamNum(), TeamColor, c);
	CrossScaleTime = FMax(0.05,(1 - 3*(WorldInfo.TimeSeconds - InitialPostRenderTime)));
	TeamColor.A = 0.8 - CrossScaleTime;

	ResScale = Canvas.ClipX / 1024;

	if ( InitialPostRenderTime == 0.0 )
	{
		InitialPostRenderTime = WorldInfo.TimeSeconds;
	}
	CrossScaler = CrossScaleTime * Canvas.ClipX;
	width = ResScale * CrossScaler;
	height = ResScale * CrossScaler;
	XStart = 662;
	YStart = 260;
	XLen = 56;
	YLen = 56;

	// if clipped out, draw offscreen indicator
	if (screenLoc.X < 0 ||
		screenLoc.X >= Canvas.ClipX ||
		screenLoc.Y < 0 ||
		screenLoc.Y >= Canvas.ClipY)
	{
		OldY = screenLoc.Y;
		screenLoc.X = FClamp(ScreenLoc.X, 0, Canvas.ClipX-1);
		screenLoc.Y = FClamp(ScreenLoc.Y, 0, Canvas.ClipY-1);
		if ( screenLoc.Y != OldY)
		{
			// draw up/down arrow
			YLen = 28;
			if ( screenLoc.Y == 0 )
			{
				YStart += YLen;
			}
		}
		else
		{
			// draw horizontal arrow
			XLen = 28;
			if ( screenLoc.X == 0 )
			{
				XStart += XLen;
			}
		}
	}

	Canvas.SetPos(ScreenLoc.X - width * 0.5, ScreenLoc.Y - height * 0.5);
	Canvas.DrawColorizedTile(BeaconTexture, width, height, XStart, YStart, XLen, YLen, TeamColor);
}

defaultproperties
{
	RaptorBoltExtendedRadius=80.0
	BeaconTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseA'
}
