/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Coder: Raven
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Plays music (mp3/ogg)
 */
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!! This code will glue UnrealScript and C++ together.
 */
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!! Stuff for string conversions
 */
#include <cstdlib>
#include <string>
#include <iostream>
#include <vector>
#include <afx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <conio.h>
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!! Engine and core implementation
 */
#include "Engine.h"
#include "Core.h"
//#include "FFileManagerWindows.h"
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * If you forget this You will have error like this:
 * '(...) inconsistent dll linkage.  dllexport assumed.(...)'
 */
#define RMUSICPLAYER_API DLL_EXPORT
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!!
 * UCC generated header implementation
 * This file was created to glue UnrealScript and C++ code together
 */
#include "RMusicPlayerClasses.h"
#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) RMUSICPLAYER_API FName RMUSICPLAYER_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "RMusicPlayerClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

void RegisterNames()
{
	static INT Registered=0;
	if(!Registered++)
	{
		#define NAMES_ONLY
		#define AUTOGENERATE_NAME(name) extern RMUSICPLAYER_API FName RMUSICPLAYER_##name; RMUSICPLAYER_##name=FName(TEXT(#name),FNAME_Intrinsic);
		#define AUTOGENERATE_FUNCTION(cls,idx,name)
		#include "RMusicPlayerClasses.h"
		#undef DECLARE_NAME
		#undef NAMES_ONLY
	}
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!! fmod implementation. This files allow me to play mp3's and ogg's :)
 */
#include "fmod.hpp"
#include "fmod_errors.h"
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Implementing package
 */
IMPLEMENT_PACKAGE(RMusicPlayer);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * DEBUGGING !!
 */
#include "FOutputDeviceFile.h"
#define debugf GLog->Logf
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * FString & FName related functions
 */
#include "RMusic_StringFunctions.h"
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Configuration
 */
//#include "RMusic_Config.cpp"
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Bunch of global variabls used by RMusic_Player
 */
FMOD::System     *RMusicPlayer_system;
FMOD::Sound      *RMusicPlayer_sound;
FMOD::Channel    *RMusicPlayer_channel = 0;
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Used to initialize all FMOD functions
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	True on success
 */
