// Greg Wilson - Aug 2003
// Networking Sample
// Replicates function calls from server to client and visa versa.
// Creates logs on client and server based on which function is called.
//
// TODO: variable replication
//
// Convention:   All overwridden functions are start with capital letters. Lower
//              case function are homemade.
//              ie: DrawHud() vs drawRadar()
//-----------------------------------------------------------
class CustomPC extends xPlayer;

DefaultProperties
{
    PawnClass=Class'SimpleB.customPawn'
}

