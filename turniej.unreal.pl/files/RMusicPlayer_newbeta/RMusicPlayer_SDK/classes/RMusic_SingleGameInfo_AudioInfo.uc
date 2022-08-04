// Related classes:
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// - RMusic_PlayerPawn_AudioInfo
// PlayerPawn subclass. Implements playing functions
// and level switching.
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// - RMusic_AudioInfo
// Gives information about Level music and related stuff
class RMusic_SingleGameInfo_AudioInfo extends SinglePlayer2;

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Makes sure we use new PlayerPawn class
 */
event PlayerPawn Login(string Portal, string Options, out string Error, Class<PlayerPawn> SpawnClass)
{
	local PlayerPawn NewPlayer;
	NewPlayer=Super.Login(Portal,Options,Error,DefaultPlayerClass);
	return NewPlayer;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Starts music on Player
 */
event PostLogin( playerpawn NewPlayer )
{
	if(RMusic_PlayerPawn_AudioInfo(NewPlayer) != none) RMusic_PlayerPawn_AudioInfo(NewPlayer).EVENT_PlayerLogin();
}

defaultproperties
{
	DefaultPlayerClass=class'RMusicPlayer_SDK.RMusic_PlayerPawn_AudioInfo'
}