/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTRemoteRedeemer extends Vehicle
	native
	notplaceable
	abstract;

var ParticleSystemComponent Trail;
var float YawAccel, PitchAccel;

var repnotify bool bDying;

/** we use this class's defaults for many properties (damage, effects, etc) to reduce code duplication */
var class<UTProj_RedeemerBase> RedeemerProjClass;

/** Controller that should get credit for explosion kills (since Controller variable won't be hooked up during the explosion) */
var Controller InstigatorController;

var AudioComponent PawnAmbientSound;

/** used to avoid colliding with Driver when initially firing */
var bool bCanHitDriver;

/** camera overlay effect */
var PostProcessChain CameraEffect;
var array<MaterialInterface> TeamCameraMaterials;

var ForcedDirVolume ForcedDirectionVolume;

replication
{
	if (Role == ROLE_Authority)
		bDying;
}



// ignored functions
function PhysicsVolumeChange(PhysicsVolume Volume);
singular event BaseChange();
function ShouldCrouch(bool Crouch);
event SetWalking(bool bNewIsWalking);
function bool CheatWalk();
function bool CheatGhost();
function bool CheatFly();
function bool DoJump(bool bUpdating);
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc);
simulated function ClientRestart();

simulated event PreBeginPlay()
{
	// skip Vehicle::PreBeginPlay() so we don't get destroyed in gametypes that don't allow vehicles
	Super(Pawn).PreBeginPlay();
}

simulated function PostBeginPlay()
{
	local vector Dir;

	Dir = vector(Rotation);
	Velocity = AirSpeed * Dir;
	Acceleration = Velocity;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		Trail.SetTemplate(RedeemerProjClass.default.ProjFlightTemplate);
		PawnAmbientSound.SoundCue = RedeemerProjClass.default.AmbientSound;
		PawnAmbientSound.Play();
	}
}

function bool DriverEnter(Pawn P)
{
	if ( !Super.DriverEnter(P) )
	{
		BlowUp();
		return false;
	}

	if ( UTPawn(P) != None )
	{
		UTPawn(P).SetMeshVisibility(true);
	}
	InstigatorController = Controller;
	SetCollision(true);
	bCanHitDriver = true;
	if (Driver != None)
	{
		Driver.Acceleration = vect(0,0,0);
	}

	SetOnlyControllableByTilt( TRUE );
	return true;
}

function DriverLeft()
{
	SetOnlyControllableByTilt(false);

	Super.DriverLeft();
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);

	SetOnlyControllableByTilt( TRUE );

	ClientSetCameraEffect(C, true);
}


/** Used to turn on or off the functionality of the controller only accepting input from the tilt aspect (if it has it) **/
reliable client function SetOnlyControllableByTilt( bool bActive )
{
	local PlayerController PC;

	PC = PlayerController(Controller);

	if( PC == none )
	{
		PC = PlayerController(Driver.Controller);
	}

	if( PC != None )
	{
		PC.SetOnlyUseControllerTiltInput( bActive );
		PC.SetControllerTiltActive( bActive );
	}
}


simulated function TurnOff()
{
	ClientSetCameraEffect(Controller, false);
	Super.TurnOff();
}

/** turns on or off the camera effect */
reliable client function ClientSetCameraEffect(Controller C, bool bEnabled)
{
	local UTPlayerController PC;
	local LocalPlayer LP;
	local MaterialEffect NewEffect;
	local byte Team;
	local int i;

	PC = UTPlayerController(C);
	if (PC != None)
	{
		LP = LocalPlayer(PC.Player);
		if (LP != None)
		{
			if (bEnabled)
			{
				LP.InsertPostProcessingChain(CameraEffect, INDEX_NONE, true);
				NewEffect = MaterialEffect(LP.PlayerPostProcess.FindPostProcessEffect('RedeemerEffect'));
				if (NewEffect != None)
				{
					Team = C.GetTeamNum();
					NewEffect.Material = (Team < TeamCameraMaterials.length) ? TeamCameraMaterials[Team] : TeamCameraMaterials[0];
				}
			}
			else
			{
				for (i = 0; i < LP.PlayerPostProcessChains.length; i++)
				{
					if (LP.PlayerPostProcessChains[i].FindPostProcessEffect('RedeemerEffect') != None)
					{
						LP.RemovePostProcessingChain(i);
						i--;
					}
				}
			}
		}
	}
}

event bool EncroachingOn(Actor Other)
{
	return Other.bWorldGeometry;
}

event EncroachedBy(Actor Other)
{
	BlowUp();
}