void ARMusic_Player::execRMusic_Startup( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_Startup);
	P_FINISH;
	FMOD_RESULT result;
	unsigned int version;
	// creates object
	result = FMOD::System_Create(&RMusicPlayer_system);
	if(result != FMOD_OK)
	{
		if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: FMOD error :: RMusic_Startup :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
		*reinterpret_cast< UBOOL * >(Result) = false;
	}
	else if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Startup :: System created"));
	// tries to get fmodex version
	if(RMusicPlayer_system != NULL)
	{
		result = RMusicPlayer_system->getVersion(&version);
		if(result != FMOD_OK)
		{
			if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: FMOD error :: RMusic_Startup :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			*reinterpret_cast< UBOOL * >(Result) = false;
		}
		// version check
		if (version < FMOD_VERSION && bIncludeDebugInfo)
		{
			debugf(NAME_Init, TEXT("RMusic_Player :: FMOD error :: RMusic_Startup :: wrong fmodex.dll version. RMusic_Player requires version %i"), FMOD_VERSION);
		}
		//loads additional codecs
		if(bAlwaysLoadCodecs)
		{
			//sets plugin directory
			result = RMusicPlayer_system->setPluginPath(TCHAR_TO_ANSI( *AddSlashes(RMusic_PluginsDirectory) ));
			if(result != FMOD_OK)
			{
				if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: FMOD error  :: RMusic_Startup ::(%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );    	
			}
			else
			{
				HANDLE hFile; //handle for file
				WIN32_FIND_DATA FileInformation; // file informations
				TCHAR* strPattern;  // search pattern

				strPattern = ANSI_TO_TCHAR ( TCHAR_TO_ANSI( *ConnectAddSlashes(RMusic_PluginsDirectory, FString(TEXT("codec_*.dll"))) ) ); // we search for FMODEX codecs

				//simple search function
				hFile = ::FindFirstFile(strPattern, &FileInformation);
				if(hFile != INVALID_HANDLE_VALUE)
				{
					do
					{
						if(appStricmp(FileInformation.cFileName,TEXT(".")) && appStricmp(FileInformation.cFileName,TEXT("..")))
						{
							if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: Plugin Found :: %s"), FileInformation.cFileName );
							result = RMusicPlayer_system->loadPlugin(TCHAR_TO_ANSI(FileInformation.cFileName), 0, 0);
							if (result != FMOD_OK)
							{
								if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: FMOD error  :: RMusic_Startup ::(%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
								*reinterpret_cast< UBOOL * >(Result) = false;
							}    
							else
							{
								if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: Plugin %s loaded"), FileInformation.cFileName);
								*reinterpret_cast< UBOOL * >(Result) = true;
							}
						}
					}
					while(::FindNextFile(hFile, &FileInformation) == TRUE);
					::FindClose(hFile);
				}
			}
		}

		/*URMusicPlayerConfig *Configuration;

		int SelectedDriver = Configuration->GetDriverNum();

		if(SelectedDriver != (int) -1)
		{
			result = RMusicPlayer_system->setDriver(SelectedDriver);
			if(result != FMOD_OK)
			{
				if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: FMOD error  :: RMusic_Startup ::(%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
				*reinterpret_cast< UBOOL * >(Result) = false;
			}
			else if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Startup :: Driver selected"));
		}*/		

		// fmodex initialize
		result = RMusicPlayer_system->init(1, FMOD_INIT_NORMAL, 0);
		if(result != FMOD_OK)
		{
			if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: FMOD error  :: RMusic_Startup ::(%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			*reinterpret_cast< UBOOL * >(Result) = false;
		}
		else if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Startup :: System initialized"));
		// everything is initialized, so we can return true
		*reinterpret_cast< UBOOL * >(Result) = true;
	}
	else
		*reinterpret_cast< UBOOL * >(Result) = false;
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Loads plugin (codec/dsp)
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required     Plugin       Plugin name
 */
void ARMusic_Player::execRMusic_LoadPlugin( FFrame &Stack, void* Result)
{
	guard(Plugin::execRMusic_LoadPlugin);
	P_GET_STR( Plugin );
	P_FINISH;
	//FMOD_RESULT result;

	*reinterpret_cast< UBOOL * >(Result) = false;
	
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Updates FMOD
 */
void ARMusic_Player::execRMusic_Update( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::RMusic_Update);
	P_FINISH; 
	if(RMusicPlayer_system != NULL)
	{    
		RMusicPlayer_system->update();
	}
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Loads plugin (codec/dsp)
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required     bPause          Pause or not :)
 */
void ARMusic_Player::execRMusic_Pause( FFrame &Stack, void* Result)
{
	guard(Plugin::execRMusic_Pause);
	P_GET_UBOOL( bPause );
	P_FINISH;
	FMOD_RESULT result;
   
	if(RMusicPlayer_channel != NULL)
	{
		if(bPause)
			result = RMusicPlayer_channel->setPaused(true);
		else
			result = RMusicPlayer_channel->setPaused(false);

		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Pause :: FMOD error  :: RMusic_Pause :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Pause :: Music paused %g"), bPause );
			}
		}
	}
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Plays song
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input  @required     File          Source file
 * @param @input  @required     Loop          Should song be looped
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	True on success
 */
void ARMusic_Player::execRMusic_Play( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_Play);
	P_GET_STR( File );
	P_GET_UBOOL( Loop );
	P_FINISH;
	FMOD_RESULT result;
	
	if(RMusicPlayer_system != NULL)
	{
		//we have to check out if music isn't already playing
		if(RMusicPlayer_channel != NULL && RMusicPlayer_sound != NULL)
		{
			bool RMusic_isPlaying=false;	//false by default

			result = RMusicPlayer_channel->isPlaying(&RMusic_isPlaying);

			if (result != FMOD_OK && bIncludeDebugInfo)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: FMOD error  :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			//if music is playing
			if(RMusic_isPlaying)
			{
				// releases sound
				result = RMusicPlayer_sound->release();
				if(bIncludeDebugInfo)
				{
					if (result != FMOD_OK)
					{
						debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: FMOD error  :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
					}
					else
					{
						debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: Sound released"));
					}
				}
			}
		}
		//creating stream
		if( Loop )
			result = RMusicPlayer_system->createStream(TCHAR_TO_ANSI(*ConnectAddSlashes(RMusic_Directory,File)), FMOD_HARDWARE | FMOD_LOOP_NORMAL | FMOD_2D, 0, &RMusicPlayer_sound);
		else
			result = RMusicPlayer_system->createStream(TCHAR_TO_ANSI(*ConnectAddSlashes(RMusic_Directory,File)), FMOD_HARDWARE | FMOD_LOOP_OFF | FMOD_2D, 0, &RMusicPlayer_sound);
		
		if( result != FMOD_OK && bUseCurrentPaths )
		{
			if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: file not found in path '%s'. Scanning GSys paths for music."), RMusic_Directory);
			FString R,Fn;
			UBOOL bFound = 0;

			// Gets target file.
			for(int i=0; i<GSys->Paths.Num(); i++ )
			{
				if( GSys->Paths(i).InStr(TEXT("*.umx")) != -1)
				{
					R = GSys->Paths(i);
					R = FStrReplace( R, FString(TEXT("*.umx")), FString(TEXT("")) );
					R = AddSlashes(R);
					R = R+File;
					if( GFileManager->FindFiles(ANSI_TO_TCHAR(TCHAR_TO_ANSI(*R)), 1, 0 ).Num() )
					{
						bFound = 1;
						Fn = R;
						break;
					}
				}
			}
			if( bFound )
			{
				if( Loop )
					result = RMusicPlayer_system->createStream(TCHAR_TO_ANSI(*Fn), FMOD_HARDWARE | FMOD_LOOP_NORMAL | FMOD_2D, 0, &RMusicPlayer_sound);
				else
					result = RMusicPlayer_system->createStream(TCHAR_TO_ANSI(*Fn), FMOD_HARDWARE | FMOD_LOOP_OFF | FMOD_2D, 0, &RMusicPlayer_sound);
				*reinterpret_cast< UBOOL * >(Result) = true;
			}
			else
			{
				if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: Scanning GSys paths completed. File not found '%s'."), File);
				*reinterpret_cast< UBOOL * >(Result) = false;
			}
		}
		//playing stream only on success
		if(result != FMOD_OK)
		{
			debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: FMOD error :: %s"), File);
			if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: FMOD error :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			*reinterpret_cast< UBOOL * >(Result) = false;
		}
		else
		{
			if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: Stream created from file %s"), ConnectAddSlashes(RMusic_Directory,File));

			result = RMusicPlayer_system->playSound(FMOD_CHANNEL_FREE, RMusicPlayer_sound, false, &RMusicPlayer_channel);
			if(result != FMOD_OK)
			{
				if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: FMOD error  :: RMusic_Play :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
				*reinterpret_cast< UBOOL * >(Result) = false;
			}
			else
			{
				if(bIncludeDebugInfo) debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: Playing sound"));
				float Volume;

				//Volume = RMusic_Volume/100.0f;
				Volume = (float)RMusic_Volume/(float)255;

				result = RMusicPlayer_channel->setVolume(Volume);
				if(bIncludeDebugInfo)
				{
					if (result != FMOD_OK)
					{
						debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: FMOD error :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
					}
					else
					{
						debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Play :: Volume is %g"), Volume );
					}
				}
			}
		}
	}
	else
	{
		*reinterpret_cast< UBOOL * >(Result) = false;
	}

	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Check if song is playing.
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	true or false
 */
void ARMusic_Player::execRMusic_IsPlaying( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_IsPlaying);
	P_FINISH; 
	FMOD_RESULT result;
	bool RMusic_isPlaying=false;

	if(RMusicPlayer_channel != NULL)
	{
		result = RMusicPlayer_channel->isPlaying(&RMusic_isPlaying);

		if (result != FMOD_OK && bIncludeDebugInfo)
		{
			debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_IsPlaying :: FMOD error :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
		}
	
		*reinterpret_cast< UBOOL * >(Result) = RMusic_isPlaying;
	}
	else
	{
		*reinterpret_cast< UBOOL * >(Result) = false;
	}

	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Changes volume (based on RMusic_Volume value)
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	True on success
 */
void ARMusic_Player::execRMusic_SetCfgVolume( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_SetCfgVolume);
	P_FINISH;
	FMOD_RESULT result;
    
	if(RMusicPlayer_channel != NULL)
	{
		float Volume;
	
		Volume = (float)RMusic_Volume/(float)255;

		result = RMusicPlayer_channel->setVolume(Volume);
	
		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_SetCfgVolume :: FMOD error  :: RMusic_SetCfgVolume :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_SetCfgVolume :: Volume is %g"), Volume );
			}
		}
	}
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Changes volume
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input  @required     NewVolume       new volume
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	True on success
 */
