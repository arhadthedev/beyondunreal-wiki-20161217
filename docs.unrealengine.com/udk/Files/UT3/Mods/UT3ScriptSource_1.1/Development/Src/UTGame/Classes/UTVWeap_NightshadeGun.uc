/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_NightshadeGun extends UTVehicleWeapon
	abstract
	hidedropdown
	native(Vehicle);

struct native DeployableData
{
	/** Class of the actors that can be deployed (team specific)*/
	var class<UTDeployable> DeployableClass;

	/** The Maximum number of deployables available to drop.  Limited to 15 */
	var byte MaxCnt;

	/** How far away from the vehicle should it be dropped */
	var vector DropOffset;

	var array<Actor> Queue;
};

const NUMDEPLOYABLETYPES=4;

var DeployableData DeployableList[NUMDEPLOYABLETYPES];

var bool	bShowDeployableName;

var int Counts[NUMDEPLOYABLETYPES];

var int DeployableIndex;

/** The sound to play when alt-fire mode is changed */
var SoundCue AltFireModeChangeSound;

/** Holds the Pawn that this weapon is linked to. */
var Actor LinkedTo;

/** Holds the component we hit on the linked pawn, for determining the linked beam endpoint on multi-component actors (such as Onslaught powernodes) */
var PrimitiveComponent LinkedComponent;

/** Holds the Actor currently being hit by the beam */
var Actor	Victim;

/** Holds the current strength (in #s) of the link */
var int		LinkStrength;

/** Holds the amount of flexibility of the link beam */
var float 	LinkFlexibility;

/** Holds the amount of time to maintain the link before breaking it.  This is important so that you can pass through
    small objects without having to worry about regaining the link */
var float 	LinkBreakDelay;

/** Momentum transfer for link beam (per second) */
var float	MomentumTransfer;

/** This is a time used with LinkBrekaDelay above */
var float	ReaccquireTimer;

/** true if beam currently hitting target */
var bool	bBeamHit;

/** saved partial damage (in case of high frame rate */
var float	SavedDamage;
/** minimum SavedDamage before we actually apply it
 * (needs to be large enough to counter any scaling factors that might reduce to below 1)
 */
var float MinimumDamage;

/** Holds the text UV's for each icon */
var UIRoot.TextureCoordinates IconCoords[NUMDEPLOYABLETYPES];

/** Sound to play when an item is deployed*/
var SoundCue DeployedItemSound;

var MaterialImpactEffect VehicleHitEffect;

replication
{
	if (Role == ROLE_Authority)
		LinkedTo,DeployableIndex;
	if ( bNetOwner && (Role == ROLE_Authority) )
		Counts;
}

simulated function FireAmmunition()
{
	local UTStealthVehicle SV;

	SV = UTStealthVehicle(MyVehicle);

	if( SV != none )
	{
		//If I'm deployed, deploy an item
		if ( SV.DeployedState == EDS_Deployed )
		{
			CustomFire();
			return;
		}
		else if ( SV.DeployedState == EDS_Deploying || SV.DeployedState == EDS_Undeploying)
		{
		    //I'm in the middle of deploying, just return
			return;
		}
	}

	//Just fire ammunition normally
	super.FireAmmunition();
}

/**
 * This function looks at who/what the beam is touching and deals with it accordingly.  bInfoOnly
 * is true when this function is called from a Tick.  It causes the link portion to execute, but no
 * damage/health is dealt out.
 */
simulated function UpdateBeam(float DeltaTime)
{
	local Vector		StartTrace, EndTrace;
	local ImpactInfo	TestImpact;

	// define range to use for CalcWeaponFire()
	StartTrace	= InstantFireStartTrace();
	EndTrace	= InstantFireEndTrace(StartTrace);

	// Trace a shot
	TestImpact = CalcWeaponFire( StartTrace, EndTrace );

	// Allow children to process the hit
	ProcessBeamHit(StartTrace, vect(0,0,0), TestImpact, DeltaTime);
}

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	for ( i=0; i<NUMDEPLOYABLETYPES; i++ )
	{
		Counts[i] = DeployableList[i].MaxCnt;
	}
}

/**
 * Process the hit info
 */
simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo TestImpact, float DeltaTime)
{
	local float DamageAmount;
	local vector PushForce, ShotDir, SideDir;

	Victim = TestImpact.HitActor;

	// If we are on the server, attempt to setup the link
	if (Role==ROLE_Authority)
	{
		// Try linking
		AttemptLinkTo(Victim, TestImpact.HitInfo.HitComponent);

		// set the correct firemode on the pawn, since it will change when linked
		SetCurrentFireMode(CurrentFireMode);

		// cause damage or add health/power/etc.
		bBeamHit = false;

		SavedDamage += InstantHitDamage[0] * DeltaTime;
		DamageAmount = int(SavedDamage);
		if (DamageAmount >= MinimumDamage)
		{
			SavedDamage -= DamageAmount;
			if ( LinkedTo != None )
			{
				// heal them if linked
				// linked players will use ammo when they fire
				if ( LinkedTo.IsA('UTVehicle') || LinkedTo.IsA('UTGameObjective') )
				{
					// use ammo only if we actually healed some damage
					LinkedTo.HealDamage(1.5*DamageAmount * Instigator.GetDamageScaling(), Instigator.Controller, InstantHitDamageTypes[0]);
				}
			}
			else
			{
				if (Victim != None && !WorldInfo.Game.GameReplicationInfo.OnSameTeam(Victim, Instigator))
				{
					bBeamHit = !Victim.bWorldGeometry;
					if ( DamageAmount > 0 )
					{
						ShotDir = Normal(TestImpact.HitLocation - Location);
						SideDir = Normal(ShotDir Cross vect(0,0,1));
						PushForce =  vect(0,0,1) + Normal(SideDir * (SideDir dot (TestImpact.HitLocation - Victim.Location)));
						PushForce *= (Victim.Physics == PHYS_Walking) ? 0.1*MomentumTransfer : DeltaTime*MomentumTransfer;
						Victim.TakeDamage(DamageAmount, Instigator.Controller, TestImpact.HitLocation, PushForce, InstantHitDamageTypes[0], TestImpact.HitInfo, self);
					}
				}
			}
		}
	}
	else
	{
		// set the correct firemode on the pawn, since it will change when linked
		SetCurrentFireMode(CurrentFireMode);
	}

	// if we do not have a link, set the flash location to whatever we hit
	// (if we do have one, AttemptLinkTo() will set the correct flash location for the Actor we're linked to)
	if (LinkedTo == None)
	{
		SetFlashLocation( TestImpact.HitLocation );
	}
}

/**
 * Returns a vector that specifics the point of linking.
 */
simulated function vector GetLinkedToLocation()
{
	if (LinkedTo == None)
	{
		return vect(0,0,0);
	}
	else if (Pawn(LinkedTo) != None)
	{
		return LinkedTo.Location + Pawn(LinkedTo).BaseEyeHeight * vect(0,0,0.5);
	}
	else if (LinkedComponent != None)
	{
		return LinkedComponent.GetPosition();
	}
	else
	{
		return LinkedTo.Location;
	}
}

/**
 * This function looks at how the beam is hitting and determines if this person is linkable
 */
