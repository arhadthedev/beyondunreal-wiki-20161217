/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtTeamAI extends UTTeamAI;

var UTOnslaughtPowerCore FinalCore; //this team's main powercore
/** this team's flag for capturing bunkers */
var UTOnslaughtFlag Flag;
var bool bAllNodesTaken;

function Reset()
{
	Super.Reset();
	bAllNodesTaken = false;
}

function SetObjectiveLists()
{
	Super.SetObjectiveLists();

	FinalCore = UTOnslaughtGame(WorldInfo.Game).PowerCore[Team.TeamIndex];
	if (FinalCore != None && FinalCore.FlagBase != None)
	{
		Flag = FinalCore.FlagBase.myFlag;
	}
}

function ReAssessStrategy()
{
	local UTGameObjective O;
	local UTBot M;

	if (FreelanceSquad == None)
		return;

	if ( (FinalCore == None) || (UTOnslaughtTeamAI(EnemyTeam.AI).FinalCore == None) )
	{
		Super.ReAssessStrategy();
		return;
	}

	// if going after barricade and already got needed weapon, don't retask now
	if (UTWarfareBarricade(FreelanceSquad.SquadObjective) != None)
	{
		for (M = FreelanceSquad.SquadMembers; M != None; M = M.NextSquadMember)
		{
			if (M.HasBarricadeDestroyingWeapon())
			{
				return;
			}
		}
	}

	if ( FinalCore.PoweredBy(EnemyTeam.TeamIndex) || UTOnslaughtTeamAI(EnemyTeam.AI).FinalCore.PoweredBy(Team.TeamIndex)
	     || (WorldInfo.Game.bOverTime && FinalCore.Health < UTOnslaughtTeamAI(EnemyTeam.AI).FinalCore.Health) )
	{
		FreelanceSquad.bFreelanceAttack = true;
		FreelanceSquad.bFreelanceDefend = false;
		O = GetPriorityAttackObjectiveFor(FreelanceSquad, FreelanceSquad.SquadLeader);
	}
	else if (WorldInfo.Game.bOverTime && FinalCore.Health > UTOnslaughtTeamAI(EnemyTeam.AI).FinalCore.Health)
	{
		FreelanceSquad.bFreelanceAttack = false;
		FreelanceSquad.bFreelanceDefend = true;
		O = GetLeastDefendedObjective(FreelanceSquad.SquadLeader);
	}
	else
	{
		FreelanceSquad.bFreelanceAttack = false;
		FreelanceSquad.bFreelanceDefend = false;
		O = GetPriorityFreelanceObjectiveFor(FreelanceSquad);
	}

	if ( (O != None) && (O != FreelanceSquad.SquadObjective) )
		FreelanceSquad.SetObjective(O,true);
}

function CriticalObjectiveWarning(UTGameObjective AttackedObjective, Pawn EventInstigator)
{
	local UTSquadAI S;
	local UTBot M;
	local bool bFoundDefense;

	for (S = Squads; S != None; S = S.NextSquad)
		if (S.SquadObjective == AttackedObjective)
		{
			bFoundDefense = true;
			if ( EventInstigator != None )
			{
				S.CriticalObjectiveWarning(EventInstigator);
				for (M = S.SquadMembers; M != None; M = M.NextSquadMember)
					if ( (M.Enemy == None || M.Enemy == EventInstigator) && UTVehicle(M.Pawn) != None && (M.Pawn.bStationary || UTVehicle(M.Pawn).bIsOnTrack)
						&& !FastTrace(EventInstigator.Location + EventInstigator.GetCollisionHeight() * vect(0,0,1), M.Pawn.Location) )
					{
						UTVehicle(M.Pawn).DriverLeave(false);
						M.WhatToDoNext();
					}
			}
		}

	if ( !bFoundDefense )
	{
		for (S = Squads; S != None; S = S.NextSquad)
			if ( (S.GetOrders() == 'Defend' || S.bFreelanceDefend)
			     && (UTOnslaughtObjective(S.SquadObjective) == None || (!UTOnslaughtObjective(S.SquadObjective).bUnderAttack && !UTOnslaughtObjective(S.SquadObjective).IsNeutral())) )
			{
				S.SetObjective(AttackedObjective, true);
				if ( EventInstigator != None )
					S.CriticalObjectiveWarning(EventInstigator);
				return;
			}
	}
}

