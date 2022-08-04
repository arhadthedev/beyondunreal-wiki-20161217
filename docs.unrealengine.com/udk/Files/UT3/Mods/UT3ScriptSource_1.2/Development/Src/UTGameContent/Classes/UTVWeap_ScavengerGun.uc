/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_ScavengerGun extends UTVehicleWeapon
	HideDropDown;

var Actor LastCurrentTarget;

var Texture2D CrossHairTexture;
var ParticleSystem TracerTemplate;
var ParticleSystemComponent Tracer;
var UTVehicle_Scavenger MyScavenger;

/** Orb fires beam- non looping sound of initial fire */
var SoundCue 		BeginFireSound;

/** Orb fires beam- looping sound orb�s laser locked on enemy target*/
var SoundCue 		FireAmbLoop;
var AudioComponent 	WeaponAmbientSound;

/** Orb stops beam- ending fire beam sound when loop stops */
var SoundCue 		EndFireSound;

/** angle for locking for lock targets */
var float 		LockAim;

/** angle for locking for lock targets when on Console */
var float 		ConsoleLockAim;

/** Targeting icon appears and quickly zooms to the target */
var SoundCue 	LockOnSound;

/** Projectile class for the blue scavenger bolt **/
var class<Projectile> BlueBoltClass;

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'MyVehicle')
	{
		MyScavenger = UTVehicle_Scavenger(MyVehicle);
	}

	Super.ReplicatedEvent(VarName);
}

simulated function ActiveRenderOverlays( HUD H )
{
	if ( MyScavenger == None )
	{
		MyScavenger = UTVehicle_Scavenger(MyVehicle);
		if ( MyScavenger == None )
		{
			return;
		}
	}
	if ( MyScavenger.BallStatus.bIsInBallMode )
	{
		return;
	}
	super.ActiveRenderOverlays(H);
	if ( (MyScavenger.ActiveSeeker != None) && (MyScavenger.ActiveSeeker.TargetActor != none) )
	{
		DrawLockedOn(H);
		if (LockOnSound != none && MyScavenger.ActiveSeeker.TargetActor != LastCurrentTarget)
		{
			WeaponPlaySound(LockOnSound);
		}
	}
	else
	{
		bWasLocked = false;
	}

	LastCurrentTarget = (MyScavenger.ActiveSeeker != None) ? MyScavenger.ActiveSeeker.TargetActor : None;
}

simulated function CustomFire()
{
	local Actor HitActor;
	local vector StartTrace, HitLocation, HitNormal;
	local rotator AimRot;
	local float MinDot;

	if (MyScavenger != None)
	{
		if (Role == ROLE_Authority && (MyScavenger.ActiveSeeker == None || MyScavenger.ActiveSeeker.bDeleteMe))
		{
			MyScavenger.ActiveSeeker = UTProj_ScavengerBolt(ProjectileFire());
		}
		if (MyScavenger.ActiveSeeker != None && !MyScavenger.ActiveSeeker.bDeleteMe && MyScavenger.ActiveSeeker.FullySpawned())
		{
			if (MyScavenger.ActiveSeeker.TargetActor != None && MyScavenger.Controller != None)
			{
				MyScavenger.Controller.GetPlayerViewPoint( StartTrace, AimRot );
				// check if can refresh target as still valid
				MinDot = (UTConsolePlayerController(MyScavenger.Controller) != None) ? ConsoleLockAim : LockAim;
				if ( (Normal(MyScavenger.ActiveSeeker.TargetActor.Location - StartTrace) dot vector(AimRot)) > MinDot )
				{
					StartTrace = MyVehicle.GetPhysicalFireStartLoc(self);
					HitActor = MyScavenger.Trace(HitLocation, HitNormal, MyScavenger.ActiveSeeker.TargetActor.Location, StartTrace, true,,, TRACEFLAG_Bullet);
					if (HitActor == None || HitActor == MyScavenger.ActiveSeeker.TargetActor)
					{
						if (Role == ROLE_Authority)
						{
							MyScavenger.ActiveSeeker.SetTargetActor(MyScavenger.ActiveSeeker.TargetActor);
						}
						SpawnTracer(StartTrace, MyScavenger.ActiveSeeker.TargetActor.Location);
						return;
					}
				}
			}
			InstantFire();
		}
	}
}

