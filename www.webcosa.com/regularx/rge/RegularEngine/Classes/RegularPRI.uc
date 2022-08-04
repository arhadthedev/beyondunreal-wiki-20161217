class RegularPRI extends PlayerReplicationInfo
      config(RegularEngineData);

var config string PlayerClassName;         // current Player class
var int MaxClassNumber;                //Max Number of Player Classes in use

struct PlayerClass {                // Player class Definition
	var string ClassTitle;
	var string ClassDescription;
	var int TeamIndex;                 //255 will be accessible by both teams
};

var PlayerClass PlayerClasses[9];    // Player Classes to Choose From
																																					// this is just one method.  9 seems to be the limit for static arrays to be
																																					// replicated.  For more classes, use more arrays.

var string ChosenMap;                // For Campaign mode, used to determine the map being voted on

replication
{
	// Things Server should send to client
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		PlayerClassName, PlayerClasses;
		// Things client should send to server
	reliable if ( Role < ROLE_Authority )
		ChosenMap;
}

function bool ValidPlayerClassChoice() {
	 local int i;

	 for(i=0;i<MaxClassNumber;i++) {
	    if(PlayerClasses[i].ClassTitle ~= PlayerClassName &&
	      (PlayerClasses[i].TeamIndex != 255 &&
	       PlayerClasses[i].TeamIndex != Team.TeamIndex) ) {
	       return false;
	       }
	 }

	 return true;
}

defaultproperties  {
	MaxClassNumber = 8
	PlayerClasses[0]=(ClassTitle="Sniper",ClassDescription="Fast and stealthy. Armed with a sniper rifle",TeamIndex=0)
	PlayerClasses[1]=(ClassTitle="Infantry",ClassDescription="Standard soldier.  Armed with minigun.",TeamIndex=0)
	PlayerClasses[2]=(ClassTitle="Heavy Arms",ClassDescription="Slow but armored.  Armed with rocket launcher.",TeamIndex=0)
	PlayerClasses[3]=(ClassTitle="Human Captain",ClassDescription="Armed with Flak Cannon.",TeamIndex=0)
	PlayerClasses[4]=(ClassTitle="Trooper",ClassDescription="Average soldier.  Armed with Link Gun.",TeamIndex=1)
	PlayerClasses[5]=(ClassTitle="Specialist",ClassDescription="Trained with the Shock Rifle.",TeamIndex=1)
	PlayerClasses[6]=(ClassTitle="Assault",ClassDescription="Armed with spider mines.",TeamIndex=1)
	PlayerClasses[7]=(ClassTitle="Skaarj Captain",ClassDescription="Has both Link Gun and Grenade Launcher.",TeamIndex=1)
}