/** @return Squads with primary attack squad(s) first, defense second, freelance third, others last
 * this is used when evaulating objective changes to make sure primary squads get the most important objectives
 * regardless of the order they were added
 */
function GetSquadsOrdered(out array<UTSquadAI> SquadList)
{
	local UTSquadAI S;
	local int DefenseStartIndex, FreelanceStartIndex, OtherStartIndex;

	for (S = Squads; S != None; S = S.NextSquad)
	{
		S.GetOrders();
		if (S.CurrentOrders == 'Freelance' || S.bFreelance)
		{
			SquadList.InsertItem(OtherStartIndex, S);
			OtherStartIndex++;
		}
		else if (S.CurrentOrders == 'Attack')
		{
			SquadList.InsertItem(DefenseStartIndex, S);
			DefenseStartIndex++;
			FreelanceStartIndex++;
			OtherStartIndex++;
		}
		else if (S.CurrentOrders == 'Defend')
		{
			SquadList.InsertItem(FreelanceStartIndex, S);
			FreelanceStartIndex++;
			OtherStartIndex++;
		}
		else
		{
			SquadList.AddItem(S);
		}
	}
}

function FindNewObjectives(UTGameObjective DisabledObjective)
{
	local UTSquadAI S, OtherSquad;
	local UTBot M;
	local UTOnslaughtNodeObjective Core, DisabledCore;
	local UTOnslaughtSpecialObjective SpecialObjective;
	local UTGameObjective O;
	local int i, SquadIndex;
	local bool bHasVulnerableNode, bCovered;
	local array<UTSquadAI> SquadList;

	for ( O=Team.AI.Objectives; O!=None; O=O.NextObjective )
	{
		Core = UTOnslaughtNodeObjective(O);
		if (Core != None && Core.IsActive() && Core.DefenderTeamIndex == Team.TeamIndex && Core.PoweredBy(EnemyTeam.TeamIndex))
		{
			bHasVulnerableNode = true;
			break;
		}
	}

	SpecialObjective = UTOnslaughtSpecialObjective(DisabledObjective);
	DisabledCore = UTOnslaughtNodeObjective(DisabledObjective);
	GetSquadsOrdered(SquadList);
	for (SquadIndex = 0; SquadIndex < SquadList.length; SquadIndex++)
	{
		S = SquadList[SquadIndex];
		Core = UTOnslaughtNodeObjective(S.SquadObjective);
		// if current objective is invalid, disabled, or the disabled objective is required for our objective
		if ( Core == None || Core.bIsDisabled ||
			(SpecialObjective != None && SpecialObjective.bMustCompleteToAttackNode && Core.ActivatedObjectives.Find(SpecialObjective) != INDEX_NONE) )
		{
			FindNewObjectiveFor(S, false);
		}
		else if (S.CurrentOrders == 'Attack' || S.bFreelanceAttack || (!bHasVulnerableNode && (S.CurrentOrders == 'Defend' || S.bFreelanceDefend)))
		{
			if ( (Core.DefenderTeamIndex == Team.TeamIndex && Core.IsActive())
			     || (!Core.PoweredBy(Team.TeamIndex) && (bHasVulnerableNode || !Core.LinkedToCoreConstructingFor(Team.TeamIndex))) )
			{
				FindNewObjectiveFor(S, false);
			}
			else if ( Core.IsCurrentlyDestroyed() )
			{
				for (M = S.SquadMembers; M != None; M = M.NextSquadMember)
					if ( M.IsInState('RangedAttack') ) //just finished destroying node, now take it over
						M.WhatToDoNext();
			}
			else if (DisabledCore != None && DisabledCore.DefenderTeamIndex != Team.TeamIndex && FinalCore.LinkedTo(DisabledCore))
			{
				// check that somebody is trying to recover prime node
				for (OtherSquad = Squads; OtherSquad != None; OtherSquad = OtherSquad.NextSquad)
				{
					// ignore defending squads because they are probably going to get retasked to defend the core
					if (OtherSquad.SquadObjective == DisabledCore && OtherSquad.GetOrders() != 'Defend')
					{
						bCovered = true;
						break;
					}
				}
				if (!bCovered)
				{
					S.SetObjective(DisabledCore, true);
				}
			}
		}
		else if (S.CurrentOrders == 'Defend' || S.bFreelanceDefend)
		{
			if ( !Core.IsNeutral() && !Core.IsCurrentlyDestroyed() && (Core.DefenderTeamIndex != Team.TeamIndex || !Core.PoweredBy(EnemyTeam.TeamIndex)) )
			{
				FindNewObjectiveFor(S, false);
			}
			else
			{
				//check if objective with higher defensepriority is now vulnerable
				if (DisabledCore != None && DisabledCore.IsActive())
				{
					for (i = 0; i < DisabledCore.NumLinks; i++)
					{
						if ( DisabledCore.LinkedNodes[i].DefensePriority > Core.DefensePriority &&
							(DisabledCore.LinkedNodes[i].DefenseSquad == None || DisabledCore.LinkedNodes[i].DefenseSquad.Team != Team) &&
							DisabledCore.LinkedNodes[i].PoweredBy(EnemyTeam.TeamIndex) )
						{
							S.SetObjective(DisabledCore.LinkedNodes[i], true);
							break;
						}
					}
				}
			}
		}
		else
			FindNewObjectiveFor(S, false);
	}
}

