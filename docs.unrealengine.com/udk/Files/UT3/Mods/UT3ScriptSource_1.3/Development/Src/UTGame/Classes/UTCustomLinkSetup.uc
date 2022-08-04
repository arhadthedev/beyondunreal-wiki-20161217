/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTCustomLinkSetup extends Object
	native(Onslaught)
	dependson(UTOnslaughtMapInfo)
	config(Map) // actually replaced with the current map name
	perobjectconfig;


var LinkSetup TheLinkSetup;

/** the actual text saved to .ini file */
var config string SavedText;

/** attempts to find and load the specified setup name in the current map's .ini file
 * @return the setup if one could be loaded
 */
native final static function UTCustomLinkSetup LoadLinkSetup(name SetupName);

/** saves the link setup to a section of this object's name in the current map's .ini */
native final function SaveLinkSetup();
