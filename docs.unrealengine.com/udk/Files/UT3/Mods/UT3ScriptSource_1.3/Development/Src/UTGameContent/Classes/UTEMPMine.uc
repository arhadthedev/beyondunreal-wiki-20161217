/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTEMPMine extends UTDeployedActor;

var SoundCue ExplosionSound;
var ParticleSystem ExplosionEffect;
var float EMPRadius;
/** used to tell client to play explosion effect */
var repnotify byte ExplosionCount;

replication
{
	if (bNetDirty)
		ExplosionCount;
}

event Landed(vector HitNormal, Actor HitActor)
{
	if ( UTVehicle(HitActor) != None )
	{
		LifeSpan = FMin(LifeSpan, 30.0);
	}
	PerformDeploy();
	if ( !bDeleteMe )
	{
		SetTimer(0.1, true, 'CheckEMP');
	}
}

simulated function PerformDeploy()
{
	bDeployed = true;
	SkeletalMeshComponent(Mesh).PlayAnim('Deploy');
}

function CheckEmp()
{
	local UTVehicle V;
	local bool bActivated;
	local UTPlayerController OldDriver;

	ForEach CollidingActors(class'UTVehicle', V, EMPRadius,, true)
	{
		if (!V.bIsDisabled
			&& (!WorldInfo.GRI.OnSameTeam(self, V) || ((UTTeamGame(WorldInfo.Game) != None) && (UTTeamGame(WorldInfo.Game).FriendlyFireScale > 0) && (UTStealthVehicle(V) == None) && (UTVehicle_Leviathan(V) == None))) )
		{
			OldDriver = UTPlayerController(V.Controller);
			if ( V.DisableVehicle() )
			{
				bActivated = true;
				OldDriver.ClientPlaySound(ExplosionSound);
			}
		}
	}

	if (bActivated)
	{
		ExplosionCount++;
		SetTimer(3.0, false, 'ClearExplosionCount');
		PlayExplosionEffect();
		MakeNoise(1.0);
		// always leave some delay after last explosion to give time to replicate effect to clients
		if (LifeSpan > 0.5)
		{
			LifeSpan = FMax(LifeSpan - 4.0, 0.5);
		}
	}
}

function ClearExplosionCount()
{
	ExplosionCount = 0;
}

simulated function PlayExplosionEffect()
{
	local vector SpawnLocation;
	local rotator SpawnRotation;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		PlaySound(ExplosionSound, true);
		SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation( 'EMPBurst', SpawnLocation, SpawnRotation );
		WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, SpawnLocation, SpawnRotation);
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'ExplosionCount')
	{
		if (ExplosionCount != 0)
		{
			PlayExplosionEffect();
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

defaultproperties
{
	EMPRadius=500.0
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=SkeletalMeshComponent Name=DeployableMesh
		Animations=MeshSequenceA
		AnimSets(0)=AnimSet'Pickups.Deployables.Anims.K_Deployables_EMP_Mine'
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_EMP_Mine'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		//Scale3D=(X=0.1,Y=0.1,Z=0.75)
		Translation=(Z=-20.0)
		CastShadow=true
		bUseAsOccluder=FALSE
		bAcceptsDecals=false
		LightEnvironment=DeployedLightEnvironment
	End Object
	Mesh=DeployableMesh
	Components.Add(DeployableMesh)

	Begin Object Class=CylinderComponent Name=ColComp
	End Object
	Components.Add(ColComp)
	CollisionComponent=ColComp

	LifeSpan=60.0
	ExplosionEffect=ParticleSystem'Pickups.Deployables.Effects.P_Deployables_EMP_Mine_Pulse'
	ExplosionSound=SoundCue'A_Pickups_Deployables.EMPMine.EMPMine_ShockCue''
	bOrientOnSlope=true
}
