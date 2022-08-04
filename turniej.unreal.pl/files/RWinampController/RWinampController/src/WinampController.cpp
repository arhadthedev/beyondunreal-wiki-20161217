/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Coder: Raven
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Winamp controling tutorial:
 * http://www.codeproject.com/KB/stl/Winamp_Controller.aspx
 */
#include <iostream>
#include <windows.h>

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IMPORTANT!! This code will glue UnrealScript and C++ together.
//
#include "WinampPrivate.h"
#include "WinampFunctions.h"
#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) RWINAMPCONTROLLER_API FName RWINAMPCONTROLLER_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "RWinampControllerClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

void RegisterNames()
{
	static INT Registered=0;
	if(!Registered++)
	{
		#define NAMES_ONLY
		#define AUTOGENERATE_NAME(name) extern RWINAMPCONTROLLER_API FName RWINAMPCONTROLLER_##name; RWINAMPCONTROLLER_##name=FName(TEXT(#name),FNAME_Intrinsic);
		#define AUTOGENERATE_FUNCTION(cls,idx,name)
		#include "RWinampControllerClasses.h"
		#undef DECLARE_NAME
		#undef NAMES_ONLY
	}
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Implementing package
//
IMPLEMENT_PACKAGE(RWinampController);
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Debugging
//
#include "FOutputDeviceFile.h"
#define debugf GLog->Logf

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// returns true if winamp is active. should be used in GUI
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// @return	@bool
//
void AWinampController::execWNP_IsActive(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_IsActive);
	P_FINISH;
	
	bool res;
	
	if(FindWinamp() != NULL) res=true;

	*reinterpret_cast< UBOOL * >(Result) = res;

	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// plays song
//
void AWinampController::execWNP_Play(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_Play);
	P_FINISH;
	ControlWinamp(WINAMP_START);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// stops song playing
//
void AWinampController::execWNP_Stop(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_Stop);
	P_FINISH;
	ControlWinamp(WINAMP_STOP);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// pauses/resumes song playing
//
void AWinampController::execWNP_PlayOrPause(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_PlayOrPause);
	P_FINISH;
	ControlWinamp(WINAMP_PLAY_OR_PAUSE);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// jumps to next track
//
void AWinampController::execWNP_NextTrack(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_NextTrack);
	P_FINISH;
	ControlWinamp(WINAMP_NEXT_TRACK);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// jumps to previous track
//
void AWinampController::execWNP_PreviousTrack(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_PreviousTrack);
	P_FINISH;
	ControlWinamp(WINAMP_PREVIOUS_TRACK);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// toggles song repeat
//
void AWinampController::execWNP_ToggleRepeat(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_ToggleRepeat);
	P_FINISH;
	ControlWinamp(WINAMP_TOGGLE_REPEAT);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// toggles song shufflet
//
void AWinampController::execWNP_ToggleShuffle(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_ToggleShuffle);
	P_FINISH;
	ControlWinamp(WINAMP_TOGGLE_SHUFFLE);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// raises volume
//
void AWinampController::execWNP_RaiseVolume(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_RaiseVolume);
	P_FINISH;
	ControlWinamp(WINAMP_RAISE_VOLUME);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// lowers volume
//
void AWinampController::execWNP_LowerVolume(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_LowerVolume);
	P_FINISH;
	ControlWinamp(WINAMP_LOWER_VOLUME);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// goes +5s in song
//
void AWinampController::execWNP_FastForward(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_FastForward);
	P_FINISH;
	ControlWinamp(WINAMP_FAST_FORWARD);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// goes -5s in song
//
void AWinampController::execWNP_FastRewind(FFrame &Stack, RESULT_DECL)
{
	guard(AWinampController::execWNP_FastRewind);
	P_FINISH;
	ControlWinamp(WINAMP_FAST_REWIND);
	unguard;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Implementing class
//
IMPLEMENT_CLASS(AWinampController);