/** returns true if the given objective is a SquadObjective for some other squad on this team than the passed in squad
 * @param O - the objective to test for
 * @param IgnoreSquad - squad to ignore (because we're calling this while evaluating changing its objective)
 * @param bRequireAttackSquad (opt) - if true, only count as covered if at least one squad has 'Attack' orders
 * @param RequiredAttackers (opt) - only valid if bRequireAttackSquad - only count as covered if this many bots are covering it
 * @return whether the objective is sufficiently covered by another squad
 */
function bool ObjectiveCoveredByAnotherSquad(UTGameObjective O, UTSquadAI IgnoreSquad, optional bool bRequireAttackSquad, optional int RequiredAttackers)
{
	local UTSquadAI S;
	local UTOnslaughtNodeObjective Node;
	local int i, NumCovering;
	local bool bSpecialObjectivesCovered, bGotAttackSquad;

	// for nodes, if special objectives must be done first, check them instead
	Node = UTOnslaughtNodeObjective(O);
	if (Node != None && Node.ActivatedObjectives.length > 0)
	{
		for (i = 0; i < Node.ActivatedObjectives.length; i++)
		{
			if (Node.ActivatedObjectives[i].bMustCompleteToAttackNode && Node.ActivatedObjectives[i].IsActive())
			{
				if (!ObjectiveCoveredByAnotherSquad(Node.ActivatedObjectives[i], IgnoreSquad, bRequireAttackSquad, RequiredAttackers))
				{
					return false;
				}
				bSpecialObjectivesCovered = true;
			}
		}
		if (bSpecialObjectivesCovered)
		{
			return true;
		}
	}

	for (S = Squads; S != None; S = S.NextSquad)
	{
		if (S.SquadObjective == O && S != IgnoreSquad)
		{
			if (!bRequireAttackSquad)
			{
				return true;
			}
			bGotAttackSquad = (bGotAttackSquad || S.GetOrders() == 'Attack');
			NumCovering += S.Size;
			if (bGotAttackSquad && NumCovering >= RequiredAttackers)
			{
				return true;
			}
		}
	}

	return false;
}

