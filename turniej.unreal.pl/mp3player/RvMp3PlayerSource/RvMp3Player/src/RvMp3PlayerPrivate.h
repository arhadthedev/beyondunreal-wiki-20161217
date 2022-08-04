/*================================================================================
	file:   CHMp3PlayerPrivate.h
	author: Raven
	description:
	This is private headers for Mp3Player.cpp. Defines basic operations.
================================================================================*/
/*--------------------------------------------------------------------------------
IMPORTANT!!
engine and core implementation
--------------------------------------------------------------------------------*/
#include "Engine.h"
#include "Core.h" 
/*--------------------------------------------------------------------------------
If you forget this You will have error like this:
   '(...) inconsistent dll linkage.  dllexport assumed.(...)'
--------------------------------------------------------------------------------*/
#define RVMP3PLAYER_API DLL_EXPORT
/*--------------------------------------------------------------------------------
IMPORTANT!!
UCC generated header implementation
This file was created to glue UnrealScript and C++ code together
--------------------------------------------------------------------------------*/
#include "RvMp3PlayerClasses.h"
/*--------------------------------------------------------------------------------
	The End.
--------------------------------------------------------------------------------*/
/*class DLL_EXPORT_CLASS ARMp3Player : public AActor
{
	DECLARE_CLASS(ARMp3Player,AActor,CLASS_Config,RvMp3Player)

	// Configuration.
	INT SoundDriver;

	// Constructor.
	void StaticConstructor();

	// UObject interface.
	void PostEditChange();
}*/