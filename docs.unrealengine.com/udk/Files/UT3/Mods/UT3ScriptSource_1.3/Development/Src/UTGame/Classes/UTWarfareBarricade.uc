/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTWarfareBarricade extends UTOnslaughtSpecialObjective
	hidecategories(UTOnslaughtSpecialObjective)
	abstract;

var		UTWarfareChildBarricade NextBarricade;
var		int TotalDamage;

/** Used to check if someone is shooting at me */
var		int FakeDamage;

var		float LastDamageTime;

/** wake up call to fools shooting invalid target :) */
var SoundCue ShieldHitSound;

var float DestroyedTime;

var float LastWarningTime;

/** Used to keep players and bots from attacking barricades at wrong time */
var() bool bAvalancheBarricadeHack;

// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	bScriptInitialized = true;

	GotoState('DestroyableObjective');
}

simulated function RegisterChild(UTWarfareChildBarricade B)
{
	local UTWarfareChildBarricade Next;

	if ( NextBarricade == None )
	{
		NextBarricade = B;
	}
	else
	{
		Next = NextBarricade;
		while ( Next.NextBarricade != None )
		{
			Next = Next.NextBarricade;
		}
		Next.NextBarricade = B;
	}
	if ( bDisabled )
	{
		B.DisableBarricade();
	}
}

/** broadcasts the requested message index */
function BroadcastObjectiveMessage(int Switch)
{
	if ( Switch == 0 )
	{
		// don't broadcast "Under attack" announcements
		return;
	}
	super.BroadcastObjectiveMessage(Switch);
}

simulated function vector GetHUDOffset(PlayerController PC, Canvas Canvas)
{
	local float Z;

	Z = 300;
	if ( PC.ViewTarget != None )
	{
		Z += 0.02 * VSize(PC.ViewTarget.Location - Location);
	}

	return Z*vect(0,0,1);
}

/** Check if should respect bAvalancheBarricadeHack */
simulated function bool ValidTargetFor(Controller C)
{
	local UTOnslaughtGame G;
	
	if ( !super.ValidTargetFor(C) )
	{
		return false;
	}
	if ( !bAvalancheBarricadeHack || (C.PlayerReplicationInfo == None) )
	{
		return true;
	}
	
	// only attack this barricade if Controller's powercore is vulnerable
	G = UTOnslaughtGame(WorldInfo.Game);
	if ( G == None )
	{	
		return true;
	}
	
	return G.PowerCore[C.PlayerReplicationInfo.Team.TeamIndex].PoweredBy(1 - C.PlayerReplicationInfo.Team.TeamIndex);
}

/**
PostRenderFor()
Hook to allow objectives to render HUD overlays for themselves.
Called only if objective was rendered this tick.
Assumes that appropriate font has already been set
*/
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	local float TextXL, XL, YL, BeaconPulseScale; // Dist,
	local vector ScreenLoc;
	local LinearColor TeamColor;
	local Color TextColor;
	local UTWeapon Weap;

	// must be in visible and valid target for player to render HUD overlay
	if ( bHidden || !ValidTargetFor(PC) )
		return;

	// only render if player can destroy it (ask weapon)
	if ( PC.Pawn != None )
	{
		if ( UTVehicle(PC.Pawn) != None )
		{
			if ( UTVehicle(PC.Pawn).Driver != None )
			{
				Weap = UTWeapon(UTVehicle(PC.Pawn).Driver.Weapon);
			}
		}
		else
		{
			Weap = UTWeapon(PC.Pawn.Weapon);
		}
	}
	if ( (Weap == None) || !Weap.bCanDestroyBarricades )
	{
		return;
	}

	screenLoc = Canvas.Project(Location + GetHUDOffset(PC,Canvas));

	// make sure not clipped out
	if (screenLoc.X < 0 ||
		screenLoc.X >= Canvas.ClipX ||
		screenLoc.Y < 0 ||
		screenLoc.Y >= Canvas.ClipY)
	{
		return;
	}

	// must have been rendered
	if ( !LocalPlayer(PC.Player).GetActorVisibility(self) )
		return;

	// fade if close to crosshair
	if (screenLoc.X > 0.45*Canvas.ClipX &&
		screenLoc.X < 0.55*Canvas.ClipX &&
		screenLoc.Y > 0.45*Canvas.ClipY &&
		screenLoc.Y < 0.55*Canvas.ClipY)
	{
		TeamColor.A = FMax(FMin(1.0, FMax(0.0,Abs(screenLoc.X - 0.5*Canvas.ClipX) - 0.025*Canvas.ClipX)/(0.025*Canvas.ClipX)), FMin(1.0, FMax(0.0, Abs(screenLoc.Y - 0.5*Canvas.ClipY)-0.025*Canvas.ClipX)/(0.025*Canvas.ClipY)));
		if ( TeamColor.A == 0.0 )
		{
			return;
		}
	}

	// make sure not behind weapon
	if ( (Weap != None) && (UTPawn(PC.Pawn) != None) && Weap.CoversScreenSpace(screenLoc, Canvas) )
	{
		return;
	}
	else if ( (UTVehicle_Hoverboard(PC.Pawn) != None) && UTVehicle_Hoverboard(PC.Pawn).CoversScreenSpace(screenLoc, Canvas) )
	{
		return;
	}

	// pulse "key" objective
	BeaconPulseScale = (self == UTPlayerController(PC).LastAutoObjective) ? UTPlayerController(PC).BeaconPulseScale : 1.0;

	Canvas.StrLen(ObjectiveName, TextXL, YL);
	XL = FMax(TextXL * BeaconPulseScale, 0.05*Canvas.ClipX);
	YL *= BeaconPulseScale;

	class'UTHUD'.Static.GetTeamColor( 255, TeamColor, TextColor);
	class'UTHUD'.static.DrawBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-3*YL,1.4*XL,3.5*YL, TeamColor, Canvas);

	// draw node name
	Canvas.DrawColor = TextColor;
	Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y - 1.75*YL);
	Canvas.DrawTextClipped(ObjectiveName, true);
}

