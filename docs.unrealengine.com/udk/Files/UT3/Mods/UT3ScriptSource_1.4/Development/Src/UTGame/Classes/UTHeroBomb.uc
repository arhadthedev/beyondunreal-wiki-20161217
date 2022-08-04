/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTHeroBomb extends Actor;

/** Controller for the dead hero that spawned this hero bomb */
var Controller InstigatorController;
/** Number of pulses before a hero's corpse explodes */
var int MaxCountdownPulses;
/** Number of countdown pulses since hero's death */
var int CountdownPulses;
/** Pulsing sound to play during hero death countdown */
var SoundCue CountdownPulseSound;
/** Effect for countdown pulsing */
var class<UTReplicatedEmitter> CountdownPulseEffect;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, false, 'ExplodeCountdown');
}

/** Sets the warning emitter class based on team */
simulated function SetTeamIndex(int TeamIndex)
{
	if ( TeamIndex == 0 )
	{
		CountdownPulseEffect = class'UTEmit_HeroBombWarning_Red';
	}
	else if ( TeamIndex == 1 )
	{
		CountdownPulseEffect = class'UTEmit_HeroBombWarning_Blue';
	}
}

/** Timer function to be called at each pulse during the hero explosion countdown */
simulated function ExplodeCountdown()
{
	++CountdownPulses;
	if (CountdownPulses <= MaxCountdownPulses)
	{
		PlaySound(CountdownPulseSound);
		Spawn(CountdownPulseEffect);
		SetTimer(1.0, false, 'ExplodeCountdown');
	}
	else
	{
		Explode();
	}	
}

reliable server function Explode()
{
	local UTProj_HeroRedeemer Proj;

	Proj = Spawn(class'UTProj_HeroRedeemer', InstigatorController,, Location);
	Proj.InstigatorController = InstigatorController;
	Proj.Explode(Location, vect(0,0,1));
	CountdownPulses = 0;
	Destroy();
}

defaultproperties
{
	bAlwaysRelevant=true

	CountdownPulseSound=SoundCue'A_Titan_Extras.Powerups.A_Powerup_Invulnerability_WarningCue'
	CountdownPulseEffect=class'UTEmit_HeroBombWarning'
	MaxCountdownPulses=3
}