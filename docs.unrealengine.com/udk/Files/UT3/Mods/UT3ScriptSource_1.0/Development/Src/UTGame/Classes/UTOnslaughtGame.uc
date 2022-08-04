/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtGame extends UTTeamGame
	abstract;

var array<UTOnslaughtObjective> PowerNodes;
var UTOnslaughtPowerCore PowerCore[2];

var float OvertimeCoreDrainPerSec;
var config bool bSwapSidesAfterReset;
var bool bSidesAreSwitched;

var bool	bSpawnNodeSelected;		/** temporarily set true if player had chosen his start position, to prevent him from being teleported to a super vehicle */

function InitGameReplicationInfo()
{
	local UTOnslaughtMapInfo OnslaughtInfo;

	Super.InitGameReplicationInfo();

	// tell GRI what link setup we're using to replicate to clients
	OnslaughtInfo = UTOnslaughtMapInfo(WorldInfo.GetMapInfo());
	if (OnslaughtInfo != None)
	{
		UTOnslaughtGRI(WorldInfo.GRI).LinkSetupName = OnslaughtInfo.GetActiveSetupName();
	}
}

event PostLogin(PlayerController PC)
{
	Super.PostLogin(PC);

	UpdateNodePlayerCountRequirements(false);
}

event Logout(Controller Exiting)
{
	Super.Logout(Exiting);

	UpdateNodePlayerCountRequirements(false);
}

function UTBot AddBot(optional string BotName, optional bool bUseTeamIndex, optional int TeamIndex)
{
	local UTBot B;

	B = Super.AddBot(BotName, bUseTeamIndex, TeamIndex);
	UpdateNodePlayerCountRequirements(false);
	return B;
}

/** update the state of nodes with player count requirements because the number of players in the game has changed */
function UpdateNodePlayerCountRequirements(bool bAllowDuringGame)
{
	local int i;
	local UTOnslaughtNodeObjective Node;

	if (!GameReplicationInfo.bMatchHasBegun || bAllowDuringGame || WorldInfo.IsPlayInEditor())
	{
		for (i = 0; i < PowerNodes.length; i++)
		{
			Node = UTOnslaughtNodeObjective(PowerNodes[i]);
			if (Node != None && !Node.IsA('UTOnslaughtPowerCore') && Node.MinPlayerCount > 0 && (Node.bStandalone || Node.NumLinks > 0))
			{
				if (NumPlayers + NumBots >= Node.MinPlayerCount)
				{
					if (Node.bIsDisabled)
					{
						Node.SetInitialState();
					}
				}
				else if (!Node.bIsDisabled)
				{
					Node.GotoState('DisabledNode');
				}
			}
		}
	}
}

// Returns whether a mutator should be allowed with this gametype
static function bool AllowMutator( string MutatorClassName )
{
	if (MutatorClassName ~= "UTGame.UTMutator_NoOrbs")
	{
		// No Orbs mutator only for Warfare
		return true;
	}
	if ( (MutatorClassName ~= "UTGame.UTMutator_Instagib") || (MutatorClassName ~= "UTGame.UTMutator_WeaponsRespawn")
		|| (MutatorClassName ~= "UTGame.UTMutator_LowGrav") )
	{
		return false;
	}
	return Super.AllowMutator(MutatorClassName);
}

function bool DominatingVictory()
{
	if ( Teams[0].Score == 0 )
	{
		return (PowerCore[1].Health >= PowerCore[1].default.DamageCapacity);
	}
	else if ( Teams[1].Score == 0 )
	{
		return (PowerCore[0].Health >= PowerCore[0].default.DamageCapacity);
	}
	return false;
}

/** return a value based on how much this pawn needs help */
function int GetHandicapNeed(Pawn Other)
{
	local int HealthDifference;

	if ( (Other.PlayerReplicationInfo == None) || (Other.PlayerReplicationInfo.Team == None) )
	{
		return 0;
	}

	// base handicap on how far team is behind in powercore health
	HealthDifference = PowerCore[1 - Other.PlayerReplicationInfo.Team.TeamIndex].Health - PowerCore[Other.PlayerReplicationInfo.Team.TeamIndex].Health;
	if (  HealthDifference < 10 )
	{
		// team is ahead, or close
		return 0;
	}
	return HealthDifference/10;
}

/**
In Onslaught, vehicle factories are activated by active powernodes
*/
function ActivateVehicleFactory(UTVehicleFactory VF)
{
	VF.bStartNeutral = false;
}

