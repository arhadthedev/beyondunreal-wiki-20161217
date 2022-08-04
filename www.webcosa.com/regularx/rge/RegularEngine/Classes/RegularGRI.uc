class RegularGRI extends GameReplicationInfo
      config(RegularEngineData);

struct GameMap {
	var string MapName;
	var string Descript;
	var int TeamIndex;
};

var config int MaxMapNumber;
var config GameMap TeamAMaps[9];
var config GameMap TeamBMaps[9];

replication
{
	// Things Server should send to client
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		TeamAMaps, TeamBMaps, RewardMap, ResetCampaign;
}

simulated function RewardMap(int TeamIndex, string MapName) {
	local int i;

	for(i=0;i<MaxMapNumber;i++) {
	    if(TeamAMaps[i].MapName ~= MapName) {TeamAMaps[i].TeamIndex=TeamIndex;}
	    if(TeamBMaps[i].MapName ~= MapName) {TeamBMaps[i].TeamIndex=TeamIndex;}
	}
	SaveConfig();
}

simulated function ResetCampaign() {
  local int i;

	for(i=0;i<MaxMapNumber;i++) {
	    TeamAMaps[i].TeamIndex=0;
	    TeamBMaps[i].TeamIndex=1;
	}
	SaveConfig();


}

defaultproperties {
	TeamAMaps[0]=(MapName="DM-Antalus",Descript="",TeamIndex=0)
	TeamAMaps[1]=(MapName="DM-Asbestos",Descript="",TeamIndex=0)
	TeamAMaps[2]=(MapName="DM-Compressed",Descript="",TeamIndex=0)
	TeamAMaps[3]=(MapName="DM-Corrugation",Descript="",TeamIndex=0)
	TeamAMaps[4]=(MapName="DM-Curse4",Descript="",TeamIndex=0)
	TeamBMaps[0]=(MapName="DM-Deck17",Descript="",TeamIndex=1)
	TeamBMaps[1]=(MapName="DM-Flux2",Descript="",TeamIndex=1)
	TeamBMaps[2]=(MapName="DM-Gael",Descript="",TeamIndex=1)
	TeamBMaps[3]=(MapName="DM-Gestalt",Descript="",TeamIndex=1)
	TeamBMaps[4]=(MapName="DM-Goliath",Descript="",TeamIndex=1)
	MaxMapNumber=5

}