simulated function Destroyed()
{
	// make sure camera effect got killed
	if (Controller != None && Controller.IsLocalPlayerController())
	{
		ClientSetCameraEffect(Controller, false);
		SetOnlyControllableByTilt( FALSE );
	}

	if (Driver != None)
	{
		DriverLeave(true);
	}

	Super.Destroyed();
}

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'bDying')
	{
		GotoState('Dying');
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function rotator GetViewRotation()
{
	return Rotation;
}

/**
 *	Calculate camera view point, when viewing this pawn.
 *
 * @param	fDeltaTime	delta time seconds since last update
 * @param	out_CamLoc	Camera Location
 * @param	out_CamRot	Camera Rotation
 * @param	out_FOV		Field of View
 *
 * @return	true if Pawn should provide the camera point of view.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	GetActorEyesViewPoint(out_CamLoc, out_CamRot);
	return true;
}

simulated native function bool IsPlayerPawn() const;

event Landed(vector HitNormal, Actor FloorActor)
{
	BlowUp();
}

event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	BlowUp();
}

function UnPossessed()
{
	ClientSetCameraEffect(Controller, false);
}

singular event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	if (Other.bProjTarget && !Other.IsA('Volume') && (bCanHitDriver || Other != Driver) && (Projectile(Other) == None) )
	{
		BlowUp();
	}
}

singular event Bump(Actor Other, PrimitiveComponent OtherComp, vector HitNormal)
{
	BlowUp();
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (Damage > 0 && (InstigatedBy == None || Controller == None || !WorldInfo.GRI.OnSameTeam(InstigatedBy, Controller)))
	{
		if ( InstigatedBy == None || DamageType == class'DmgType_Crushed'
			|| (class<UTDamageType>(DamageType) != None && class<UTDamageType>(DamageType).default.bVehicleHit) )
		{
			BlowUp();
		}
		else
		{
			Spawn(RedeemerProjClass.default.ExplosionClass);
			if ( PlayerController(Controller) != None )
				PlayerController(Controller).ReceiveLocalizedMessage(class'UTLastSecondMessage', 1, Controller.PlayerReplicationInfo, None, None);
			if ( (InstigatedBy != Controller) && (PlayerController(InstigatedBy) != None) )
			{
				PlayerController(InstigatedBy).ReceiveLocalizedMessage(class'UTLastSecondMessage', 1, Controller.PlayerReplicationInfo, None, None);
			}
			if ( UTPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo) != None )
			{
				UTPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).IncrementEventStat('EVENT_DENIEDREDEEMER');
			}
			DriverLeave(true);
			SetCollision(false, false);
			HurtRadius( RedeemerProjClass.default.Damage, RedeemerProjClass.default.DamageRadius * 0.125,
					RedeemerProjClass.default.MyDamageType, RedeemerProjClass.default.MomentumTransfer, Location,, InstigatorController);
			Destroy();
		}
	}
}

/** PoweredUp()
returns true if pawn has game play advantages, as defined by specific game implementation
*/
function bool PoweredUp()
{
	return true;
}

simulated function StartFire(byte FireModeNum)
{
	ServerBlowUp();
}

reliable server function ServerBlowUp()
{
	BlowUp();
}

function BlowUp()
{
	if (Role == ROLE_Authority)
	{
		GotoState('Dying');
	}
}

simulated function DrawHUD(HUD H)
{
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	BlowUp();
	return true;
}

function Suicide()
{
	BlowUp();
	Super.Suicide();
}

function DriverDied()
{
	local Pawn OldDriver;

	OldDriver = Driver;
	Super.DriverDied();
	// don't consider the pawn as having died while driving a vehicle
	OldDriver.DrivenVehicle = None;

	BlowUp();
}

function bool PlaceExitingDriver(optional Pawn ExitingDriver)
{
	// leave the pawn where it is
	return true;
}

auto state Flying
{
	simulated function FaceRotation(rotator NewRotation, float DeltaTime)
	{
		local vector X,Y,Z;
		local float PitchThreshold, YMag, SmoothRoll;
		local int Pitch, CurrentRoll;
		local PlayerController PC;
		local Rotator RolledRotation;

		PC = PlayerController(Controller);
		if (PC != None && LocalPlayer(PC.Player) != None)
		{
			// process input and adjust acceleration
			YawAccel = (1 - 2 * DeltaTime) * YawAccel + DeltaTime * PC.PlayerInput.aTurn;
			PitchAccel = (1 - 2 * DeltaTime) * PitchAccel + DeltaTime * PC.PlayerInput.aLookUp;
			GetAxes(Rotation,X,Y,Z);
			PitchThreshold = 3000;
			Pitch = Rotation.Pitch & 65535;
			if (Pitch > 16384 - PitchThreshold && Pitch < 49152 + PitchThreshold)
			{
				if (Pitch > 49152 - PitchThreshold)
				{
					PitchAccel = Max(PitchAccel, 0);
				}
				else if (Pitch < 16384 + PitchThreshold)
				{
					PitchAccel = Min(PitchAccel,0);
				}
			}
			Acceleration = Velocity + 5 * (YawAccel * Y + PitchAccel * Z);
			if (Acceleration == vect(0,0,0))
			{
				Acceleration = Velocity;
			}
			if ( ForcedDirectionVolume != None )
			{
				// make sure still touching it
				ForcedDirectionVolume = None;
				ForEach TouchingActors(class'ForcedDirVolume', ForcedDirectionVolume)
				{
					break;
				}
				if ( ForcedDirectionVolume != None )
				{
					Acceleration = ForcedDirectionVolume.ArrowDirection;
				}
			}
			if ( Location.Z > WorldInfo.StallZ )
			{
				Acceleration = Normal(Acceleration);
				Acceleration.Z = -1;
			}

			Acceleration = Normal(Acceleration) * AccelRate;
			RolledRotation = rotator(Velocity);
			YMag = Acceleration Dot Y;
			if( YMag > 0 )
			{
				RolledRotation.Roll = Min( 6000, 4*YMag);
			}
			else
			{
				RolledRotation.Roll = Max( 59536, 65536 + 4*YMag );
			}

			//smoothly change rotation
			CurrentRoll = Rotation.Roll & 65535;
			if (RolledRotation.Roll > 32768)
			{
				if (CurrentRoll < 32768)
				{
					CurrentRoll += 65536;
				}
			}
			else if (CurrentRoll > 32768)
			{
				CurrentRoll -= 65536;
			}

			SmoothRoll = FMin( 1.0, 5.0 * deltaTime );
			RolledRotation.Roll = float(RolledRotation.Roll) * SmoothRoll + float(CurrentRoll) * (1.0 - SmoothRoll);
			setRotation(RolledRotation);
		}
	}

	simulated function Tick(float DeltaTime)
	{
		// if on non-owning client or on the server, just face in the same direction as velocity
		if (!IsLocallyControlled())
		{
			SetRotation(rotator(Velocity));
		}
	}
}

event bool DriverLeave( bool bForceLeave )
{
	if ( (Controller != None) && (Driver != None) )
	{
		Controller.SetRotation(Driver.Rotation);
	}
	return super.DriverLeave(bForceLeave);
}

simulated state Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, SetInitialState;

	simulated function StartFire(byte FireModeNum);
	function BlowUp();
	reliable server function ServerBlowUp();
	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser);

	simulated function TurnOff()
	{
		Global.TurnOff();
		GotoState(, 'None');
	}

	simulated function BeginState(name OldStateName)
	{
		local ParticleSystem Template;

		bDying = true;
		if (Role == ROLE_Authority)
		{
			MakeNoise(1.0);
			SetHidden(True);
			RedeemerProjClass.static.ShakeView(Location, WorldInfo);
		}
		Template = class'UTEmitter'.static.GetTemplateForDistance(RedeemerProjClass.default.DistanceExplosionTemplates, Location, WorldInfo);
		if (Template != None)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(Template, Location, Rotation);
		}
		SetPhysics(PHYS_None);
		SetCollision(false, false);
		bCollideWorld = false;
		SetZone(false);
	}