event InitGame(string Options, out string ErrorMessage)
{
	local UTOnslaughtObjective O;
	local string LinkSetupName;
	local UTOnslaughtMapInfo OnslaughtInfo;

	Super.InitGame(Options, ErrorMessage);

	foreach AllActors(class'UTOnslaughtObjective', O)
	{
		// Register all the PowerNodes
		PowerNodes[PowerNodes.length] = O;
	}

	// set up startup link setup, if any
	OnslaughtInfo = UTOnslaughtMapInfo(WorldInfo.GetMapInfo());
	if (OnslaughtInfo != None)
	{
		// if we are in the editor, use the LD specified preview setup
		if (OnslaughtInfo.EditorPreviewSetup != 'None')
		{
			OnslaughtInfo.ApplyLinkSetup(OnslaughtInfo.EditorPreviewSetup);
		}
		else
		{
			LinkSetupName = ParseOption(Options, "LinkSetup");
			OnslaughtInfo.ApplyLinkSetup((LinkSetupName != "") ? name(LinkSetupName) : 'Default');
		}
	}

	SetPowerCores();
	FindCloseActors();

	if (PowerNodes.Length == 0)
	{
		`log("Onslaught: Level doesn't have any PowerNodes!",,'Error');
	}
}

function CreateTeam(int TeamIndex)
{
	Super.CreateTeam(TeamIndex);

	if (TeamIndex < ArrayCount(Teams) && TeamIndex < ArrayCount(PowerCore))
	{
		Teams[TeamIndex].HomeBase = PowerCore[TeamIndex];
	}
}

/* FindCloseActors()
Associate certain actor classes with neares Onslaught Objective
*/
function FindCloseActors()
{
	local Actor A;
	local UTOnslaughtObjective O;
	local UTOnslaughtPowerCore ReverseCore;
	local UTOnslaughtNodeObjective Node;
	local int i;

	for (i = 0; i < PowerNodes.Length; i++)
	{
		PowerNodes[i].InitCloseActors();
	}

	if ( PowerCore[0].bReverseForThisCore )
		ReverseCore = PowerCore[0];
	else if ( PowerCore[1].bReverseForThisCore )
		ReverseCore = PowerCore[1];

	ForEach AllActors(class 'Actor', A)
	{
		if ( PlayerStart(A) != None )
		{
			O = ClosestObjectiveTo(A);
			O.PlayerStarts[O.PlayerStarts.Length] = PlayerStart(A);
		}
		else if ( UTVehicleFactory(A) != None )
		{
			UTVehicleFactory(A).AddToClosestObjective();
			UTVehicleFactory(A).ReverseObjective = ReverseCore;
		}
		else if (UTOnslaughtNodeEnhancement(A) != None)
		{
			if (UTOnslaughtNodeEnhancement(A).ControllingNode == None)
			{
				UTOnslaughtNodeEnhancement(A).SetControllingNode(ClosestNodeTo(A));
			}
		}
		else if(UTDeployableNodeLocker(A) != none)
		{
			UTDeployableNodeLocker(A).AddToClosestObjective();
		}
		else if (UTOnslaughtNodeTeleporter(A) != None)
		{
			Node = ClosestNodeTo(A);
			Node.NodeTeleporters[Node.NodeTeleporters.length] = UTOnslaughtNodeTeleporter(A);
		}
	}
}

/* SetPowerCores()
Find the Red and Blue team PowerCores
Set the distance in hops from every PowerNode to each powercore
*/
function SetPowerCores()
{
	local int i;
	local int CoreCnt, PrefTeam;
	local UTOnslaughtPowerCore PC;
	local UTOnslaughtNodeObjective Node;
	local bool bTooManyCores;
	local byte MaxDistance, DesiredDistance;

	for (i = 0; i < ArrayCount(PowerCore); i++)
	{
		PowerCore[i] = None;
	}

	CoreCnt = 0;

	// Find the two powercores
	for (i=0; i<PowerNodes.Length; i++)
	{
		PC = UTOnslaughtPowerCore(PowerNodes[i]);
		if ( PC != None  )
		{
			if (CoreCnt < 2)
			{
				// figure out the team
				PrefTeam = bSidesAreSwitched ? 1 - CoreCnt : CoreCnt;

				// If this core's slot is taken, move the person there
				if ( PowerCore[PrefTeam] != None )
				{
					PowerCore[1-PrefTeam] = PowerCore[PrefTeam];
					PowerCore[1-PrefTeam].DefenderTeamIndex = 1-PrefTeam;
				}

				PowerCore[PrefTeam] = PC;
				PowerCore[PrefTeam].DefenderTeamIndex = PrefTeam;
				if (Teams[PrefTeam] != None)
				{
					Teams[PrefTeam].HomeBase = PC;
				}
			}
			else
			{

				// If we have more than 2 cores, flag it for a warning, but
				// also reset the core just in case :)

				bTooManyCores = true;
				PC.Reset();
			}

			CoreCnt++;
		}

		// clear core distance - will be reinitialized in the PowerCores' InitializeForThisRound()
		PowerNodes[i].FinalCoreDistance[0] = 255;
		PowerNodes[i].FinalCoreDistance[1] = 255;
		// initialize links - make sure they are all two way
		Node = UTOnslaughtNodeObjective(PowerNodes[i]);
		if (Node != None)
		{
			Node.InitLinks();
		}

	}

	PowerCore[0].Reset();
	PowerCore[0].InitializeForThisRound(0);
	PowerCore[1].Reset();
	PowerCore[1].InitializeForThisRound(1);

	// init core distance for standalone nodes using StandaloneSpawnPriority, since the cores won't be linked to us so it won't get set normally
	MaxDistance = Max(PowerCore[0].FinalCoreDistance[1], PowerCore[1].FinalCoreDistance[0]) - 1;
	for (i = 0; i < PowerNodes.length; i++)
	{
		Node = UTOnslaughtNodeObjective(PowerNodes[i]);
		if (Node != None && Node.bStandalone)
		{
			DesiredDistance = (Node.StandaloneSpawnPriority != 255) ? Node.StandaloneSpawnPriority : MaxDistance;
			Node.SetCoreDistance(0, DesiredDistance);
			Node.SetCoreDistance(1, DesiredDistance);
		}
	}

	if (bTooManyCores)
	{
		`log("!! TOO MANY CORES FOUND IN MAP (found "$CoreCnt$" expect no more than 2) !!");
	}

}