simulated function SetDestroyedTime()
{
	DestroyedTime = WorldInfo.TimeSeconds;
	bUnderAttack = true;
	SetTimer(4.0, false, 'ClearUnderAttack');
}

simulated function ClearUnderAttack()
{
	 bUnderAttack = false;
}

State DestroyableObjective
{
	event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		if (!WorldInfo.GRI.OnSameTeam(self, InstigatedBy))
		{
			if (class<UTDamageType>(DamageType) != None && class<UTDamageType>(DamageType).default.bDestroysBarricades)
			{
				TotalDamage += Damage;
				if (TotalDamage > 1000)
				{
					Global.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

					if (InstigatedBy != None && UTPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo) != None)
					{
						AddScorer(UTPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo), 1);
					}

					DisableObjective(InstigatedBy);
				}
			}
			else if (UTPlayerController(InstigatedBy) != None)
			{
				if (WorldInfo.TimeSeconds - LastDamageTime > 5.0)
				{
					FakeDamage = Damage;
				}
				else
				{
					FakeDamage += Damage;
					if (FakeDamage > 100)
					{
						WarnAboutBarricade(UTPlayerController(InstigatedBy));
						LastDamageTime = 0;
						FakeDamage = 0;
						return;
					}
				}
				LastDamageTime = WorldInfo.TimeSeconds;
			}
		}
	}

	function bool TellBotHowToDisable(UTBot B)
	{
		local UTWeapon Weapon;
		local class<UTWeapon> WeaponClass;
		local array<UTPickupFactory> FoundPickups;
		local UTPickupFactory Pickup;
		local Vehicle V;
		local bool bResult;

		Weapon = UTWeapon(B.Pawn.Weapon);
		if (Weapon != None && Weapon.bCanDestroyBarricades)
		{
			B.GoalString = "Destroy barricade" @ self;
			// temporarily remove bBlocked so bot can path to us
			bBlocked = false;
			bResult = Super.TellBotHowToDisable(B);
			bBlocked = true;
			return bResult;
		}
		else
		{
			// if bot already has barricade destroying weapon, head to objective
			V = Vehicle(B.Pawn);
			if (V != None && V.Driver != None)
			{
				Weapon = UTWeapon(V.Driver.Weapon);
				if (Weapon != None && Weapon.bCanDestroyBarricades)
				{
					if (V.bStationary || UTWeaponPawn(V) != None)
					{
						B.LeaveVehicle(true);
						B.NoVehicleGoal = self;
						return true;
					}
					else
					{
						B.GoalString = "Destroy barricade" @ self;
						// temporarily remove bBlocked so bot can path to us
						bBlocked = false;
						bResult = B.Squad.FindPathToObjective(B, self);
						bBlocked = true;
						if (!bResult)
						{
							// try leaving vehicle
							B.NoVehicleGoal = self;
							B.LeaveVehicle(true);
						}
						return true;
					}
				}
			}
			// look for pickupfactory with weapon that can destroy barricades
			foreach WorldInfo.AllNavigationPoints(class'UTPickupFactory', Pickup)
			{
				if (Pickup.ReadyToPickup(B.RespawnPredictionTime))
				{
					WeaponClass = class<UTWeapon>(Pickup.InventoryType);
					if (WeaponClass != None && WeaponClass.default.bCanDestroyBarricades)
					{
						if (B.Pawn.ValidAnchor() && !B.Pawn.Anchor.bFlyingPreferred && B.ActorReachable(Pickup))
						{
							B.GoalString = "Get weapon to destroy barricade" @ self;
							B.MoveTarget = Pickup;
							B.NoVehicleGoal = Pickup;
							if (Vehicle(B.Pawn) != None)
							{
								B.LeaveVehicle(true);
								return true;
							}
							else
							{
								return B.StartMoveToward(Pickup);
							}
						}
						FoundPickups.AddItem(Pickup);
					}
				}
			}

			if (FoundPickups.length > 0)
			{
				foreach FoundPickups(Pickup)
				{
					Pickup.bTransientEndPoint = true;
				}
				B.MoveTarget = B.FindPathToward(FoundPickups[0], true);
				if (B.MoveTarget != None)
				{
					B.GoalString = "Get weapon to destroy barricade" @ self;
					B.SetAttractionState();
					return true;
				}
			}

			return false;
		}
	}
}

