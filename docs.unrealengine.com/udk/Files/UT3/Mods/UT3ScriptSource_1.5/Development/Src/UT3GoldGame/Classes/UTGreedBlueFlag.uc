/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTGreedBlueFlag extends UTGreedFlag;

defaultproperties
{
	MessageClass=class'UTGameContent.UTCTFMessage'

	Begin Object Class=ParticleSystemComponent Name=ScoreEffect
		Translation=(X=0.0,Y=0.0,Z=0.0)
		Template=ParticleSystem'Pickups.Flag.Effects.P_Flagbase_FlagCaptured_Blue'
		bAcceptsLights=false
		bAutoActivate=false
	End Object
	SuccessfulCaptureSystem=ScoreEffect
	Components.Add(ScoreEffect)

}
