/**
 * when an enemy player gets within range, spawns spider mines to attack that player 
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
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

/** spawn a mine to attack the given target */
function UTProj_SpiderMineBase SpawnMine(Pawn Target, vector TargetDir)
{
	local UTProj_SpiderMineBase Mine;
	local vector X,Y,Z;

	if ( AvailableMines > 0 )
	{
		PlaySound(ActivateSound);
		GetAxes(Rotation, X,Y,Z);
		Mine = Spawn(MineClass,,, Location + 25*Z);
		if (Mine != None)
		{
			Mine.Lifeline = self;
			Mine.InstigatorController = InstigatorController;
			Mine.TeamNum = TeamNum;
			Mine.TargetPawn = Target;
			Mine.KeepTargetExtraRange = FMax(0.f, DetectionRange - Mine.DetectionRange);
			Mine.TossZ = 300.0;
			Mine.Init(TargetDir);
			AvailableMines--;
			DeployedMines++;
		}
	}
	return Mine;
}

/** called on a timer to check for enemies to target with mines */
function CheckForEnemies()
{
	local Controller C;
	local float NextInterval;

	// make sure we have an Instigator
	if (Instigator == None)
	{
		if (InstigatorController == None)
		{
			// no one to take credit, so destroy
			Destroy();
			return;
		}
		else
		{
			Instigator = InstigatorController.Pawn;
		}
	}

	if (InstigatorController == None || !WorldInfo.GRI.OnSameTeam(self, InstigatorController))
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
			if ( C.Pawn != None && !WorldInfo.GRI.OnSameTeam(self, C) && !C.Pawn.IsA('UTVehicle_DarkWalker')
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
}
