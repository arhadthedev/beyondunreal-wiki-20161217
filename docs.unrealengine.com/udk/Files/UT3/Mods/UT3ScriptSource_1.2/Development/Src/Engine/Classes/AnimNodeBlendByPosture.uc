﻿/**
 * AnimNodeBlendByPosture.uc
 * Looks at the posture of the Pawn that owns this node and blends accordingly.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class AnimNodeBlendByPosture extends AnimNodeBlendList
		native(Anim);

/*
 * Note: this is obsolete. This class is going to be removed soon.
 */



defaultproperties
{
	Children(0)=(Name="Standing")
	Children(1)=(Name="Crouched")
}
