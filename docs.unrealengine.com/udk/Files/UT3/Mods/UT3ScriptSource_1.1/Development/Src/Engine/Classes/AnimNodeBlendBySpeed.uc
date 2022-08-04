/**
 * AnimNodeBlendBySpeed
 *
 * Blends between child nodes based on the owners speed and the defined constraints.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class AnimNodeBlendBySpeed extends AnimNodeBlendList
		native(Anim);

/** How fast they are moving this frame.							*/
var float			Speed;
/** Last Channel being used											*/
var int				LastChannel;		
/** How fast to blend when going up									*/
var() float			BlendUpTime;		
/** How fast to blend when going down								*/
var() float			BlendDownTime;
/** When should we start blending back down							*/
var() float			BlendDownPerc;
/** Weights/ constraints used for transition between child nodes	*/
var() array<float>	Constraints;
/** Use acceleration instead of Velocity to determine speed */
var() bool	bUseAcceleration;



defaultproperties
{
	BlendUpTime=0.1;
    BlendDownTime=0.1;
    BlendDownPerc=0.2;
	Constraints=(0,180,350,900);
}
