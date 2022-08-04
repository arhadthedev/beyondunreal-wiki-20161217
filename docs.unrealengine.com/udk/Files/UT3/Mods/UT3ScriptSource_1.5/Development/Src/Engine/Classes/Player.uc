//=============================================================================
// Player: Corresponds to a real player (a local camera or remote net player).
// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class Player extends Object
	native
	transient
	config(Engine)
	Inherits(FExec);

// The actor this player controls.
var transient const playercontroller		Actor;

// Net variables.
var const int CurrentNetSpeed;
var globalconfig int ConfiguredInternetSpeed, ConfiguredLanSpeed;

/** Global multiplier for scene desaturation PP effect.					*/
var config float							PP_DesaturationMultiplier;
/** Global multiplier for scene highlights PP effect.					*/
var config float							PP_HighlightsMultiplier;
/** Global multiplier for scene midtones PP effect.						*/
var config float							PP_MidTonesMultiplier;
/** Global multiplier for scene shadows PP effect.						*/
var config float							PP_ShadowsMultiplier;

/**
 * Dynamically assign Controller to Player and set viewport.
 *
 * @param    PC - new player controller to assign to player
 **/
native function SwitchController( PlayerController PC );


/**
 * Returns true if the client is currently downloading files from the server
 */
native function bool IsDownloading();

/**
 * Returns information about the currently active downloads (NOTE: Clientside only)
 *
 * @param	DownloadList - Outputs the full list of files to be downloaded
 * @param	GUIDList - Outputs the raw (non-string) GUID list, which directly corresponds to 'DownloadList'
 *
 * @return	The total number of files to be downloaded
 */
native final noexport function int GetDownloadListInfo(optional out array<name> DownloadList, optional out array<GUID> GUIDList);

/**
 * Retrieves information about the currently active file download
 *
 * @param	File - Outputs the name of the file being downloaded
 * @param	Size - Outputs the size (in bytes) of the active download
 * @param	NumReceived - Outputs the number of bytes transferred thus far
 * @param	Optional - Outputs whether or not the current download is optional
 *
 * @return	Returns the download completion percentage
 */
native final noexport function float GetDownloadStatus(optional out name File, optional out int Size, optional out int NumReceived, optional out byte Optional);

/**
 * Allows script code to skip the currently active file download (NOTE: Clientside only)
 */
native function SkipDownload();


