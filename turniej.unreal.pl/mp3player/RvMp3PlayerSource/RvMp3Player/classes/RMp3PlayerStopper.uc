class RMp3PlayerStopper extends Mutator;

var RMp3Player JukeBox; 

function AddMutator(Mutator M) 
{ 
   if ( M.IsA('RMp3PlayerStopper') ) 
   { 
       return; //only allow one mutator 
   } 
   Super.AddMutator(M);
} 


function BeginPlay() 
{ 
   foreach AllActors(class'RMp3Player', JukeBox) 
      break; 
   log("Mp3Player: mutator begins play. JukeBox="$JukeBox); 
} 

event tick(float DeltaTime) 
{ 
   local bool bFirstTick; 

   log("Mp3Player: ticking");
    log("Mp3Player: "$Level.Game.bGameEnded);
   if(Level.Game.bGameEnded || Level.Game.bOverTime)
      ShutDownMusicSys(); 

} 

function bool HandleEndGame()
{
      ShutDownMusicSys();
      return true;
}

simulated function Destroyed()
{
   ShutDownMusicSys();
}

function ShutDownMusicSys()
{
   log("Mp3Player: shutting down");
   JukeBox.ShutDown();
   JukeBox.Destroy();
}
