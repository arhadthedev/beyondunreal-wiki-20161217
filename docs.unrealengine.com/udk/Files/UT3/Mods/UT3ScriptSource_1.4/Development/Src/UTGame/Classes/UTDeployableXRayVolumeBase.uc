/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTDeployableXRayVolumeBase extends UTDeployable
	abstract;

/** Classname of the deployable class to return **/
var class<Actor> DeployableClass;

static function class<Actor> GetTeamDeployable(int TeamNum)
{
	return default.DeployableClass;
}

function bool Deploy()
{
	local UTXRayVolume Volume;
	local vector SpawnLocation;
	local vector HitLocation, HitNormal;
	local rotator Aim;
	local float DistSqToObstacle;

	SpawnLocation = GetPhysicalFireStartLoc();

	//Get the Z location of where the visual mesh will be placed
	if (Trace(HitLocation, HitNormal, SpawnLocation, Instigator.GetPawnViewLocation(), false) != None)
	{
		DistSqToObstacle = VSizeSq(HitLocation-Location);
		if (DistSqToObstacle < (60.0 * 60.0))
		{
			//Too close to a wall or something to spawn in front of us
            //the actual deployable will do a Z line check right around here
            //and we want it to be on 'safe' ground
			return false;
		}
	}

	//Start at player height
	SpawnLocation.Z = Instigator.Location.Z;
	Aim = GetAdjustedAim(SpawnLocation);
	Aim.Pitch = 0;
	Aim.Roll = 0;
	Volume = UTXRayVolume(Spawn(DeployableClass,,, SpawnLocation, Aim));
	if (Volume != None)
	{
		Volume.OnDeployableUsedUp = Factory.DeployableUsed;
		bForceHidden = true;
		Mesh.SetHidden(true);
		return true;
	}
	else
	{
		return false;
	}
}

defaultproperties
{
}
