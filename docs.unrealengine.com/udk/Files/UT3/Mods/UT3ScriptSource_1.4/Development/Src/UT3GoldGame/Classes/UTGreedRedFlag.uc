/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedRedFlag extends UTGreedFlag;

defaultproperties
{
	MessageClass=class'UTGameContent.UTCTFMessage'

	Begin Object Class=ParticleSystemComponent Name=ScoreEffect
		Translation=(X=0.0,Y=0.0,Z=0.0)
		Template=ParticleSystem'Pickups.Flag.Effects.P_Flagbase_FlagCaptured_Red'
		bAcceptsLights=false
		bAutoActivate=false
	End Object
	Components.Add(ScoreEffect)
	SuccessfulCaptureSystem=ScoreEffect
}
