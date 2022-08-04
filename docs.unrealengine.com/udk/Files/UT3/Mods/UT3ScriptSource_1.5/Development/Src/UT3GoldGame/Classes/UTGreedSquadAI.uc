/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedSquadAI extends UTSquadAI;

var int FreelanceThreshold;
var UTCTFBase HomeBase, EnemyBase;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	FreelanceThreshold = Default.FreelanceThreshold + Rand(2);
}

function bool CheckVehicle(UTBot B)
{
	local UTVehicle DeployableVehicle;
	local Pawn FocusEnemy;
	local int i;
	local UTVehicle V;

	DeployableVehicle = B.GetDeployableVehicle();
	if ( (DeployableVehicle == None) && (UTVehicle(B.Pawn) != None) && UTVehicle(B.Pawn).IsArtillery() )
	{
		DeployableVehicle = UTVehicle(B.Pawn);
	}
	if ( DeployableVehicle != None )
	{
		if ( DeployableVehicle.IsArtillery() )
		{
			// if possible, just target and fire at nodes or important enemies
			if ( (B.Enemy != None) && DeployableVehicle.CanDeployedAttack(B.Enemy) )
			{
				B.DoRangedAttackOn(B.Enemy);
				B.GoalString = "Artillery Attack Enemy";
				return true;
			}
			if ( DeployableVehicle.IsDeployed() )
			{
				// check if already focused on valid target
				FocusEnemy = Pawn(B.Focus);
				if ( (FocusEnemy != None) && (FocusEnemy.Health > 0) && !WorldInfo.GRI.OnSameTeam(B,FocusEnemy) && DeployableVehicle.CanDeployedAttack(FocusEnemy) )
				{
					B.DoRangedAttackOn(FocusEnemy);
					B.GoalString = "Artillery Focus Enemy";
					return true;
				}
			}			
				
			// check squad enemies
			for ( i=0; i<8; i++ )
			{
				if ( (Enemies[i] != None) && (Enemies[i] != B.Enemy) && (Enemies[i] != FocusEnemy) && DeployableVehicle.CanDeployedAttack(Enemies[i]) )
				{
					B.DoRangedAttackOn(Enemies[i]);
					B.GoalString = "Artillery Attack Squad Enemy";
					return true;
				}
			}

			// check important enemies
			for ( V=UTGame(WorldInfo.Game).VehicleList; V!=None; V=V.NextVehicle )
			{
				if ( (V.Controller != None) && !V.bCanFly && (V != FocusEnemy) && (V.ImportantVehicle() || V.IsArtillery()) && !WorldInfo.GRI.OnSameTeam(V,B) && DeployableVehicle.CanDeployedAttack(V) )
				{
					B.DoRangedAttackOn(V);
					B.GoalString = "Artillery Attack important vehicle";
					return true;
				}
			}
			if ( UTVehicle_Deployable(DeployableVehicle) != None )
			{
				UTVehicle_Deployable(DeployableVehicle).bNotGoodArtilleryPosition = true;
			}
		}
		// check deployables
		else if ( UTStealthVehicle(DeployableVehicle) != None && UTStealthVehicle(DeployableVehicle).ShouldDropDeployable() )
		{
			return true;
		}
	}
	return Super.CheckVehicle(B);
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, UTBot B)
{
	local UTGreedPRI PRI;

	PRI = UTGreedPRI(NewThreat.PlayerReplicationInfo);
	return (PRI != None) ? current + PRI.NumCoins/5.0 : current;
}

function byte PriorityObjective(UTBot B)
{
	local UTGreedPRI PRI;

	PRI = UTGreedPRI(B.PlayerReplicationInfo);
	if ( PRI == None )
	{
		return 0;
	}
	if ( PRI.NumCoins > Min(5, Worldinfo.Game.GoalScore - PRI.Team.Score) )
	{
		return 2;
	}
	if ( PRI.NumCoins < 3 )
	{
		return 0;
	}
	if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex != Team.TeamIndex) && SquadObjective.BotNearObjective(B) )
	{
		return 2;
	}
	return 0;

}

