class MapTrader extends UT2K4GUIPage;

var Automated GuiListBox TeamAMapList, TeamBMapList;
var Automated GUIButton TeamAVote, TeamBVote;
var Automated GUILabel		TeamAName, TeamBName, CampaignWon;
var RegularPlayer RgPlayer;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	RgPlayer = RegularPlayer(PlayerOwner());
	FillMapLists();
	if(RgPlayer != none && RgPlayer.PlayerReplicationInfo != none) {

    if( RgPlayer.PlayerReplicationInfo.Team.TeamIndex == 0 ) {
      TeamAVote.bVisible = false;
    }

    if( RgPlayer.PlayerReplicationInfo.Team.TeamIndex == 1 ) {
      TeamBVote.bVisible = false;
    }

    }
//	txtAvailable.SetContent(pcAvailable.List.GetExtra());
}

function FillMapLists() {
 local string TeamAString,TeamBString;
	local array<string> TeamAMaps,TeamBMaps;
	local RegularGRI RgGRI;
	local int i;

	TeamAMapList.List.Clear();
	TeamBMapList.List.Clear();

	if(RgPlayer != none && RgPlayer.GameReplicationInfo != none &&
    RegularGRI(RgPlayer.GameReplicationInfo) != none) {
    RgGRI = RegularGRI(RgPlayer.GameReplicationInfo);
    for(i=0; i<RgGRI.MaxMapNumber; i++) {
        if(RgGRI.TeamAMaps[i].TeamIndex == 0 ) {
								  TeamAString = TeamAString$"|"$RgGRI.TeamAMaps[i].MapName;
          }
        if(RgGRI.TeamAMaps[i].TeamIndex == 1 ) {
								  TeamBString = TeamBString$"|"$RgGRI.TeamAMaps[i].MapName;
          }

       if(RgGRI.TeamBMaps[i].TeamIndex == 0 ) {
								  TeamAString = TeamAString$"|"$RgGRI.TeamBMaps[i].MapName;
          }
        if(RgGRI.TeamBMaps[i].TeamIndex == 1 ) {
								  TeamBString = TeamBString$"|"$RgGRI.TeamBMaps[i].MapName;
          }


    }
	}

 Split(TeamAString, "|", TeamAMaps);
 Split(TeamBString, "|", TeamBMaps);

	for(i=0; i<RgGRI.MaxMapNumber*2; i++)
	{
	  if(i<TeamAMaps.Length) {TeamAMapList.List.Add(TeamAMaps[i],,TeamAMaps[i]);}
	  if(i<TeamBMaps.Length) {TeamBMapList.List.Add(TeamBMaps[i],,TeamBMaps[i]);}

   }

  TeamAMapList.List.Index = -1;
  TeamBMapList.List.Index = -1;
		LOG("Humans have "$TeamAMaps.Length$" Maps");
  if( TeamAMaps.Length == 1) {
		    CampaignWon.Caption = "SKAARJ WIN THE CAMPAIGN";
		    TeamAVote.bVisible = false;
		    TeamBVote.bVisible = false;
		    }
  if( TeamBMaps.Length == 1) {
		    CampaignWon.Caption = "HUMANS WIN THE CAMPAIGN";
		    TeamAVote.bVisible = false;
		    TeamBVote.bVisible = false;
		    }


}

function bool InternalOnClick(GUIComponent Sender)
{
	if( Sender == TeamAVote ) {
	   RgPlayer.SetChosenMap(TeamBMapList.List.Get());
	}

	if( Sender == TeamBVote ) {
	   RgPlayer.SetChosenMap(TeamBMapList.List.Get());
	}

	Controller.CloseMenu();
 return true;
}

function InternalOnChange(GUIComponent sender) {
}


defaultproperties {


Begin Object Class=GUIListBox Name=TeamALST
    bVisibleWhenEmpty=True
    WinTop=0.1000000
    WinLeft=0.200000
    WinWidth=0.250000
    WinHeight=0.45000
    StyleName="IRCText"
    RenderWeight=1.5
    OnChange=InternalOnChange
End Object
TeamAMapList=RegularEngine.MapTrader.TeamALST

Begin Object Class=GUIListBox Name=TeamBLST
    bVisibleWhenEmpty=True
    WinTop=0.1000000
    WinLeft=0.500000
    WinWidth=0.250000
    WinHeight=0.45000
    StyleName="IRCText"
    RenderWeight=1.5
    OnChange=InternalOnChange
End Object
TeamBMapList=RegularEngine.MapTrader.TeamBLST

Begin Object Class=GUIButton Name=TeamABTN
  Caption="VOTE"
  WinTop=0.600000
  WinLeft=0.20000
  WinWidth=0.25000
  OnClick=MapTrader.InternalOnClick
  RenderWeight=1.5
End Object
TeamAVote=RegularEngine.MapTrader.TeamABTN

Begin Object Class=GUIButton Name=TeamBBTN
  Caption="VOTE"
  WinTop=0.600000
  WinLeft=0.50000
  WinWidth=0.25000
  OnClick=MapTrader.InternalOnClick
  RenderWeight=1.5
End Object
TeamBVote=RegularEngine.MapTrader.TeamBBTN


Begin Object Class=GUILabel Name=AName
    FontScale=FNS_Large
    TextFont="UT2LargeFont"
    StyleName="TextLabel"
    Caption="HUMAN MAPS"
    WinTop=0.00500000
    WinLeft=0.2000000
    WinHeight=0.185
    RenderWeight=9.0
End Object
TeamAName=RegularEngine.MapTrader.AName



Begin Object Class=GUILabel Name=BName
    FontScale=FNS_Large
    TextFont="UT2LargeFont"
    StyleName="TextLabel"
    Caption="SKAARJ MAPS"
    WinTop=0.00500000
    WinLeft=0.5000000
    WinHeight=0.185
    RenderWeight=9.0
End Object
TeamBName=RegularEngine.MapTrader.BName



Begin Object Class=GUILabel Name=Won
    FontScale=FNS_Large
    TextFont="UT2LargeFont"
    StyleName="TextLabel"
    Caption=""
    WinTop=0.600000
    WinLeft=0.2000000
    WinHeight=0.185
    RenderWeight=9.0
End Object
CampaignWon=RegularEngine.MapTrader.Won

bAllowedAsLast=True
bRenderWorld=True

}