function WarnAboutBarricade(UTPlayerController InstigatedBy)
{
	local float BestDist, NewDist;
	local UTPickupFactory BestPickup, Pickup;

	if ( WorldInfo.TimeSeconds - LastWarningTime < 1.0 )
	{
		return;
	}

	LastWarningTime = WorldInfo.TimeSeconds;
	InstigatedBy.ReceiveLocalizedMessage(class'UTWarfareBarricadeMessage', 0);
	InstigatedBy.ClientPlaySound(ShieldHitSound);
	if ( !UTPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).bHasFlag
		&& (UTPickupFactory(InstigatedBy.LastAutoObjective) == None) )
	{
		// look for super items
		BestPickup = None;
		ForEach WorldInfo.AllNavigationPoints(class'UTPickupFactory', Pickup)
		{
			if ( Pickup.ReadyToPickup(0) && (class<UTWeapon>(Pickup.InventoryType) != None)
				&& class<UTWeapon>(Pickup.InventoryType).default.bCanDestroyBarricades )
			{
				NewDist = VSize(Pickup.Location - InstigatedBy.Pawn.Location);
				if ( (BestPickup == None) || (NewDist < BestDist) )
				{
					BestPickup = Pickup;
					BestDist = NewDist;
				}
			}
		}
		if ( BestPickup != None )
		{
			InstigatedBy.SetAutoObjective(BestPickup, false);
		}
	}
}

function Reset()
{
	super.Reset();

	SetDisabled(false);
}

simulated function SetDisabled(bool bNewValue)
{
	local UTWarfareChildBarricade Next;

	bDisabled = bNewValue;

	if ( bDisabled )
	{
		// disable (collision and visibility) barricade and children
		Next = NextBarricade;
		while ( Next != None )
		{
			Next.DisableBarricade();
			Next = Next.NextBarricade;
		}
		SetCollision(false, false);
		SetHidden(true);
		CollisionComponent.SetBlockRigidBody(false);
		bBlocked = false;
	}
	else
	{
		// enable (collision and visibility) barricade and children
		Next = NextBarricade;
		while ( Next != None )
		{
			Next.EnableBarricade();
			Next = Next.NextBarricade;
		}
		SetCollision(true, true);
		SetHidden(false);
		CollisionComponent.SetBlockRigidBody(true);
		bBlocked = true;
	}
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollideActors=false
		BlockActors=false
	End Object

	// this will make it such that this can be statically lit
	bMovable=FALSE
	bNoDelete=true

	bProjTarget=true
	bCollideActors=true
	bBlockActors=true
	ObjectiveType=OBJ_Destroyable
	bTriggerOnceOnly=true
	bInitiallyActive=true
	bTeamControlled=false
	bMustCompleteToAttackNode=false
	bAttackableWhenNodeShielded=true
	DestroyedTime=-1000.0
	bMustTouchToReach=false
	bBlocked=true
	MaxBeaconDistance=4000.0
	IconHudTexture=None
}