Begin:
	Instigator = self;
	if (Role == ROLE_Authority && !WorldInfo.Game.IsInState('MatchOver'))
	{
		DriverLeave(true);
	}
	PlaySound(RedeemerProjClass.default.ExplosionSound, true);
	RedeemerProjClass.static.RedeemerHurtRadius(0.125, self, InstigatorController);
	Sleep(0.5);
	RedeemerProjClass.static.RedeemerHurtRadius(0.300, self, InstigatorController);
	Sleep(0.2);
	RedeemerProjClass.static.RedeemerHurtRadius(0.475, self, InstigatorController);
	Sleep(0.2);
	if (Role == ROLE_Authority && !WorldInfo.Game.IsInState('MatchOver'))
	{
		RedeemerProjClass.static.DoKnockdown(Location, WorldInfo, InstigatorController);
	}
	RedeemerProjClass.static.RedeemerHurtRadius(0.650, self, InstigatorController);
	Sleep(0.2);
	RedeemerProjClass.static.RedeemerHurtRadius(0.825, self, InstigatorController);
	Sleep(0.2);
	RedeemerProjClass.static.RedeemerHurtRadius(1.0, self, InstigatorController);
	if (Role == ROLE_Authority && !WorldInfo.Game.IsInState('MatchOver'))
	{
		Destroy();
	}
}

defaultproperties
{
	// all default properties are located in the _Content version for easier modification and single location
}
