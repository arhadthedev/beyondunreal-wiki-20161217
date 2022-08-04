class RegularPlayer extends xPlayer;

replication
{
	// Things client should send to server
	reliable if ( Role < ROLE_Authority )
		RestartPawn,SetChosenMap,SetPlayerTeam;
}


event InitInputSystem()
{
    local int i;
				super.InitInputSystem();

				for (i = 0; i < Player.LocalInteractions.Length; i++)
    {
    	if (  UDSVersatileKeyBind(Player.LocalInteractions[i]) != None )
    	{ Player.interactionMaster.RemoveInteraction(Player.LocalInteractions[i]);}
    }

    Player.interactionMaster.AddInteraction("RegularEngine.RegularVersatileKeyBind", Player);
}


exec function keybinds() {
 ClientOpenMenu("RegularEngine.RegularVKBTrader");
}

exec function OpenClassTrader() {
   Log("Opening class Trader");
   ClientOpenMenu("RegularEngine.ClassTrader");
}


function OpenMapTrader() {
   Log("Opening Map Trader");
   ClientOpenMenu("RegularEngine.MapTrader");
}


function OpenMapViewer() {
   Log("Opening Map Trader");
   ClientOpenMenu("RegularEngine.MapViewer");
}

function Possess( Pawn aPawn )
{
    local RegularPawn rp;

				rp = RegularPawn(aPawn);

				if (rp != none) {rp.PlayerClassName = RegularPRI(PlayerReplicationInfo).PlayerClassName;}

    Super.Possess( aPawn );
}

simulated function RestartPawn(string NewClass) {
 RegularPRI(PlayerReplicationInfo).PlayerClassName = NewClass;
 RegularPRI(PlayerReplicationInfo).SaveConfig();
	Suicide();
	AskForPawn();
}

simulated function SetChosenMap(string ChosenMap) {
	RegularPRI(PlayerReplicationInfo).ChosenMap = ChosenMap;
}


simulated function SetPlayerTeam(int i) {


 if(GameReplicationInfo.Teams[i] != none){

			if(PlayerReplicationInfo.Team != none){PlayerReplicationInfo.Team.RemoveFromTeam(self);}

			if(PlayerReplicationInfo.Team != GameReplicationInfo.Teams[i]) {
			  GameReplicationInfo.Teams[i].AddToTeam(self);
					PlayerReplicationInfo.Team = GameReplicationInfo.Teams[i];
			  }
		  log("SBPlayer Set Player Team to "$PlayerReplicationInfo.Team.TeamName );
			} else{ log("ERROR NO PLAYER TEAM SET");}

}


auto state PlayerWaiting
{
  exec function AltFire(optional float F)
    {
        OpenClassTrader();
    }

}


state Dead
{
  exec function AltFire(optional float F)
    {
        OpenClassTrader();
    }

}

defaultproperties {
PawnClass=class'RegularPawn'
PlayerReplicationInfoClass=Class'RegularPRI'
}
