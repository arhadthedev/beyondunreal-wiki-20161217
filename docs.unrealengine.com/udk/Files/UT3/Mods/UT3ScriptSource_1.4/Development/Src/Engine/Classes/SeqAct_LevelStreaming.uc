﻿/**
 * SeqAct_LevelStreaming
 *
 * Kismet action exposing loading and unloading of levels.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_LevelStreaming extends SeqAct_LevelStreamingBase
	native(Sequence);

/** LevelStreaming object that is going to be loaded/ unloaded on request	*/
var() const	 LevelStreaming			Level;

/** LevelStreaming object name */
var() const	 Name					LevelName<autocomment=true>;

;

defaultproperties
{
	ObjName="Stream Level"
	bSuppressAutoComment=false
}
