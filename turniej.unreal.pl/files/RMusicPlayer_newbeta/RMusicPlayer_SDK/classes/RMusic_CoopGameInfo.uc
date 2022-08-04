class RMusic_CoopGameInfo extends coopgame2;

event PostLogin( playerpawn NewPlayer )
{
        local RMusic_Controller RMusic_Controller;
        local RMusic_Save RMusic_Save;
        local RMusic_Player RMusic_Player;
 
        Super.PostLogin(NewPlayer);
 
        if(Level.NetMode != NM_DedicatedServer)
        {
                if(NewPlayer.GetEntryLevel() != none)
                {
                        //we have to find music player in Entry level
                        foreach NewPlayer.GetEntryLevel().AllActors(class'RMusic_Player',RMusic_Player)
                        {
                                //then we stops currently played song
                                RMusic_Player.RMusic_Stop();
                                //and eventually add info about player/current level
                                if( RMusic_Player.bAuthoritative )
                                {
                                        RMusic_Player.RMusic_LocalPlayer = NewPlayer;
                                        RMusic_Player.RMusic_OldLevel = NewPlayer.Level;
                                }
                        }
                }
        }
}
