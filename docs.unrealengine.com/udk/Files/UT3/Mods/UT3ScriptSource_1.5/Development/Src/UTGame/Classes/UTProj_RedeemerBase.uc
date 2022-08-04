/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_RedeemerBase extends UTProjectile
	abstract;

var CameraAnim ExplosionShake;
var class<UTReplicatedEmitter> ExplosionClass;
var array<DistanceBasedParticleTemplate> DistanceExplosionTemplates;

var StaticMeshComponent ProjMesh;
/** Used to pulse the lights */
var MaterialInstanceConstant RocketMaterialInstance;
var name TeamParamName;
var LinearColor TeamColor;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if ( !bDeleteMe && (WorldInfo.NetMode != NM_DedicatedServer) && ProjMesh != none )
	{
		RocketMaterialInstance = ProjMesh.CreateAndSetMaterialInstanceConstant(0);
		RocketMaterialInstance.SetVectorParameterValue( TeamParamName, TeamColor );
	}
}

event bool EncroachingOn(Actor Other)
{
	return Other.bWorldGeometry;
}

simulated function bool EffectIsRelevant(vector SpawnLocation, bool bForceDedicated, float CullDistance )
{
	return true;
}

simulated function ProcessTouch(Actor Other, vector HitLocation, vector HitNormal)
{
	if ( Projectile(Other) == None )
	{
		Explode(HitLocation, HitNormal);
	}
}

simulated function PhysicsVolumeChange(PhysicsVolume Volume);

simulated function Landed(vector HitNormal, Actor FloorActor)
{
	Explode(Location, HitNormal);
}

simulated function HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	Explode(Location, HitNormal);
}

event TakeDamage(int DamageAmount, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (DamageAmount > 0 && (InstigatedBy == None || InstigatorController == None || InstigatedBy == InstigatorController || !WorldInfo.GRI.OnSameTeam(InstigatedBy, InstigatorController)))
	{
		if ( InstigatedBy == None || DamageType == class'DmgType_Crushed'
			|| (class<UTDamageType>(DamageType) != None && class<UTDamageType>(DamageType).default.bVehicleHit) )
		{
			Explode(Location, vect(0,0,1));
		}
		else
		{
			Spawn(ExplosionClass);
			if ( PlayerController(InstigatorController) != None )
				PlayerController(InstigatorController).ReceiveLocalizedMessage(class'UTLastSecondMessage', 1, InstigatorController.PlayerReplicationInfo, None, None);
			if ( (InstigatedBy != InstigatorController) && (PlayerController(InstigatedBy) != None) )
			{
				PlayerController(InstigatedBy).ReceiveLocalizedMessage(class'UTLastSecondMessage', 1, InstigatorController.PlayerReplicationInfo, None, None);
			}
			if ( UTPlayerReplicationInfo(InstigatorController.PlayerReplicationInfo) != None )
			{
				UTPlayerReplicationInfo(InstigatorController.PlayerReplicationInfo).IncrementEventStat('EVENT_DENIEDREDEEMER');
			}
			bSuppressExplosionFX = true;
			SetCollision(false, false);
			HurtRadius(Damage, DamageRadius * 0.125, MyDamageType, MomentumTransfer, Location);
			Destroy();
		}
	}
}

