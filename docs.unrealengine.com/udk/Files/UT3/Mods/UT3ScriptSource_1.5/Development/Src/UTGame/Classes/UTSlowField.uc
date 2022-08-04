/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTSlowField extends UTTimedPowerup
	native
	abstract;

/** Ambient sound played while active*/
var SoundCue SlowFieldAmbientSound;
/** Sound indicating that the powerup is about to expire */
var SoundCue WarningSound;
/** Time dilation scaling applied to projectiles inside the area of effect */
var float ProjectileScalingFactor;
/** Slow field effect mesh */
var StaticMeshComponent SlowFieldMesh;
/** Camera emitter played on player using the powerup */
var class<UTEmitCameraEffect> InsideCameraEffect;
/** Indicates that the effects are on and attached to the owner pawn */
var repnotify bool bEffectsOn;
/** Replicated owner pawn, since the pickup owner does not replicate when we need it */
var UTPawn PawnOwner;
/** Desired scale of the slow field effect mesh */
var Vector DesiredScale;
/** Rate at which the slow field effect rotates */
var float YawRotationRate;

/** Projectiles that touched this slow field without an Instigator set
 *  The Instigator should be set on the following Tick
 */
var array<Projectile> ProjectilesToUpdate;

replication
{
	if ( bNetDirty )
		bEffectsOn, PawnOwner;
}



simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'bEffectsOn' || VarName == 'PawnOwner' )
	{
		ToggleSlowFieldEffects(bEffectsOn);
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function GivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	Super.GivenTo(NewOwner, bDoNotActivate);

	PawnOwner = UTPawn(NewOwner);
	if (PawnOwner != None)
	{
		PawnOwner.SetPawnAmbientSound(SlowFieldAmbientSound);
		PawnOwner.bHasSlowField = true;
		ToggleSlowFieldEffects(true);
	}
	SetLocation(NewOwner.Location);
	SetBase(NewOwner);
	SetCollision(true, false);

	// set timer for ending effects
	SetTimer(TimeRemaining - 3.0, false, 'PlaySlowFieldFadingEffects');
}

simulated event Destroyed()
{
	if (Role < ROLE_Authority)
	{
		SetCollision(false,false);
	}
	ToggleSlowFieldEffects(false);

	Super.Destroyed();
}

function ItemRemovedFromInvManager()
{
	local UTPlayerReplicationInfo UTPRI;
	local UTPawn P;

	P = UTPawn(Owner);
	if (P != None)
	{
		P.SetPawnAmbientSound(none);
		P.bHasSlowField = false;

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
	SetBase(None);
	SetCollision(false,false);
	ToggleSlowFieldEffects(false);
}

simulated function ToggleSlowFieldEffects(bool bEnabled)
{
	local MaterialInstanceConstant MIC;

	if ( PawnOwner != None )
	{
		bEffectsOn = bEnabled;
		MIC = SlowFieldMesh.CreateAndSetMaterialInstanceConstant(0);
		if ( PawnOwner.Controller != None && PawnOwner.Controller.IsLocalPlayerController() )
		{
			MIC.SetScalarParameterValue('Opacity', 0.1);
		}
		else
		{
			MIC.SetScalarParameterValue('Opacity', 1.0);
		}

		if ( bEnabled )
		{
			DesiredScale = Vect(2.1, 2.1, 1.8);
			PawnOwner.AttachComponent(SlowFieldMesh);
		}
		else
		{
			DesiredScale = Vect(0.117, 0.117, 0.1);
			PawnOwner.DetachComponent(SlowFieldMesh);
		}
	}
}

simulated function PlaySlowFieldFadingEffects()
{
	// reset timer if time got added
	if (TimeRemaining > 3.0)
	{
		SetTimer(TimeRemaining - 3.0, false, 'PlaySlowFieldFadingEffects');
	}
	else
	{
		if (TimeRemaining <= 1.0)
		{
			DesiredScale = Vect(0.117, 0.117, 0.1);
		}
		Instigator.PlaySound(WarningSound);
		SetTimer(1.0, false, 'PlaySlowFieldFadingEffects');
	}
}

simulated function UpdateTouchingProjectiles()
{
	local Projectile Proj;
	foreach ProjectilesToUpdate(Proj)
	{
		if ( Proj.Instigator != Instigator )
		{
			Proj.CustomTimeDilation = ProjectileScalingFactor;
		}
	}
	ProjectilesToUpdate.length = 0;
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if ( Projectile(Other) != None )
	{
		if ( Other.Instigator == None )
		{
			ProjectilesToUpdate[ProjectilesToUpdate.length] = Projectile(Other);
			SetTimer(0.01, false, 'UpdateTouchingProjectiles');
			
		}
		else if ( Other.Instigator != Instigator )
		{
			Other.CustomTimeDilation = ProjectileScalingFactor;
		}
	}
}

simulated event UnTouch( Actor Other )
{
	if ( (Projectile(Other) != None) && (UTSlowVolume(Other.PhysicsVolume) == None) )
	{
		Other.CustomTimeDilation = Other.Default.CustomTimeDilation;
	}
}

simulated function bool StopsProjectile(Projectile P)
{
	return false;
}

defaultproperties
{
	PowerupStatName=POWERUPTIME_SLOWFIELD
	ProjectileScalingFactor=0.125

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=+00280.000000
		CollisionHeight=+00200.000000
		CollideActors=true
		BlockNonZeroExtent=true
		BlockZeroExtent=true
	End Object
	Components.Add(CollisionCylinder)

	DesiredScale=(X=2.1,Y=2.1,Z=1.8)
	YawRotationRate=2000

	RemoteRole=ROLE_SimulatedProxy
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bIgnoreEncroachers=true
	bHardAttach=true
	bReplicateMovement=true
	bOnlyRelevantToOwner=false
	bProjTarget=true

	TimeRemaining=60.0
}
