/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTShapedCharge_Red extends UTShapedCharge;

defaultproperties
{
	Begin Object Class=ParticleSystemComponent Name=ConstantEffect
	    Template=ParticleSystem'WP_Translocator.Particles.P_WP_Translocator_Beacon'
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
	End Object
	LandEffects=ConstantEffect
	Components.Add(ConstantEffect)
}