void ARMusic_Player::execRMusic_SetVolume( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_SetVolume);
	P_GET_INT( NewVolume );
	P_FINISH;
	FMOD_RESULT result;

	if(RMusicPlayer_channel != NULL)
	{
		if(bIncludeDebugInfo)
		{
			float Volume2;
			RMusicPlayer_channel->getVolume(&Volume2);

			debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_SetVolume :: inserted %d"), NewVolume );
			debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_SetVolume :: Old %g"), Volume2 );
		}
		float Volume;
	
		Volume = (float)NewVolume/(float)255;

		result = RMusicPlayer_channel->setVolume(Volume);
	
		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_SetVolume :: FMOD error :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				float TrueVolume;
				RMusicPlayer_channel->getVolume(&TrueVolume);
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_SetVolume :: Volume should be %g and is %f :: (%d) %s"), Volume, TrueVolume, result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
		}
	}
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Checks current volume
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	Current volume
 */
void ARMusic_Player::execRMusic_GetVolume( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_GetVolume);
	P_FINISH;
	FMOD_RESULT result;

	if(RMusicPlayer_channel != NULL)
	{
		float Volume;
		int TrueVolume;

		result = RMusicPlayer_channel->getVolume(&Volume);

		if (result != FMOD_OK && bIncludeDebugInfo)
		{
			debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_GetVolume :: FMOD error  :: RMusic_GetVolume :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
		}

		Volume = Volume * 255;

		TrueVolume = (int) Volume;
	
		*reinterpret_cast< int * >(Result) = TrueVolume;
	}
	else
	{
		*reinterpret_cast< int * >(Result) = (int) 0;
	}

	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Increments volume
 */