function AttemptLinkTo(Actor Who, PrimitiveComponent HitComponent)
{
	local UTVehicle UTV;
	local UTOnslaughtObjective UTO;
	local Vector 		StartTrace, EndTrace, V, HitLocation, HitNormal;
	local Actor			HitActor;

	// redirect to vehicle if owned by a vehicle and the vehicle allows it
	if( Who != none )
	{
		UTV = UTVehicle(Who.Owner);
		if (UTV != None && UTV.AllowLinkThroughOwnedActor(Who))
		{
			Who = UTV;
		}
	}

	// Check for linking to pawns
	UTV = UTVehicle(Who);
	if (UTV != None && UTV.bValidLinkTarget)
	{
		// Check teams to make sure they are on the same side
		if (WorldInfo.Game.GameReplicationInfo.OnSameTeam(Who,Instigator))
		{
			LinkedComponent = HitComponent;
			if ( LinkedTo != UTV )
			{
				UnLink();
				LinkedTo = UTV;
				UTV.IncrementLinkedToCount();
			}
		}
		else
		{
			// Enemy got in the way, break any links
			UnLink();
		}
	}
	else
	{
		UTO = UTOnslaughtObjective(Who);
		if ( UTO != none )
		{
			if ( (UTO.LinkHealMult > 0) && WorldInfo.Game.GameReplicationInfo.OnSameTeam(UTO,Instigator) )
			{
				LinkedTo = UTO;
				LinkedComponent = HitComponent;
			}
			else
			{
				UnLink();
			}
		}
		else
		{
			UnLink();
		}
	}

	if (LinkedTo != None)
	{
		// Determine if the link has been broken for another reason

		if (LinkedTo.bDeleteMe || (Pawn(LinkedTo) != None && Pawn(LinkedTo).Health <= 0))
		{
			UnLink();
			return;
		}

		// if we were passed in LinkedTo, we know we hit it straight on already, so skip the rest
		if (LinkedTo != Who)
		{
			StartTrace = Instigator.GetWeaponStartTraceLocation();
			EndTrace = GetLinkedtoLocation();

			// First, check to see if we have skewed too much, or if the LinkedTo pawn has died and
			// we didn't get cleaned up.
			V = Normal(EndTrace - StartTrace);
			if ( V dot vector(Instigator.GetViewRotation()) < LinkFlexibility || VSize(EndTrace - StartTrace) > 1.5 * WeaponRange )
			{
				UnLink();
				return;
			}

			//  If something is blocking us and the actor, drop the link
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
			if (HitActor != none && HitActor != LinkedTo)
			{
				UnLink(true);		// In this case, use a delayed UnLink
			}
		}
	}

	// if we are linked, make sure the proper flash location is set
	if (LinkedTo != None)
	{
		SetFlashLocation(GetLinkedtoLocation());
	}
}

/**
 * Unlink this weapon from it's parent.  If bDelayed is true, it will give a
 * short delay before unlinking to allow the player to re-establish the link
 */
function UnLink(optional bool bDelayed)
{
	local UTVehicle V;

	if (!bDelayed)
	{
		V = UTVehicle(LinkedTo);
		if(V != none)
		{
			V.DecrementLinkedToCount();
		}
		LinkedTo = None;
		LinkedComponent = None;
	}
	else if (ReaccquireTimer <= 0)
	{
		// Set the Delay timer
		ReaccquireTimer = LinkBreakDelay;
	}
}
/* ********************************************************** */

simulated function CustomFire()
{
	local vector DepLoc;
	local rotator DepRot;
    local UTVehicle_Deployable DeployableVehicle;
	local bool bIsDeployableNearby;

	if ( Role == ROLE_Authority &&
			MyVehicle.Mesh.GetSocketWorldLocationAndRotation('DeployableDrop',DepLoc,DepRot) )
	{
	DeployableVehicle = UTVehicle_Deployable(MyVehicle);
		if(DeployableVehicle == none || DeployableVehicle.IsDeployed() )
		{
			//If there are any deployables in the vicinity, exit
			bIsDeployableNearby = class'UTDeployable'.static.DeployablesNearby(DeployableVehicle, DepLoc, class'UTDeployable'.default.DeployCheckRadiusSq);
			if (bIsDeployableNearby)
			{
				DeployableVehicle.ReceiveLocalizedMessage(class'UTStealthVehicleMessage', 2);
				return;
			}

		    if (Counts[DeployableIndex] != 0 )
			{
				DeployItem();
			}
		}
		else if ( DeployableVehicle.IsLocallyControlled() )
		{
			DeployableVehicle.ServerToggleDeploy();
		}
	}
	//EndFire(0);
}

/**
 * Send weapon to proper firing state
 * Also sets the CurrentFireMode.
 * Network: LocalPlayer and Server
 *
 * @param	FireModeNum Fire Mode.
 */
simulated function SendToFiringState(byte FireModeNum)
{
	local UTStealthVehicle SV;

	SV = UTStealthVehicle(MyVehicle);

	if( SV != none )
	{
		if ( SV.DeployedState == EDS_Deployed )
		{
			FireModeNum = 1;
		}
	}
	super.SendToFiringState(FireModeNum);
}

