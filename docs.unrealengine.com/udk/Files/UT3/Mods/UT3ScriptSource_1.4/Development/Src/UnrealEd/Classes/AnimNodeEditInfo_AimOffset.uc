/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */


class AnimNodeEditInfo_AimOffset extends AnimNodeEditInfo
	native;
	
	
var native const pointer	EditWindow{class WxAnimAimOffsetEditor};	
var	AnimNodeAimOffset		EditNode;



defaultproperties
{
	AnimNodeClass=class'Engine.AnimNodeAimOffset'
}