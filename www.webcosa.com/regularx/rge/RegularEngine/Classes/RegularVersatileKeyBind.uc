class RegularVersatileKeyBind extends Interaction
      config(RegularEngineData);


var config bool bClientSet;
var config Array<string> Keys;
var config Array<string> Binds;
var config Array<string> Descriptions;

function Initialize()
{
    Log("VersatileKeyBind Interaction Initialized");
    if(bClientSet) {
      bClientSet=true;
      SaveConfig();
      }
}

function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta )
{
    local int i;

    if (Action == IST_Release) {
    //    ViewportOwner.Actor.ClientMessage("Key PRESSED:"$class'Engine.Interactions'.static.GetFriendlyName(Key));

    for(i=0; i<Keys.Length; i++) {
        if(Keys[i] ~= class'Engine.Interactions'.static.GetFriendlyName(Key)) {
      //     ViewportOwner.Actor.ClientMessage("Key PRESSED:"$class'Engine.Interactions'.static.GetFriendlyName(Key));
											if(!ViewportOwner.Actor.bIsTyping){ ViewportOwner.Actor.ConsoleCommand(Binds[i]); }
   //        LOG(self$" Called Keybind");
											break;
        }
    }

    }
    return false;
}



defaultproperties {
 bClientSet=False
 bActive=True
 Keys[0]="K"
 Binds[0]="keybinds"
 Descriptions[0]="Open This Menu"
 Keys[1]="P"
 Binds[1]="openclasstrader"
 Descriptions[1]="Open Class Menu"


}