function UTGameObjective GetPriorityAttackObjectiveFor(UTSquadAI AnAttackSquad, Controller InController)
{
	local UTGameObjective O;
	local UTOnslaughtNodeObjective Node, PickedNode, NextPickedNode;
	local array<UTOnslaughtNodeObjective> NodeList;
	local int i;
	local bool bPickedObjectiveCovered, bTestObjectiveCovered;
	local bool bCheckDistance;
	local float BestDistSq, NewDistSq;

	bCheckDistance = (InController != None) && (InController.Pawn != None);

	PickedObjective = None;
	for (O = Objectives; O != None; O = O.NextObjective)
	{
		Node = UTOnslaughtNodeObjective(O);
		if ( Node != None && !Node.bIsDisabled && (Node.DefenderTeamIndex != Team.TeamIndex || !Node.IsActive())
			&& Node.PoweredBy(Team.TeamIndex) )
		{
			// if we're testing an attack squad going to a linked (not standalone) node, only count other attack squads here
			// as squads with other orders may get repurposed and not actually make it to the objective
			if (AnAttackSquad != None)
			{
				bTestObjectiveCovered = ObjectiveCoveredByAnotherSquad(Node, AnAttackSquad, (!Node.bStandalone && AnAttackSquad.CurrentOrders == 'Attack'), AnAttackSquad.Size);
			}
			else
			{
				bTestObjectiveCovered = ObjectiveCoveredByAnotherSquad(Node, None);
			}
			if ( (PickedNode == None) || (!bTestObjectiveCovered && (bPickedObjectiveCovered || PickedNode.DefensePriority < Node.DefensePriority)) )
			{
				PickedNode = Node;
				bPickedObjectiveCovered = bTestObjectiveCovered;
				if (bCheckDistance)
				{
					BestDistSq = VSizeSq(PickedNode.Location - InController.Pawn.Location);
				}
			}
			else if ( bCheckDistance && (PickedNode.DefensePriority == O.DefensePriority) && (bPickedObjectiveCovered == bTestObjectiveCovered) )
			{
				// prioritize closer nodes
				NewDistSq = VSizeSq(Node.Location - InController.Pawn.Location);
				if ( NewDistSq < BestDistSq )
				{
					PickedNode = Node;
					BestDistSq = NewDistSq;
					bPickedObjectiveCovered = bTestObjectiveCovered;
				}
			}
		}
	}
	if (PickedNode != None && bPickedObjectiveCovered)
	{
		// make list of nodes that will be attainable when this node is taken
		//but only if this one is neutral or owned by this team because don't want bots waiting on "future" nodes
		//while a single squad futilely attacks the enemy controlled node!
		if (PickedNode.DefenderTeamIndex == Team.TeamIndex || (!PickedNode.IsActive() && !PickedNode.bIsConstructing) )
		{
			for (i = 0; i < PickedNode.NumLinks; i++ )
			{
				if ( (PickedNode.LinkedNodes[i] != None)
					&& (PickedNode.LinkedNodes[i].IsNeutral() || PickedNode.LinkedNodes[i].bIsConstructing) )
				{
					NodeList[NodeList.length] = PickedNode.LinkedNodes[i];
				}
			}

			for (i = 0; i < NodeList.length; i++)
			{
				// pick highest priority node not already taken by another squad
				if ( !ObjectiveCoveredByAnotherSquad(NodeList[i], AnAttackSquad) &&
					( NextPickedNode == None || NextPickedNode.DefensePriority < NodeList[i].DefensePriority
						|| (NextPickedNode.DefensePriority == NodeList[i].DefensePriority && FRand() < 0.5) ) )
				{
					NextPickedNode = NodeList[i];
				}
			}

			if (NextPickedNode != None)
			{
				PickedNode = NextPickedNode;
			}
		}
	}
	PickedObjective = PickedNode;
	return PickedObjective;
}

function UTGameObjective GetLeastDefendedObjective(Controller InController)
{
	local UTGameObjective O, Best;
	local bool bCheckDistance;
	local float BestDistSq, NewDistSq;

	bCheckDistance = (InController != None) && (InController.Pawn != None);
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (O.DefenderTeamIndex == Team.TeamIndex) && UTOnslaughtObjective(O) != None && UTOnslaughtObjective(O).IsActive()
			&& UTOnslaughtObjective(O).PoweredBy(EnemyTeam.TeamIndex) )
		{
			if ( (Best == None) || (Best.DefensePriority < O.DefensePriority) )
			{
				Best = O;
				if (bCheckDistance)
				{
					BestDistSq = VSizeSq(Best.Location - InController.Pawn.Location);
				}
			}
			else if ( Best.DefensePriority == O.DefensePriority )
			{
				// prioritize less defended or closer nodes
				if (Best.GetNumDefenders() > O.GetNumDefenders())
				{
					Best = O;
					if (bCheckDistance)
					{
						BestDistSq = VSizeSq(Best.Location - InController.Pawn.Location);
					}
				}
				else if (bCheckDistance)
				{
					NewDistSq = VSizeSq(Best.Location - InController.Pawn.Location);
					if (NewDistSq < BestDistSq)
					{
						Best = O;
						BestDistSq = NewDistSq;
					}
				}
			}
		}
	}
	if (Best == None)
		Best = GetPriorityAttackObjectiveFor(None, InController); //nothing needs defending, so head to neutral node

	return Best;
}

