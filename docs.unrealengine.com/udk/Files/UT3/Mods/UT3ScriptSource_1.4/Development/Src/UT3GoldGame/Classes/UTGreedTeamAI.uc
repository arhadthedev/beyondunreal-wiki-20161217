/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// UTGreedTeamAI.
// strategic team AI control for UTGreedGame
//
//=============================================================================
class UTGreedTeamAI extends UTTeamAI;

var UTCTFBase HomeBase, EnemyBase;

function UTSquadAI AddSquadWithLeader(Controller C, UTGameObjective O)
{
	local UTGreedSquadAI S;
	local UTCTFBase CTFBase;

	if ( EnemyBase == None )
	{
		ForEach WorldInfo.AllNavigationPoints(class'UTCTFBase', CTFBase)
		{
			if ( Team.TeamIndex == CTFBase.DefenderTeamIndex )
			{
				HomeBase = CTFBase;
			}
			else
			{
				EnemyBase = CTFBase;
			}
		}
	}

	if ( O == None )
		O = EnemyBase;
	S = UTGreedSquadAI(Super.AddSquadWithLeader(C,O));
	if ( S != None )
	{
		S.HomeBase = HomeBase;
		S.EnemyBase = EnemyBase;
	}
	return S;
}

function ReAssessStrategy()
{
}

defaultproperties
{
	SquadType=class'UT3GoldGame.UTGreedSquadAI'

	OrderList(0)=ATTACK
	OrderList(1)=ATTACK
	OrderList(2)=ATTACK
	OrderList(3)=ATTACK
	OrderList(4)=ATTACK
	OrderList(5)=ATTACK
	OrderList(6)=ATTACK
	OrderList(7)=ATTACK
}