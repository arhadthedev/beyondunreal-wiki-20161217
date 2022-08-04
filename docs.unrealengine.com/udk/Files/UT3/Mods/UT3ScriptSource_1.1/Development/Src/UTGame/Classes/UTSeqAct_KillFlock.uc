/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTSeqAct_KillFlock extends SequenceAction;

event Activated()
{
	local FlockTest_Spawner Spawner;
	local FlockTestActor Agent;

	// Find the spawner we want to kill actors from
	Spawner = FlockTest_Spawner(Targets[0]);
	if(Spawner != None)
	{
		// Find all actors spawned from spawner.
		foreach Spawner.AllActors(class'FlockTestActor', Agent)
		{
			if(Agent.Spawner == Spawner)
			{
				// .. and kill them
				Agent.Destroy();
			}
		}
	}
}


defaultproperties
{
	ObjName="Kill Flock"
	ObjCategory="Flock"
}
