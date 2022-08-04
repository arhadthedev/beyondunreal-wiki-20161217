class RMusic_SingleGameInfo2 extends SinglePlayer2;

simulated function RMusic_Player Find_RMusicPlayerNoSpawn(PlayerPawn PP)
{
	local RMusic_Player RMP;

	if(Level.NetMode != NM_DedicatedServer)
        {

		if(PP.GetEntryLevel() == none)
		{
			PP.Log("No Entry level",'RMusicPlayer');
			return none;
		}

		foreach PP.GetEntryLevel().AllActors(class'RMusic_Player', RMP) break;
		return RMP;
	}
	else
	{
		return None;
	}
}

event PostLogin( playerpawn NewPlayer )
{
        local RMusic_Controller RMusic_Controller;
        local RMusic_Save RMusic_Save;
        local RMusic_Player RMusic_Player;
 
        Super.PostLogin(NewPlayer);
 
        if(Level.NetMode != NM_DedicatedServer)
        {
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
			//we found RMusic_Save, so RMusic_Controller is used, but wasn't activated. We have to stop the music if playing
//			RMusic_Player = Find_RMusicPlayerNoSpawn(NewPlayer);
			RMusic_Player = class'RMusic_Component'.static.Find_RMusicPlayerByPPawn(NewPlayer,none,true);
			if( RMusic_Player != none)
			{
				if( RMusic_Player.RMusic_IsPlaying() ) RMusic_Player.RMusic_Stop();
			}
		}
        }
}
