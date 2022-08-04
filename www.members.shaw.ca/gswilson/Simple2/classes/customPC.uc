// Greg Wilson - May 2003
// Networking Sample
//
//
//
// Convention:   All overwridden functions are start with capital letters. Lower
//              case function are homemade.
//              ie: DrawHud() vs drawRadar()
//-----------------------------------------------------------
class CustomPC extends xPlayer;

exec function transform()
{
    If(role < Role_AUTHORITY)
    {
        LOG("======>CLIENT PC TRANSFORMING: - bRobotMode == "@customPawn(pawn).bRobotMode);
    }
    If(role == Role_AUTHORITY)
    {
        LOG("======>SERVER PC TRANSFORMING: - bRobotMode == "@customPawn(pawn).bRobotMode);
    }
    /*  SETSENSITIVITY PERSISTS THROUGH ENGINE RE-STARTS!! MEANING, if YOU QUIT THE GAME IN
        JET MODE, THE NEXT TIME  YOU RUN UT2K3 AND PLAY ANY GAME TYPE. YOUR MOUSE WILL NOT WORK!
        IT CAN BE RUN FROM THE CONSOLE HOWEVER OR JUST TRANSFORM AGAIN TO RESET */
    if(!customPawn(pawn).bRobotMode)
        SetSensitivity(3.0);
    else
        SetSensitivity(0.0);             // mouse turns off in jet mode...

    customPawn(pawn).transform();        // start the transformation...
}

// every X seconds, run the Timer() function.
//simulated function PostNetBeginPlay()
//{
//    SetTimer(15.0, true);
//}

// called every X seconds as set by SetTimer();
//simulated function Timer()
//{
//    transform();
//}

DefaultProperties
{
   PawnClass=Class'Simple2.customPawn'    // make sure our customPawn is being used
}

