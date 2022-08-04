class RMp3SPGameInfo extends SinglePlayer2;

replication
{
      reliable if( Role==ROLE_Authority ) SetMp3Music;
}

event PostLogin( playerpawn NewPlayer )
{
      SetMp3Music(NewPlayer);
      Super.PostLogin(NewPlayer);
}

function SetMp3Music( playerpawn NewPlayer )
{
      local RMp3PlayerController Mp3PlayerController;
      local RSaveController RCon;
      local RMp3Player JB;
      local bool bMp3Initialized;

      foreach NewPlayer.GetEntryLevel().AllActors(class'RMp3Player',JB)
      {
             JB.StopSong();
             JB.ReadPlayerPawn(NewPlayer);
      }
      foreach AllActors(class'RSaveController', RCon)
      {
             if(RCon.ToPlay != none)
             {
                  Mp3PlayerController=RCon.ToPlay;
                  break;
             }
      }
      Mp3PlayerController.LoadAction();
}