simulated event FellOutOfWorld(class<DamageType> DmgType)
{
	Explode(Location, vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	SpawnExplosionEffects(HitLocation, HitNormal);

	// Clean up the effects here
	if (ProjEffects != None)
	{
		ProjEffects.DeactivateSystem();
	}

  	GotoState('Dying');
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	ProjExplosionTemplate = class'UTEmitter'.static.GetTemplateForDistance(DistanceExplosionTemplates, HitLocation, WorldInfo);

	Super.SpawnExplosionEffects(HitLocation, HitNormal);
}

/** shakes the view of players near Location
 *	static so that it can be shared with UTRemoteRedeemer
 */
static function ShakeView(vector Loc, WorldInfo WI)
{
	local UTPlayerController PC;
	local float Dist, Scale;

	foreach WI.AllControllers(class'UTPlayerController', PC)
	{
		if (PC.ViewTarget != None)
		{
			Dist = VSize(Loc - PC.ViewTarget.Location);
			if (Dist < default.DamageRadius * 2.0)
			{
				if (Dist < default.DamageRadius)
				{
					Scale = 1.0;
				}
				else
				{
					Scale = (default.DamageRadius * 2.0 - Dist) / default.DamageRadius;
				}
				PC.ClientPlayCameraAnim(CameraAnim'Camera_FX_02.WP_Redeemer.C_WP_Redeemer_Shake_UT3G', Scale);
			}
		}
	}
}

/** knocks down all players that would have been killed, but avoided it by being out of line of sight
 *	static so that it can be shared with UTRemoteRedeemer
 */
static function DoKnockdown(vector Loc, WorldInfo WI, Controller InstigatedByController)
{
	local Controller C;
	local vector Dir;
	local float DamageScale;
	local UTPawn P;

	foreach WI.AllControllers(class'Controller', C)
	{
		P = UTPawn(C.Pawn);
		if (P != None && P.Health > 0 && !P.bIgnoreForces && !P.InGodMode() && !WI.GRI.OnSameTeam(P, InstigatedByController))
		{
			Dir = P.Location - Loc;
			DamageScale = FClamp(1.0 - (VSize(Dir) / default.DamageRadius), 0.0, 1.0);
			if (P.Health < default.Damage * DamageScale)
			{
				P.AddVelocity(((default.MomentumTransfer * DamageScale) / P.Mass) * 0.5 * Normal(Dir), P.Location, default.MyDamageType);
				P.ForceRagdoll();
			}
		}
	}
}

/** special version of HurtRadius() for the Redeemer that works better with the giant radius by tracing to edges
 * of large objects instead of just the center
 * static so that it can be shared with UTRemoteRedeemer
 */
static function RedeemerHurtRadius(float RadiusFactor, Actor Redeemer, Controller InstigatedByController)
{
	local Actor Victim, HitActor;
	local bool bCauseDamage;
	local float HurtRadius, Radius, Height, VictimDamage;
	local vector Side, Up, ExplosionCenter, HitNormal, HitLocation;

	HurtRadius = default.DamageRadius * RadiusFactor;

	if (InstigatedByController == None && Redeemer.Instigator != None)
	{
		InstigatedByController = Redeemer.Instigator.Controller;
	}

	// move explosion center up a bit to address not hitting pawns
	ExplosionCenter = Redeemer.Location + vect(0,0,200);
	HitActor = Redeemer.Trace(HitLocation, HitNormal, ExplosionCenter, Redeemer.Location, true,,,TRACEFLAG_Blocking);
	ExplosionCenter = (HitActor == None) ? Redeemer.Location + vect(0,0,100) : 0.5 * (Redeemer.Location + HitLocation);

	foreach Redeemer.CollidingActors(class'Actor', Victim, HurtRadius, ExplosionCenter)
	{
		if (!Victim.bStatic && (Victim != Redeemer) )
		{
			Victim.GetBoundingCylinder(Radius, Height);
			Up = vect(0,0,1) * Height;
			bCauseDamage = Redeemer.FastTrace(Victim.Location + Up, ExplosionCenter);
			if (!bCauseDamage)
			{
				bCauseDamage = Redeemer.FastTrace(Victim.Location , ExplosionCenter);
				if ( !bCauseDamage )
				{
					bCauseDamage = Redeemer.FastTrace(Victim.Location , Redeemer.Location);
				}

				if ( !bCauseDamage && (Radius > 100.0) )
				{
					// try sides
					Side = (Normal(Victim.Location - ExplosionCenter) Cross vect(0,0,1)) * Radius;
					bCauseDamage = Redeemer.FastTrace(Victim.Location + Side + Up, ExplosionCenter) ||
							Redeemer.FastTrace(Victim.Location - Side + Up, ExplosionCenter);
				}
			}
			if (bCauseDamage)
			{
				VictimDamage = (UTOnslaughtPowerNode(Victim) == None) ? default.Damage : 2*default.Damage;

				Victim.TakeRadiusDamage( InstigatedByController, VictimDamage, HurtRadius, default.MyDamageType,
							default.MomentumTransfer, ExplosionCenter, false, Redeemer );
			}
		}
	}
}

simulated state Dying
{
	event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{}
	function Timer() {}

	simulated function BeginState(Name PreviousStateName)
	{
		if (Role == ROLE_Authority)
		{
			MakeNoise(1.0);
			ShakeView(Location, WorldInfo);
		}
		SetHidden(True);
		SetPhysics(PHYS_None);
		SetCollision(false, false);
		InitialState = 'Dying';
		SetTimer(0, false);
	}

Begin:
	RedeemerHurtRadius(0.125, self, InstigatorController);
	Sleep(0.5);
	RedeemerHurtRadius(0.300, self, InstigatorController);
	Sleep(0.2);
	RedeemerHurtRadius(0.475, self, InstigatorController);
	Sleep(0.2);
	RedeemerHurtRadius(0.650, self, InstigatorController);
	if (Role == ROLE_Authority)
	{
		DoKnockdown(Location, WorldInfo, InstigatorController);
	}
	Sleep(0.2);
	RedeemerHurtRadius(0.825, self, InstigatorController);
	Sleep(0.2);
	RedeemerHurtRadius(1.0, self, InstigatorController);
	Shutdown();
}


defaultproperties
{
	TeamParamName=Redeemer_Team_Color
	TeamColor=(R=0.5,G=1.0,B=14.0)

	bWaitForEffects=false
	bImportantAmbientSound=true

	speed=1000.0
	MaxSpeed=1000.0
	Damage=250.0
	DamageRadius=2600.0
	MomentumTransfer=250000
	LifeSpan=20.00

	bCollideWorld=true
	bCollideActors=true
	bProjTarget=true
	bCollideComplex=false
	bNetTemporary=false
	bSuppressExplosionFX=true

	Begin Object Name=CollisionCylinder
		CollisionRadius=20
		CollisionHeight=12
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		CollideActors=true
	End Object
	Begin Object Class=DynamicLightEnvironmentComponent Name=RedeemerLightEnvironment
 	    bDynamic=TRUE
 	    bCastShadows=FALSE
 	End Object
  	//LightEnvironment=RedeemerLightEnvironment
  	Components.Add(RedeemerLightEnvironment)
}
