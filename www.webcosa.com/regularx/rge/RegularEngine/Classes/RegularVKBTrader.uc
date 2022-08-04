class RegularVKBTrader extends UT2K4GUIPage
      config(RegularEngineData);

var Array<string> Keys;
var Array<string> Binds;
var Array<string> Descriptions;

var Automated GUIListBox 		vkbAvailable;
var Automated GUIScrollTextBox	txtAvailable;

var Automated GUIButton btnAvailChange,btnAvailAccept,btnAvailCancel;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	FillBindList();
	txtAvailable.SetContent(vkbAvailable.List.GetExtra());
}


function FillBindList() {
    local int x,i;

    vkbAvailable.List.Clear();

    for (i = 0; i < PlayerOwner().Player.LocalInteractions.Length; i++)
    {
    	if (  RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]) != None )
    	{
    		for ( x = 0; x<RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]).Keys.Length; x++ ) {
    		Keys[x]=RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]).Keys[x];
    		Binds[x]=RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]).Binds[x];
    		Descriptions[x]=RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]).Descriptions[x];

            }
    	}
    }

    for (i = 0; i < Keys.Length; i++)
    {
     vkbAvailable.List.Add(Binds[i]$"["$Keys[i]$"]",,Descriptions[i]);
    }


}

function PreviewBinds() {
 local int i;

 vkbAvailable.List.Clear();
 for (i = 0; i < Keys.Length; i++)
 {
 vkbAvailable.List.Add(Binds[i]$"["$Keys[i]$"]",,Descriptions[i]);
 }

}


function AcceptBinds() {
   local int x,i;


    for (i = 0; i < PlayerOwner().Player.LocalInteractions.Length; i++)
    {
    	if (  RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]) != None )
    	{
    		for ( x = 0; x<RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]).Keys.Length; x++ ) {
    		RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]).Keys[x]=Keys[x];
    		RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]).Binds[x]=Binds[x];
    		RegularVersatileKeyBind(PlayerOwner().Player.LocalInteractions[i]).Descriptions[x]=Descriptions[x];
    		PlayerOwner().Player.LocalInteractions[i].SaveConfig();
            }
    	}
    }
}

function bool InternalOnClick(GUIComponent Sender)
{
 if(Sender==btnAvailAccept) // continue
	{
		AcceptBinds();
  Controller.CloseMenu(); // Close _all_ menus
	}

 if(Sender==btnAvailCancel) // continue
	{
		Controller.CloseMenu(); // Close _all_ menus
	}

	return true;
}

function InternalOnChange(GUIComponent sender) {
		 txtAvailable.SetContent(vkbAvailable.List.GetExtra());

}

function bool KeyClick(GUIComponent Sender)
{
   if(Sender==btnAvailChange) // continue
	{
	    btnAvailChange.Caption="PRESS NEW KEY";
        Controller.OnNeedRawKeyPress = RawKeyPress;
	    Controller.Master.bRequireRawJoystick = True;
	    PlayerOwner().ConsoleCommand("toggleime 0");

	    return true;
	}

	return false;
}

function bool RawKeyPress(byte NewKey)
{
	local string NewKeyName, LocalizedKeyName;

    btnAvailChange.Caption="Change";
    Controller.OnNeedRawKeyPress = None;
    Controller.Master.bRequireRawJoystick = False;
    PlayerOwner().ConsoleCommand("toggleime 1");

	if ( NewKey == 0x1B )
	{
		return true;
	}

	Controller.KeyNameFromIndex( NewKey, NewKeyName, LocalizedKeyName );
    Keys[vkbAvailable.List.Index]=NewKeyName;
	PlayerOwner().ClientPlaySound(Controller.ClickSound);
    PreviewBinds();
    return true;
}


defaultproperties {


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
vkbAvailable=RegularEngine.RegularVKBTrader.AvailLST


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
txtAvailable=RegularEngine.RegularVKBTrader.AvailTXT

Begin Object Class=GUIButton Name=AvailChangeBTN
  Caption="CHANGE"
  WinTop=0.5500000
  WinLeft=0.200000
  WinWidth=0.650000
  RenderWeight=1.5
  OnClick=RegularVKBTrader.KeyClick
End Object
btnAvailChange=RegularEngine.RegularVKBTrader.AvailChangeBTN

Begin Object Class=GUIButton Name=AvailAcceptBTN
  Caption="ACCEPT"
  WinTop=0.6000000
  WinLeft=0.200000
  WinWidth=0.550000
  RenderWeight=1.5
  OnClick=RegularVKBTrader.InternalOnClick
End Object
btnAvailAccept=RegularEngine.RegularVKBTrader.AvailAcceptBTN

Begin Object Class=GUIButton Name=AvailCancelBTN
  Caption="CANCEL"
  WinTop=0.6000000
  WinLeft=0.750000
  WinWidth=0.10000
  OnClick=RegularVKBTrader.InternalOnClick
  RenderWeight=1.5
End Object
btnAvailCancel=RegularEngine.RegularVKBTrader.AvailCancelBTN


bAllowedAsLast=True
bRenderWorld=True
}
