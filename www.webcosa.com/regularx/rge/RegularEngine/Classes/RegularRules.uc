class RegularRules extends GameRules
      config(RegularEngineData);

var config string LastMapName;
var bool bCampaignWon;

var string ChosenMaps;

//
// Here we're going to try and trick the server into going to the right map for campaign mode
//
function bool HandleRestartGame()
{
	local String MapName;

 Level.Game.bGameRestarted = true;

	if(RegularGame(Level.Game).bCampaignGame) {
    if(RegularGame(Level.Game) != none && !RegularGame(Level.Game).bGameVoted) {return false;}  //allow voting

    // these server travels should all be relative to the current URL
    if ( Level.Game.bChangeLevels && !Level.Game.bAlreadyChanged )
    {
     MapName = GetWinningMap();

					if (MapName == "") { MapName = RegularGame(Level.Game).CheckEndCampaign(); }
    	Level.Game.bAlreadyChanged = true;
    	LastMapName = MapName;
    	SaveConfig();
    	LOG("Travelling to "$MapName);
     Level.ServerTravel(MapName$"?game=RegularEngine.RegularGame", false );
	  }
	} else {        // end normally
	  Level.Game.bChangeLevels=true;
   Level.Game.bAlreadyChanged=false;
   Level.Game.bGameRestarted=true;

			LOG("Getting next map");
			RegularGame(Level.Game).RestartGame();
	}

	if ( (NextGameRules != None) && NextGameRules.HandleRestartGame() )       // try to allow other mutators
		return true;
	return false;
}

function CastVote(string MapName) {
 ChosenMaps = ChosenMaps$"|"$MapName;
// LOG("Chosen Maps is "$ChosenMaps);
}

function string GetWinningMap() {
 local int x,y,z;
 local int MostVotes;
 local string WinningMap;
 local Array<string> MapNames;

 Split(ChosenMaps,"|",MapNames);
	MostVotes = 0;

//	LOG("Finding Winning Map");

 for(x=1;x<MapNames.Length;x++) {
     z=0;
					for(y=0;y<MapNames.Length;y++) {
         if(MapNames[y] ~= MapNames[x]) {z++;}
					//				LOG("Found Vote");
									}
					if(z > MostVotes) {
					   MostVotes = z;
					   WinningMap = MapNames[x];
					}


 }
	if (WinningMap == "") { WinningMap = ChoseNextMap();}

 return WinningMap;
}

function string ChoseNextMap() {
		local int TeamIndex,i;

		TeamIndex = RegularGame(Level.Game).FinalWinner.Team.TeamIndex;

		for(i=0;i<RegularGRI(Level.Game.GameReplicationInfo).MaxMapNumber;i++) {
		    if(RegularGRI(Level.Game.GameReplicationInfo).TeamAMaps[i].TeamIndex != TeamIndex) {
		       return RegularGRI(Level.Game.GameReplicationInfo).TeamAMaps[i].MapName;
		    }

		    if(RegularGRI(Level.Game.GameReplicationInfo).TeamBMaps[i].TeamIndex != TeamIndex) {
		       return RegularGRI(Level.Game.GameReplicationInfo).TeamBMaps[i].MapName;
		    }
		}

}

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	if ( NextGameRules != None )
		Damage = NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	if ( RegularPawn(injured) != None )
		Damage *= RegularPawn(injured).ReceivedDamageScaling;
	return Damage;
}
