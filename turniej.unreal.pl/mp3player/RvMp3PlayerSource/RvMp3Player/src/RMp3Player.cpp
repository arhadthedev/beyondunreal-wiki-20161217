/*=====================================================================================
	file:   RMp3Player.cpp
	author: Raven
	description:
	Main code of mp3 player for The Chosen One modification (my first native class:P.
	If you mess something in here leave me as an author :).
=====================================================================================
additional credits
=====================================================================================
- [Sixpack]-Shambler
- Enigma
=====================================================================================*/
/*--------------------------------------------------------------------------------
IMPORTANT!! Stuff for string conversions
--------------------------------------------------------------------------------*/
#include <cstdlib> 
#include <string> 
#include <iostream>
#include <vector>
#include <afx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*--------------------------------------------------------------------------------
IMPORTANT!! fmod implementation. This files allow me to play mp3's and ogg's :)
--------------------------------------------------------------------------------*/
#include "fmod.h"
#include "fmod_errors.h"
/*--------------------------------------------------------------------------------
IMPORTANT!! This code will glue UnrealScript and C++ together.
--------------------------------------------------------------------------------*/
#include "RvMp3PlayerPrivate.h"
#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) RVMP3PLAYER_API FName RVMP3PLAYER_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "RvMp3PlayerClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

void RegisterNames()
{
	static INT Registered=0;
	if(!Registered++)
	{
		#define NAMES_ONLY
		#define AUTOGENERATE_NAME(name) extern RVMP3PLAYER_API FName RVMP3PLAYER_##name; RVMP3PLAYER_##name=FName(TEXT(#name),FNAME_Intrinsic);
		#define AUTOGENERATE_FUNCTION(cls,idx,name)
		#include "RvMp3PlayerClasses.h"
		#undef DECLARE_NAME
		#undef NAMES_ONLY
	}
}
/*--------------------------------------------------------------------------------
Implementing package
--------------------------------------------------------------------------------*/
IMPLEMENT_PACKAGE(RvMp3Player);
/*--------------------------------------------------------------------------------
DEBUGGING !!
--------------------------------------------------------------------------------*/
#include "FOutputDeviceFile.h"
#define debugf GLog->Logf
/*--------------------------------------------------------------------------------
Part created by ENIGMA - Big THX men :)
--------------------------------------------------------------------------------*/
// new function 
// handle the case where TCHAR is char 
std::string toAnsiString(char const * const string) 
{ 
   // no conversion necessary 
   return string; 
} 

// new function 
// handle the case where TCHAR is wchar_t 
std::string toAnsiString(wchar_t const * const string) 
{ 
   // create a vector big enough to hold the converted string 
   std::vector< char > convertedCharacters(wcstombs(0, string, 0)); 
   // convert the characters 
   wcstombs(&convertedCharacters[0], string, convertedCharacters.size()); 
   // convert to a string and return 
   return std::string(convertedCharacters.begin(), convertedCharacters.end()); 
} 

std::string toAnsiString(FString * string) 
{ 
   return toAnsiString(**string); 
}
/*--------------------------------------------------------------------------------
Statioc Constructor :)
--------------------------------------------------------------------------------*/
/*
void UObject::StaticConstructor()
{
	guard(UObject::StaticConstructor);

	long i

	UEnum* SoundDrivers = new( GetClass(), TEXT("SoundDrivers") )UEnum( NULL );
        for (i=0; i < FSOUND_GetNumDrivers(); i++) 
        {
            new( SoundDrivers->Names )FName( TEXT(FSOUND_GetDriverName(i)));
        }	
	
	new(GetClass(),TEXT("SoundDriver"), RF_Public)UIntProperty(CPP_PROPERTY(SoundDriver), TEXT("RvMp3Player"), CPF_Config, SoundDrivers);

	unguard;
}
void UObject::PostEditChange()
{
	guard(UObject::PostEditChange);

	// Validate configurable variables.
	SoundDriver      = Clamp(SoundDriver,(INT)0,(INT)FSOUND_GetNumDrivers()-1);

	unguard;
}*/
/*--------------------------------------------------------------------------------
Player Code :)
--------------------------------------------------------------------------------*/
void ARMp3Player::execMusicSystemInit(FFrame &Stack, RESULT_DECL)
{ 
   guard(ARMp3Player::execMusicSystemInit);
   P_FINISH; 

    bool res; 
    if (FSOUND_GetVersion() < FMOD_VERSION) 
    { 
       res = false; 
	   debugf(NAME_Init, TEXT("Mp3Player :: fmod :: wrong fmod.dll version. Mp3Player requires version %i"), FSOUND_GetVersion()); 
    } 
    else 
    { 
       res = true; 
//	   debugf(NAME_Init, TEXT("Mp3Player :: fmod :: fmod.dll version correct.")); 
    } 

    #if defined(WIN32) || defined(_WIN64) || defined(__CYGWIN32__) || defined(__WATCOMC__) 
        FSOUND_SetOutput(FSOUND_OUTPUT_WINMM); 
//        FSOUND_SetOutput(FSOUND_OUTPUT_DSOUND); 
    #elif defined(__linux__) 
        FSOUND_SetOutput(FSOUND_OUTPUT_OSS); 
    #endif 

//    debugf(NAME_Init, TEXT("Mp3Player: init sound")); 

    if (!FSOUND_Init(44100, 32, 0)) 
    { 
      res = false; 
      FSOUND_Close();
    } 
    else 
    { 
       res = true; 
    } 

    FSOUND_SetDriver(0); 
    FSOUND_Stream_SetBufferSize(1000); 

//    debugf(NAME_Init, TEXT("Mp3Player: System check")); 

//    debugf(NAME_Init, TEXT("Mp3Player: returning value")); 

    // To understand exactly how this works, you need to know about pointers 
    // use proper C++ cast 
    // not the cause of any problems, but good practice 
    *reinterpret_cast< UBOOL * >(Result) = res; 


//    debugf(NAME_Init, TEXT("Mp3Player: unguard")); 

    unguard; 
} 