void ARMusic_Player::execRMusic_IncVolume( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_IncVolume);
	P_FINISH;
	FMOD_RESULT result;

	if(RMusicPlayer_channel != NULL)
	{
		float CurrentVolume;
		RMusicPlayer_channel->getVolume(&CurrentVolume);
		CurrentVolume+=(float)0.01;

		result = RMusicPlayer_channel->setVolume(CurrentVolume);
	
		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_IncVolume :: FMOD error :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				float TrueVolume;
				RMusicPlayer_channel->getVolume(&TrueVolume);
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_IncVolume :: Volume should be %g and is %f :: (%d) %s"), CurrentVolume, TrueVolume, result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
		}
	}
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Decrements volume
 */
void ARMusic_Player::execRMusic_DecVolume( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_DecVolume);
	P_FINISH;
	FMOD_RESULT result;

	if(RMusicPlayer_channel != NULL)
	{
		float CurrentVolume;
		RMusicPlayer_channel->getVolume(&CurrentVolume);
		CurrentVolume-=(float)0.01;

		result = RMusicPlayer_channel->setVolume(CurrentVolume);
	
		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_DecVolume :: FMOD error :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				float TrueVolume;
				RMusicPlayer_channel->getVolume(&TrueVolume);
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_DecVolume :: Volume should be %g and is %f :: (%d) %s"), CurrentVolume, TrueVolume, result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
		}
	}
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Stops currently played song
 */
void ARMusic_Player::execRMusic_Stop( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_Stop);
	P_FINISH;
	FMOD_RESULT result;

	if(RMusicPlayer_sound != NULL)
	{
		// releases sound
		result = RMusicPlayer_sound->release();
		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Stop :: FMOD error  :: RMusic_Stop :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Stop :: Sound released"));
			}
		}
	}

	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Shuts down FMOD functions
 */
void ARMusic_Player::execRMusic_Close( FFrame &Stack, void* Result)
{
	guard(ARMusic_Player::execRMusic_Close);
	P_FINISH;
	FMOD_RESULT result;

	// releases sound
	if(RMusicPlayer_sound != NULL)
	{
		result = RMusicPlayer_sound->release();
		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Stop :: FMOD error  :: RMusic_Stop :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Stop :: Sound released"));
			}
		}
	}
	// closes fmodex
	if(RMusicPlayer_sound != NULL)
	{
		result = RMusicPlayer_system->close();
		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Close :: FMOD error  :: RMusic_Close :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Close :: FMODEX closed"));
			}
		}
	}
	// releases fmodex
	if(RMusicPlayer_sound != NULL)
	{
		result = RMusicPlayer_system->release();
		if(bIncludeDebugInfo)
		{
			if (result != FMOD_OK)
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Close :: FMOD error  :: RMusic_Close :: (%d) %s"), result, ANSI_TO_TCHAR(FMOD_ErrorString(result)) );
			}
			else
			{
				debugf(NAME_Init, TEXT("RMusic_Player :: RMusic_Close :: FMODEX released"));
			}
		}
	}
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * class implementation
 */
IMPLEMENT_CLASS(ARMusic_Component);
IMPLEMENT_CLASS(ARMusic_Player);