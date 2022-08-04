RvMp3Player is simple mp3 and ogg player for UT. It's open source so feel free to modify it, but if you want to release modified version, you have to compile it with different name, so it won't conflict with main version. I've a plan to port it to Unreal 1 as well.
Installation

Copy:

    * RvMp3Player.dll
    * RvMp3Player.int
    * RvMp3Player.u
    * RvMP3PlayerGame.u

to your UnrealTournament system directory. If you don't have newest fmod.dll (3.74!!), copy it too. Otherwise mp3player won't work.
Usage

In editor open RvMp3Player.u (in Actor Browser), then add RMp3PlayerController (as many as you wish). Then configure RMp3PLayerController:

    * MusicDirectory - music directory (not used)
    * bMuteModMusic - will mute original UT music if true
    * Song - mp3 name (with extension e.g. 01.mp3)
    * Action - action (used only when triggered):
          o AC_PlayOnStart - will play music on startup
          o AC_Stop - will stop music
          o AC_Play - will play music (important, if mp3 is loaded, use AC_Switch action)
          o AC_Switch - will switch to new track
          o AC_ShutDown - will shutdown mp3player (not used)
    * PlaType - should music be...
          o PT_Loop - looped
          o PT_PlayOnce - or played once

RvMp3Player comes with new gametype, to handle save/load actions. But if you want to create your own, here's code which has to be in event PostLogin( playerpawn NewPlayer ):

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

for incstance:

event PostLogin( playerpawn NewPlayer )
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
      Super.PostLogin(NewPlayer);
}