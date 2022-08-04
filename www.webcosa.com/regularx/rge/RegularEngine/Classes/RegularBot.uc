class RegularBot extends xBot;

function Possess( Pawn aPawn )
{
    local RegularPawn rp;

				rp = RegularPawn(aPawn);

				if (rp != none) {rp.PlayerClassName = RegularPRI(PlayerReplicationInfo).PlayerClassName;}

    Super.Possess( aPawn );
}

function SetPawnClass(string inClass, string inCharacter)
{
    PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
    PlayerReplicationInfo.SetCharacterName(PawnSetupRecord.DefaultName);
}

function ChoosePlayerClass() {
	local int i;
	if(RegularPRI(PlayerReplicationInfo) != none) {
	   for(i=0;i<RegularPRI(PlayerReplicationInfo).MaxClassNumber;i++) {
	       if(RegularPRI(PlayerReplicationInfo).PlayerClasses[i].TeamIndex == RegularPRI(PlayerReplicationInfo).Team.TeamIndex ||
	          RegularPRI(PlayerReplicationInfo).PlayerClasses[i].TeamIndex == 255 ) {
											RegularPRI(PlayerReplicationInfo).PlayerClassName = RegularPRI(PlayerReplicationInfo).PlayerClasses[i].ClassTitle;
											if(Rand(10) > 5) {break;}
											}
	   }
	}

}


defaultproperties {
PawnClass=class'RegularPawn'
PlayerReplicationInfoClass=Class'RegularPRI'
}
