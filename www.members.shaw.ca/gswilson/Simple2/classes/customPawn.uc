// Greg Wilson - May 2003
// Networking Sample
//
//
//
// Convention:  All overwridden functions are start with capital letters. Lower
//              case function are homemade.
//              ie: DrawHud() vs drawRadar()
//-----------------------------------------------------------
class customPawn extends xPawn;

var bool bRobotMode;

replication
{
    // server replicates this to the client
    reliable if(role == Role_AUTHORITY)
                setupModeClient, bRobotMode;   // this is the server saying: ok
                                               // I've updated your variable based
                                               // on player input, here's it's new
                                               // value and btw, run this function.


    // client replicates this to the server
    reliable if(role < Role_AUTHORITY)
                transform;     // this is updating the server of the players
                               // desired state.
}

// this is a server side only function. it will not do anything if called on a client.   You cannot both, run
// a function on the server and replicate it or visa versa,...thus, separate server and client functions that
// appear to do exactly the same thing.
function setupModeServer()
{
    if (role < Role_AUTHORITY)     // if we are a client...
        return;

    if(!bRobotMode)
    {
        PlayerController(Controller).FOV(120);
        playercontroller(controller).BehindView(true);
    }
    else
    {
        PlayerController(Controller).FOV(100);
        playercontroller(controller).BehindView(false);
    }
}

// this is a client only function, it will not do anything if called on a server.  this function is replicated to
// the client as fob and behindview are restricted commands in networked games.
simulated function setupModeClient()
{
     if (role == Role_AUTHORITY)     // if we are the server...
        return;

    if(!bRobotMode)
    {
        PlayerController(Controller).FOV(120);
        playercontroller(controller).BehindView(true);
    }
    else
    {
        PlayerController(Controller).FOV(100);
        playercontroller(controller).BehindView(false);
    }
}

// this function sets our 'mode' and enters the appropriate state
simulated function transform()
{
    bRobotMode = !bRobotMode;    // toggle the value of bRobotMode

    if (!bRobotMode)
    {
        GotoState('JetMode');
    }
    else
    {
        GotoState('MechMode');
    }
}

// Mech state. auto keyword means we start in this state
auto state MechMode
{
     // go through this state and hang in it until another state is called
    function beginstate()
    {
        LOG("======>ENTERING MECHSTATE");

        if(role == Role_AUTHORITY)          // if we are the server.
        {
           setupModeServer();
        }
        else if( role < Role_AUTHORITY)     // we are a client
        {
           setupModeClient();
        }

        SetPhysics(PHYS_Falling);           // gravity applies
    }

    function endstate()       // this is guaranteed to be called before we exit this state.
    {
        LOG("======>EXITING MECHSTATE");
    }
}

// Jet state
state JetMode
{
    // go through this state and hang in it until another state is called
    function beginstate()
    {
        LOG("======>ENTERING JETSTATE");
        if(bRobotMode)
        {
            LOG("bROBOTMODE INCORRECT BEFORE ENTERING STATE");
        }

        if(role == Role_AUTHORITY)   // if we are the server.
        {
           setupModeServer();
        }
        else if( role < Role_AUTHORITY)
        {
           setupModeClient();
        }

        SetPhysics(PHYS_Flying);         // gravity does not apply to jets
    }

    function endstate()
    {
        LOG("======>EXITING JETSTATE");
    }
}

defaultproperties
{
      bAlwaysRelevant = true        // guarantees replication of our pawn
      bRobotMode = true
}
