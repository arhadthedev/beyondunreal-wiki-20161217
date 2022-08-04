/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTLinkGenerator extends UTDeployedActor
	native
	abstract;

/** Array of current health of each shield piece */
var int RemainingCharge;

var SkeletalMeshComponent ShieldBase;

/** sounds to play */
var SoundCue SpawnSound, DestroySound;

/** team based colors for altfire beam when targeting a teammate */
var color LinkBeamColor;

/** team based systems for altfire beam when targetting a teammate*/
var ParticleSystem LinkBeamSystem;

var ParticleSystem WallHitTemplate;
var UTEmitter HitWallEffect[5];

/** templates for beam impact effect */
var ParticleSystem BeamEndpointTemplate;

/** emitter playing the endpoint effect */
var UTEmitter BeamEndpointEffect[5];

/** Holds the actor that this weapon is linked to. */
var UTVehicle LinkedTo[5];

/** The Particle System Template for the Beam */
var particleSystem BeamTemplate;

/** Beam emitters */
var ParticleSystemComponent BeamEmitter[5];

/** Discharge effect */
var ParticleSystemComponent DischargeEffect;

/** The name of the EndPoint parameter */
var name EndPointParamName;

var vector LinkLocation[5];

var vector LinkDirection[5];

var float LinkReset[5];

var int BeamPitchAdjust[5];

/** Max range can heal vehicles */
var float MaxRange;

/** 1.1 * Square(MaxRange) */
var float MaxEffectDistSq;

/* Healing charge available */
var int AvailableCharge;

var float LastHealTime[5];

var float LastChargeLostTime;

/** interval between giving health to vehicles */
var float HealInterval;

/** Amount to heal vehicles at each interval */
var float HealAmountPerInterval;

/** Damagetype when damaging enemy vehicles */
var class<UTDamageType> MyDamageType;




replication
{
	if ( bNetDirty )
		LinkedTo;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( !bDeleteMe && (Role == ROLE_Authority) )
	{
		PlaySound(SpawnSound);
	}
	SetTimer(2.0, false, 'AddBeamEmitters');
}

simulated event Destroyed()
{
	local int i;

	Super.Destroyed();

	if (Role == ROLE_Authority)
	{
		PlaySound(DestroySound);
	}

	for ( i=0; i<5; i++ )
	{
		Unlink(i);
		KillEndpointEffect(i);
	}
}

event Landed(vector HitNormal, Actor HitActor)
{
	if ( Vehicle(HitActor) == None )
	{
		PerformDeploy();
	}
}

simulated function PerformDeploy()
{
	local Rotator NewRot;

	NewRot = Rotation;
	NewRot.Yaw = -16384;
	SetRotation(NewRot);
	bDeployed = true;
	ShieldBase.PlayAnim('Deploy');
	//bCollideWorld = FALSE;

	bForceNetUpdate = true;
	bNetDirty = true;
}

simulated function AddBeamEmitters()
{
	local int i;

	for ( i=0; i<5; i++ )
	{
		BeamEmitter[i] = new(self) class'UTParticleSystemComponent';
		BeamEmitter[i].SetTemplate(BeamTemplate);
		BeamEmitter[i].SetHidden(false);
		BeamEmitter[i].SetTickGroup(TG_PostAsyncWork);
		BeamEmitter[i].bUpdateComponentInTick = true;
		ShieldBase.AttachComponent(BeamEmitter[i], 'Top');

		if (BeamEmitter[i].Template != LinkBeamSystem)
		{
			BeamEmitter[i].SetTemplate(LinkBeamSystem);
		}
		BeamEmitter[i].SetColorParameter('Link_Beam_Color', LinkBeamColor);
	}
	DischargeEffect.Activatesystem();
}

simulated event UpdateLink(UTVehicle UTV, int Index)
{
	UnLink(Index);

	LinkedTo[Index] = UTV;
	UTV.IncrementLinkedToCount();
}

simulated event CreateEndpoint(int Index, vector EndPoint)
{
	BeamEndpointEffect[Index] = Spawn(class'UTEmitter', self,, EndPoint);
	BeamEndpointEffect[Index].LifeSpan = 0.0;
	BeamEndpointEffect[Index].SetFloatParameter('Touch', 1);
	if ( BeamEndpointEffect[Index].ParticleSystemComponent.Template != BeamEndpointTemplate )
	{
		BeamEndpointEffect[Index].SetTemplate(BeamEndpointTemplate, true);
	}
}
	
/**
 * Unlink this weapon from its parent.  If bDelayed is true, it will give a
 * short delay before unlinking to allow the player to re-establish the link
 */
simulated event UnLink(int Index)
{
	if(LinkedTo[Index] != none)
	{
		LinkedTo[Index].DecrementLinkedToCount();
	}
	LinkedTo[Index] = None;
}


event UpdateHealing(int i)
{
	if ( WorldInfo.GRI.OnSameTeam(LinkedTo[i],self) )
	{
		if ( (LinkedTo[i].Health < LinkedTo[i].Default.Health) )
		{
			LinkedTo[i].HealDamage(HealAmountPerInterval, InstigatorController, None);
			LastHealTime[i] += HealInterval;
			AvailableCharge--;
			if ( AvailableCharge <= 0 )
			{
				Destroy();
				return;
			}
		}
	}
	else
	{
		LinkedTo[i].TakeDamage(0.5*HealAmountPerInterval, InstigatorController, LinkedTo[i].Location, vect(0,0,0), MyDamageType);
	}
}

simulated event SetImpactedActor(int Index, Actor HitActor, vector HitLocation, vector HitNormal)
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		HitWallEffect[Index] = Spawn(class'UTEmitter', self,, HitLocation);			
		HitWallEffect[Index].SetTemplate(WallHitTemplate);

		if (BeamEndpointEffect[Index] != None)
		{
			BeamEndpointEffect[Index].SetRotation(rotator(HitNormal));
		}
	}
}

/** deactivates the beam endpoint effect, if present */
simulated function KillEndpointEffect(int Index)
{
	if (BeamEndpointEffect[Index] != None)
	{
		BeamEndpointEffect[Index].ParticleSystemComponent.DeactivateSystem();
		BeamEndpointEffect[Index].LifeSpan = 2.0;
		BeamEndpointEffect[Index] = None;
	}
}

defaultproperties
{
	EndPointParamName=LinkBeamEnd

	RemainingCharge=1000

	bPushedByEncroachers=FALSE
	bHardAttach=TRUE
	bBlockActors=FALSE

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=true
		ModShadowFadeoutTime=1.0
		AmbientGlow=(R=0.3,G=0.3,B=0.3,A=1.0)
	End Object
	Components.Add(MyLightEnvironment)

    LifeSpan=300.0

	bAlwaysRelevant=true

	MaxRange=1000.0
	MaxEffectDistSq=1210000.0

	AvailableCharge=500
	HealInterval=0.2
	HealAmountPerInterval=10
}
