/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtHUD extends UTTeamHUD;

var UTOnslaughtPowerCore PowerCore[2];
var float LastMouseMoveTime;
var array<UTOnslaughtPowerNode> PowerNodes;
var bool bPowerNodesInitialized;
var EFlagState FlagStates[2];

simulated function PostBeginPlay()
{
	GetPowerCores();

	Super.PostBeginPlay();
	SetTimer(1.0, True);
}

simulated function Timer()
{
	local UTPlayerReplicationInfo PawnOwnerPRI;
	local int i, NumNodes;
	local UTOnslaughtFlag EnemyFlag, CarriedFlag;
	local UTOnslaughtPowerNode Node;
	local UTTeamInfo EnemyTeam;

	Super.Timer();

	if ( PawnOwner == None )
		return;

	PawnOwnerPRI = UTPlayerReplicationInfo(PawnOwner.PlayerReplicationInfo);

	if ( PawnOwnerPRI == None || PawnOwnerPRI.Team == None
		|| (PlayerOwner.IsSpectating() && UTPlayerController(PlayerOwner).bBehindView) )
	{
		return;
	}

	if (!bPowerNodesInitialized)
	{
		bPowerNodesInitialized = true;
		foreach WorldInfo.AllNavigationPoints(class'UTOnslaughtPowerNode',Node)
		{
			PowerNodes[PowerNodes.Length] = Node;
		}
	}

	if (WorldInfo.GRI != None)
	{
		EnemyTeam = UTTeamInfo(WorldInfo.GRI.Teams[1 - PawnOwnerPRI.Team.TeamIndex]);
		if (EnemyTeam != None)
		{
			NumNodes = PowerNodes.length;
			EnemyFlag = UTOnslaughtFlag(EnemyTeam.TeamFlag);
			if ( (EnemyFlag != None) && (EnemyFlag.HolderPRI != None) )
			{
				for (i = 0; i < NumNodes; i++)
				{
					if ( (PowerNodes[i] != None) && (PowerNodes[i].DefenderTeamIndex == PawnOwnerPRI.Team.TeamIndex) )
					{
						if ( VSize(PowerNodes[i].Location - EnemyFlag.Location) < PowerNodes[i].MaxSensorRange
							 && VSize(PowerNodes[i].Location - PawnOwner.Location) < PowerNodes[i].MaxSensorRange
							 && PowerNodes[i].PoweredBy(1 - PawnOwnerPRI.Team.TeamIndex) )
						{
							PlayerOwner.ReceiveLocalizedMessage(class'UTOnslaughtHUDMessage', 1);
							break;
						}
					}
				}
			}
		}
	}

	if ( PawnOwnerPRI.bHasFlag )
	{
		CarriedFlag = UTOnslaughtFlag(UTTeamInfo(PawnOwnerPRI.Team).TeamFlag);
		if ( (CarriedFlag != None) && (CarriedFlag.LockedNode != None) )
		{
			CarriedFlag.LockedNode.VerifyOrbLock(CarriedFlag);
			if ( CarriedFlag.LockedNode != None )
			{
				PlayerOwner.ReceiveLocalizedMessage( class'UTOnslaughtHUDMessage', 2 );
			}
			else
			{
				PlayerOwner.ReceiveLocalizedMessage( class'UTOnslaughtHUDMessage', 0 );
			}
		}
		else
		{
			PlayerOwner.ReceiveLocalizedMessage( class'UTOnslaughtHUDMessage', 0 );
		}
	}
}

function AddLocalizedMessage
(
	int						Index,
	class<LocalMessage>		InMessageClass,
	string					CriticalString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	color					DrawColor,
	optional int			MessageCount,
	optional object			OptionalObject
)
{
	Super.AddLocalizedMessage(Index, InMessageClass, CriticalString, Switch, Position, LifeTime, FontSize, DrawColor, MessageCount, OptionalObject);

	// highlight minimap node
	if ( InMessageClass.static.IsKeyObjectiveMessage(Switch) )
	{
		if ( UTGameObjective(OptionalObject) != None )
		{
			UTGameObjective(OptionalObject).HighlightOnMinimap(Switch);
		}
		else if ( (UTTeamInfo(OptionalObject) != None) && (UTTeamInfo(OptionalObject).TeamFlag != None) )
		{
			UTTeamInfo(OptionalObject).TeamFlag.HighlightOnMinimap(Switch);
		}
	}
}

