/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedCoin extends UTDroppedItemPickup
	abstract;

/** Number of points this coin is worth when returned */
var int Value;

/** Effects Template */
var ParticleSystem TrailTemplate;
/** This is the effect that is played while in flight */
var ParticleSystemComponent	TrailEffects;
/** Scaling for the in-flight trail effects */
var float TrailEffectScale;

var TextureCoordinates CoinIconCoords;

var SoundCue BounceSound;

var ForceFeedbackWaveform PickUpWaveForm;

var LinearColor SkullColor;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Particle trail setup
	if (WorldInfo.NetMode != NM_DedicatedServer && TrailTemplate != None)
	{
		TrailEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(TrailTemplate);
		if (TrailEffects != None)
		{
			TrailEffects.SetAbsolute(false, false, false);
			TrailEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
			//TrailEffects.OnSystemFinished = MyOnParticleSystemFinished;
			TrailEffects.bUpdateComponentInTick = true;
			TrailEffects.SetScale(TrailEffectScale);
			AttachComponent(TrailEffects);
		}
	}
}

/** Add this coin's value to the pawn */
function GiveTo( Pawn P )
{
	local UTPawn UTP;
	local UTPlayerController PC;
	local UTPlayerReplicationInfo PRI;
	local UTHUD HUD;

	UTP = UTPawn(P);
	if (UTP != None)
	{
		PRI = UTPlayerReplicationInfo(UTP.PlayerReplicationInfo);
		if (PRI != None)
		{
			PRI.AddCoins(Value);
		}
	}
	PickedUpBy(P);

	PC = UTPlayerController(P.Controller);
	if (PC != None)
	{
		PC.CheckAutoObjective(false);

		// Inform the HUD of the pickup time, for crosshair scaling
		HUD = UTHUD(PC.myHUD);
		if (HUD != None)
		{
			HUD.LastPickupTime = HUD.WorldInfo.TimeSeconds;
		}

		PC.ClientPlayForceFeedbackWaveform(PickUpWaveForm);
	}
}

/** Disable particle effects upon landing */
simulated event Landed(vector HitNormal, Actor FloorActor)
{
	local PrimitiveComponent RealPickupMesh;

	RealPickupMesh = PickupMesh;
	PickupMesh = None; // prevent mesh adjustment
	Super.Landed(HitNormal, FloorActor);
	PickupMesh = RealPickupMesh;
	
	// clear component and return to pool
	if (TrailEffects != None)
	{
		TrailEffects.DeactivateSystem();
		DetachComponent(TrailEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(TrailEffects);
		TrailEffects = None;
	}
	SetPhysics(PHYS_None);
}

/**
* Give a little bounce
*/
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local float Speed;

	// check to make sure we didn't hit a pawn
	if ( Pawn(Wall) == none )
	{
		Velocity = 0.6*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);

		if (Velocity.Z > 400)
		{
			Velocity.Z = 0.5 * (400 + Velocity.Z);
		}

		// Only play the bounce sound if the skull is moving fast
		if (Speed > 40.0)
		{
			if ( WorldInfo.NetMode != NM_DedicatedServer )
			{
				PlaySound(BounceSound);
			}
		}
		// If the skull is moving slowly, clear the trail effect
		else 
		{
			bBounce = false;
			Landed(HitNormal, Wall);
		}
	}
}

/** Slow down skulls that enter water */
simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( WaterVolume(NewVolume) != none )
	{
		Velocity *= 0.25;
	}

	Super.PhysicsVolumeChange(NewVolume);
}

function float BotDesireability(Pawn Bot, Controller C)
{
	local UTPlayerReplicationInfo PRI;
	local float ValueMult;

	// don't chase coins that haven't landed yet
	if ( Physics != PHYS_None )
	{
		return 0;
	}

	// Desire based on coins already held and value of this one
	PRI = UTPlayerReplicationInfo(C.PlayerReplicationInfo);
	ValueMult = (PRI == None) ? 0.2 : FMax(0.2, 8.0/(7.0+PRI.GetNumCoins()));
	return FClamp(ValueMult * float(Value), 0.4, 1.5);
}


State FadeOut
{
	simulated function BeginState(Name PreviousStateName)
	{
		bFadeOut = true; 
		if ( PickupMesh != None )
		{
			StartScale = PickupMesh.Scale;
		}

		if( PickupParticles != None )
		{
			PickupParticles.DeactivateSystem();
		}

		LifeSpan = 2.0;
		YawRotationRate = 60000;
	}
}

defaultproperties
{
	TickGroup=TG_PostAsyncWork
	Physics=PHYS_Falling
	//bRotatingPickup=true

	bCollideWorld=true
	bBounce=true

	TrailEffectScale=0.3

	CoinIconCoords=(U=223,UL=36,V=49,VL=36)
}