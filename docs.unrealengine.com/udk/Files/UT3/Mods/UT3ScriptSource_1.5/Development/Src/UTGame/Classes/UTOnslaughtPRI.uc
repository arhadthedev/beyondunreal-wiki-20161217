/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtPRI extends UTPlayerReplicationInfo;

var bool bPendingMapDisplay;

var float PendingHealBonus; //node healing score bonus that hasn't yet been added to Score

var float PendingDamageBonus; //node damaging score bonus that hasn't yet been added to Score

// returns the powecore/node the player is currently standing on or in the node teleport trigger radius of,
// if that core/node is currently constructed for the same team as the player
simulated function UTOnslaughtObjective GetCurrentNode()
{
	local UTOnslaughtObjective Core;
	local Pawn P;

	P = Controller(Owner).Pawn;
	if (P != None)
	{
		if (P.Base != None)
		{
			Core = UTOnslaughtObjective(P.Base);
			if (Core == None)
			{
				Core = UTOnslaughtObjective(P.Base.Owner);
			}
		}

		if (Core == None)
		{
			foreach P.OverlappingActors(class'UTOnslaughtObjective', Core, P.VehicleCheckRadius)
			{
				break;
			}
		}
	}

	if (Core != None && Core.IsActive() && Core.DefenderTeamIndex == Team.TeamIndex)
	{
		return Core;
	}
	else
	{
		return None;
	}
}

//scoring bonus for healing powernodes
//we wait until the healing bonus >= 1 point before adding to score to minimize ScoreEvent() calls
function AddHealBonus(float Bonus)
{
	PendingHealBonus += Bonus;
	if (PendingHealBonus >= 1.f)
	{
		Score += 1;
		PendingHealBonus -= 1.0;
		IncrementNodeStat('NODE_HEALEDNODE');
	}
}

//scoring bonus for damaging powernodes
function AddDamageBonus(float Bonus)
{
	PendingDamageBonus += Bonus;
	if (PendingDamageBonus >= 1.f)
	{
		Score += 1;
		PendingDamageBonus -= 1.0;
	}
}

defaultproperties
{
}
