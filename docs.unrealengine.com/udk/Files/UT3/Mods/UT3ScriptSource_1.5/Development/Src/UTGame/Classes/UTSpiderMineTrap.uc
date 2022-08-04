/**
 * when an enemy player gets within range, spawns spider mines to attack that player 
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTSpiderMineTrap extends UTDeployedActor
	abstract;

/** number of spider mines available */
var int AvailableMines;

/** currently deployed spidermine count */
var int DeployedMines;

/** range for detecting enemies */
var float DetectionRange;
/** class of spider mine to spawn */
var class<UTProj_SpiderMineBase> MineClass;

/** played when we spawn a mine */
var SoundCue ActivateSound;

/** SpawnOffset used when spidermines fail to spawn */
var vector SpawnOffset[5];
var int CurrentOffset;

event Landed(vector HitNormal, Actor HitActor)
{
	PerformDeploy();
	SetTimer(0.5, false, 'CheckForEnemies');
}

simulated function PerformDeploy()
{
	bDeployed = true;
	SkeletalMeshComponent(Mesh).PlayAnim('Deploy');
}

function UTProj_SpiderMineBase SpawnOffsetMine(vector Z)
{
	local UTProj_SpiderMineBase Mine;

	while ( CurrentOffset < 4 )
	{
		CurrentOffset++;
		Mine = Spawn(MineClass,,, Location + SpawnOffset[CurrentOffset] + 25*Z);
		if ( Mine != None )
		{
			break;
		}
	}
	return Mine;
}

/** spawn a mine to attack the given target */
function UTProj_SpiderMineBase SpawnMine(Pawn Target, vector TargetDir)
{
	local UTProj_SpiderMineBase Mine;
	local vector X,Y,Z;

	if ( AvailableMines > 0 )
	{
		PlaySound(ActivateSound);
		GetAxes(Rotation, X,Y,Z);
		Mine = Spawn(MineClass,,, Location + SpawnOffset[CurrentOffset] + 25*Z);
		if ( Mine == None )
		{
			if ( CurrentOffset == 0 )
		{
				Mine = SpawnOffsetMine(Z);
			}
			if ( Mine == None )
			{
				Destroy();
				return None;
			}
		}
		
			Mine.Lifeline = self;
			Mine.InstigatorController = InstigatorController;
			Mine.TeamNum = TeamNum;
			Mine.TargetPawn = Target;
		if ( UTPawn(Target) != None )
		{
			UTPawn(Target).AddSpiderChaser(Mine);
		}
			Mine.KeepTargetExtraRange = FMax(0.f, DetectionRange - Mine.DetectionRange);
			Mine.TossZ = 300.0;
			Mine.Init(TargetDir);
			AvailableMines--;
			DeployedMines++;
		}
	return Mine;
}

/** called on a timer to check for enemies to target with mines */
function CheckForEnemies()
{
	local Controller C;
	local float NextInterval;

	// make sure we have an Instigator
	if ( InstigatorController != None )
	{
		if ( InstigatorController.Pawn != None )
		{
			 Instigator = InstigatorController.Pawn;
		}
		}
		else
		{
		// no one to take credit, so destroy
		Destroy();
		return;
	}

	if ( !WorldInfo.GRI.OnSameTeam(self, InstigatorController) && (InstigatorController.PlayerReplicationInfo.Team != None) )
	{
		Destroy();
		return;
	}

	if ( AvailableMines + DeployedMines <= 0 )
	{
		// out of mines
		Destroy();
		return;
	}

	if (!bDeleteMe)
	{
		NextInterval = 0.5;
		foreach WorldInfo.AllControllers(class'Controller', C)
		{
			if ( C.Pawn != None && C != InstigatorController && !WorldInfo.GRI.OnSameTeam(self, C) && !C.Pawn.IsA('UTVehicle_DarkWalker')
				&& VSize(C.Pawn.Location - Location) < DetectionRange && FastTrace(C.Pawn.Location, Location) )
			{
				SpawnMine(C.Pawn, Normal(C.Pawn.Location - Location));
				NextInterval = 1.5;
			}
		}
		SetTimer(NextInterval, false, 'CheckForEnemies');
	}
}

defaultproperties
{
	LifeSpan=150.0
	AvailableMines=15
	DetectionRange=1500.0
	bOrientOnSlope=true

	bCollideActors=true
	bBlockActors=true

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=0
		CollisionHeight=0
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
	
	CurrentOffset=0
	SpawnOffset(0)=(X=0.0,Y=0.0,Z=0.0)
	SpawnOffset(1)=(X=0.0,Y=-12.0,Z=0.0)
	SpawnOffset(2)=(X=0.0,Y=12.0,Z=0.0)
	SpawnOffset(3)=(X=12.0,Y=0.0,Z=0.0)
	SpawnOffset(4)=(X=-12.0,Y=0.0,Z=0.0)
}
