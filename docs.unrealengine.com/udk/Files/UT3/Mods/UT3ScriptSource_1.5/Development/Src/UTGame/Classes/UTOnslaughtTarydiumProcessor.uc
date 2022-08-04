/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtTarydiumProcessor extends UTOnslaughtNodeEnhancement
	abstract;

var()	UTOnslaughtTarydiumMine	Mine;
var()	float					OreEventThreshold;
var		repnotify float			OreCount;

const MAXMINERS = 4;
var UTOnslaughtMiningRobot MiningBots[MAXMINERS];

var class<UTOnslaughtMiningRobot> MiningBotClass;

var() SkeletalMeshComponent		Mesh;
var() StaticMeshComponent		StaticMesh;

var MaterialInstanceConstant	SailMIC;
var MaterialInstanceConstant	TopMIC;
var MaterialInstanceConstant	PistonMIC;

var vector	ProcColor;
var vector	TargetProcColor;
var float	ProcColorBlend;

var() float	BotSpawnDist;

replication
{
	if (bNetDirty)
		OreCount;
}

simulated function PostBeginPlay()
{
	local UTOnslaughtTarydiumMine M;
	local float BestDist, NewDist;

	super.PostBeginPlay();

	if ( Mine == None )
	{
		// find closest mine
		ForEach WorldInfo.AllNavigationPoints(class'UTOnslaughtTarydiumMine', M)
		{
			NewDist = VSize(M.Location - Location);
			if ( (Mine == None) || (NewDist < BestDist) )
			{
				Mine = M;
				BestDist = NewDist;
			}
		}
	}

	SailMIC = Mesh.CreateAndSetMaterialInstanceConstant(1);
	TopMIC = Mesh.CreateAndSetMaterialInstanceConstant(4);
	PistonMIC = Mesh.CreateAndSetMaterialInstanceConstant(3);
}

simulated function UpdateTeamEffects()
{
	TargetProcColor = (DefenderTeamIndex%2==0) ? vect(1.0, 0.0, 0.0) : vect(0.0, 0.0, 1.0);
	ProcColorBlend = 0.0;
}

simulated function LinearColor VecToLinColor(vector InVec)
{
	local LinearColor OutColor;

	OutColor.R = InVec.X;
	OutColor.G = InVec.Y;
	OutColor.B = InVec.Z;
	OutColor.A = 1.0;

	return OutColor;
}

simulated function Tick(float DeltaSeconds)
{
	local float UseBlend;
	local vector NewColor;

	Super.Tick(DeltaSeconds);

	if( ProcColorBlend < 1.0 )
	{
		ProcColorBlend += (1.0 * DeltaSeconds);

		if(ProcColorBlend >= 1.0)
		{
			ProcColor = TargetProcColor;
			NewColor = TargetProcColor;
		}
		else
		{
			UseBlend = FCubicInterp(0.0, 0.0, 1.0, 0.0, ProcColorBlend);
			NewColor = (UseBlend * (TargetProcColor - ProcColor)) + ProcColor;
		}

		PistonMIC.SetVectorParameterValue('Color_Pistons', VecToLinColor(1.5 * NewColor));
		TopMIC.SetVectorParameterValue('Color_top', VecToLinColor(11.0 * NewColor));
		SailMIC.SetVectorParameterValue('Color', VecToLinColor(22.0 * NewColor));
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'OreCount')
	{
		UpdateAnimRate();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/** Update rate of animation based on how much ore we have. */
simulated function UpdateAnimRate()
{
	local AnimNodeSequence SeqNode;

	SeqNode = AnimNodeSequence(Mesh.Animations);
	SeqNode.Rate = FClamp(OreCount/OreEventThreshold, 0.0, 1.0);
}

function ReceiveOre(float Quantity)
{
	local int i;
	local float Count, OreShare;
	local UTOnslaughtObjective O;
	local UTOnslaughtGame TheGame;

	// count received ore for Kismet event
	OreCount += Quantity;
	if ( OreCount >= OreEventThreshold )
	{
		OreCount -= OreEventThreshold;
		TriggerEventClass(class'UTSeqEvent_MinedOre', None);
	}

	UpdateAnimRate();

	if (ControllingNode != None && ControllingNode.IsActive())
	{
		// count how many team controlled objectives accept tarydium boosts
		count = 0;
		TheGame = UTOnslaughtGame(WorldInfo.Game);
		for ( i=0; i<TheGame.PowerNodes.Length; i++ )
		{
			O = TheGame.PowerNodes[i];
			if ( O.IsActive() && WorldInfo.GRI.OnSameTeam(ControllingNode, O) )
			{
				Count += 1;
			}
		}

		// give a boost to each team controlled objective which accepts it
		OreShare = Quantity/Count;
		TheGame.PowerCore[ControllingNode.DefenderTeamIndex].ProcessedTarydium += Quantity;
		for ( i=0; i<TheGame.PowerNodes.Length; i++ )
		{
			TheGame.PowerNodes[i].TarydiumBoost(OreShare);
		}
	}
}

function MinerDestroyed()
{
	CreateMiner(10);
}

function Activate()
{
	CreateMiner(3);
	super.Activate();
}

function CreateMiner(float MinerCreationTime)
{
	local float CurrentTimer;

	// if timer is already active, set to lesser of remaining time and new time
	CurrentTimer = GetTimerRate('SpawnMiner');
	if (CurrentTimer > 0.f)
	{
		SetTimer(FMin(MinerCreationTime, CurrentTimer - GetTimerCount('SpawnMiner')), false, 'SpawnMiner');
	}
	else
	{
		SetTimer(MinerCreationTime, false, 'SpawnMiner');
	}
}

function SpawnMiner()
{
	local int i, Count, Slot;
	local vector X,Y,Z;

	Slot = -1;
	for ( i=0; i<MAXMINERS; i++ )
	{
		if ( (MiningBots[i] != None) && !MiningBots[i].bDeleteMe )
			Count++;
		else if ( Slot == -1 )
			Slot = i;
	}

	if ( Count == MAXMINERS )
		return;

	GetAxes(Rotation, X,Y,Z);
	MiningBots[Slot] = spawn(MiningBotClass,,, Location - (BotSpawnDist*Y));
	if ( MiningBots[Slot] != None && !MiningBots[Slot].bDeleteMe )
	{
		MiningBots[Slot].Home = self;
		MiningBots[Slot].ControllingNode = ControllingNode;
		Count++;
	}

	if ( Count < MAXMINERS )
	{
		SetTimer(5, false, 'SpawnMiner');
	}
}


function Deactivate()
{
	local int i;

	for ( i=0; i<MAXMINERS; i++ )
	{
		if ( (MiningBots[i] != None) && !MiningBots[i].bDeleteMe )
			MiningBots[i].Destroy();
	}
	ClearTimer('SpawnMiner');
	Super.Deactivate();
}

defaultproperties
{
	BotSpawnDist=300.0
}
