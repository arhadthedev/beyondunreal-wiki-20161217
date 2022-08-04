/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Coder: Raven
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Holds commands to send to Winamp.
 */
#define WINAMP_START 40045
#define WINAMP_PLAY_OR_PAUSE 40046
#define WINAMP_NEXT_TRACK 40048
#define WINAMP_PREVIOUS_TRACK  40044
#define WINAMP_STOP 40047
#define WINAMP_RAISE_VOLUME 40058
#define WINAMP_LOWER_VOLUME 40059
#define WINAMP_TOGGLE_REPEAT 40022
#define WINAMP_TOGGLE_SHUFFLE 40023
#define WINAMP_FAST_FORWARD 40148
#define WINAMP_FAST_REWIND 40144

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//returns winamp window
//
HWND FindWinamp()
{
	return FindWindow(TEXT("Winamp v1.x"), NULL);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//sends commands to winamp
//
void ControlWinamp(int command)
{
	HWND winamp;
	winamp = FindWinamp();
	if(winamp != NULL) SendMessage(winamp, WM_COMMAND, command, 1);
}