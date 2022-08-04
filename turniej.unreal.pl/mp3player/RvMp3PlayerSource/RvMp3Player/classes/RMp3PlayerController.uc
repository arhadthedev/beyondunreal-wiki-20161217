class RMp3PlayerController extends Actor;

#exec TEXTURE IMPORT NAME=empeP FILE="textures\Icons\mp3t.bmp" GROUP=Icons LODSET=2
#exec OBJ LOAD FILE="..\Music\NoMusic.umx" PACKAGE="RvMp3Player"

var music SilentSong;
var(Mp3Player) string MusicDirectory;
var(Mp3Player) bool bMuteModMusic;
var(Mp3Player) string Song;
var(Mp3Player) enum EAction
{
    AC_PlayOnStart,
    AC_Play,
    AC_Switch,
    AC_Stop,
    AC_ShutDown
} Action;
var(Mp3Player) enum EPlayType
{
    PT_Loop,
    PT_PlayOnce
} PlayType;
var(Mp3Transition) enum EMp3Transition
{
    TRANS_Instanly,
    TRANS_Fade
} Mp3Transition;
var string SongPlay;
var bool bIsInitialized;
var bool bPlaySongTr;

replication
{
	reliable if( Role==ROLE_Authority )
		LoadAction;
}

function ActivateSaveCon()
{
	local RSaveController JB;

        foreach AllActors(class'RSaveController',JB) break;
        if (JB == none)
		JB = Spawn(class'RSaveController');

	JB.ToPlay=self;
}

simulated function PlayerPawn GetLocalPlayer()
{
        local PlayerPawn playerp;
	if(Level.NetMode != NM_DedicatedServer)
	{
           foreach AllActors(class'PlayerPawn',playerp)
   	   {
	               if(Viewport(playerp.Player) != None) return playerp; //we found local player in visibility radius
	   }
	}
}

simulated function bool ReturnStartup()
{
        if(Action == AC_PlayOnStart && bIsInitialized) return true;
        return false;
}

simulated function RMp3Player ReturnJukebox()
{
	local RMp3Player JB;
	if(GetLocalPlayer() == none) return none;

        foreach GetLocalPlayer().GetEntryLevel().AllActors(class'RMp3Player',JB) break;
        if (JB == none)
		JB = GetLocalPlayer().GetEntryLevel().Spawn(class'RMp3Player');
        return JB;
}

simulated function bool CheckForOS()
{
         if(ConsoleCommand("get ini:Engine.Engine.ViewportManager Class") == "Class'WinDrv.WindowsClient'")
            return true;
         else
            return false;
}

simulated function PostBeginPlay()
{
        if(!CheckForOS())
            return;
        if (Level.NetMode != NM_DedicatedServer)
		SetTimer(1.0,true);
}

simulated function Timer()
{
        local PlayerPawn PlayerP;
        local RMp3Player JukeBox;
	if (Level.NetMode == NM_DedicatedServer) return;

	if (Level.LevelAction == LEVACT_None)
        {
                PlayerP=GetLocalPlayer();

		if (PlayerP == none) return;

		foreach PlayerP.GetEntryLevel().AllActors(class'RMp3Player',JukeBox)
			break;

		JukeBox=ReturnJukebox();

                Mp3PlayerInit();
		SetTimer(0, false);
	}
}

simulated function Mp3PlayerInit()
{
    local RMp3Player JukeBox;
    local Pawn P;

    JukeBox = ReturnJukebox();
    
    if(JukeBox == none) return;
    JukeBox.ReadPlayerPawn(GetLocalPlayer());
    SongPlay="../music/"$Song;

    if(!JukeBox.bWasInitialized)
    {
       if(JukeBox.MusicSystemInit())
          bIsInitialized=true;
       if(!bIsInitialized)
       {
          JukeBox.bWasInitialized=false;
          return;
       }   
       JukeBox.ChangeVolume(JukeBox.MusicVolume);
       if(bIsInitialized)
          JukeBox.bWasInitialized=true;
    }
    else if(JukeBox.bWasInitialized)
    {
       bIsInitialized=true;
    }

    if(SongPlay != "")
    {
       if(Action == AC_PlayOnStart)
       {
          if(bMuteModMusic)
          {
                P = Level.PawnList;
		While ( P != None )
		{
			if ( P.IsA('PlayerPawn') )
				PlayerPawn(P).ClientSetMusic(music'RvMp3Player.null', 0, 0, MTRAN_Fade);
			P = P.nextPawn;
		}
	  }

           if(MusicDirectory != "")
             JukeBox.Directory=MusicDirectory;
           if(PlayType == PT_PlayOnce) ReturnJukebox().PlayUnLoopSong(SongPlay);
           else ReturnJukebox().PlayNewSong(SongPlay);
           ActivateSaveCon();
       }
    }
}

simulated function SetTransition()
{
   switch Mp3Transition
   {
      case TRANS_Instanly:
//            JukeBox.bDoFade=false;
          break;
      case TRANS_Fade:
//            JukeBox.bDoFade=true;
          break;
   }
}

simulated function LoadAction()
{
   SetTransition();
   switch Action
   {
      case AC_Stop:
            ReturnJukebox().StopSong();
          break;
      case AC_PlayOnStart:
      case AC_Play:
            if(PlayType == PT_PlayOnce) ReturnJukebox().PlayUnLoopSong(SongPlay);
            else ReturnJukebox().PlayNewSong(SongPlay);
          break;
      case AC_Switch:
            if(PlayType == PT_PlayOnce) ReturnJukebox().PlayUnLoopSong(SongPlay);
            else ReturnJukebox().PlayNewSong(SongPlay);
          break;
     case AC_ShutDown: 
            ReturnJukebox().ShutDown();
          break; 
   }
}
//Sets Action
simulated function SetAction()
{
   SetTransition();
   ActivateSaveCon();
   switch Action
   {
      case AC_Stop:
            ReturnJukebox().StopSong();
          break;
      case AC_Play:
            if(PlayType == PT_PlayOnce) ReturnJukebox().PlayUnLoopSong(SongPlay);
            else ReturnJukebox().PlayNewSong(SongPlay);
          break;
      case AC_Switch:
            if(PlayType == PT_PlayOnce) ReturnJukebox().PlayUnLoopSong(SongPlay);
            else ReturnJukebox().PlayNewSong(SongPlay);
          break;
     case AC_ShutDown:
            ReturnJukebox().ShutDown();
          break;
   }
}
//Disable music 
simulated function CheckForMusic()
{
        GetLocalPlayer().ClientSetMusic(music'RvMp3Player.null', 0, 0, MTRAN_FastFade);
}

simulated function Trigger( actor Other, pawn EventInstigator )
{
      if(!bIsInitialized)
            return;

      if(MusicDirectory == "")
            ReturnJukebox().Directory=MusicDirectory;
      if(Song != "")
      {
//            PlayerInstigator=PlayerPawn(EventInstigator);
            if(bMuteModMusic)
               CheckForMusic(); 
            ReturnJukebox().ChangeVolume(ReturnJukebox().MusicVolume);
            SetAction(); 
      }
}

function Destroyed()
{
      log("Mp3PLayer: In Destroyed");
      Super.Destroyed();
}


defaultproperties
{
     MusicDirectory="../Music/"
     bMuteModMusic=True
     bHidden=True
     Texture=Texture'RvMp3Player.Icons.empeP'
     bStatic=false
     bStasis=false
     bNoDelete=false
     bAlwaysRelevant=true
     bNetTemporary=true
     bNoDelete=true
     RemoteRole=ROLE_SimulatedProxy
     bNoDelete=true
}
