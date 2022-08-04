class RegularGame extends xTeamGame
      config(RegularEngineData);

var() class<Controller> BotControllerClass;
var bool bGameVoted,bMapVoting;

var RegularRules RegularRules;

var PlayerReplicationInfo FinalWinner;
var string FinalReason;

var config bool bCampaignGame;



function PostBeginPlay()
{
 Super.PostBeginPlay();
 RegularRules = spawn(class'RegularRules');
 if (Level.Game.GameRulesModifiers == None) {
     Level.Game.GameRulesModifiers = RegularRules;
     }else{
     Level.Game.GameRulesModifiers.AddGameRules(RegularRules);
     }
}

function Bot SpawnBot(optional string botName)
{
    local Bot NewBot;
    local RosterEntry Chosen;
	   local UnrealTeamInfo BotTeam;

	   BotTeam = GetBotTeam();
    Chosen = BotTeam.ChooseBotClass(botName);

    if (Chosen.PawnClass == None)
        Chosen.Init(); //amb
    //log("Chose pawn class "$Chosen.PawnClass);

    NewBot = Bot(Spawn(BotControllerClass));


    if ( NewBot != None )
        InitializeBot(NewBot,BotTeam,Chosen);

    return NewBot;
}

function RestartPlayer(Controller aPlayer) {
	if(RegularPlayer(aPlayer) != none) {
	   if(RegularPRI(aPlayer.PlayerReplicationInfo) != none &&
				   RegularPRI(aPlayer.PlayerReplicationInfo).PlayerClassName ~= "" || !RegularPRI(aPlayer.PlayerReplicationInfo).ValidPlayerClassChoice()
							) {
				   RegularPlayer(aPlayer).OpenClassTrader();
				   return;
				   }
	}
	if(RegularBot(aPlayer) != none) {
	   RegularBot(aPlayer).ChoosePlayerClass();
	}
	super.RestartPlayer(aPlayer);
//	Log("Spawned a "$aPlayer.Pawn$" for "$aPlayer);
}





function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	if(!bCampaignGame) { return super.CheckEndGame(Winner,Reason);  }  //  no campaign? end as normal

 if(bGameVoted) {return true;}
	super.CheckEndGame(Winner,Reason);          //get a winner

	//allow voting
	RegularGRI(GameReplicationInfo).RewardMap(Winner.Team.TeamIndex,GetURLMap());

	PromptMapVote(TeamInfo(GameReplicationInfo.Winner));
	FinalWinner = Winner;
	FinalReason = Reason;
 GotoState('WaitingForVote');
 return false;


}

function string CheckEndCampaign() {

//	if( RegularGRI(GameReplicationInfo).CampaignWon() ) {
	    RegularGRI(GameReplicationInfo).ResetCampaign();
//	}

	if (FinalWinner.Team.TeamIndex == 0) { return RegularGRI(GameReplicationInfo).TeamAMaps[0].MapName; }
	else {return RegularGRI(GameReplicationInfo).TeamBMaps[0].MapName; }

}

function PromptMapVote(TeamInfo Winner) {
 local Controller P;
	local RegularPlayer RgPlayer;

    if(Winner == None) {Log("What the hell??"); return;}
    if(bMapVoting) {return;}

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		RgPlayer = RegularPlayer(P);
		if ( RgPlayer != None  && RegularPRI(P.PlayerReplicationInfo).ChosenMap == "" )
		{
		 if(RgPlayer.PlayerReplicationInfo.Team == Winner) {
		    RgPlayer.OpenMapTrader();
		    } else {
		    RgPlayer.OpenMapViewer();
		    }
		}

	}
	bMapVoting = true;
}

state WaitingForVote extends MatchInProgress {

function BeginState() {
  SetTimer(10.0,false);
//  Log("In WaitingForVote");
}

function Timer() {
  local Controller P;
  local RegularPlayer RgPlayer;

// Log("Hit WaitingForVote Timer");
 bGameVoted = true;
 if(FinalWinner == None) {Log("What the hell?!!?"); return;}

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		RgPlayer = RegularPlayer(P);
		if ( RgPlayer != None && RgPlayer.PlayerReplicationInfo.Team == FinalWinner.Team )
		{
		   RegularRules.CastVote(RegularPRI(RgPlayer.PlayerReplicationInfo).ChosenMap);
		//   LOG("Cast vote for "$RegularPRI(RgPlayer.PlayerReplicationInfo).ChosenMap);
		}

	}
  RegularRules.HandleRestartGame();
}

}


/* Restart the game.
*/
function RestartGame()
{
    local string NextMap;
    local MapList MyList;

				//campaign check
				if(bCampaignGame) {return;}

	// allow voting handler to stop travel to next map
    if ( VotingHandler != None && !VotingHandler.HandleRestartGame() )
        return;

    // these server travels should all be relative to the current URL
    if ( bChangeLevels && !bAlreadyChanged && (MapListType != "") )
    {
        // open a the nextmap actor for this game type and get the next map
        bAlreadyChanged = true;
        MyList = GetMapList(MapListType);
		if (MyList != None)
		{
			NextMap = MyList.GetNextMap();
			MyList.Destroy();
		}
        if ( NextMap == "" )
            NextMap = GetMapName(MapPrefix, NextMap,1);

        if ( NextMap != "" )
        {
            Level.ServerTravel(NextMap, false);
            return;
        }
    }

    Level.ServerTravel( "?Restart", false );
}



defaultproperties {
 GameName="RegularEngine Example"
	PlayerControllerClassName="RegularEngine.RegularPlayer"
 BotControllerClass=class'RegularBot'
 DefaultPlayerClassName="RegularEngine.RegularPawn"
 GameReplicationInfoClass=class'RegularGRI'
	ScoreboardType="RegularEngine.RegularScoreboard"
	HUDType="RegularEngine.RegularHUD"
	bCampaignGame=true

 Description="Example game on the RgEngine with optional campaign mode."
}
