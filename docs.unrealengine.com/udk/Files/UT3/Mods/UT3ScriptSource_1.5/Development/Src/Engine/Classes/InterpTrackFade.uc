﻿class InterpTrackFade extends InterpTrackFloatBase
	native(Interpolation);

/** 
 * InterpTrackFade
 *
 * Special float property track that controls camera fading over time.
 * Should live in a Director group.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */



defaultproperties
{
	bOnePerGroup=true
	bDirGroupOnly=true
	TrackInstClass=class'Engine.InterpTrackInstFade'
	TrackTitle="Fade"
}