/* UpdateLinks()
determine which powernodes are severed
*/
function UpdateLinks()
{
	local int i;
	local UTOnslaughtNodeObjective N;

	for (i = 0; i < PowerNodes.Length; i++)
	{
		N = UTOnslaughtNodeObjective(PowerNodes[i]);
		if ( N != None )
		{
			N.bWasSevered = N.bSevered;
			N.bSevered = !N.bStandalone;
		}
	}

	CheckSevering(PowerCore[0], 0);
	CheckSevering(PowerCore[1], 1);

	for (i = 0; i < PowerNodes.Length; i++)
	{
 		N = UTOnslaughtNodeObjective(PowerNodes[i]);
		if ( N != None  && N.bSevered && !N.bWasSevered )
			N.Sever();
	}
}

function CheckSevering(UTOnslaughtNodeObjective PC, int TeamIndex)
{
	local int i;

	PC.bSevered = False;
	if ( !PC.IsActive() )
	{
		return;
	}
	for (i = 0; i < PC.NumLinks; i++)
	{
		if (PC.LinkedNodes[i] != None && PC.LinkedNodes[i].bSevered && PC.LinkedNodes[i].DefenderTeamIndex == TeamIndex)
		{
			CheckSevering(PC.LinkedNodes[i], TeamIndex);
		}
	}
}


function UTOnslaughtNodeObjective ClosestNodeTo(Actor A)
{
	local float Distance, BestDistance;
	local UTOnslaughtNodeObjective Node, Best;
	local int i;

	for (i = 0; i < PowerNodes.Length; i++)
	{
		Node = UTOnslaughtNodeObjective(PowerNodes[i]);
		if (Node != None)
		{
			Distance = VSize(A.Location - PowerNodes[i].Location);
			if (Best == None || Distance < BestDistance)
			{
				BestDistance = Distance;
				Best = Node;
			}
		}
	}
	return Best;
}

function UTOnslaughtObjective ClosestObjectiveTo(Actor A)
{
	local float Distance, BestDistance;
	local UTOnslaughtObjective Best;
	local int i;

	for ( i=0; i<PowerNodes.Length; i++ )
	{
		Distance = VSize(A.Location - PowerNodes[i].Location);
		if ( (Best == None) || (Distance < BestDistance) )
		{
			BestDistance = Distance;
			Best = PowerNodes[i];
		}
	}
	return Best;
}

function bool ShouldReset(Actor ActorToReset)
{
	return ( Super.ShouldReset(ActorToReset) && !ActorToReset.IsA('UTOnslaughtObjective') && !ActorToReset.IsA('TeamInfo') &&
		!ActorToReset.IsA('PlayerReplicationInfo') );
}

function Reset()
{
	local int i;
	local UTPlayerReplicationInfo PRI;

	// we reset PowerNodes and PowerCores after everything else because their reset might cause
	// vehiclefactories, etc to activate and spawn new actors that we don't want to affect
	if (bSwapSidesAfterReset && !PowerCore[0].bNoCoreSwitch && !PowerCore[1].bNoCoreSwitch)
	{
		bSidesAreSwitched = !bSidesAreSwitched;
	}

	SetPowerCores();

	for (i = 0; i < PowerNodes.length; i++)
	{
		// powercores are reset in SetPowerCores()
		if (UTOnslaughtPowerCore(PowerNodes[i]) == None)
		{
			PowerNodes[i].Reset();
		}
	}

	FindCloseActors();

	UpdateNodePlayerCountRequirements(true);

	Super.Reset();

	// reset per-life PRI properties
	for (i = 0; i < GameReplicationInfo.PRIArray.length; i++)
	{
		PRI = UTPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]);
		if (PRI != None)
		{
			PRI.Spree = 0;
		}
	}

	for (i = 0; i < ArrayCount(Teams); i++)
	{
		Teams[i].AI.SetObjectiveLists();
	}
}

State MatchInProgress
{
	event Timer()
	{
		local int i, TeamNodes[2], TotalNodes;
		local float OvertimeDrain;

		if (bOverTime)
		{
			for (i = 0; i < PowerNodes.Length; i++)
			{
				if (UTOnslaughtPowerNode(PowerNodes[i]) != None && !PowerNodes[i].bIsDisabled)
				{
					if (PowerNodes[i].IsActive() && PowerNodes[i].DefenderTeamIndex < 2)
					{
				    		TeamNodes[PowerNodes[i].DefenderTeamIndex]++;
				    	}
					TotalNodes++;
				}
			}


			for (i = 0; i < ArrayCount(PowerCore); i++)
			{
				OvertimeDrain = OvertimeCoreDrainPerSec - (OvertimeCoreDrainPerSec * float(TeamNodes[i]) / float(TotalNodes));
				PowerCore[i].Health -= OvertimeDrain;
				PowerCore[i].DamagePanels(OvertimeDrain, PowerCore[i].Location);
				PowerCore[i].UpdateDamageEffects(false);
				PowerCore[i].bForceNetUpdate = TRUE;
			}

			if ( (PowerCore[0].Health <= 0) && (PowerCore[1].Health <= 0) )
			{
				// DRAW
				ScoreDraw();
			}
			else
			{
				if (PowerCore[0].Health <= 0)
				{
					PowerCore[0].DisableObjective(None);
				}
				if (PowerCore[1].Health <= 0)
				{
					PowerCore[1].DisableObjective(None);
				}
			}
		}

		Super.Timer();
	}
}

function ScoreDraw()
{
	Teams[0].Score += 1;
	Teams[1].Score += 1;
	BroadcastLocalizedMessage( MessageClass, 4);
	CheckScore(PowerCore[0].LastDamagedBy);
	if ( !bGameEnded )
	{
		EndRound(PowerCore[0]);
	}
}

