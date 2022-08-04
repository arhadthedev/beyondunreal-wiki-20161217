// Related classes:
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// - RMusic_PlayerPawn_AudioInfo
// PlayerPawn subclass. Implements playing functions
// and level switching.
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// - RMusic_SingleGameInfo_AudioInfo
// spawns new playerclass and calls EVENT_PlayerLogin
// to play correct level music
class RMusic_AudioInfo extends Info;

var() string RMusic_File;		// Music file to play
var() class<RMusic_Player> PlayerClass;	// Player class (if you want to have own music directory)
var() bool bFade, bLoop;
var() enum EPlayType
{
    PT_Loop,				// Loops music
    PT_PlayOnce				// Plays once
} RMusic_PlayType;			// Play type
var() enum ERMusicTransition
{
    TRANS_Instanly,			// Instant transition
    TRANS_Fade				// Smooth fade
} RMusic_Transition;			// Transition type

defaultproperties
{
	bNoDelete=true
	RemoteRole=ROLE_SimulatedProxy
	bFade=true
	bLoop=true
	PlayerClass=class'RMusicPlayer.RMusic_Player'
}