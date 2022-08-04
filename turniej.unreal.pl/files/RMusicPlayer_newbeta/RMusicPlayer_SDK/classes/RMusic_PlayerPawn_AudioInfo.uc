// Related classes:
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// - RMusic_AudioInfo
// Gives information about Level music and related stuff
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// - RMusic_SingleGameInfo_AudioInfo
// spawns new playerclass and calls EVENT_PlayerLogin
// to play correct level music
class RMusic_PlayerPawn_AudioInfo extends MaleTwo;

replication
{
	reliable if( Role == ROLE_Authority )
		EVENT_PlayerLogin;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * This gives us info whenever we need to stop music
 */
function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
	local RMusic_Player RMusic_Player;

	Super.ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);

	if(NewSong != Music'RMusicPlayer.null')
	{
		RMusic_Player = Find_RMusicPlayerNoSpawn();
		if(RMusic_Player != none && RMusic_Player.RMusic_IsPlaying()) RMusic_Player.RMusic_Stop();
	}
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Tries to find local RMusic_Player.
 */
simulated function RMusic_Player Find_RMusicPlayerNoSpawn()
{
	local RMusic_Player RMP;

	if(Level.NetMode != NM_DedicatedServer)
        {

		if(GetEntryLevel() == none)
		{
			Log("No Entry level",'RMusicPlayer');
			return none;
		}

		foreach GetEntryLevel().AllActors(class'RMusic_Player', RMP) break;
		return RMP;
	}
	else
	{
		return None;
	}
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Called by GameInfo on PostLogin. Plays music.
 */
simulated function EVENT_PlayerLogin()
{
        local RMusic_Controller RMusic_Controller;
        local RMusic_Save RMusic_Save;
        local RMusic_Player RMusic_Player;
        local class<RMusic_Player> PlayerClass;
        local bool bFade, bLoop;
        local RMusic_AudioInfo RMusic_AudioInfo;
        local string File;

	if(Level.NetMode != NM_DedicatedServer)
        {
		if(GetEntryLevel() != none)
                {
                        foreach AllActors(class'RMusic_AudioInfo', RMusic_AudioInfo)
                        {
				break;
			}
			if(RMusic_AudioInfo != none)
			{
				PlayerClass = RMusic_AudioInfo.PlayerClass;
				bFade = RMusic_AudioInfo.bLoop;
				bLoop = RMusic_AudioInfo.bLoop;
				File = RMusic_AudioInfo.RMusic_File;
			}
			ClientSetMusic(Music'RMusicPlayer.null', 0, 0, MTRAN_FastFade);
			RMusic_Player = class'RMusic_Component'.static.Find_RMusicPlayerByPPawn(self, PlayerClass);
			//we have to find music player in Entry level
                        if(Rmusic_Player != none)
                        {
                                //then we stops currently played song
                                if(RMusic_Player.RMusic_IsPlaying()) RMusic_Player.RMusic_Stop();
                                //and eventually add info about player/current level
                                if( RMusic_Player.bAuthoritative )
                                {
                                        RMusic_Player.RMusic_LocalPlayer = self;
                                        RMusic_Player.RMusic_OldLevel = Level;
                                }
                        }
                }
                //we have to found save part
                foreach AllActors(class'RMusic_Save', RMusic_Save)
                {
                        //we have to check if we have saved controller
                        if(RMusic_Save.SavedController != none)
                        {
                                RMusic_Controller=RMusic_Save.SavedController;
                                break;
                        }
                }
                //if saved controller is found, we have to restore music
                if(RMusic_Controller != none) RMusic_Controller.EVENT_Player();
                else
                {
			if(File != "")
			{
				if(!bFade)
					RMusic_Player.RMusic_Play(File,bLoop);
				else
					RMusic_Player.RMusic_PlayStream(File,bLoop);
			}
		}
        }
}