function MainCoreDestroyed(byte T)
{
	local int Score;

	Score = bOverTime ? 1 : 2;

	if (T == 1)
	{
		BroadcastLocalizedMessage( MessageClass, 0);
		Teams[0].Score += Score;
		Teams[0].bForceNetUpdate = TRUE;
		CheckScore(PowerCore[1].LastDamagedBy);
	}
	else
	{
		BroadcastLocalizedMessage( MessageClass, 1);
		Teams[1].Score += Score;
		Teams[1].bForceNetUpdate = TRUE;
		CheckScore(PowerCore[0].LastDamagedBy);
	}
	BroadcastLocalizedMessage( MessageClass, bOverTime ? 12 : 11);

	if ( !bGameEnded )
	{
		EndRound(PowerCore[T]);
	}
}

state MatchOver
{
	function FindNewObjectives(UTGameObjective DisabledObjective) {}

	function MainCoreDestroyed(byte T) {}
}

function bool CheckScore(PlayerReplicationInfo Scorer)
{
	if (CheckMaxLives(Scorer))
	{
		return false;
	}
	else if (GoalScore != 0 && (Teams[0].Score >= GoalScore || Teams[1].Score >= GoalScore))
	{
		EndGame(Scorer,"teamscorelimit");
		return true;
	}
	else
	{
		return false;
	}
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	if (Reason ~= "TimeLimit")
	{
		// if we are doing automated perf testing then we have reached the end of the match and watch to exit so the perf logs are saved out
		if( bAutomatedPerfTesting )
		{
			if( bAutoContinueToNextRound == FALSE )
			{
				ConsoleCommand("EXIT");
			}
			return TRUE;
		}

		if ( !bOverTimeBroadcast )
		{
			StartupStage = 7;
			PlayStartupMessage();
			bOverTimeBroadcast = true;
		}

		return false;
	}

	return Super.CheckEndGame(Winner, Reason);
}

function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;

	if ( Winner != None )
	{
		if (Winner.Team.TeamIndex == 0)
			EndGameFocus = PowerCore[1];
		else
			EndGameFocus = PowerCore[0];
	}
	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		P.GameHasEnded(EndGameFocus, (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) );
	}
}

/** returns whether a node with a flag at it should be prioritized for spawning members of Team */
function bool ShouldPrioritizeNodeWithFlag(byte Team, byte EnemyTeam, bool bEnemyCanAttackCore, controller Player)
{
	local UTPlayerController PC;

	PC = UTPlayerController(Player);
	if ( PC != None )
	{
		if ( PC.bNotUsingOrb )
		{
			return false;
		}
		if ( PC.AutoObjectivePreference == AOP_OrbRunner )
		{
			return true;
		}
		if ( PC.AutoObjectivePreference == AOP_Defend )
		{
			return PowerCore[EnemyTeam].PoweredBy(Team);
		}
	}
	return !PowerCore[EnemyTeam].PoweredBy(Team) && (UTBot(Player) != None || !TeamHasOrbRunner(Player));
}

function bool TeamHasOrbRunner(Controller Player)
{
	local Controller C;
	local UTPlayerReplicationInfo PRI;

	ForEach WorldInfo.AllControllers(class'Controller', C)
	{
		if ( WorldInfo.GRI.OnSameTeam(C, Player) )
		{
		  	PRI = UTPlayerReplicationInfo(C.PlayerReplicationInfo);
		  	if ( (PRI != None) && PRI.bHasFlag )
		  	{
				  return true;
		  	}
		  	if ( UTBot(C) != None )
		  	{
				  if ( UTBot(C).GetOrders() == 'Attack' )
				  return true;
		  	}
		  	else if ( (UTPlayerController(C) != None) && (UTPlayerController(C).AutoObjectivePreference == AOP_OrbRunner) )
		  	{
				  return true;
		  	}
		}
	}
	return false;
}

/** ChoosePlayerStart()
* Return the 'best' player start for this player to start from.  PlayerStarts are rated by RatePlayerStart().
* @param Player is the controller for whom we are choosing a playerstart
* @param InTeam specifies the Player's team (if the player hasn't joined a team yet)
* @returns NavigationPoint chosen as player start (usually a PlayerStart)
 */
