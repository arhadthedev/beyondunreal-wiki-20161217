class ClassTrader extends UT2K4GUIPage;

var Automated GUIListBox 		pcAvailable;
var Automated GUIScrollTextBox	txtAvailable;

var Automated GUIButton btnTeamA,btnTeamB;
var Automated GUIButton btnAvailChange,btnAvailAccept,btnAvailCancel;

var config string ClientTeam,ClientClass;
var RegularPlayer RgPlayer;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	RgPlayer = RegularPlayer(PlayerOwner());
	FillClassList();
//	txtAvailable.SetContent(pcAvailable.List.GetExtra());
}

function string CleanInv( coerce string S )
{
    ReplaceText(S, "|", "");
	return S;
}




function FillClassList() {
 local string ClassNameString,ClassDefString;
	local array<string> ClassNames,ClassDefs;
	local int i;
	local RegularPRI RgPRI;

	pcAvailable.List.Clear();

 if(RgPlayer != none && RgPlayer.PlayerReplicationInfo != none &&
    RegularPRI(RgPlayer.PlayerReplicationInfo) != none) {
    RgPRI = RegularPRI(RgPlayer.PlayerReplicationInfo);
    for(i=0; i<RgPRI.MaxClassNumber; i++) {
        if(RgPRI.PlayerClasses[i].TeamIndex == 255 || RgPRI.PlayerClasses[i].TeamIndex == RgPlayer.PlayerReplicationInfo.Team.TeamIndex ) {
								  ClassNameString = ClassNameString$"|"$RgPRI.PlayerClasses[i].ClassTitle;
          ClassDefString = ClassDefString$"|"$RgPRI.PlayerClasses[i].ClassDescription;
          }


    }
	}

// LOG("Found "$ClassString);
	Split(ClassNameString, "|", ClassNames);
 Split(ClassDefString, "|", ClassDefs);

	for(i=1; i<ClassNames.Length; i++)
	{
	  pcAvailable.List.Add(ClassNames[i],,ClassDefs[i]);
   }

  pcAvailable.List.Index = -1;
}



function bool InternalOnClick(GUIComponent Sender)
{
 if(Sender==btnTeamA) // choose human classes
	{
        RgPlayer.SetPlayerTeam(0);
        FillClassList();
	}

 if(Sender==btnTeamB) // choose human classes
	{
        RgPlayer.SetPlayerTeam(1);
        FillClassList();
	}


 if(Sender==btnAvailAccept) // continue
	{
        ClientClass = CleanInv(pcAvailable.List.GetExtra());
        RgPlayer.RestartPawn(pcAvailable.List.Get());
        Controller.CloseMenu(); // Close _all_ menus
	}

 if(Sender==btnAvailCancel) // continue
	{
		Controller.CloseMenu(); // Close _all_ menus
	}
	return true;
}

function InternalOnChange(GUIComponent sender) {
		 txtAvailable.SetContent(CleanInv(pcAvailable.List.GetExtra()));

}



defaultproperties {
Begin Object Class=GUIButton Name=TeamABTN
  Caption="TEAM A"
  WinTop=0.0500000
  WinLeft=0.20000
  WinWidth=0.10000
  OnClick=ClassTrader.InternalOnClick
  RenderWeight=1.5
End Object
btnTeamA=RegularEngine.ClassTrader.TeamABTN

Begin Object Class=GUIButton Name=TeamBBTN
  Caption="TEAM B"
  WinTop=0.0500000
  WinLeft=0.30000
  WinWidth=0.10000
  OnClick=ClassTrader.InternalOnClick
  RenderWeight=1.5
End Object
btnTeamB=RegularEngine.ClassTrader.TeamBBTN

Begin Object Class=GUIListBox Name=AvailLST
    bVisibleWhenEmpty=True
    WinTop=0.1000000
    WinLeft=0.200000
    WinWidth=0.250000
    WinHeight=0.45000
    StyleName="IRCText"
    RenderWeight=1.5
    OnChange=InternalOnChange
End Object
pcAvailable=RegularEngine.ClassTrader.AvailLST


 Begin Object Class=GUIScrollTextBox Name=AvailTXT
//    bNoTeletype=True
    bVisibleWhenEmpty=True
    CharDelay=0.001500
    EOLDelay=0.250000
    InitialDelay=0.001500
    bRepeat=false
    WinTop=0.1000000
    WinLeft=0.450000
    WinWidth=0.400000
    WinHeight=0.45000
    StyleName="IRCText"
    RenderWeight=1.5
End Object
txtAvailable=RegularEngine.ClassTrader.AvailTXT


Begin Object Class=GUIButton Name=AvailAcceptBTN
  Caption="ACCEPT"
  WinTop=0.6000000
  WinLeft=0.200000
  WinWidth=0.550000
  RenderWeight=1.5
  OnClick=ClassTrader.InternalOnClick
End Object
btnAvailAccept=RegularEngine.ClassTrader.AvailAcceptBTN

Begin Object Class=GUIButton Name=AvailCancelBTN
  Caption="CANCEL"
  WinTop=0.6000000
  WinLeft=0.750000
  WinWidth=0.10000
  OnClick=ClassTrader.InternalOnClick
  RenderWeight=1.5
End Object
btnAvailCancel=RegularEngine.ClassTrader.AvailCancelBTN


bAllowedAsLast=True
bRenderWorld=True


}