simulated function bool SelectWeapon(int WeaponNumber)
{
	if(WeaponNumber < NUMDEPLOYABLETYPES)
	{
		if ( Counts[WeaponNumber] <= 0 )
		{
			return false;
		}
		bShowDeployableName = true;
		DeployableIndex = WeaponNumber;
		if ( Instigator.IsLocallyControlled() )
		{
			WeaponPlaySound(AltFireModeChangeSound);
		}
		return true;
	}
	return false;
}

/**
  * Returns index of next available deployable
  */
simulated function bool NextAvailableDeployableIndex(int Direction, out int ResultIndex)
{
	local int TestCount, TempResult;

	TempResult = DeployableIndex + Direction;
	while ( (TempResult != DeployableIndex) && (TestCount < NUMDEPLOYABLETYPES) )
	{
		if ( TempResult >= NUMDEPLOYABLETYPES )
		{
			TempResult = 0;
		}
		else if ( TempResult < 0 )
		{
			TempResult = NUMDEPLOYABLETYPES - 1;
		}

		if ( Counts[TempResult] > 0 )
		{
			ResultIndex = TempResult;
			return TRUE;
		}
		TempResult += Direction;
		TestCount++;
	}

	//No other ammo exists, do we still have any where we were?
	ResultIndex = DeployableIndex;
	if ( Counts[ResultIndex] > 0 )
	{
		return TRUE;
	}

	return FALSE;
}

function byte BestMode()
{
	local UTBot B;
	local int SelectedDeployable;

	// choose deployable here
	B = UTBot(Instigator.Controller);
	if (B != None && B.IsDefending())
	{
		// spider mines or energy shield
		SelectedDeployable = (FRand() < 0.5) ? 0 : 3;
	}
	else
	{
		SelectedDeployable = Rand(NUMDEPLOYABLETYPES);
	}
	SelectWeapon(SelectedDeployable);

	return 0;
}

function bool CanHeal(Actor Other)
{
	if (!HasAmmo(0))
	{
		return false;
	}
	else if (UTGameObjective(Other) != None)
	{
		return UTGameObjective(Other).TeamLink(Instigator.GetTeamNum());
	}
	else
	{
		return (UTVehicle(Other) != None && UTVehicle(Other).LinkHealMult > 0.f);
	}
}

/*********************************************************************************************
 * State WeaponFiring
 * See UTWeapon.WeaponFiring
 *********************************************************************************************/

simulated state WeaponBeamFiring
{
	/**
	 * In this weapon, RefireCheckTimer consumes ammo and deals out health/damage.  It's not
	 * concerned with the effects.  They are handled in the tick()
	 */
	simulated function RefireCheckTimer()
	{
		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			return;
		}

		// Otherwise we're done firing, so go back to active state.
		GotoState('Active');
	}

	/**
	 * Update the beam and handle the effects
	 */
	simulated function Tick(float DeltaTime)
	{
		// If we are in danger of losing the link, check to see if
		// time has run out.
		if ( ReaccquireTimer > 0 )
		{
	    		ReaccquireTimer -= DeltaTime;
	    		if (ReaccquireTimer <= 0)
	    		{
		    		ReaccquireTimer = 0.0;
		    		UnLink();
		    	}
		}

		// Retrace everything and see if there is a new LinkedTo or if something has changed.
		UpdateBeam(DeltaTime);
	}

	simulated function int GetAdjustedFireMode()
	{
		// on the pawn, set a value of 2 if we're linked so the weapon attachment knows the difference
		if (LinkedTo != None)
		{
			return 2;
		}
		else
		{
			return CurrentFireMode;
		}
	}

	simulated function SetCurrentFireMode(byte FiringModeNum)
	{
		CurrentFireMode = FiringModeNum;
		if (Instigator != None)
		{
			Instigator.SetFiringMode(GetAdjustedFireMode());
		}
	}

	function SetFlashLocation(vector HitLocation)
	{
		local byte RealFireMode;

		RealFireMode = CurrentFireMode;
		CurrentFireMode = GetAdjustedFireMode();
		Global.SetFlashLocation(HitLocation);
		CurrentFireMode = RealFireMode;
	}

	simulated function BeginState( Name PreviousStateName )
	{
		// Fire the first shot right away
		RefireCheckTimer();
		TimeWeaponFiring( CurrentFireMode );
	}

	/**
	 * When leaving the state, shut everything down
	 */

	simulated function EndState(Name NextStateName)
	{
		ClearTimer('RefireCheckTimer');
		ClearFlashLocation();

		ReaccquireTimer = 0.0;
		UnLink();
		Victim = None;

		super.EndState(NextStateName);
	}

	simulated function bool IsFiring()
	{
		return true;
	}

	/**
	 * When done firing, we have to make sure we unlink the weapon.
	 */
	simulated function EndFire(byte FireModeNum)
	{
		UnLink();
		Global.EndFire(FireModeNum);
	}
}

