﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class PrimitiveComponentFactory extends Object
	native
	abstract;

// Collision flags.

var(Collision) const bool	CollideActors,
							BlockActors,
							BlockZeroExtent,
							BlockNonZeroExtent,
							BlockRigidBody;

// Rendering flags.

var(Rendering) bool	HiddenGame,
					HiddenEditor,
					CastShadow;



defaultproperties
{
}