function bool MustKeepEnemy(Pawn E)
{
	local UTGreedPRI PRI;

	if ( (E == None) || (E.PlayerReplicationInfo == None) || (E.Health <= 0) )
		return false;

	PRI = UTGreedPRI(E.PlayerReplicationInfo);
	if ( (PRI != None) && (PRI.NumCoins > 10) )
	{
		return true;
	}
	return false;
}

function bool OverrideFollowPlayer(UTBot B)
{
	if ( (UTPawn(B.Pawn) != None) && UTPawn(B.Pawn).IsHero() )
	{
		return false;
	}
	return super.OverrideFollowPlayer(B);
}

/** 
 * Have bot freelance if not enough flags, and pick up nearby flags
*/
function bool CheckSquadObjectives(UTBot B)
{
	local UTGreedPRI PRI;
	local UTGreedCoin Coin;
	local int Count;
	local UTVehicle V;

	//`log("Check objectives for "$B);
	PRI = UTGreedPRI(B.PlayerReplicationInfo);

	if ( (PRI.NumCoins < 10) && MustKeepEnemy(B.Enemy) )
	{
		return TryToIntercept(B, B.Enemy, HomeBase);
	}
	
	// heroes can't pick up coins
	if ( (UTPawn(B.Pawn) != None) && UTPawn(B.Pawn).IsHero() )
	{
		// If the squad's orders are to attack, the hero bot should play 
		// deathmatch instead of going to the enemy base
		if ( GetOrders() == 'ATTACK' )
		{
			return false;
		}
		return super.CheckSquadObjectives(B);
	}
	
	V = UTVehicle(B.Pawn);
	if ( (V == None) || !V.ImportantVehicle() )
	{
		// look for nearby skulls
		ForEach B.Pawn.VisibleCollidingActors(class'UTGreedCoin', Coin, 1000.0)
		{
			if ( Coin.BotDesireability(B.Pawn,B) > 0.5 ) 
			{
				if ( FindPathToObjective(B,Coin) )
			  	{
					if ( V != None && !V.bCanPickupInventory && (B.MoveTarget == Coin) )
					{
						// get out of vehicle here so driver can get it
						V.VehicleLostTime = WorldInfo.TimeSeconds + 3.0;
						B.LeaveVehicle(true);
					}
					B.GoalString = "Pickup coin";
					return true;
				}
				Count++;
				if ( Count > 3 )
				{
					break;
				}
			}
		}
	}

	if ( (PRI != None) && ((GetOrders() != 'DEFEND') || (PRI.NumCoins > 7)) )
	{
		// only attack if have skulls
		if ( (PRI.NumCoins < 1) || (PRI.NumCoins < Min(PRI.Score+2, Min(FreelanceThreshold, Max(Worldinfo.Game.GoalScore - PRI.Team.Score, 1)))) )
		{
			return CheckVehicle(B);
		}
		else if ( (PRI.NumCoins > 7) && NotForSkullDelivery(UTVehicle(B.Pawn)) )
		{
			B.LeaveVehicle(true);
			return true;
		}
	}

	return super.CheckSquadObjectives(B);
}

/** 
  * returns true if vehicle not appropriate for skull delivery
  */
function bool NotForSkullDelivery(UTVehicle V)
{
	return ( (V != None) && (V.IsArtillery() || (UTVehicle_TrackTurretBase(V) != None)) );
}	
	
/**
  * make sure bots with lots of skulls don't get into artillery only to jump back out
  */
function float VehicleDesireability(UTVehicle V, UTBot B)
{
	local UTGreedPRI PRI;

	PRI = UTGreedPRI(B.PlayerReplicationInfo);

	if ( (PRI.NumCoins > 7) && NotForSkullDelivery(V) )
	{
		return 0.0;
	}
	
	return Super.VehicleDesireability(V, B);
}

defaultproperties
{
	bShouldUseGatherPoints=false
	FreelanceThreshold=3
}