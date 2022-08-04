/**
 * GameBreakableActor
 *
 * Currently does not yet support replication.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class GameBreakableActor extends KActor
	config(Game)
	native
	placeable;

/** Types of damage that are counted */
var() array<class<DamageType> > DamageTypes;

struct native BreakableStep
{
	struct native BreakableParticleSystem
	{
		/** Particle system to spawn. */
		var() ParticleSystem  Emitter;

		/** Offset relative to the breakable actor to attach the particle system. */
		var() vector          Offset;
	};

	/** Total amount of damage to take before activating the event */
	var() float                          DamageThreshold;

	/** Emitter system to use when this object breaks */
	var() array<BreakableParticleSystem> ParticleEmitters;

	/** KActor template to use when this object breaks */
	var() StaticMesh                     BreakMesh;

	/** The physics mode to switch to. */
	var() EPhysics                       Physics;

	/** Sound to play. */
	var() SoundCue                       BreakSound;

	structdefaultproperties
	{
		DamageThreshold = 0.0
		Physics = PHYS_RigidBody
	}
};

/** sequence of events of destruction... starts at 0. */
var() array<BreakableStep> BreakableSteps;

/** current breakable step. */
var int CurrentBreakableStep;

/**�Particles lighting */
var() LightingChannelContainer	ParticleLightingChannels;
var() bool						bParticlesAcceptLights;
var() bool						bParticlesAcceptDynamicLights;

native function vector GetOffsetToWorld(vector Offset);
native function        SetParticlesLighting(Emitter Emit);

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (IsValidDamageType(DamageType))
	{
		if (CurrentBreakableStep == BreakableSteps.Length - 1)
		{
			TakeLastDamage(Damage, EventInstigator, false, CurrentBreakableStep);
		}
		else
		{
			TakeStepDamage(Damage, EventInstigator, false, CurrentBreakableStep);
		}
	}
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}


function TakeLastDamage(int Damage, Controller EventInstigator, bool bIsBroken, int BrokenStep)
{
	BreakableSteps[CurrentBreakableStep].DamageThreshold -= Damage;
	if (BreakableSteps[CurrentBreakableStep].DamageThreshold < 0)
	{
		BreakLastApart(EventInstigator);
	}
	else if (bIsBroken)
	{
		BreakStepApart(BrokenStep);
	}
}

function TakeStepDamage(int Damage, Controller EventInstigator, bool bIsBroken, int BrokenStep)
{
	BreakableSteps[CurrentBreakableStep].DamageThreshold -= Damage;
	if (BreakableSteps[CurrentBreakableStep].DamageThreshold < 0)
	{
		CurrentBreakableStep++;

		if (CurrentBreakableStep < BreakableSteps.Length - 1)
		{
			TakeStepDamage(-BreakableSteps[CurrentBreakableStep-1].DamageThreshold, EventInstigator, true, CurrentBreakableStep-1);
		}
		else
		{
			TakeLastDamage(-BreakableSteps[CurrentBreakableStep-1].DamageThreshold, EventInstigator, true, CurrentBreakableStep-1);
		}
	}
	else if (bIsBroken)
	{
		BreakStepApart(BrokenStep);
	}
}

/**
 * Searches DamageTypes[] for the specified damage type.
 */
final function bool IsValidDamageType(class<DamageType> inDamageType)
{
	local bool bValid;
	bValid = true;
	if (DamageTypes.Length > 0)
	{
		bValid = (DamageTypes.Find(inDamageType) != -1);
	}
	return bValid;
}


function BreakStepApart(int BrokenStep)
{
	local EmitterSpawnable Emit;
	local int i;
	local vector SpawnLocation;

	if (WorldInfo.NetMode != NM_DedicatedServer && BreakableSteps[BrokenStep].ParticleEmitters.Length > 0)
	{
		for (i=0; i<BreakableSteps[BrokenStep].ParticleEmitters.Length; i++)
		{
			SpawnLocation = Location + BreakableSteps[BrokenStep].ParticleEmitters[i].Offset;
			Emit = Spawn(class'EmitterSpawnable',,,SpawnLocation,Rotation);
			if(Emit != none)
			{
				SetParticlesLighting(Emit);
				Emit.SetTemplate(BreakableSteps[BrokenStep].ParticleEmitters[i].Emitter);
				Emit.SetBase(self);
			}
		}
	}

	if (BreakableSteps[BrokenStep].BreakSound != None)
	{
		PlaySound(BreakableSteps[BrokenStep].BreakSound, true,,, CollisionComponent.Bounds.Origin);
	}

	if (BreakableSteps[BrokenStep].BreakMesh != None)
	{
		StaticMeshComponent.SetStaticMesh(BreakableSteps[BrokenStep].BreakMesh);
	}
	SetPhysics(BreakableSteps[BrokenStep].Physics);
	if(BreakableSteps[BrokenStep].Physics == PHYS_RigidBody)
	{
		StaticMeshComponent.WakeRigidBody();
	}
}

function BreakLastApart(Controller EventInstigator)
{
	local EmitterSpawnable Emit;
	local int i;
	//local KActorSpawnable SpawnedActor;
	local vector SpawnLocation;

	if (WorldInfo.NetMode != NM_DedicatedServer && BreakableSteps[CurrentBreakableStep].ParticleEmitters.Length > 0)
	{
		for (i=0; i<BreakableSteps[CurrentBreakableStep].ParticleEmitters.Length; i++)
		{
			SpawnLocation = Location + BreakableSteps[CurrentBreakableStep].ParticleEmitters[i].Offset;
			Emit = Spawn(class'EmitterSpawnable',,,SpawnLocation,Rotation);
			if(Emit != none)
			{
				SetParticlesLighting(Emit);
				Emit.SetTemplate(BreakableSteps[CurrentBreakableStep].ParticleEmitters[i].Emitter);
				Emit.SetBase(self);
			}
		}
	}

	SetPhysics(PHYS_None);
	SetCollision(false,false);
	if (CollisionComponent != None)
	{
		CollisionComponent.SetBlockRigidBody(false);
	}
	SetTimer(0.1, false, 'HideAndDestroy');
	TriggerEventClass(class'SeqEvent_Destroyed',EventInstigator);

	if (BreakableSteps[CurrentBreakableStep].BreakSound != None)
	{
		PlaySound(BreakableSteps[CurrentBreakableStep].BreakSound, true,,, CollisionComponent.Bounds.Origin);
	}
/* Disabled for now...
	if (BreakableSteps[CurrentBreakableStep].BreakMesh != None)
	{
		SpawnedActor = spawn(class'KActorSpawnable',,,Location, Rotation);
		if (SpawnedActor != none)
		{
			SpawnedActor.StaticMeshComponent.SetStaticMesh(BreakableSteps[CurrentBreakableStep].BreakMesh);
			SpawnedActor.SetPhysics(BreakableSteps[CurrentBreakableStep].Physics);
			if(BreakableSteps[CurrentBreakableStep].Physics == PHYS_RigidBody)
			{
				SpawnedActor.StaticMeshComponent.WakeRigidBody();
			}
		}
	}
*/
}

function HideAndDestroy()
{
	StaticMeshComponent.SetHidden(true);
	Destroy();
}

event Destroyed()
{
	Super.Destroyed();
}

defaultproperties
{
	CollisionType = COLLIDE_BlockAll
	bNoDelete = true
	bProjTarget = true
	CurrentBreakableStep = 0
}
