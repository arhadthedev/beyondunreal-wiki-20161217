/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtSquadAI extends UTSquadAI;

/** pointer to Team.AI so we don't have to cast all the time */
var UTOnslaughtTeamAI ONSTeamAI;
var bool bDefendingSquad;
var float LastFailedNodeTeleportTime;
var float MaxObjectiveGetOutDist; //cached highest ObjectiveGetOutDist of all the vehicles available on this level

function Initialize(UTTeamInfo T, UTGameObjective O, Controller C)
{
	Super.Initialize(T, O, C);

	ONSTeamAI = UTOnslaughtTeamAI(T.AI);
	`Warn("TeamAI is not a subclass of UTOnslaughtTeamAI",ONSTeamAI == None);
}

/* BeDevious()
return true if bot should use guile in hunting opponent (more expensive)
*/
function bool BeDevious(Pawn Enemy)
{
	return false;
}

function name GetOrders()
{
	local name NewOrders;

	if ( PlayerController(SquadLeader) != None )
		NewOrders = 'Human';
	else if ( bFreelance && !bFreelanceAttack && !bFreelanceDefend )
		NewOrders = 'Freelance';
	else if ( bDefendingSquad || bFreelanceDefend || (SquadObjective != None && SquadObjective.DefenseSquad == self) )
		NewOrders = 'Defend';
	else
		NewOrders = 'Attack';
	if ( NewOrders != CurrentOrders )
	{
		CurrentOrders = NewOrders;
		bForceNetUpdate = TRUE;
	}
	return CurrentOrders;
}

function byte PriorityObjective(UTBot B)
{
	local UTOnslaughtObjective Core;

	if (B.PlayerReplicationInfo.bHasFlag)
	{
		return 1;
	}
	else if (GetOrders() == 'Defend')
	{
		Core = UTOnslaughtObjective(SquadObjective);
		if (Core != None && (Core.DefenderTeamIndex == Team.TeamIndex) && Core.bUnderAttack)
			return 1;
	}
	else if (CurrentOrders == 'Attack' || CurrentOrders == 'Freelance')
	{
		Core = UTOnslaughtObjective(SquadObjective);
		if (Core != None)
		{
			if ( (Core.IsA('UTOnslaughtPowerCore') && B.Enemy != None && Core.BotNearObjective(B)) ||
				(Core.DefenderTeamIndex != Team.TeamIndex && !Core.IsNeutral() && Core.IsA('UTOnslaughtPowerNode') && B.Pawn.CanAttack(Core)) ||
				(VSize(B.Pawn.Location - Core.Location) < 2000.0) )
			{
				return 1;
			}
		}
	}
	return 0;
}

function SetDefenseScriptFor(UTBot B)
{
	local UTOnslaughtObjective Core;

	// don't look for defense points when shielding node with orb
	if ( !B.PlayerReplicationInfo.bHasFlag || UTOnslaughtPowerNode(SquadObjective) == None ||
		SquadObjective.DefenderTeamIndex != Team.TeamIndex )
	{
		// don't look for defense scripts when heading for neutral node
		Core = UTOnslaughtObjective(SquadObjective);
		if (Core == None || (Core.DefenderTeamIndex == Team.TeamIndex && (Core.bIsConstructing || Core.IsActive())) )
		{
			Super.SetDefenseScriptFor(B);
			return;
		}
	}

	if (B.DefensePoint != None)
	{
		B.FreePoint();
	}
}

/** returns the maximum distance the given Pawn should search for vehicles to enter */
function float MaxVehicleDist(Pawn P)
{
	local UTOnslaughtPowerNode Node;

	Node = UTOnslaughtPowerNode(SquadObjective);
	if (Node != None && Node.DefenderTeamIndex != Team.TeamIndex && ONSTeamAI.Flag != None && ONSTeamAI.Flag.Holder == None)
	{
		return FMin(FMin(3000.0, VSize(SquadObjective.Location - P.Location)), VSize(ONSTeamAI.Flag.Position().Location - P.Location));
	}
	else
	{
		return Super.MaxVehicleDist(P);
	}
}

function bool ShouldUseAlternatePaths()
{
	local UTOnslaughtObjective ONSObjective;

	// use alternate paths only when attacking active enemy objective
	ONSObjective = UTOnslaughtObjective(SquadObjective);
	return (ONSObjective != None && ONSObjective.DefenderTeamIndex != Team.TeamIndex && ONSObjective.IsActive());
}

function bool MustCompleteOnFoot(Actor O)
{
	local UTOnslaughtNodeObjective Node;

	Node = UTOnslaughtNodeObjective(O);
	//@FIXME: only need to be on foot for non-neutral powernode if have orb
	if (Node != None && (Node.IsNeutral() || UTOnslaughtPowerNode(Node) != None))
	{
		return true;
	}
	else
	{
		return (UTWarfareBarricade(O) != None || Super.MustCompleteOnFoot(O));
	}
}

/** used with bot's CustomAction interface to process a node teleport */
function bool NodeTeleport(UTBot B)
{
	local UTOnslaughtObjective Objective;

	Objective = UTOnslaughtObjective(B.RouteGoal);
	if (Objective == None || !Objective.TeleportTo(UTPawn(B.Pawn)))
	{
		LastFailedNodeTeleportTime = WorldInfo.TimeSeconds;
	}

	return true;
}

function bool ShouldCheckSuperVehicle(UTBot B)
{
	if ( UTOnslaughtPowerNode(SquadObjective) != None && ONSTeamAI.Flag != None && ONSTeamAI.Flag.Holder == None &&
		VSize(B.Pawn.Location - ONSTeamAI.Flag.Position().Location) < 1500.0 )
	{
		// get orb instead
		return false;
	}
	else
	{
		return Super.ShouldCheckSuperVehicle(B);
	}
}

function bool CheckVehicle(UTBot B)
{
	local UTOnslaughtNodeObjective Best, ClosestNode;
	local UTOnslaughtObjective Core;
	local UTGameObjective O;
	local float NewRating, BestRating;
	local byte SourceDist;
	local Weapon SuperWeap;
	local int i, j;
	local UTVehicle V;
	local Actor Goal;
	local UTVehicle_Deployable DeployableVehicle;
	local UTOnslaughtGame ONSGame;
	local UTOnslaughtNodeObjective Node;
	local NavigationPoint TeleportSource;
	local UTOnslaughtObjective ONSObjective;

	ONSObjective = UTOnslaughtObjective(SquadObjective);
	if (UTVehicle(B.Pawn) != None && (B.Skill + B.Tactics >= 5.0 || UTVehicle(B.Pawn).bKeyVehicle) && UTVehicle(B.Pawn).IsArtillery())
	{
		DeployableVehicle = B.GetDeployableVehicle();
		if (DeployableVehicle != None && DeployableVehicle.IsDeployed())
		{
			// if possible, just target and fire at nodes or important enemies
			if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex != Team.TeamIndex) && (ONSObjective != None)
				&& ONSObjective.LegitimateTargetOf(B) && B.Pawn.CanAttack(SquadObjective) )
			{
				B.DoRangedAttackOn(SquadObjective);
				B.GoalString = "Artillery Attack Objective";
				return true;
			}
			if ( (B.Enemy != None) && B.Pawn.CanAttack(B.Enemy) )
			{
				B.DoRangedAttackOn(B.Enemy);
				B.GoalString = "Artillery Attack Enemy";
				return true;
			}
			// check squad enemies
			for ( i=0; i<8; i++ )
			{
				if ( (Enemies[i] != None) && (Enemies[i] != B.Enemy) && B.Pawn.CanAttack(Enemies[i]) )
				{
					B.DoRangedAttackOn(Enemies[i]);
					B.GoalString = "Artillery Attack Squad Enemy";
					return true;
				}
			}
			// check other nodes
			for ( O=Team.AI.Objectives; O!=None; O=O.NextObjective )
			{
				Core = UTOnslaughtObjective(O);
				if ( (Core != None) && Core.PoweredBy(Team.TeamIndex) && (Core.DefenderTeamIndex != Team.TeamIndex) && Core.LegitimateTargetOf(B) && B.Pawn.CanAttack(Core) )
				{
					B.DoRangedAttackOn(Core);
					B.GoalString = "Artillery Attack Other Node";
					return true;
				}
			}

			// check important enemies
			for ( V=UTGame(WorldInfo.Game).VehicleList; V!=None; V=V.NextVehicle )
			{
				if ( (V.Controller != None) && !V.bCanFly && (V.ImportantVehicle() || V.IsArtillery()) && !WorldInfo.GRI.OnSameTeam(V,B) && B.Pawn.CanAttack(V) )
				{
					B.DoRangedAttackOn(V);
					B.GoalString = "Artillery Attack important vehicle";
					return true;
				}
			}

			if ( Team.Size == DeployableVehicle.NumPassengers() ||
					( VSize(B.Pawn.Location - SquadObjective.Location) > DeployableVehicle.ObjectiveGetOutDist &&
						DeployableVehicle.NoPassengerObjective != SquadObjective &&
						!SquadObjective.ReachedParkingSpot(B.Pawn) && !B.Pawn.CanAttack(SquadObjective) ) )
			{
				DeployableVehicle.SetTimer(0.01, false, 'ServerToggleDeploy');
			}
		}
		else if ( !B.Pawn.IsFiring() && (B.Enemy != None) && B.Pawn.CanAttack(B.Enemy) )
		{
			B.Focus = B.Enemy;
			B.FireWeaponAt(B.Enemy);
		}
	}

	if ( SquadObjective != None )
	{
		if ( GetOrders() == 'Attack' )
		{
			if ( ONSObjective != None && !ONSObjective.IsNeutral() && !WorldInfo.GRI.OnSameTeam(ONSObjective, B)
				&& ONSObjective.PoweredBy(1 - Team.TeamIndex) && (UTVehicle(B.Pawn) == None || !UTVehicle(B.Pawn).bKeyVehicle) )
			{
				SuperWeap = B.HasSuperWeapon();
				if ( (SuperWeap != None) &&  B.LineOfSightTo(SquadObjective) )
				{
					if (Vehicle(B.Pawn) != None)
					{
						B.DirectionHint = Normal(SquadObjective.Location - B.Pawn.Location);
						B.LeaveVehicle(true);
						return true;
					}
					return SquadObjective.TellBotHowToDisable(B);
				}
			}
		}
		else if ( UTVehicle(B.Pawn) != None && GetOrders() == 'Defend' && UTVehicle(B.Pawn).AIPurpose == AIP_Offensive
			&& VSize(B.Pawn.Location - SquadObjective.Location) < 1600 && !UTVehicle(B.Pawn).bKeyVehicle
			&& ((B.Enemy == None) || (WorldInfo.TimeSeconds - B.LastSeenTime > 4) || (!UTVehicle(B.Pawn).ImportantVehicle() && !B.LineOfSightTo(B.Enemy))) )
		{
			B.DirectionHint = Normal(SquadObjective.Location - B.Pawn.Location);
			B.LeaveVehicle(true);
			return true;
		}
	}
	if (Vehicle(B.Pawn) == None && ONSObjective != None)
	{
		if ( ONSObjective.IsActive() )
		{
			if ( GetOrders() == 'Defend' && (B.Enemy == None || (!B.LineOfSightTo(B.Enemy) && WorldInfo.TimeSeconds - B.LastSeenTime > 3))
			     && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist()
			     && ONSObjective.Health < ONSObjective.DamageCapacity
			     && ( (UTWeapon(B.Pawn.Weapon) != None && UTWeapon(B.Pawn.Weapon).CanHeal(SquadObjective)) ||
			     		(B.Pawn.InvManager != None && UTWeapon(B.Pawn.InvManager.PendingWeapon) != None && UTWeapon(B.Pawn.InvManager.PendingWeapon).CanHeal(SquadObjective)) ) )
				return false;
		}
		else if ( ONSObjective.bIsConstructing )
		{
			if ( (B.Enemy == None || !B.LineOfSightTo(B.Enemy)) && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist() )
				return false;
		}
		else if ((ONSObjective.IsNeutral() || ONSObjective.IsCurrentlyDestroyed()) && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist())
			return false;

		if ( UTOnslaughtPowerNode(ONSObjective) != None && ONSTeamAI.Flag != None && ONSTeamAI.Flag.Holder == None &&
			VSize(B.Pawn.Location - ONSTeamAI.Flag.Position().Location) < 1500.0 )
		{
			// don't get in vehicle because will just have to get out again for orb
			B.NoVehicleGoal = ONSTeamAI.Flag;
			return false;
		}
	}

	if (Super.CheckVehicle(B))
		return true;
	if ( Vehicle(B.Pawn) != None || SquadObjective == None || (B.Enemy != None && B.LineOfSightTo(B.Enemy))
		|| LastFailedNodeTeleportTime > WorldInfo.TimeSeconds - 20.0
		|| UTOnslaughtPRI(B.PlayerReplicationInfo) == None
		|| B.PlayerReplicationInfo.bHasFlag || B.Skill + B.Tactics < 2.0 + FRand() )
	{
		return false;
	}

	// no vehicles around
	if (SquadObjective.IsA('UTOnslaughtPowerNode') && ONSTeamAI.Flag != None && ONSTeamAI.Flag.Holder == None)
	{
		Goal = ONSTeamAI.Flag.Position();
	}
	else
	{
		Goal = SquadObjective;
	}
	if (VSize(B.Pawn.Location - Goal.Location) > 5000 && !B.LineOfSightTo(Goal))
	{
		// really want a vehicle to get to Goal, so teleport to a different node to find one
		ONSGame = UTOnslaughtGame(WorldInfo.Game);

		ClosestNode = ONSGame.ClosestNodeTo(B.Pawn);
		if (ClosestNode == None || ClosestNode.HasUsefulVehicles(B))
		{
			return false;
		}

		if (ONSGame.IsTouchingNodeTeleporter(B.Pawn))
		{
			SourceDist = ClosestNode.FinalCoreDistance[Abs(1 - Team.TeamIndex)];
			for (O = Team.AI.Objectives; O != None; O = O.NextObjective)
			{
				if ( O != ClosestNode && O.IsA('UTOnslaughtNodeObjective') &&
					UTOnslaughtNodeObjective(O).ValidSpawnPointFor(Team.TeamIndex) )
				{
					NewRating = UTOnslaughtNodeObjective(O).TeleportRating(B, Team.TeamIndex, SourceDist);
					if (NewRating > BestRating || (NewRating == BestRating && FRand() < 0.5))
					{
						Best = UTOnslaughtNodeObjective(O);
						BestRating = NewRating;
					}
				}
			}

			if (Best == None)
			{
				LastFailedNodeTeleportTime = WorldInfo.TimeSeconds;
				return false;
			}
			else
			{
				B.RouteGoal = Best;
				B.PerformCustomAction(NodeTeleport);
				return true;
			}
		}

		// mark all usable nearby node teleporters as pathing endpoints
		for (i = 0; i < ONSGame.PowerNodes.Length; i++)
		{
			Node = UTOnslaughtNodeObjective(ONSGame.PowerNodes[i]);
			if (Node != None && Node.IsActive() && WorldInfo.GRI.OnSameTeam(B, Node))
			{
				for (j = 0; j < Node.NodeTeleporters.Length; j++)
				{
					if (VSize(Node.NodeTeleporters[j].Location - B.Pawn.Location) < 2000.0)
					{
						Node.NodeTeleporters[j].bTransientEndPoint = true;
						TeleportSource = Node.NodeTeleporters[j];
					}
				}
			}
		}
		// if we didn't find any, abort
		if (TeleportSource == None)
		{
			return false;
		}
		// otherwise, try to find path to one of them
		B.MoveTarget = B.FindPathToward(TeleportSource, false);
		if (B.MoveTarget != None)
		{
			B.NoVehicleGoal = B.RouteGoal;
			B.GoalString = "Node teleport from" @ B.RouteGoal;
			B.SetAttractionState();
			return true;
		}
	}

	return false;
}

//return a value indicating how useful this vehicle is to the bot
function float VehicleDesireability(UTVehicle V, UTBot B)
{
	local float Rating;

	if (CurrentOrders == 'Defend')
	{
		// consider taking offensive vehicle to get to defense location faster
		if ((V.bKeyVehicle || SquadObjective == None || VSize(SquadObjective.Location - B.Pawn.Location) < 2000))
		{
			if (Super.VehicleDesireability(V, B) <= 0.0)
			{
				return 0.0;
			}
		}
		else if (B.PlayerReplicationInfo.bHasFlag && !V.bCanCarryFlag)
		{
			return 0.0;
		}
		else if (V.Health < V.HealthMax * 0.125 && B.Enemy != None && B.LineOfSightTo(B.Enemy))
		{
			return 0.0;
		}
		Rating = V.BotDesireability(self, Team.TeamIndex, SquadObjective);
		if (Rating <= 0.0)
		{
			return 0.0;
		}

		if (V.AIPurpose == AIP_Defensive || V.AIPurpose == AIP_Any || V.bStationary)
		{
			if (UTOnslaughtObjective(SquadObjective) != None)
			{
				//turret can't hit priority enemy
				if ( (V.bStationary || V.bIsOnTrack) && B.Enemy != None && UTOnslaughtObjective(SquadObjective).LastDamagedBy == B.Enemy.PlayerReplicationInfo
				     && !FastTrace(B.Enemy.Location + B.Enemy.GetCollisionHeight() * vect(0,0,1), V.Location) )
				{
					return 0.0;
				}
				if (UTOnslaughtNodeObjective(SquadObjective) != None && UTOnslaughtGame(WorldInfo.Game).ClosestNodeTo(V) != SquadObjective)
				{
					return 0.0;
				}
			}
		}

		return V.SpokenFor(B) ? (Rating * V.ReservationCostMultiplier(B.Pawn)) : Rating;
	}
	else
	{
		return Super.VehicleDesireability(V, B);
	}
}

function float GetMaxObjectiveGetOutDist()
{
	local UTVehicleFactory F;

	if (MaxObjectiveGetOutDist == 0.0)
		foreach DynamicActors(class'UTVehicleFactory', F)
			if (F.VehicleClass != None)
				MaxObjectiveGetOutDist = FMax(MaxObjectiveGetOutDist, F.VehicleClass.default.ObjectiveGetOutDist);

	return MaxObjectiveGetOutDist;
}

/** check if bot can destroy any barricades */
function bool CheckBarricades(UTBot B)
{
	local UTGameObjective O;
	local UTWarfareBarricade Barricade;
	local array<UTWarfareBarricade> BarricadeList;
	local int Index;
	local UTBot M;
	local bool bCoreVulnerable;

	// if already going for barricade, keep going
	Barricade = UTWarfareBarricade(SquadObjective);
	if (Barricade != None)
	{
		if (B.NeedWeapon() && B.FindInventoryGoal(0))
		{
			B.GoalString = "Need weapon or ammo";
			B.SetAttractionState();
			return true;
		}
		else if (CheckVehicle(B) || Barricade.TellBotHowToDisable(B))
		{
			return true;
		}
		else if (B != SquadLeader)
		{
			// squadleader might be able to attack, so just follow him
			return TellBotToFollow(B, SquadLeader);
		}
		else
		{
			// can't attack barricades right now, find something else to do
			Team.AI.FindNewObjectiveFor(self, true);
			return false;
		}
	}

	// don't consider changing objectives if squad has flag
	for (M = SquadMembers; M != None; M = M.NextSquadMember)
	{
		if (M.PlayerReplicationInfo.bHasFlag)
		{
			return false;
		}
	}

	// see if we can go after a new barricade now
	bCoreVulnerable = ONSTeamAI.FinalCore.PoweredBy(Team.AI.EnemyTeam.TeamIndex);
	for (O = Team.AI.Objectives; O != None; O = O.NextObjective)
	{
		Barricade = UTWarfareBarricade(O);
		if ( Barricade != None && Barricade.IsActive() && Barricade.DefenderTeamIndex != Team.TeamIndex &&
			(!bCoreVulnerable || Barricade.bAvalancheBarricadeHack) )
		{
			// if this barricade is higher priority, remove previous
			if (BarricadeList.length > 0 && Barricade.DefensePriority > BarricadeList[0].DefensePriority)
			{
				BarricadeList.length = 0;
			}
			BarricadeList.AddItem(Barricade);
		}
	}

	// choose one valid barricade at random
	if (BarricadeList.length > 0)
	{
		Index = Rand(BarricadeList.length);
		if (BarricadeList[Index].TellBotHowToDisable(B))
		{
			SetObjective(BarricadeList[Index], false);
			return true;
		}
	}

	return false;
}

/** @return whether my team owns all power nodes */
function bool OwnAllPowerNodes()
{
	local int i;
	local UTOnslaughtGame Game;

	Game = UTOnslaughtGame(WorldInfo.Game);
	for (i = 0; i < Game.PowerNodes.length; i++)
	{
		if ( UTOnslaughtPowerNode(Game.PowerNodes[i]) != None &&
			(Game.PowerNodes[i].DefenderTeamIndex != Team.TeamIndex || !Game.PowerNodes[i].IsActive()) )
		{
			return false;
		}
	}

	return true;
}

/** consider telling B to get the orb to defend SquadObjective */
function bool GetOrbToDefendNode(UTBot B)
{
	local Actor FlagPosition;

	FlagPosition = Team.TeamFlag.Position();
	if ( (B.RouteGoal != FlagPosition && B.RouteGoal != Team.TeamFlag.LastAnchor && VSize(FlagPosition.Location - B.Pawn.Location) > 1000.0) ||
	 	ONSTeamAI.FinalCore.FindNodeLinkIndex(UTOnslaughtPowerNode(SquadObjective)) == INDEX_NONE || !OwnAllPowerNodes() )
	{
		return false;
	}
	else
	{
		B.GoalString = "Get orb to defend node" @ SquadObjective;
		if (FindPathToObjective(B, Team.TeamFlag))
		{
			B.RouteGoal = Team.TeamFlag.LastAnchor;
			return true;
		}
		else
		{
			return false;
		}
	}
}

function float GetMaxDefenseDistanceFrom(Actor Center, UTBot B)
{
	if ( B.PlayerReplicationInfo.bHasFlag && Center == SquadObjective && UTOnslaughtPowerNode(Center) != None &&
		SquadObjective.DefenderTeamIndex == Team.TeamIndex && GetOrders() == 'Defend' )
	{
		return UTOnslaughtPowerNode(Center).InvulnerableRadius;
	}
	else
	{
		return Super.GetMaxDefenseDistanceFrom(Center, B);
	}
}

function bool AssignSquadResponsibility(UTBot B)
{
	local bool bResult;

	// if we have the flag, but we're not doing anything with a powernode, drop it
	if ( B.PlayerReplicationInfo.bHasFlag && UTOnslaughtPowerNode(SquadObjective) == None &&
		B.PlayerReplicationInfo.IsA('UTPlayerReplicationInfo') )
	{
		// can't drop flag during physics tick
		UTPlayerReplicationInfo(B.PlayerReplicationInfo).GetFlag().SetTimer(0.01, false, 'Drop');
	}

	bResult =  Super.AssignSquadResponsibility(B);

	if ( B.bSendFlagMessage )
	{
		if ( B.PlayerReplicationInfo.bHasFlag )
		{
			B.SendMessage(None, 'HOLDINGFLAG', 10);
		}
		B.bSendFlagMessage = false;
	}
	return bResult;
}

function bool CheckSquadObjectives(UTBot B)
{
	local bool bResult;
	local UTOnslaughtPowerNode ClosestNode;
	local float Dist;
	local int i;

	if (B.Enemy != None && B.Enemy == ONSTeamAI.FinalCore.LastAttacker && !B.PlayerReplicationInfo.bHasFlag)
	{
		if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
		{
			B.GoalString = "Need weapon or ammo";
			B.SetAttractionState();
			return true;
		}
		return false;
	}

	// if bot has weapon that can destroy barricades, try that
	// freelance squad always goes after barricades when possible
	if ((Team.AI.FreelanceSquad == self || B.HasBarricadeDestroyingWeapon()) && CheckBarricades(B))
	{
		return true;
	}

	if (!ONSTeamAI.bAllNodesTaken && self == Team.AI.FreelanceSquad)
	{
		// keep moving to any unpowered nodes if current objective is constructing
		if ( UTOnslaughtObjective(SquadObjective).DefenderTeamIndex == Team.TeamIndex )
			Team.AI.ReAssessStrategy();
	}

	// consider stopping to attack enemy orb carrier
	if ( B.Enemy != None && B.Enemy.PlayerReplicationInfo != None && B.Enemy.PlayerReplicationInfo.bHasFlag &&
		!B.PlayerReplicationInfo.bHasFlag )
	{
		if (GetOrders() == 'Defend')
		{
			B.FightEnemy(true, 0.0);
			return true;
		}
		else if (B.LineOfSightTo(B.Enemy))
		{
			B.FightEnemy(false, 0.0);
			return true;
		}
	}
	// consider returning orb
	else if ( B.Enemy == None && Team.AI.EnemyTeam.TeamFlag != None && Team.AI.EnemyTeam.TeamFlag.Holder == None &&
		(SquadObjective == None || (SquadObjective.DefenderTeamIndex == Team.TeamIndex && !SquadObjective.bUnderAttack)) &&
		VSize(Team.AI.EnemyTeam.TeamFlag.Location - B.Pawn.Location) < 2000.0 &&
		!B.Pawn.PoweredUp() && B.HasSuperWeapon() == None && !B.HasTimedPowerup() )
	{
		ClosestNode = UTOnslaughtPowerNode(UTOnslaughtGame(WorldInfo.Game).ClosestNodeTo(Team.AI.EnemyTeam.TeamFlag));
		if ( ClosestNode != None && ClosestNode.DefenderTeamIndex == Team.TeamIndex &&
			VSize(ClosestNode.Location - Team.AI.EnemyTeam.TeamFlag.Location) < 2000.0 &&
			FindPathToObjective(B, Team.AI.EnemyTeam.TeamFlag) )
		{
			B.GoalString = "Return enemy orb";
			return true;
		}
	}

	// check if should defend node with orb
	if ( GetOrders() == 'Defend' && UTOnslaughtPowerNode(SquadObjective) != None && SquadObjective.DefenderTeamIndex == Team.TeamIndex &&
		Team.TeamFlag != None && Team.TeamFlag.Holder == None &&
		GetOrbToDefendNode(B) )
	{
		return true;
	}
	// if have flag, core is under attack, and prime node is closer, go there instead
	else if ( B.PlayerReplicationInfo.bHasFlag && ONSTeamAI.FinalCore.bUnderAttack &&
		ONSTeamAI.FinalCore.PoweredBy(Team.AI.EnemyTeam.TeamIndex) &&
		(UTOnslaughtPowerNode(SquadObjective) == None || ONSTeamAI.FinalCore.FindNodeLinkIndex(UTOnslaughtPowerNode(SquadObjective)) == INDEX_NONE) )
	{
		Dist = (SquadObjective != None) ? VSize(B.Pawn.Location - SquadObjective.Location) : 1000000.0;
		for (i = 0; i < ONSTeamAI.FinalCore.NumLinks; i++)
		{
			if ( ONSTeamAI.FinalCore.LinkedNodes[i] != None &&
				VSize(ONSTeamAI.FinalCore.LinkedNodes[i].Location - B.Pawn.Location) < Dist &&
				ONSTeamAI.FinalCore.LinkedNodes[i].DefenderTeamIndex != Team.TeamIndex )
			{
				SetObjective(ONSTeamAI.FinalCore.LinkedNodes[i], false);
				break;
			}
		}
	}

	bResult = Super.CheckSquadObjectives(B);

	if (!bResult && CurrentOrders == 'Freelance' && (B.Enemy == None || B.PlayerReplicationInfo.bHasFlag) && UTOnslaughtObjective(SquadObjective) != None)
	{
		if ( UTOnslaughtObjective(SquadObjective).PoweredBy(Team.TeamIndex) )
		{
			B.GoalString = "Disable Objective "$SquadObjective;
			return (SquadObjective.DefenderTeamIndex == Team.TeamIndex ? SquadObjective.TellBotHowToHeal(B) : SquadObjective.TellBotHowToDisable(B));
		}
		else if ( !B.LineOfSightTo(SquadObjective) )
		{
			B.GoalString = "Harass enemy at "$SquadObjective;
			return FindPathToObjective(B, SquadObjective);
		}
	}

	return bResult;
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, UTBot B)
{
	if ( NewThreat.PlayerReplicationInfo != None && UTOnslaughtObjective(SquadObjective) != None
	     && UTOnslaughtObjective(SquadObjective).LastDamagedBy == NewThreat.PlayerReplicationInfo
	     && UTOnslaughtObjective(SquadObjective).bUnderAttack )
	{
		if ( NewThreat == ONSTeamAI.FinalCore.LastAttacker )
		{
			return current + 6.0;
		}
		if (!bThreatVisible)
		{
			return current + 0.5;
		}
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 2000) || B.Pawn.IsA('Vehicle') || UTWeapon(B.Pawn.Weapon).bSniping
			|| UTOnslaughtObjective(SquadObjective).Health < UTOnslaughtObjective(SquadObjective).DamageCapacity * 0.5 )
		{
			return current + 6.0;
		}
		else
		{
			return current + 1.5;
		}
	}
	else if (NewThreat.PlayerReplicationInfo != None && NewThreat.PlayerReplicationInfo.bHasFlag && bThreatVisible)
	{
		if ( VSize(B.Pawn.Location - NewThreat.Location) < 1500.0 || (B.Pawn.Weapon != None && UTWeapon(B.Pawn.Weapon).bSniping)
			|| (UTOnslaughtPowerNode(SquadObjective) != None && VSize(NewThreat.Location - SquadObjective.Location) < 2000.0) )
		{
			return current + 6.0;
		}
		else
		{
			return current + 1.5;
		}
	}
	else
	{
		return current;
	}
}

function bool MustKeepEnemy(Pawn E)
{
	if ( (E.PlayerReplicationInfo != None) && (UTOnslaughtObjective(SquadObjective) != None) )
	{
		if ( UTOnslaughtObjective(SquadObjective).bUnderAttack && (UTOnslaughtObjective(SquadObjective).LastDamagedBy == E.PlayerReplicationInfo) )
			return true;
		if ( E == ONSTeamAI.FinalCore.LastAttacker )
			return true;
	}
	return false;
}

function SetObjective(UTGameObjective O, bool bForceUpdate)
{
	local UTOnslaughtNodeObjective Node;
	local UTOnslaughtSpecialObjective Best;
	local int i;

	Node = UTOnslaughtNodeObjective(O);
	if (Node != None && Node.ActivatedObjectives.length > 0)
	{
		// consider attacking side objectives instead
		if ( UTOnslaughtSpecialObjective(SquadObjective) != None &&
			Node.ActivatedObjectives.Find(UTOnslaughtSpecialObjective(SquadObjective)) != INDEX_NONE &&
			SquadObjective.IsActive() )
		{
			// keep the current one
			Super.SetObjective(SquadObjective, bForceUpdate);
		}
		else
		{
			Best = None;
			for (i = 0; i < Node.ActivatedObjectives.length; i++)
			{
				if ( Node.ActivatedObjectives[i].IsActive() &&
					(!Node.ActivatedObjectives[i].bNeverDefend || Node.ActivatedObjectives[i].DefenderTeamIndex != Team.TeamIndex) )
				{
					if ( Best == None ||
						(!Best.bMustCompleteToAttackNode && Node.ActivatedObjectives[i].bMustCompleteToAttackNode) ||
						Best.DefensePriority < Node.ActivatedObjectives[i].DefensePriority ||
						( ONSTeamAI != None && ONSTeamAI.ObjectiveCoveredByAnotherSquad(Best, self) &&
							!ONSTeamAI.ObjectiveCoveredByAnotherSquad(Node.ActivatedObjectives[i], self) ) ||
						(Best.DefensePriority == Node.ActivatedObjectives[i].DefensePriority && FRand() < 0.5) )
					{
						Best = Node.ActivatedObjectives[i];
					}
				}
			}
			// if we don't have to do it, sometimes skip it
			if (Best != None && (Best.bMustCompleteToAttackNode || FRand() < (0.1 * Best.DefensePriority)))
			{
				Super.SetObjective(Best, bForceUpdate);
			}
			else
			{
				if ( (Node != SquadObjective) && (UTBot(SquadLeader) != None) )
				{
					UTBot(SquadLeader).SendMessage(None, 'STATUS', 15);
				}
				Super.SetObjective(Node, bForceUpdate);
			}
		}
	}
	else
	{
		Super.SetObjective(O, bForceUpdate);
	}
}

function UTGameObjective GetStartObjective(UTBot B)
{
	local UTOnslaughtFlagBase FlagBase;

	// if bot is attacking a node (not core) and orb is available at base, spawn there instead
	//@todo: what about defending bots if have closest node to enemy core?
	if (GetOrders() == 'ATTACK' && UTOnslaughtPowerNode(SquadObjective) != None && ONSTeamAI.Flag != None && ONSTeamAI.Flag.IsNearlyHome())
	{
		FlagBase = UTOnslaughtFlagBase(ONSTeamAI.Flag.HomeBase);
		if (FlagBase != None && FlagBase.ControllingNode != None && FlagBase.ControllingNode.ValidSpawnPointFor(Team.TeamIndex))
		{
			return FlagBase.ControllingNode;
		}
	}

	return Super.GetStartObjective(B);
}

function MarkHuntingSpots(UTBot B)
{
	local UTOnslaughtObjective ONSObjective;
	local UTDefensePoint DefensePoint;
	local vector StartTrace, TargetLoc;
	local float WeaponRange;

	ONSObjective = UTOnslaughtObjective(SquadObjective);
	if ( ONSObjective != None && ONSObjective.LastAttacker == B.Enemy && B.Pawn.Weapon != None &&
		WorldInfo.TimeSeconds - ONSObjective.LastAttackTime < 3.0 )
	{
		TargetLoc = B.Enemy.GetTargetLocation();
		WeaponRange = B.Pawn.Weapon.MaxRange();
		for (DefensePoint = ONSObjective.DefensePoints; DefensePoint != None; DefensePoint = DefensePoint.NextDefensePoint)
		{
			StartTrace = DefensePoint.Location + (B.Pawn.GetCollisionHeight() + B.Pawn.BaseEyeHeight - DefensePoint.CylinderComponent.CollisionHeight) * vect(0,0,1);
			if (VSize(StartTrace - TargetLoc) < WeaponRange && FastTrace(TargetLoc, StartTrace))
			{
				if (B.Pawn.Anchor == DefensePoint && B.Pawn.ValidAnchor())
				{
					// bot already at a point we thought was good and it isn't, so give up and use direct route
					B.bDirectHunt = true;
					return;
				}
				DefensePoint.bTransientEndPoint = true;
			}
		}
	}
}

function Actor GetTowingDestination(UTVehicle Towed)
{
	local UTOnslaughtPowerNode Node, Best;
	local UTGameObjective O;
	local float Dist, BestDist;

	if (!Towed.PlayerReplicationInfo.bHasFlag || UTOnslaughtPowerNode(SquadObjective) != None)
	{
		return SquadObjective;
	}
	// find closest powernode for orb carrier
	BestDist = 1000000.0;
	for (O = Team.AI.Objectives; O != None; O = O.NextObjective)
	{
		Node = UTOnslaughtPowerNode(O);
		if (Node != None && (Node.DefenderTeamIndex != Team.TeamIndex ? Node.PoweredBy(Team.TeamIndex) : Node.PoweredBy(1 - Team.TeamIndex)))
		{
			Dist = VSize(Node.Location - Towed.Location);
			if (Dist < BestDist)
			{
				Best = Node;
				BestDist = Dist;
			}
		}
	}

	return Best;
}

function ModifyAggression(UTBot B, out float Aggression);

defaultproperties
{
	MaxSquadSize=3
	bAddTransientCosts=true
}
