// Greg Wilson - Aug 2003
// Networking Sample
// Replicates function calls from server to client and visa versa.
// Creates logs on client and server based on which function is called.
//
// Since the server cannont call a function on the client via an exec command
// we set a boolean when the exec is pressed and have a timer()or tick() call it
// for us.
//
// The exec function are mapped to F11 (serverOnly) and F12 (clientOnly) in the
// user.ini included with this zip.
//-----------------------------------------------------------
class customPawn extends xPawn;

var() bool bUpdate;

replication
{
    // server calls these on the client
    reliable if(role == Role_AUTHORITY)
                clientOnlyFunctionCalledByServer;

    // client calls these on the server
    reliable if(role < Role_AUTHORITY)
                serverOnlyFunctionCalledbyClient;
}

// calls a client only function from the server...based on bUpdate
// comment the whole tick function out if you uncomment clientOnlyFunctionCalledByServer  inside serverOnlyFunction
simulated event tick(float deltaTime)
{
    super.Tick(deltaTime);
    if(bUpdate)
    {
        clientOnlyFunctionCalledByServer();
        bUpdate = false ;     // after we update the client, set update to false and wait for next keypress.
    }
}

// server side function only. calls clientOnlyFunctionCalledByServer on the clients
function exec serverOnlyFunction()
{
    LOG("=====>serverOnlyFunction called by role"@role); // role should log as a 4
    //  clientOnlyFunctionCalledByServer();         // uncomment this to see that server cant call a client only function via an exec
    bUpdate = true;
}

// replicated function. Server can call this function on each client via serverOnlyFunction
simulated function clientOnlyFunctionCalledByServer()
{
    if(role < role_authority)
        LOG("=====>serverOnlyFunction called on client via serverOnlyFunction on server"@role);   // Role should log as a 3 or less
}

// clientside function only. calls serverOnlyFunctionCalledbyClient on the server.
exec function clientOnlyFunction()
{
    if(role == role_authority)
        return;
    LOG("=====>clientOnlyFunction called by role"@role); // role should log as a 3 or less
    serverOnlyFunctionCalledbyClient();     // simulated function allows replication across network
}

// replicated function. Clients calls this function on the sever via clientOnlyFunction
simulated function serverOnlyFunctionCalledByClient()
{
    if(role < role_authority)
        return;
    if(role == role_authority)
        LOG("=====>serverOnlyFunctionCalledByClient called on server via clientOnlyFunction on client"@role);  // role should log as a 4
}

defaultproperties
{
    bUpdate = false;
    bAlwaysRelevant = true
}
