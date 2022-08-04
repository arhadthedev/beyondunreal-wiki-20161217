/**
 * effect that links the orb to a node it's protecting. In C++ we do extra work to make sure the beam start point stays inside the orb mesh 
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 **/
class UTEmit_OrbLinkEffect extends UTEmitter
	native(Onslaught);



defaultproperties
{
	Begin Object Name=ParticleSystemComponent0
		bUpdateComponentInTick=true
		Translation=(Y=5.0,Z=5.0)
		AbsoluteRotation=true
	End Object

	LifeSpan=0.0
}