function PlayerStart ChoosePlayerStart( Controller Player, optional byte InTeam )
{
	local PlayerStart BestStart;
	local float CoreDistA, CoreDistB, BestRating, NewRating;
	local byte Team, EnemyTeam;
	local UTGameObjective SelectedPC;
	local int i;
	local bool bTeammateFound, bPrioritizeNodeWithFlag, bEnemyCanAttackCore;
	local controller C;
	local UTOnslaughtNodeObjective Node;

	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
	{
		// use InTeam if player doesn't have a team yet
		Team = (Player.PlayerReplicationInfo.Team != None) ? byte(Player.PlayerReplicationInfo.Team.TeamIndex) : InTeam;

		//Use the powernode the player selected (if it's valid)
		if ( UTPlayerReplicationInfo(Player.PlayerReplicationInfo) != None )
		{
			SelectedPC = UTPlayerReplicationInfo(Player.PlayerReplicationInfo).GetStartObjective();
		}
	}
	else
	{
		Team = InTeam;
	}

	bSpawnNodeSelected = (SelectedPC != None);
	if (SelectedPC == None)
	{
		bEnemyCanAttackCore = PowerCore[Team].PoweredBy(1 - Team);
		EnemyTeam = Abs(Team - 1);
		bPrioritizeNodeWithFlag = ShouldPrioritizeNodeWithFlag(Team, EnemyTeam, bEnemyCanAttackCore, Player);
		if (bEnemyCanAttackCore && !bPrioritizeNodeWithFlag)
		{
			SelectedPC = PowerCore[Team];
		}
		else
		{
			// Find the Closest Controlled Node(s) to Enemy PowerCore.
			BestRating = 256;
			for (i = 0; i < PowerNodes.Length; i++)
			{
				if ( PowerNodes[i].ValidSpawnPointFor(Team) )
				{
					if (bPrioritizeNodeWithFlag)
					{
						// if Onslaught Flag sitting at a node with no teammate close by, chose that node
						Node = UTOnslaughtNodeObjective(PowerNodes[i]);
						if (Node != None && Node.FlagBase != None && Node.FlagBase.MyFlag != None && Node.FlagBase.MyFlag.IsNearlyHome())
						{
							// check if nearby teammate
							bTeammateFound = false;
							ForEach WorldInfo.AllControllers(class'Controller', C)
							{
								if ( C.bIsPlayer && (C.Pawn != None) && WorldInfo.GRI.OnSameTeam(Player,C)
									&& (VSizeSq(C.Pawn.Location - Node.FlagBase.Location) < 4000000) )
								{
									bTeammateFound = true;
									break;
								}
							}
							if ( !bTeammateFound )
							{
								SelectedPC = Node;
								bSpawnNodeSelected = true;
								break;
							}
						}
					}
					if (!bEnemyCanAttackCore)
					{
						// rating based first on link distance, then available vehicles
						NewRating = PowerNodes[i].GetSpawnRating(EnemyTeam);
						if ( NewRating < BestRating )
						{
							BestRating = NewRating;
							SelectedPC = PowerNodes[i];
						}
						else if ( NewRating == BestRating ) // If we have two nodes at equal link distance, we check geometric distance
						{
							CoreDistA = VSize(PowerCore[EnemyTeam].Location - PowerNodes[i].Location);
							CoreDistB = VSize(PowerCore[EnemyTeam].Location - SelectedPC.Location);
							if (CoreDistA < CoreDistB)
							{
								SelectedPC = PowerNodes[i];
							}
						}
					}
				}
			}

			// If no valid power node found, set to power core.
			if (SelectedPC == None)
			{
				SelectedPC = PowerCore[Team];
			}
		}
	}

	BestStart = BestPlayerStartAtNode(SelectedPC, Team, Player);
	if ( (BestStart == None) && (SelectedPC != PowerCore[Team]) )
	{
		BestStart = BestPlayerStartAtNode(PowerCore[Team], Team, Player);
	}
	return BestStart;
}

function PlayerStart BestPlayerStartAtNode(UTGameObjective SelectedPC, byte Team, Controller Player)
{
	local PlayerStart BestStart, P;
	local float BestRating, NewRating, GoodEnoughRating;
	local int i, RandStart;

	GoodEnoughRating = (SelectedPC.bUnderAttack) ? 60.0 : 30.0;

	// Avoid randomness for profiling.
	if( bFixedPlayerStart )
	{
		RandStart = 0;
	}
	// start at random point to randomize finding "good enough" playerstart
	else
	{
		RandStart = Rand(SelectedPC.PlayerStarts.Length);
	}

	for ( i=RandStart; i<SelectedPC.PlayerStarts.Length; i++ )
	{
		P = SelectedPC.PlayerStarts[i];
		NewRating = RatePlayerStart(P,Team,Player);
		if (SelectedPC.bUnderAttack && P.IsA('UTWarfarePlayerStart') && UTWarfarePlayerStart(P).bPrioritizeWhenUnderAttack)
		{
			NewRating += 30.0;
		}
		if (NewRating >= GoodEnoughRating)
		{
			// this PlayerStart is good enough
			return P;
		}
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = P;
		}
	}
	for ( i=0; i<RandStart; i++ )
	{
		P = SelectedPC.PlayerStarts[i];
		NewRating = RatePlayerStart(P,Team,Player);
		if (SelectedPC.bUnderAttack && P.IsA('UTWarfarePlayerStart') && UTWarfarePlayerStart(P).bPrioritizeWhenUnderAttack)
		{
			NewRating += 30.0;
		}
		if (NewRating >= GoodEnoughRating)
		{
			// this PlayerStart is good enough
			return P;
		}
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = P;
		}
	}
	return BestStart;
}

/** finds the closest node to the enemy powercore that has vehicles available according to the passed in array
 * may return None if no node with vehicles is available for that team
 * @param Player the Player we're choosing a node for
 * @param NumVehicleFactories
 */
function UTGameObjective GetClosestNodeToEnemyWithVehicles(Controller Player, const out array<int> NumVehicleFactories)
{
	local float CoreDistA, CoreDistB, BestRating, NewRating;
	local byte Team, EnemyTeam;
	local UTGameObjective SelectedNode;
	local int i;
	local bool bPrioritizeNodeWithFlag;
	local UTOnslaughtNodeObjective Node;

	Team = Player.GetTeamNum();
	EnemyTeam = Abs(Team - 1);
	bPrioritizeNodeWithFlag = ShouldPrioritizeNodeWithFlag(Team, EnemyTeam, false, Player);
	BestRating = 255;
	for (i = 0; i < PowerNodes.Length; i++)
	{
		if (NumVehicleFactories[i] > 0 && PowerNodes[i].ValidSpawnPointFor(Team))
		{
			NewRating = PowerNodes[i].FinalCoreDistance[EnemyTeam];
			if (bPrioritizeNodeWithFlag)
			{
				Node = UTOnslaughtNodeObjective(PowerNodes[i]);
				if (Node != None && Node.FlagBase != None && Node.FlagBase.myFlag != None && Node.FlagBase.myFlag.bHome)
				{
					NewRating -= 1000.0;
				}
			}
			if (NewRating < BestRating)
			{
				BestRating = NewRating;
				SelectedNode = PowerNodes[i];
			}
			else if (NewRating == BestRating) // If we have two nodes at equal link distance, we check geometric distance
			{
				CoreDistA = VSize(PowerCore[EnemyTeam].Location - PowerNodes[i].Location);
				CoreDistB = VSize(PowerCore[EnemyTeam].Location - SelectedNode.Location);
				if (CoreDistA < CoreDistB)
				{
					SelectedNode = PowerNodes[i];
				}
			}
		}
	}

	return SelectedNode;
}