simulated function SpawnTracer(vector EffectLocation, vector HitLocation)
{
	if (WorldInfo.NetMode != NM_DedicatedServer && MyScavenger != None)
	{
		if (Tracer == None)
		{
			Tracer = new(self) class'ParticleSystemComponent';
			Tracer.SetTemplate(TracerTemplate);
		}

		Tracer.SetVectorParameter('BeamEnd', HitLocation);

		if (!Tracer.bAttached)
		{
			MyScavenger.AttachComponent(Tracer);
			//Play some sound associated with this
			StartTracerSounds();
		}
	}
}

simulated function StartTracerSounds()
{
	if (BeginFireSound != none)
	{
		WeaponPlaySound(BeginFireSound);
	}

	if (WeaponAmbientSound.SoundCue != None)
	{
		WeaponAmbientSound.FadeIn(0.2f,1.0f);
	}
}

simulated function StopTracerSounds()
{
    if (EndFireSound != none)
	{
		WeaponPlaySound(EndFireSound);
	}

	if (WeaponAmbientSound.SoundCue != None)
	{
		WeaponAmbientSound.FadeOut(0.2f,0.0f);
	}
}

simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact )
{
	SpawnTracer( Instigator.Location, Impact.HitLocation);
	if ( MyScavenger != None )
	{
		MyScavenger.ActiveSeeker.SetTargetActor(Impact.HitActor);
	}
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (Tracer != None && Tracer.bAttached && MyScavenger != None)
	{
		MyScavenger.DetachComponent(Tracer);
		StopTracerSounds();
	}
}

simulated state WeaponFiring
{
	simulated event EndState(name NextStateName)
	{
		Super.EndState(NextStateName);

		if (Tracer != None && Tracer.bAttached && MyScavenger != None)
		{
			MyScavenger.DetachComponent(Tracer);
			StopTracerSounds();
		}
	}
}

/**
 *
 */
function class<Projectile> GetProjectileClass()
{
	if ( (Instigator != None) && (Instigator.GetTeamNum() == 1) )
	{
		return BlueBoltClass;
	}
	return WeaponProjectiles[CurrentFireMode];
}



defaultproperties
{
	ConsoleLockAim=0.9
	LockAim=0.93
	bLeadTarget=false
	bFastRepeater=true

	FireInterval(0)=+0.2
	ShotCost(0)=0
	ShotCost(1)=0
	FireTriggerTags=(MantaWeapon01,MantaWeapon02)

	bIgnoreSocketPitchRotation=true
	WeaponFireTypes(0)=EWFT_Custom
	WeaponProjectiles(0)=class'UTProj_ScavengerBolt'
	//WeaponFireSnd[0]=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Fire_Cue'
	LockOnSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_TargetLock_Cue'

	//Weapon firing ambient sound
	Begin Object Class=AudioComponent name=WeaponAmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		SoundCue=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_OrbFireLoop_Cue'
		bStopWhenOwnerDestroyed=true
	End Object
	WeaponAmbientSound=WeaponAmbientSoundComponent
	Components.Add(WeaponAmbientSoundComponent)

	BeginFireSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_OrbFireStart_Cue'
	EndFireSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_OrbFireStop_Cue'

	WeaponFireTypes(1)=EWFT_None
	BlueBoltClass=class'UTProj_ScavengerBoltBlue'

	// ~15 degrees - since this vehicle's gun doesn't move by itself, we give some more leeway
	MaxFinalAimAdjustment=0.966

	CrossHairTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseA'
	TracerTemplate=ParticleSystem'WP_AVRiL.Particles.P_WP_AVRiL_TargetBeam'
	VehicleClass=class'UTVehicle_Scavenger_Content'
}