void ARMp3Player::execPlaySong(FFrame &Stack, RESULT_DECL)
{ 
    guard(ARMp3Player::execPlaySong);
    P_GET_STR_REF( title ); 
    P_FINISH;

	std::string titleString = toAnsiString(title); 

    FSOUND_STREAM *stream; 
    bool res;
	  
//    debugf(NAME_Init, TEXT("Mp3Player: CURRENT MP3 DIRECTORY IS %s"),title);

    stream = FSOUND_Stream_Open(titleString.c_str(), FSOUND_LOOP_NORMAL, 0, 0);

    FSOUND_Stream_Play(FSOUND_FREE, stream); 

	if(stream)
	{
		res=true;
	}
	else
	{
		res=false;
	}

	*reinterpret_cast< UBOOL * >(Result) = res; 
    unguard; 
} 

void ARMp3Player::execStopSong( FFrame &Stack, void* Result)
{
    guard(ARMp3Player::execStopSong);
    P_FINISH; 

    FSOUND_StopSound(FSOUND_ALL);

    unguard; 
} 

void ARMp3Player::execChangeVolume( FFrame &Stack, void* Result)
{ 
    guard(ARMp3Player::execChangeVolume);
    P_GET_INT( Volume ); 
    P_FINISH; 
    
//	debugf(NAME_Init, TEXT("Mp3Player: VOLUME=%i"), Volume);
	FSOUND_SetSFXMasterVolume(Volume);

    unguard; 
} 

void ARMp3Player::execPlayNewSong( FFrame &Stack, void* Result)
{ 
    guard(ARMp3Player::execPlayNewSong);
    P_GET_STR_REF(title); 
    P_FINISH; 

	std::string titleString = toAnsiString(title); 
    FSOUND_STREAM *stream; 

    FSOUND_StopSound(FSOUND_ALL);
 
    stream = FSOUND_Stream_Open(titleString.c_str(), FSOUND_LOOP_NORMAL, 0, 0);
    FSOUND_Stream_Play(FSOUND_FREE, stream); 

    unguard; 
} 

void ARMp3Player::execPlayUnLoopSong( FFrame &Stack, void* Result)
{ 
    guard(ARMp3Player::execPlayUnLoopSong);
    P_GET_STR_REF(title); 
    P_FINISH; 

	std::string titleString = toAnsiString(title); 
    FSOUND_STREAM *stream; 

    FSOUND_StopSound(FSOUND_ALL);
 
    stream = FSOUND_Stream_Open(titleString.c_str(), FSOUND_LOOP_OFF, 0, 0);
    FSOUND_Stream_Play(FSOUND_FREE, stream); 

    unguard; 
}

void ARMp3Player::execShutdown( FFrame &Stack, void* Result)
{
//    guard(ARMp3Player::execShutDown);
    
//	FSOUND_StopSound(FSOUND_ALL);
//	FSOUND_Close();
    
//    debugf(NAME_Init, TEXT("Mp3Player: Shutting down music sys")); 

//	unguard;
}

void ARMp3Player::execReadUserDirectory( FFrame &Stack, void* Result)
{
       guard(ARMp3Player::execReadUserDirectory);
       P_GET_STR_REF(Dir); 
       P_FINISH; 
       PlaylistEntires=0;
	   //TCHAR* TruDire;
	   //for(int k=0; k<Dir.Len(); k++)
	   //{
		   //TruDire+=(TCHAR*)Dir[k];
	   //}
       int j, max;
	   std::string titleString = toAnsiString(Dir);
	   //FString RealDir=this->eventAddSlashes(*Dir);//(TCHAR*)titleString.c_str()
	   TArray<FString> List = GFileManager->FindFiles((TCHAR*)titleString.c_str(), 1, 1 );
	   //TArray<FString> List = GFileManager->FindFiles(TEXT("I://Mp3//Kazik//*.mp3"), 1, 1 );
	   //TArray<FString> List = GFileManager->FindFiles(TCHAR_TO_ANSI(titleString.c_str()), 1, 1 );
	   //TCHAR_TO_ANSI
	   //ANSI_TO_TCHAR
	   if(List.Num() < 256) max=List.Num();
	   else max=256;
	   debugf(NAME_Init, TEXT("Mp3Player: Directory=%s)"),(TCHAR*)titleString.c_str());
	   debugf(NAME_Init, TEXT("Mp3Player: NumberOfFiles=%i"), max);

       if(List.Num() > 0)
	   {
	        for( j=0; j<max; j++ )
			{
				   PlayList[j]=(FString)List(j);
			}
	   }
	   PlaylistEntires=max;

       unguard;
}

/*
void ARMp3Player::execPauseMusic( FFrame &Stack, void* Result)
{
   guard(AMp3Player::execPauseMusic);
   P_GET_BOOL(PauseMusic);
   P_FINISH;

   FSOUND_SetPaused(FSOUND_ALL, PauseMusic);

   unguard;
}  */

//class implementation
IMPLEMENT_CLASS(ARMp3Player);
