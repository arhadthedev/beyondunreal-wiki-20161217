class RMp3Player extends Actor
      native
      config(user)
      NoUserCreate;

var native string Directory;
var config int MusicVolume;
var bool bWasInitialized;
var PlayerPawn PP;
var LevelInfo CurLevel, OldLevel;
var config string RUserDirectory;
var config string PlayList[256];
var int PlaylistEntires;

native final function bool MusicSystemInit();             //Initialize music system
native final function bool PlaySong(string title);        //Plays song (use only for the first time)
native final function StopSong();                         //Stop playing new song
native final function ChangeVolume(int Volume);           //Changes volume
native final function PlayNewSong(string title);          //Plays new song
native final function ShutDown();                         //Shuts down music system
native final function ReadUserDirectory(string Dir);      //Reads user directory
native final function PlayUnLoopSong(string title);       //Plays new song
function ClearPlaylist()                                        //Clears playlist
{
      local int i;
      for(i=0; i<256; i++)
      {
           PlayList[i]="none";
      }
      PlaylistEntires=0;
}
event string AddSlashes(string sourcestring)
{
      local string tempstr,mainstr,leftstr,rightstr;
      local int MPos;

      mainstr=sourcestring;
      log("sourcestring"$sourcestring, 'TCO');
      if(mainstr != "")
      {
          MPos=InStr(mainstr, "\\");
          while(MPos != -1)
          {
              MPos=InStr(mainstr, "\\");
              leftstr=Left(mainstr,MPos);
              rightstr=Right(mainstr,MPos-2);
              tempstr=leftstr$"//"$rightstr;
          }
     }
     return tempstr;
}
event ReadPlaylist()                            //Creates playlist
{
      local int i;
      log("Playlist[0]="$Playlist[0], 'TCO');
      for(i=0; i<PlaylistEntires; i++)
      {
          log("Playlist["$i$"]="$Playlist[i], 'TCO');
      }
}
function ReadPlayerPawn(PlayerPawn PlP)                         //Reads player pawn
{
        PP=PlP;
        OldLevel = PlP.level;
}
event Tick(float Delta)                                         //Checks for new map and if new map is loaded destroys teh player
{
	if (PP == none || !bWasInitialized) return;

	CurLevel = PP.player.console.viewport.actor.level;


        if (CurLevel != OldLevel && CurLevel != Level)
        {
                if(bWasInitialized)
                {
                     PlayNewSong("");
		     bWasInitialized=false;
		     Disable('Tick');
		}
		Destroy();
	}
}

defaultproperties
{
   PlaylistEntires=0
   Directory="../music/"
   MusicVolume=128
   bHidden=True
   bStatic=false
   bStasis=false
   bNoDelete=false
}