simulated function float GetFireInterval( byte FireModeNum )
{
	if (FireModeNum==1)
	{
		return 0.75;
	}
	else
	{
		return Super.GetFireInterval(FireModeNum);
	}
}

simulated static function MaterialImpactEffect GetImpactEffect(Actor HitActor, PhysicalMaterial HitMaterial, byte FireModeNum)
{
	return (FireModeNum == 0 && HitActor != None) ? default.VehicleHitEffect : Super.GetImpactEffect(HitActor, HitMaterial, FireModeNum);
}

/** Adjust the amount of ammo available for the deployable 'ammo' by the modification value */
function ChangeDeployableCount(int InDeployableIndex, int modification)
{
	Counts[InDeployableIndex] = Min(Max(0,Counts[InDeployableIndex]+Modification), DeployableList[InDeployableIndex].MaxCnt);
}

/** Return the amount of deployable 'ammo' available */
simulated function byte GetDeployableCount(int InDeployableIndex)
{
	return Counts[InDeployableIndex];
}
/**
 * This function checks to see if the weapon has any ammo available for a given fire mode.
 *
 * @param	FireModeNum		- The Fire Mode to Test For
 * @param	Amount			- [Optional] Check to see if this amount is available.  If 0 it will default to checking
 *							  for the ShotCost
 */
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
    local int i, Count;
    local UTStealthVehicle SV;
    local bool bHaveAmmo;

    bHaveAmmo = FALSE;

	//Check if we are deployed (duplicate of code in SendToFiringState)
	SV = UTStealthVehicle(MyVehicle);
	if( SV != none && SV.DeployedState == EDS_Deployed)
	{
		FireModeNum = 1;
	}

	if (FireModeNum == 0)
	{
		bHaveAmmo = TRUE;
	}
	else if (FireModeNum == 1)
	{
	    for (i=0; i<NUMDEPLOYABLETYPES; i++)
	    {
			Count = GetDeployableCount(i);
	    	if (Count > 0)
	    	{
	    		if (Count >= Amount)
	    		{
	    			bHaveAmmo = TRUE;
	    		}
	    		else
	    		{
	    			bHaveAmmo = FALSE;
	    		}
	    	}
	    }
	}

	return bHaveAmmo;
}

simulated function string GetHumanReadableName()
{
	if ( bShowDeployableName )
		return DeployableList[DeployableIndex].DeployableClass.Default.ItemName;
	else
		return ItemName;
}