function UTGameObjective GetPriorityPlayerAttackObjectiveFor(UTPlayerController PC)
{
	local UTGameObjective O, PlayerPickedObjective;
	local UTOnslaughtNodeObjective Node;
	local bool bCheckDistance;
	local float BestDistSq, NewDistSq;

	// keep same objective to attack if still valid
	Node = UTOnslaughtNodeObjective(PC.LastAutoObjective);
	if ( Node != None && !Node.bIsDisabled && (Node.DefenderTeamIndex != Team.TeamIndex || !Node.IsActive())
		&& Node.PoweredBy(Team.TeamIndex) )
	{
		return Node;
	}

	bCheckDistance = (PC != None) && (PC.Pawn != None);

	PlayerPickedObjective = None;
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		Node = UTOnslaughtNodeObjective(O);
		if ( Node != None && !Node.bIsDisabled && (Node.DefenderTeamIndex != Team.TeamIndex || !Node.IsActive())
			&& Node.PoweredBy(Team.TeamIndex) )
		{
			if ( (PlayerPickedObjective == None) || (PlayerPickedObjective.DefensePriority < Node.DefensePriority) )
			{
				PlayerPickedObjective = Node;
				if (bCheckDistance)
				{
					BestDistSq = VSizeSq(PlayerPickedObjective.Location - PC.Pawn.Location);
				}
			}
			else if ( bCheckDistance && (PlayerPickedObjective.DefensePriority == O.DefensePriority) )
			{
				// prioritize closer nodes
				NewDistSq = VSizeSq(Node.Location - PC.Pawn.Location);
				if ( NewDistSq < BestDistSq )
				{
					PlayerPickedObjective = Node;
					BestDistSq = NewDistSq;
				}
			}
		}
	}
	return PlayerPickedObjective;
}

function UTGameObjective GetLeastDefendedPlayerObjective(UTPlayerController PC)
{
	local UTGameObjective O, Best;
	local bool bCheckDistance;
	local float BestDistSq, NewDistSq;

	bCheckDistance = (PC != None) && (PC.Pawn != None);
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (O.DefenderTeamIndex == Team.TeamIndex) && UTOnslaughtObjective(O) != None && UTOnslaughtObjective(O).IsActive()
			&& UTOnslaughtObjective(O).PoweredBy(EnemyTeam.TeamIndex) )
		{
			if ( (Best == None) || (Best.DefensePriority < O.DefensePriority) )
			{
				Best = O;
				if (bCheckDistance)
				{
					BestDistSq = VSizeSq(Best.Location - PC.Pawn.Location);
				}
			}
			else if ( Best.DefensePriority == O.DefensePriority )
			{
				// prioritize less defended or closer nodes
				if (Best.GetNumDefenders() > O.GetNumDefenders())
				{
					Best = O;
					if (bCheckDistance)
					{
						BestDistSq = VSizeSq(Best.Location - PC.Pawn.Location);
					}
				}
				else if (bCheckDistance)
				{
					NewDistSq = VSizeSq(Best.Location - PC.Pawn.Location);
					if (NewDistSq < BestDistSq)
					{
						Best = O;
						BestDistSq = NewDistSq;
					}
				}
			}
		}
	}

	if ( Best == None )
	{
		Best = GetPriorityPlayerAttackObjectiveFor(PC);
	}

	return Best;
}