function StartHumans()
{
	// start everyone, including bots, in the same pass so we can count them and match them up with the number of vehicles at all starting nodes
	StartAllPlayers();
}

function StartBots();

function StartAllPlayers()
{
	local Controller C;
	local PlayerController PC;
	local array<int> NumVehicleFactories;
	local int i;
	local UTPlayerReplicationInfo PRI;
	local UTBot B;

	// construct an array containing the number of vehicle factories at each node
	for (i = 0; i < PowerNodes.Length; i++)
	{
		NumVehicleFactories[i] = PowerNodes[i].VehicleFactories.length;
	}

	// spawn players, prioritizing spawning them at a node that has a vehicle available
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if (C.bIsPlayer && C.Pawn == None)
		{
			if (bGameEnded)
			{
				return; // telefrag ended the game with ridiculous frag limit
			}
			else
			{
				PC = PlayerController(C);
				if (PC == None || PC.CanRestartPlayer())
				{
					PRI = UTPlayerReplicationInfo(C.PlayerReplicationInfo);
					if (PRI != None)
					{
						B  = UTBot(C);
						// bots first try to spawn at their objective
						if ( B != None && B.Squad != None && B.Squad.SquadObjective != None &&
							B.Squad.SquadObjective.ValidSpawnPointFor(B.GetTeamNum()) )
						{
							PRI.TemporaryStartObjective = B.Squad.SquadObjective;
							i = PowerNodes.Find(UTOnslaughtNodeObjective(PRI.TemporaryStartObjective));
						}
						// if player specified a start, just use that
						else if (PRI.StartObjective != None && PRI.StartObjective.ValidSpawnPointFor(C.GetTeamNum()))
						{
							i = PowerNodes.Find(UTOnslaughtNodeObjective(PRI.StartObjective));
						}
						else if (ShouldSpawnAtStartSpot(C))
						{
							i = PowerNodes.Find(ClosestNodeTo(C.StartSpot));
						}
						else
						{
							// otherwise, set temporary start to a node with vehicles
							PRI.TemporaryStartObjective = GetClosestNodeToEnemyWithVehicles(C, NumVehicleFactories);
							i = PowerNodes.Find(UTOnslaughtNodeObjective(PRI.TemporaryStartObjective));
						}

						if (i != INDEX_NONE)
						{
							NumVehicleFactories[i]--;
						}
					}

					if (PC != None || WorldInfo.NetMode == NM_Standalone)
					{
						RestartPlayer(C);
					}
					else
					{
						C.GotoState('Dead','MPStart');
					}
				}
			}
		}
	}
}

function ShowPathTo(PlayerController P, int TeamNum)
{
	local int i;
	local UTOnslaughtObjective Best;
	local float BestDist;

	for (i = 0; i < PowerNodes.Length; i++)
	{
		if ( (!PowerNodes[i].IsActive() || PowerNodes[i].DefenderTeamIndex != TeamNum) && PowerNodes[i].PoweredBy(TeamNum)
		     && (Best == None || VSize(P.Pawn.Location - PowerNodes[i].Location) < BestDist) )
		{
			Best = PowerNodes[i];
			BestDist = VSize(P.Pawn.Location - PowerNodes[i].Location);
		}
	}

	if (Best != None)
	{
		for (i = 0; i < Best.ShootSpots.length; i++)
		{
			if (Best.ShootSpots[i] != None)
			{
				Best.ShootSpots[i].bTransientEndPoint = true;
			}
		}
		if (P.FindPathToward(Best, false) != None)
		{
			Spawn(class'UTWillowWhisp', P,, P.Pawn.Location);
		}
	}
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local int i;
	local UTOnslaughtPRI PRI;
	local PlayerController PC;

	if (Super.ChangeTeam(Other, num, bNewTeam))
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( Other == PC )
			{
				//Update client side effects on PowerNodes to reflect which ones the player can go after changing teams
				for (i = 0; i < PowerNodes.length; i++)
					PowerNodes[i].UpdateEffects(false);
			}
			break;
		}

		PRI = UTOnslaughtPRI(Other.PlayerReplicationInfo);
		if (PRI != None)
		{
			PRI.StartObjective = None;
			PRI.TemporaryStartObjective = None;
		}

		return true;
	}

	return false;
}

function ScoreObjective(PlayerReplicationInfo Scorer, int Score)
{
	AddObjectiveScore(Scorer,Score);
}

function ScoreFlag(Controller Scorer, UTOnslaughtFlag TheFlag)
{
	local UTPlayerReplicationInfo ScorerPRI;

	ScorerPRI = UTPlayerReplicationInfo(Scorer.PlayerReplicationInfo);

	if (ScorerPRI.Team != TheFlag.Team)
	{
		BroadcastLocalizedMessage(TheFlag.MessageClass, 1 + 7 * TheFlag.Team.TeamIndex, ScorerPRI, None, TheFlag.Team);
		ScorerPRI.IncrementEventStat('EVENT_RETURNEDORB');
	}
	else
	{
		ScorerPRI.IncrementEventStat('EVENT_SCOREDORB');
	}
}