function DeployItem()
{
	local vector DepLoc, DesiredDropLoc;
	local vector TraceDropStart;
	local rotator DepRot;
	local class<Actor> SpawnClass;
	local actor Deployable;
	local UTStealthVehicle StealthVehicle;
	local vector HitLocation,HitNormal;

    StealthVehicle = UTStealthVehicle(MyVehicle);
	bShowDeployableName = true;
	MyVehicle.Mesh.GetSocketWorldLocationAndRotation('DeployableDrop',DepLoc,DepRot);
	DesiredDropLoc = DepLoc + ( DeployableList[DeployableIndex].DropOffset >> DepRot );

	//Make sure the actual drop location is above ground
	TraceDropStart = DesiredDropLoc;
	TraceDropStart.Z += 100.0f;
	if (Trace(HitLocation, HitNormal, DesiredDropLoc, TraceDropStart, FALSE) != None)
	{
	//Place the object just slightly above the hit point
		DesiredDropLoc = HitLocation + HitNormal*vect(0.1,0.1,0.1);
	}

	SpawnClass = DeployableList[DeployableIndex].DeployableClass.static.GetTeamDeployable(MyVehicle.GetTeamNum());

    //Offset the drop by any negative translation stored in the collision Z (Energy Shield fix)
    DesiredDropLoc.Z -= Min(0, SpawnClass.Default.CollisionComponent.Translation.Z);

	DepRot.Pitch = 0;
	DepRot.Roll = 0;
	Deployable = Spawn( SpawnClass, instigator,, DesiredDropLoc, DepRot );
	if ( Deployable != none )
	{
		WeaponPlaySound(DeployedItemSound);
		ChangeDeployableCount(DeployableIndex,-1);
		if ( UTSlowVolume(Deployable) != none )
		{
			UTSlowVolume(Deployable).OnDeployableUsedUp = DeployableUsedUp;
		}
		else if ( UTDeployedActor(Deployable) != none )
		{
			UTDeployedActor(Deployable).OnDeployableUsedUp = DeployableUsedUp;
		}

		DeployableList[DeployableIndex].Queue[DeployableList[DeployableIndex].Queue.Length] = Deployable;

		if ( Counts[DeployableIndex] == 0 )
		{
			//Find another deployable
			if (NextAvailableDeployableIndex(1, DeployableIndex) == FALSE)
			{
				//Can't find a nonzero quantity
			}
		}
		if (UTVehicle_Deployable(MyVehicle) != none)
		{
			if(StealthVehicle != none)
			{
				//Hide the deployable (and tell clients)
				StealthVehicle.SetDeployMeshHidden(TRUE);
		//This will play the release animation and setup the undeploy
			    StealthVehicle.PlayReleaseAnim();
			}
	    else
	    {
		UTVehicle_Deployable(MyVehicle).ServerToggleDeploy(); // undeploy!
	    }
		}
	}
}

function DeployableUsedUp(Actor ChildDeployable)
{
	local bool bHadNoAmmo;
	local int DepIndex,i;

	//When the active deployable is used up, add it back to the vehicles inventory?
	for ( DepIndex=0; DepIndex<NUMDEPLOYABLETYPES; DepIndex++ )
	{
		for (i=0;i<DeployableList[DepIndex].Queue.Length;i++)
		{
			if ( DeployableList[DepIndex].Queue[i] == ChildDeployable )
			{
				bHadNoAmmo = !HasAmmo(1);

				DeployableList[DepIndex].Queue.Remove(i,1);
				ChangeDeployableCount(DepIndex,+1);

				if (bHadNoAmmo)
				{
					//If we previously had no ammo, update the weapon bar
					NextAvailableDeployableIndex(1, DeployableIndex);
				}
				return;
			}
		}
	}
}

//Only show the crosshair in the undeployed state
simulated function DrawWeaponCrosshair( Hud HUD )
{
	local UTVehicle_Deployable DV;

	DV = UTVehicle_Deployable(MyVehicle);
	if( (DV == None) || (DV.DeployedState == EDS_Undeployed) )
	{
		super.DrawWeaponCrosshair(HUD);
	}
}

simulated event Destroyed()
{
	local int DepIndex, i;
	local float NewLifeSpan;

	if (Role == ROLE_Authority)
	{
		// destroy deployables around when vehicle would respawn so that they don't accumulate
		// if the vehicle doesn't last as long as the deployables it drops
		NewLifeSpan = (MyVehicle != None) ? FMax(1.0, MyVehicle.RespawnTime) : 1.0;
		for (DepIndex = 0; DepIndex < NUMDEPLOYABLETYPES; DepIndex++)
		{
			for (i = 0; i < DeployableList[DepIndex].Queue.Length; i++)
			{
				if (DeployableList[DepIndex].Queue[i] != None)
				{
					DeployableList[DepIndex].Queue[i].LifeSpan = NewLifeSpan;
				}
			}
		}
	}

	Super.Destroyed();
}

defaultproperties
{
	FireInterval(0)=+0.16
	FireInterval(1)=+1.5
	FiringStatesArray(0)=WeaponBeamFiring
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_Custom
	InstantHitDamage(0)=120

	AIRating=+0.71
	CurrentRating=+0.71
	bInstantHit=true
	ShouldFireOnRelease(0)=0
	InventoryGroup=5
	GroupWeight=0.5

	WeaponRange=900
	MomentumTransfer=50000.0
	MinimumDamage=5.0
}