function bool PutOnDefense(UTBot B)
{
	local UTGameObjective O;

	O = GetLeastDefendedObjective(B);
	if ( O != None )
	{
		//we need this because in Onslaught, unlike other gametypes, two defending squads (possibly from different teams!)
		//could be headed to the same objective
		if ( O.DefenseSquad == None || O.DefenseSquad.Team != Team )
		{
			O.DefenseSquad = AddSquadWithLeader(B, O);
			UTOnslaughtSquadAI(O.DefenseSquad).bDefendingSquad = true;
		}
		else
			O.DefenseSquad.AddBot(B);
		return true;
	}
	return false;
}

function bool IsFastFreelanceObjective(UTOnslaughtObjective Core)
{
	return ( (Core != None) && Core.IsNeutral() && (Core.PoweredBy(Team.TeamIndex) || Core.LinkedToCoreConstructingFor(Team.TeamIndex)) );
}

function float CoreAvailabilityScore(UTOnslaughtNodeObjective Core)
{
	if ( !IsFastFreelanceObjective(Core) )
		return -1;

	// distinguish based on whether enemy can get this node as well
	if ( Core.PoweredBy(1-Team.TeamIndex) )
		return 1;

	if ( Core.LinkedToCoreConstructingFor(1-Team.TeamIndex) )
		return 2;

	// if only linked to power core, lower score
	if ( Core.NumLinks == 1 )
		return 3;

	return 4;
}

function UTGameObjective FindFastFreelanceObjective()
{
	local UTGameObjective O;
	local UTOnslaughtNodeObjective OPC, Best;
	local float BestRating, NewRating;
	local float BestScore, NewScore;

	if ( (FreelanceSquad != None) && IsFastFreelanceObjective(UTOnslaughtObjective(FreelanceSquad.SquadObjective)) )
		return FreelanceSquad.SquadObjective;

	//find a node that the enemy wants to get (regardless of whether this team can get it)
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		OPC = UTOnslaughtNodeObjective(O);
		if ( OPC != None )
		{
			NewScore = CoreAvailabilityScore(OPC);
			//`log("Team "$Team.TeamIndex$" score for node "$OPC.NodeNum$" ("$OPC$") is "$NewScore$" vs best "$BestScore);
			if ( NewScore >= BestScore )
			{
				if ( BestScore < NewScore )
					Best = None;
				NewRating = OPC.RateCore();
				if ( (Best == None) || (NewRating > BestRating) )
				{
					Best = OPC;
					BestRating = NewRating;
					BestScore = NewScore;
				}
			}
		}
	}
	//`log("Team "$Team.TeamIndex$" best node "$best.NodeNum$" ("$best$")");
	if ( Best == None )
		bAllNodesTaken = true;
	return Best;
}

function UTGameObjective GetPriorityFreelanceObjectiveFor(UTSquadAI InFreelanceSquad)
{
	local UTGameObjective O, Best;
	local UTOnslaughtObjective Core;

	if ( !bAllNodesTaken )
	{
		Best = FindFastFreelanceObjective();
		if ( !bAllNodesTaken )
			return Best;
	}

	//find a node that the enemy wants to get (regardless of whether this team can get it)
	for (O = Objectives; O != None; O = O.NextObjective)
	{
		Core = UTOnslaughtObjective(O);
		if ( Core != None && (Core.IsNeutral() || Core.bIsConstructing) && Core.DefenderTeamIndex != Team.TeamIndex
		     && Core.PoweredBy(EnemyTeam.TeamIndex) && (Best == None || Best.DefensePriority < Core.DefensePriority) )
			Best = O;
	}
	if (Best == None)
		Best = GetPriorityAttackObjectiveFor(InFreelanceSquad, (InFreelanceSquad != None) ? InFreelanceSquad.SquadLeader : None);

	return Best;
}

defaultproperties
{
	OrderList(0)=ATTACK
	OrderList(1)=ATTACK
	OrderList(2)=DEFEND
	OrderList(3)=FREELANCE
	OrderList(4)=DEFEND
	OrderList(5)=ATTACK
	OrderList(6)=ATTACK
	OrderList(7)=ATTACK
	SquadType=class'UTGame.UTOnslaughtSquadAI'
}