function bool NearGoal(Controller C)
{
	local UTOnslaughtPowerNode Node;

	Node = UTOnslaughtPowerNode(ClosestNodeTo(C.Pawn));
	return (Node != None && Node.GetTeamNum() != C.GetTeamNum() && Node.PoweredBy(C.GetTeamNum()) && VSize(C.Pawn.Location - Node.Location) < 1000.0);
}

/** @return whether the given Pawn is touching/walking on an Actor that allows node teleporting */
function bool IsTouchingNodeTeleporter(Pawn P, optional out UTOnslaughtNodeTeleporter Teleporter)
{
	local UTOnslaughtNodeTeleporter TestTeleporter;

	// allow if touching a teleporter
	TestTeleporter = UTOnslaughtNodeTeleporter(P.Base);
	if (TestTeleporter != None && WorldInfo.GRI.OnSameTeam(P, P.Base))
	{
		Teleporter = TestTeleporter;
		return true;
	}
	foreach P.TouchingActors(class'UTOnslaughtNodeTeleporter', Teleporter)
	{
		if (WorldInfo.GRI.OnSameTeam(P, Teleporter))
		{
			Teleporter = TestTeleporter;
			return true;
		}
	}

	return false;
}

function bool AllowClientToTeleport(UTPlayerReplicationInfo ClientPRI, Actor DestinationActor)
{

	local bool IsTouchingTeleporter;
	local UTOnslaughtNodeTeleporter Tp;
	local UTOnslaughtNodeObjective Obj;
	local int i;

	IsTouchingTeleporter = IsTouchingNodeTeleporter(Controller(ClientPRI.Owner).Pawn, Tp);
	Obj = UTOnslaughtNodeObjective(DestinationActor);
	if (IsTouchingTeleporter && Tp!=none && Obj != none)
	{
		for (i=0;i<Obj.NodeTeleporters.Length;i++)
		{
			if (Obj.NodeTeleporters[i] == tp)
			{
				return false;
			}
		}
	}

	return (Super.AllowClientToTeleport(ClientPRI, DestinationActor) && IsTouchingTeleporter);
}

function FindNewObjectives(UTGameObjective DisabledObjective)
{
	local UTPlayerController PC;

	Super.FindNewObjectives(DisabledObjective);

	// check recommended objectives for human players
	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		if ( (PC.LastAutoObjective == DisabledObjective) && (PC.bWasDefendingObjective != WorldInfo.GRI.OnSameTeam(PC.LastAutoObjective, PC)) )
		{
			PC.LastAutoObjective = None;
		}
		PC.CheckAutoObjective(true);
	}
}

/**
  * Adjust skill level in campaign based on relative health of cores
  */
function AdjustOnslaughtSkill()
{
	if ( UTGameReplicationInfo(GameReplicationInfo).bStoryMode && (PowerCore[0].Health > 0) && (PowerCore[1].Health > 0) )
	{
		AdjustedDifficulty = GameDifficulty + 1.25 * (PowerCore[0].Health - PowerCore[1].Health)/PowerCore[0].DamageCapacity;
	}
}

