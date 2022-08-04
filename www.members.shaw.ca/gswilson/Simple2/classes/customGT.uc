// Greg Wilson - May 2003
// Networking Sample
//
//
// Convention:   All overwridden functions are start with capital letters. Lower
//              case function are homemade.
//              ie: DrawHud() vs drawRadar()
//-----------------------------------------------------------
class CustomGT extends xDeathMatch;

defaultproperties
{
    CountDown=0
    PlayerControllerClassName = "Simple2.CustomPC"    // make sure our customPC is being used.
    bAllowBehindView = true
}