function bool FindGround(out vector KnownVect)
{
	local vector HitLocation, HitNormal;
	local actor a;

	A = Trace(HitLocation, HitNormal, KnownVect + Vect(0,0,-50000), KnownVect + Vect(0,0,+50000),false);
	if (A!= none)
	{
		KnownVect = HitLocation;
		return true;
	}
	return false;
}

function GetPowerCores()
{
	local UTOnslaughtPowerCore Core;

	if (PowerCore[0] == None || PowerCore[1] == None || PowerCore[0].GetTeamNum() != 0 || PowerCore[1].GetTeamNum() != 1)
	{
		foreach WorldInfo.AllNavigationPoints(class'UTOnslaughtPowerCore',Core)
		{
			if ( Core.DefenderTeamIndex < 2 )
			{
				PowerCore[Core.DefenderTeamIndex] = Core;
			}
		}
	}
}

exec function SetMapExtent(float value)
{
`if(`notdefined(FINAL_RELEASE))
	local float OldValue;
	OldValue = UTOnslaughtMapInfo(WorldInfo.GetMapInfo()).MapExtent;
`endif

    if (Value>0)
	{
		UTOnslaughtMapInfo(WorldInfo.GetMapInfo()).MapExtent = Value;
	}

	`log("### MapExtent:"@OldValue@Value);
}


function DisplayTeamScore()
{
	GetPowerCores();
	Super.DisplayTeamScore();
}

function DisplayTeamLogos(byte TeamIndex, vector2d POS, optional float DestScale=1.0)
{
	local linearColor Alpha;
	local linearColor TC,Black;
	local float Modifier;
	local color TTC;

	Super.DisplayTeamLogos(TeamIndex, Pos, DestScale);

	GetTeamColor(TeamIndex, TC, TTC);
	Alpha = ColorToLinearColor(LightGoldColor);

	Black.A=1.0;

	TC.A = 1.0;
	Modifier = 1.0 + (0.5 * Abs(cos(WorldInfo.TimeSeconds * 3)));//0.25 + ( 0.75 * Abs(cos(WorldInfo.TimeSeconds * 3)));

	DestScale *= ResolutionScale * 0.7;

	if (UTGRI != None && (TeamIndex == 0 || TeamIndex == 1))
	{
		switch (UTGRI.FlagState[TeamIndex])
		{
		case FLAG_Home:
		case FLAG_Down:
			Canvas.SetPos(POS.X, POS.Y + (7*DestScale));
			DrawTileCentered(AltHudTexture, 50 * DestScale, 48 * DestScale, 843,0,50,48,TC);

			if ( UTGRI.FlagState[TeamIndex] == FLAG_Down )
			{
			    Canvas.SetPos(POS.X-2, POS.Y - (7 * DestScale * Modifier)+2);
				Canvas.DrawColorizedTile(AltHudTexture, 27 * DestScale * Modifier, 27 * DestScale * Modifier, 893,0,27,37,BLACK);

			    Canvas.SetPos(POS.X, POS.Y - (7 * DestScale * Modifier));
				Canvas.DrawColorizedTile(AltHudTexture, 27 * DestScale * Modifier, 27 * DestScale * Modifier, 893,0,27,37,Alpha);
			}

			break;

		case FLAG_HeldEnemy:

        	DestScale *=  Modifier;

			Canvas.SetPos(POS.X - (20 * DestScale), POS.Y - (22*DestScale));
			Canvas.DrawColorizedTile(AltHudTexture,27*DestScale, 27*DestScale,893,37,27,27,TC);

			Canvas.SetPos(POS.X-8, POS.Y - (15*DestScale)+2);
			Canvas.DrawColorizedTile(AltHudTexture,40*DestScale , 38*DestScale,843,48,40,38,BLACK);

			Canvas.SetPos(POS.X-6, POS.Y - (15*DestScale));
			Canvas.DrawColorizedTile(AltHudTexture,40*DestScale , 38*DestScale,843,48,40,38,Alpha);

			break;
		}
	}

}

function int GetTeamScore(byte TeamIndex)
{
	local int Health;

	if ((TeamIndex == 0 || TeamIndex == 1) && PowerCore[TeamIndex] != None)
	{
		Health = PowerCore[TeamIndex].Health;
		Health = Health > 0 ? Max(1, 100 * Health / PowerCore[TeamIndex].DamageCapacity) : 0;
		return Health;
	}
	else
	{
		return 0;
	}
}


defaultproperties
{
	bShowDirectional=true
	bHasMap=true
	bShowFragCount=false
	ScoreboardSceneTemplate=Scoreboard_ONS'UI_Scenes_Scoreboards.sbONS'
	FlagStates(0)=FLAG_Down
	FlagStates(1)=FLAG_Down
}