function Actor GetAutoObjectiveFor(UTPlayerController PC)
{
	local UTTeamInfo Team;
	local UTOnslaughtFlag Flag;
	local UTPlayerReplicationInfo PRI;
	local int i;
	local UTOnslaughtPowerNode Node;
	local UTDeployable Deployable;
	local UTGameObjective Result, AltResult;
	local float BestDist, NewDist;
	local UTPickupFactory BestPickup, Pickup;
	local UTVehicle V;
	local UTWeapon Weap;
	local UTOnslaughtTeamAI TeamAI;

	PRI = UTPlayerReplicationInfo(PC.PlayerReplicationInfo);
	if (PRI != None)
	{
		Flag = UTOnslaughtFlag(PRI.GetFlag());
	}

	// if carrying deployable, ask it to recommend an objective
	if ( PC.Pawn != None )
	{
		Deployable = UTDeployable(PC.Pawn.Weapon);
		if ( Deployable != None )
		{
			Result = Deployable.RecommendObjective(PC);
			if ( Result != None )
			{
				return Result;
			}
		}
	}

	// ask the team AI for the best objective
	Team = UTTeamInfo(PC.PlayerReplicationInfo.Team);
	if ( Team != None )
	{
		TeamAI = UTOnslaughtTeamAI(Team.AI);
	}
	if ( TeamAI != None )
	{
		switch (PC.AutoObjectivePreference)
		{
			case AOP_Disabled:
				return None;
			case AOP_OrbRunner:
				Result = TeamAI.GetPriorityPlayerAttackObjectiveFor(PC);

				// override with node
				if ( UTOnslaughtPowerNode(Result) == None )
				{
					AltResult = TeamAI.GetLeastDefendedPlayerObjective(PC);
					if ( UTOnslaughtPowerNode(AltResult) != None )
					{
						return AltResult;
					}
					for (i = 0; i < PowerNodes.length; i++)
					{
						Node = UTOnslaughtPowerNode(PowerNodes[i]);
						if (Node != None && Node.PoweredBy(PRI.Team.TeamIndex) && !WorldInfo.GRI.OnSameTeam(Node, PC) && !Node.bIsDisabled )
						{
							return Node;
						}
					}
					for (i = 0; i < PowerNodes.length; i++)
					{
						Node = UTOnslaughtPowerNode(PowerNodes[i]);
						if (Node != None && Node.PoweredBy(1 - PRI.Team.TeamIndex) && WorldInfo.GRI.OnSameTeam(Node, PC) && !Node.bIsDisabled )
						{
							return Node;
						}
					}
				}
				return Result;
			case AOP_NoPreference:
				if ( (WorldInfo.TimeSeconds - PowerCore[Team.TeamIndex].LastDamagedTime < 5.0)
					&& PowerCore[Team.TeamIndex].PoweredBy(1 - Team.TeamIndex) )
				{
					// defend core if it is still vulnerable
					return PowerCore[Team.TeamIndex];
				}
			case AOP_Attack:
				Result = TeamAI.GetPriorityPlayerAttackObjectiveFor(PC);
				// override with attackable node if player has orb
				if ( Flag != None )
				{
					if ( UTOnslaughtPowerNode(Result) == None )
					{
						for (i = 0; i < PowerNodes.length; i++)
						{
							Node = UTOnslaughtPowerNode(PowerNodes[i]);
							if (Node != None && Node.PoweredBy(PRI.Team.TeamIndex) && !WorldInfo.GRI.OnSameTeam(Node, PC) && !Node.bIsDisabled )
							{
								Result = Node;
								break;
							}
						}
						if ( UTOnslaughtPowerCore(Result) != None )
						{
							// defend the prime node instead
							AltResult = TeamAI.GetLeastDefendedPlayerObjective(PC);
							if ( (AltResult != None) && (UTOnslaughtPowerCore(AltResult) == None) )
							{
								Result = AltResult;
							}
						}
					}
				}
				return Result;
			case AOP_SpecialOps:
				V = UTVehicle(PC.Pawn);
				if ( (Flag == None) && (PC.Pawn != None) && ((V == None) || (!V.bKeyVehicle && (UTVehicle_Deployable(V) == None))) )
				{
					Weap = (Vehicle(PC.Pawn) == None) ? UTWeapon(PC.Pawn.Weapon) : UTWeapon(Vehicle(PC.Pawn).Driver.Weapon);
					if ( (Weap == None) || (!Weap.bSuperWeapon && (UTDeployable(Weap) == None)) )
					{
						// look for super items, if not already holding one
						ForEach WorldInfo.AllNavigationPoints(class'UTPickupFactory', Pickup)
						{
							if ( Pickup.bIsSuperItem && ClassIsChildOf(Pickup.InventoryType, class'UTWeapon') && Pickup.ReadyToPickup(0) )
							{
								NewDist = VSize(Pickup.Location - PC.Pawn.Location);
								if ( (BestPickup == None) || (NewDist < BestDist) )
								{
									BestPickup = Pickup;
									BestDist = NewDist;
								}
							}
						}
						if ( BestPickup != None )
						{
							 return BestPickup;
						}

						// look for key vehicles
						ForEach WorldInfo.AllPawns(class'UTVehicle', V)
						{
							if ( (V.Driver == None) && V.bTeamLocked && (V.Health > 0)
								&& (V.bKeyVehicle || (UTVehicle_Deployable(V) != None))
								&& Worldinfo.GRI.OnSameTeam(PC,V) )
							{
								return V;
							}
						}
					}
				}
				if ( Flag == None )
				{
					Result = TeamAI.GetPriorityStandaloneObjectiveFor(None, PC);
				}
				if ( Result == None )
				{
					Result = TeamAI.GetPriorityPlayerAttackObjectiveFor(PC);
					// override with attackable node if player has orb
					if ( (Flag != None) && (UTOnslaughtPowerNode(Result) == None) )
					{
						for (i = 0; i < PowerNodes.length; i++)
						{
							Node = UTOnslaughtPowerNode(PowerNodes[i]);
							if (Node != None && Node.PoweredBy(PRI.Team.TeamIndex) && !WorldInfo.GRI.OnSameTeam(Node, PC) && !Node.bIsDisabled )
							{
								return Node;
							}
						}
					}
				}
				return Result;
			case AOP_Defend:
				Result = TeamAI.GetLeastDefendedPlayerObjective(PC);

				// override with defendable node if player has orb
				if ( (Flag != None) && (UTOnslaughtPowerNode(Result) == None) )
				{
					for (i = 0; i < PowerNodes.length; i++)
					{
						Node = UTOnslaughtPowerNode(PowerNodes[i]);
						if (Node != None && !Node.bStandalone && Node.PoweredBy(1 - PRI.Team.TeamIndex) && WorldInfo.GRI.OnSameTeam(Node, PC) && !Node.bIsDisabled )
						{
							return Node;
						}
					}
				}
				return Result;
			default:
				`Warn("Unknown AutoObjectivePreference:" @ PC.AutoObjectivePreference);
				return None;
		}
	}
	else
	{
		return None;
	}
}

defaultproperties
{
	MapPrefixes[0]="WAR"
	Acronym="WAR"

	bUndrivenVehicleDamage=true
	bScoreTeamKills=False
	bSpawnInTeamArea=false
	bTeamScoreRounds=False
	bScoreVictimsTarget=false
	bAllowHoverboard=true
	OvertimeCoreDrainPerSec=20.0
	DeathMessageClass=class'UTTeamDeathMessage'
	FlagKillMessageName=ORBKILL

	// Class used to write stats to the leaderboard
	OnlineStatsWriteClass=class'UTGame.UTLeaderboardWriteWAR'

	bScoreDeaths=false
	MidgameScorePanelTag=ONSPanel
	bMidGameHasMap=true

}
