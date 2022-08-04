/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Leviathan extends UTVehicle_Deployable
	native(Vehicle)
	abstract;

// Define all of the variables needed for the turrets

var repnotify	vector 				LFTurretFlashLocation;
var repnotify	byte				LFTurretFlashCount;
var repnotify 	rotator 			LFTurretWeaponRotation;

var repnotify	vector 				RFTurretFlashLocation;
var repnotify	byte				RFTurretFlashCount;
var repnotify 	rotator 			RFTurretWeaponRotation;

var repnotify	vector 				LRTurretFlashLocation;
var repnotify	byte				LRTurretFlashCount;
var repnotify 	rotator 			LRTurretWeaponRotation;

var repnotify	vector 				RRTurretFlashLocation;
var repnotify	byte				RRTurretFlashCount;
var repnotify 	rotator 			RRTurretWeaponRotation;

/** These are the turret Shock Beams */

var ParticleSystem 			BeamTemplate;
var name					BeamEndpointVarName;

/** This is the primary beam emitter */

var ParticleSystem 			BigBeamTemplate;
var ParticleSystemComponent BigBeamEmitter;
var name					BigBeamEndpointVarName;
var name					BigBeamSocket;

// Shields

var UTVehicleShield Shield[4];
var class<UTVehicleShield> ShieldClass;
var repnotify byte ShieldStatus;
var byte OldVisStatus;
var	byte OldFlashStatus;

var(Collision) CylinderComponent TurretCollision[4];

var repnotify 	byte TurretStatus;
var				byte OldTurretDeathStatus, OldTurretVisStatus;

var 			int  LFTurretHealth;
var 			int  RFTurretHealth;
var 			int  LRTurretHealth;
var 			int  RRTurretHealth;

var				int	 MaxTurretHealth;

var SoundCue BigBeamFireSound;

var()			float MaxHitCheckDist;

var UTSkelControl_TurretConstrained	CachedTurrets[4];

/** Indicates big gun is firing. */
var repnotify bool bFreezeMainGunRotation;

var name MainTurretPivot, DriverTurretPivot;

var(test) int StingerTurretTurnRate;

var SoundCue TurretExplosionSound;
var SoundCue TurretActivate;
var SoundCue TurretDeactivate;

/** PRI of player in 2nd passenger turret */
var UTPlayerReplicationInfo PassengerPRITwo;

/** PRI of player in 2nd passenger turret */
var UTPlayerReplicationInfo PassengerPRIThree;

/** PRI of player in 2nd passenger turret */
var UTPlayerReplicationInfo PassengerPRIFour;

var vector ExtraPassengerTeamBeaconOffset[3];

/** particle effect played when a turret is destroyed */
var ParticleSystem TurretExplosionTemplate;

/** secondary material for team skins*/
var array<MaterialInterface> TeamMatSec;

/** template for the turrets*/
var MaterialInterface TurretMaterial[2];

/** Accumulate damage, and only notify periodically */
var int NotifyDamage;

/** Camera anim to play when player is close to leviathan. */
var CameraAnim	RumbleCameraAnim;

/** Range from leviathan to play rumble. */
var	float		RumbleRange;

replication
{
	if (bNetDirty)
		LFTurretFlashLocation, RFTurretFlashLocation,
		LRTurretFlashLocation, RRTurretFlashLocation,
		LFTurretHealth, RFTurretHealth, LRTurretHealth, RRTurretHealth,
		ShieldStatus, TurretStatus, PassengerPRITwo, PassengerPRIThree, PassengerPRIFour, bFreezeMainGunRotation;
	if (!IsSeatControllerReplicationViewer(1))
		LFTurretFlashCount, LFTurretWeaponRotation;
	if (!IsSeatControllerReplicationViewer(2))
		RFTurretFlashCount, RFTurretWeaponRotation;
	if (!IsSeatControllerReplicationViewer(3))
		LRTurretFlashCount, LRTurretWeaponRotation;
	if (!IsSeatControllerReplicationViewer(4))
		RRTurretFlashCount, RRTurretWeaponRotation;
}



simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	Shield[0] = SpawnShield( vect(320,-180,200), 'LT_Front_TurretPitch');
	Shield[1] = SpawnShield( vect(320,180,200), 'RT_Front_TurretPitch');
	Shield[2] = SpawnShield( vect(-200,-180,200), 'LT_Rear_TurretPitch');
	Shield[3] = SpawnShield( vect(-200,180,200), 'RT_Rear_TurretPitch');
	Mesh.AttachComponent(TurretCollision[0],'LT_Front_TurretYaw');
	Mesh.AttachComponent(TurretCollision[1],'RT_Front_TurretYaw');
	Mesh.AttachComponent(TurretCollision[2],'LT_Rear_TurretYaw');
	Mesh.AttachComponent(TurretCollision[3],'RT_Rear_TurretYaw');

	CachedTurrets[0] = UTSkelControl_TurretConstrained(mesh.FindSkelControl('DriverTurret_Yaw'));
	CachedTurrets[1] = UTSkelControl_TurretConstrained(mesh.FindSkelControl('Driverturret_Pitch'));
	CachedTurrets[2] = UTSkelControl_TurretConstrained(mesh.FindSkelControl('MainTurret_Yaw'));
	CachedTurrets[3] = UTSkelControl_TurretConstrained(mesh.FindSkelControl('MainTurret_Pitch'));
	CachedTurrets[2].DesiredBoneRotation.Yaw = 32767;
	// THIS MUST BE AFTER SUPER:
	DamageMaterialInstance[0] = Mesh.CreateAndSetMaterialInstanceConstant(1);
	DamageMaterialInstance[1] = Mesh.CreateAndSetMaterialInstanceConstant(2);

	// Force init of big turret
	WeaponRotationChanged(0);
	CachedTurrets[2].InitTurret(Rotation, Mesh);
	CachedTurrets[3].InitTurret(Rotation, Mesh);
}


function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	NotifyDamage += Damage;

	if ( NotifyDamage > Min(Health/8, 150) )
	{
		NotifyDamage =0;
		Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
	}
}

/**
 * FindAutoExit() Tries to find exit position on either side of vehicle, in back, or in front
 * returns true if driver successfully exited.
 *
 * @param	ExitingDriver	The Pawn that is leaving the vehicle
 */
function bool FindAutoExit(Pawn ExitingDriver)
{
	local vector OutDir;

	// if in turret, try to get out beside the turret
	if ( (ExitingDriver != None) && (ExitingDriver != Driver) )
	{
		OutDir = ExitingDriver.Location - Location;
		OutDir.Z = 0;

		if ( TryExitPos(ExitingDriver, ExitingDriver.Location + 120*Normal(OutDir) - vect(0,0,120), false) )
		{
			return true;
		}
	}
	return Super.FindAutoExit(ExitingDriver);
}

simulated function PlayerReplicationInfo GetSeatPRI(int SeatNum)
{
	if ( Role == ROLE_Authority )
	{
		if( Seats[SeatNum].SeatPawn != none )
		{
			return Seats[SeatNum].SeatPawn.PlayerReplicationInfo;
		}
		else
		{
			return none;
		}
	}
	else
	{
		Switch(SeatNum)
		{
			case 0:
				return PlayerReplicationInfo;
			case 1:
				return PassengerPRI;
			case 2:
				return PassengerPRITwo;
			case 3:
				return PassengerPRIThree;
			case 4:
				return PassengerPRIFour;
		}
	}
	return PlayerReplicationInfo;
}

simulated function UTVehicleShield SpawnShield(vector Offset, name SocketName)
{
	local UTVehicleShield NewShield;

	if (ShieldClass != None)
	{
		NewShield = Spawn(ShieldClass, self);
		StaticMeshComponent(NewShield.CollisionComponent).SetTranslation(Offset);
		NewShield.SetBase(self,, Mesh, SocketName);
		Mesh.AttachComponent(NewShield.ShieldEffectComponent, SocketName);
	}

	return NewShield;
}

/** PoweredUp()
returns true if pawn has game play advantages, as defined by specific game implementation
*/
function bool PoweredUp()
{
	return true;
}

simulated function RenderPassengerBeacons(PlayerController PC, Canvas Canvas, LinearColor TeamColor, Color TextColor, UTWeapon Weap)
{
	if ( PassengerPRI != None )
	{
		PostRenderPassengerBeacon(PC, Canvas, TeamColor, TextColor, Weap, PassengerPRI, PassengerTeamBeaconOffset);
	}
	if ( PassengerPRITwo != None )
	{
		PostRenderPassengerBeacon(PC, Canvas, TeamColor, TextColor, Weap, PassengerPRITwo, ExtraPassengerTeamBeaconOffset[0]);
	}
	if ( PassengerPRIThree != None )
	{
		PostRenderPassengerBeacon(PC, Canvas, TeamColor, TextColor, Weap, PassengerPRIThree, ExtraPassengerTeamBeaconOffset[1]);
	}
	if ( PassengerPRIFour != None )
	{
		PostRenderPassengerBeacon(PC, Canvas, TeamColor, TextColor, Weap, PassengerPRIFour, ExtraPassengerTeamBeaconOffset[2]);
	}
}


function SetSeatStoragePawn(int SeatIndex, Pawn PawnToSit)
{
	Super.SetSeatStoragePawn(SeatIndex, PawnToSit);

	if ( Role == ROLE_Authority )
	{
		if ( SeatIndex == 2 )
		{
			PassengerPRITwo = (PawnToSit == None) ? None : Seats[SeatIndex].SeatPawn.PlayerReplicationInfo;
		}
		else if ( SeatIndex == 3 )
		{
			PassengerPRIThree = (PawnToSit == None) ? None : Seats[SeatIndex].SeatPawn.PlayerReplicationInfo;
		}
		else if ( SeatIndex == 4 )
		{
			PassengerPRIFour = (PawnToSit == None) ? None : Seats[SeatIndex].SeatPawn.PlayerReplicationInfo;
		}
	}
}

simulated function WeaponRotationChanged(int SeatIndex)
{
	local rotator DriverRot, MainRot, WeapRot;

	if (SeatIndex == 0)
	{
		if (DeployedState != EDS_Deployed || !bFreezeMainGunRotation)
		{
			WeapRot = SeatWeaponRotation(SeatIndex,,true);

			if (DeployedState == EDS_Undeployed)
			{
				DriverRot = WeapRot;
				MainRot = Rotation;
			}
			else if (DeployedState == EDS_Deployed)
			{
				MainRot = WeapRot;
				DriverRot = Rotation;
			}
			else
			{
				MainRot = Rotation;
				DriverRot = Rotation;
			}

			CachedTurrets[0].DesiredBoneRotation = DriverRot;
			CachedTurrets[1].DesiredBoneRotation = DriverRot;
			CachedTurrets[2].DesiredBoneRotation = MainRot;
			CachedTurrets[3].DesiredBoneRotation = MainRot;
		}
		else if (DeployedState == EDS_Deployed)
		{
			CachedTurrets[0].DesiredBoneRotation = Rotation;
			CachedTurrets[1].DesiredBoneRotation = Rotation;
		}
	}
	else
	{
		Super.WeaponRotationchanged(SeatIndex);
	}
}


simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'ShieldStatus')
	{
		ShieldStatusChanged();
	}
	else if (VarName == 'TurretStatus')
	{
		TurretStatusChanged();
	}
	else if(VarName == 'bFreezeMainGunRotation')
	{
		WeaponRotationChanged(0);
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

function bool PassengerEnter(Pawn P, int SeatIndex)
{
	if ( !Super.PassengerEnter(P, SeatIndex) )
		return false;

	TurretStatus = TurretStatus | (1 << (SeatIndex-1));
	TurretStatusChanged();
	return true;
}

function PassengerLeave(int SeatIndex)
{
	Super.PassengerLeave(SeatIndex);

	SetShieldActive(SeatIndex, FALSE);

	TurretStatus = TurretStatus & ( 0xFF ^ (1<<(SeatIndex-1)) );
	TurretStatusChanged();
}

event bool CanDeploy(optional bool bShowMessage = true)
{
	local int i;

	// Check current speed
	if (VSize(Velocity) > MaxDeploySpeed)
	{
		if (bShowMessage)
		{
			ReceiveLocalizedMessage(class'UTSPMAMessage',0);
		}
		return false;
	}
	else if (IsFiring())
	{
		return false;
	}
	else
	{
		// Make sure all 4 wheels are on the ground if required
		if (bRequireAllWheelsOnGround)
		{
			for (i=0;i<Wheels.Length-1;i++) // -1 because the very last wheel is a 'fake' wheel.
			{
				if ( !Wheels[i].bWheelOnGround )
				{
					if (bShowMessage)
					{
						ReceiveLocalizedMessage(class'UTSPMAMessage',3);
					}
					return false;
				}
			}
		}
		return true;
	}
}

simulated function DeployedStateChanged()
{
	super.DeployedStateChanged();
	switch (DeployedState)
	{
	case EDS_Deploying:
		//BigBeam laser needs this extra update to look correct on frame 1
		mesh.bForceUpdateAttachmentsInTick=TRUE;
	    break;
	case EDS_Undeploying:
		//BigBeam laser no longer able to fire so disable extra updates
		mesh.bForceUpdateAttachmentsInTick=FALSE;
		break;
	}
}

simulated function PlayTurretAnim(int ShieldIndex, string BaseName)
{
	local string Prefix;
	local AnimNodeSequence Player;
	local int SeatIndex;

	SeatIndex = ShieldIndex + 1;

	switch	(SeatIndex)
	{
		case 1 : PreFix = "Lt_Front_"; break;
		case 2 : PreFix = "Rt_Front_"; break;
		case 3 : PreFix = "Lt_Rear_"; break;
		case 4 : PreFix = "Rt_Rear_"; break;
	}



	Player = AnimNodeSequence( Mesh.Animations.FindAnimNode( name(PreFix$"Player") ) );

	Player.SetAnim( name(Prefix$BaseName) );
	Player.PlayAnim();
}

simulated function TurretStatusChanged()
{
	local int i;
	local byte DeathStatus, VisStatus;
	local SkelControlSingleBone SkelControl;
	local vector ExpVect;

	DeathStatus = (TurretStatus & 0xF0) >> 4;
	VisStatus   = TurretStatus & 0x0F;

	for (i=0;i<4;i++)
	{
		if ( (VisStatus & (1<<i)) != (OldTurretVisStatus & (1<<i) ) )
		{
			if ( (VisStatus & (1<<i)) >0 )
			{
				PlayTurretAnim(i,"turret_deplying");
				PlaySound(TurretActivate, true);
			}
			else
			{
				PlaySound(TurretDeactivate, true);
				PlayTurretAnim(i,"turret_undeplyed");
			}
		}
	}

	for (i=0;i<4;i++)
	{
		if ( (DeathStatus & (1<<i)) != (OldTurretDeathStatus & (1<<i) ) )
		{
			if ( (DeathStatus & (1<<i)) > 0 )
			{
				switch (i)
				{
					case 0:
						SkelControl = SkelControlSingleBone(Mesh.FindSkelControl('LF_TurretScale'));
						break;
					case 1:
						SkelControl = SkelControlSingleBone(Mesh.FindSkelControl('RF_TurretScale'));
						break;
					case 2:
						SkelControl = SkelControlSingleBone(Mesh.FindSkelControl('LR_TurretScale'));
						break;
					case 3:
						SkelControl = SkelControlSingleBone(Mesh.FindSkelControl('RR_TurretScale'));
						break;
				}

				VehicleEvent(Name("Damage"$i$"Smoke") );

				VehicleEffects[i].EffectRef.SetFloatParameter('smokeamount',0.9);
				VehicleEffects[i].EffectRef.SetFloatParameter('fireamount',0.9);

				if (EffectIsRelevant(Location, false))
				{
					Mesh.GetSocketWorldLocationAndRotation(VehicleEffects[i].EffectSocket, ExpVect);
					WorldInfo.MyEmitterPool.SpawnEmitter(TurretExplosionTemplate, ExpVect);
				}

				// Spawn Smoke and explosion effect

				if (SkelControl != none && SkelControl.BoneScale > 0)
				{
					SkelControl.BoneScale = 0;
				}

				// Play the Explosion Sound

				PlaySound(TurretExplosionSound, true);

			}
		}
	}

	OldTurretDeathStatus = DeathStatus;
	OldTurretVisStatus = VisStatus;
}

simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
	local UTSkelControl_Rotate SKR;
	local vector BigBeamSocketPosition;
	local rotator BigBeamSocketRotation;


	if (SeatIndex == 3)	// Minigun Turret
	{
		SKR = UTSkelControl_Rotate(Mesh.FindSkelControl('StingerRotate'));
		if (SKR != None)
		{
			SKR.DesiredBoneRotation.Roll += StingerTurretTurnRate;
		}
	}
	if (SeatIndex == 0 && DeployedState == EDS_Deployed )
	{
		if (BigBeamEmitter == None)
		{
			BigBeamEmitter = new(Outer) class'UTParticleSystemComponent';
			BigBeamEmitter.SetAbsolute(false, true, false);
			BigBeamEmitter.bAutoActivate = FALSE;
			BigBeamEmitter.SetTemplate(BigBeamTemplate);
			Mesh.AttachComponentToSocket(BigBeamEmitter, BigBeamSocket);
		}

		Mesh.GetSocketWorldLocationAndRotation(BigBeamSocket, BigBeamSocketPosition, BigBeamSocketRotation);
		BigBeamEmitter.SetRotation(rotator(HitLocation - BigBeamSocketPosition));
		BigBeamEmitter.SetVectorParameter(BigBeamEndpointVarName, HitLocation);
		BigBeamEmitter.ActivateSystem();

		PlaySound(BigBeamFireSound);

		if(Seats[0].Gun != None)
		{
			Seats[0].Gun.ShakeView();
		}
		CauseMuzzleFlashLight(0);
	}
	else
	{
		Super.VehicleWeaponFired(bViaReplication, HitLocation, SeatIndex);
	}
}

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local ParticleSystemComponent Beam;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	// Handle Beam Effects for the shock beam
	if (!IsZero(HitLocation))
	{
		Beam = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, GetEffectLocation(SeatIndex));
		Beam.SetVectorParameter(BeamEndpointVarName, HitLocation);
	}
}

function FlashShield(int SeatIndex)
{
	SeatIndex += 4;
	ShieldStatus = ShieldStatus ^ (1 << SeatIndex);
	ShieldStatusChanged();
}

function SetShieldActive(int SeatIndex, bool bActive)
{
	local int ShieldIndex;

	ShieldIndex = SeatIndex - 1;
	if (bActive)
	{
		ShieldStatus = ShieldStatus | (1<<ShieldIndex);
	}
	else
	{
		ShieldStatus = ShieldStatus & ( 0xFF ^ (1<<ShieldIndex) );
	}
	ShieldStatusChanged();
}

simulated function ShieldStatusChanged()
{
	local byte FlashStatus;
	local byte VisStatus;
	local byte Mask;
	local int i;

	FlashStatus    = (ShieldStatus & 0xf0) >> 4;
	VisStatus      = (ShieldStatus & 0x0f);

	Mask = 0x01;
	for (i=0;i<4;i++)
	{
		if ( (FlashStatus & Mask) != (OldFlashStatus & Mask) )
		{
			TriggerShieldEffect(i);
		}

		if (Shield[i] != none && (VisStatus & Mask) != (OldVisStatus & Mask) )
		{
			Shield[i].SetActive( bool( VisStatus & Mask ) );
		}

		Mask = Mask << 1;
	}

	OldFlashStatus = FlashStatus;
	OldVisStatus = VisStatus;

}

simulated function TriggerShieldEffect(int SeatIndex)
{
	// TODO: The paladin sheild effect doesn't have a "hit shimmer" yet.
}


native function int CheckActiveTurret(vector HitLocation, float MaxDist) const;

/** kills the turret if it is dead */
function CheckTurretDead(int TurretIndex, int CurHealth, Controller InstigatedBy, class<DamageType> DamageType, vector HitLocation)
{
	if (CurHealth <= 0)
	{
		Seats[TurretIndex+1].SeatPawn.Died(InstigatedBy, DamageType, HitLocation);
		TurretStatus = TurretStatus | (1 << (TurretIndex+4));
		TurretStatus = TurretStatus & ( 0xFF ^ (1<<(TurretIndex)) );
		switch (TurretIndex)
		{
			case 0:
				PassengerPRI = None;
				break;
			case 1:
				PassengerPRITwo = None;
				break;
			case 2:
				PassengerPRIThree = None;
				break;
			case 3:
				PassengerPRIFour = None;
				break;
			default:
				break;
		}
		TurretStatusChanged();
	}
}

function int TotalTurretHealth()
{
	return LFTurretHealth + RFTurretHealth + LRTurretHealth + RRTurretHealth;
}

native function bool TurretAlive(int TurretIndex) const;

function bool SeatAvailable(int SeatIndex)
{
	if ( SeatIndex<1 || TurretAlive(SeatIndex-1) )
	{
		return Super.SeatAvailable(SeatIndex);
	}

	return false;
}

function bool ChangeSeat(Controller ControllerToMove, int RequestedSeat)
{
	if (RequestedSeat < 1 || TurretAlive(RequestedSeat - 1))
	{
		return Super.ChangeSeat(ControllerToMove, RequestedSeat);
	}
	else
	{
		if ( PlayerController(ControllerToMove) != None )
		{
			PlayerController(ControllerToMove).ClientPlaySound(VehicleLockedSound);
		}
		return false;
	}
}

function bool TurretTakeDamage(int TurretIndex, int Damage, Controller InstigatedBy, class<DamageType> DamageType, vector HitLocation)
{
	switch (TurretIndex)
	{
		case 0 :
			LFTurretHealth = Max( (LFTurretHealth - Damage), 0);
			CheckTurretDead(0, LFTurretHealth, InstigatedBy, DamageType, HitLocation);
			break;
		case 1 :
			RFTurretHealth = Max( (RFTurretHealth - Damage), 0);
			CheckTurretDead(1, RFTurretHealth, InstigatedBy, DamageType, HitLocation);
			break;
		case 2 :
			LRTurretHealth = Max( (LRTurretHealth - Damage), 0);
			CheckTurretDead(2, LRTurretHealth, InstigatedBy, DamageType, HitLocation);
			break;
		case 3 :
			RRTurretHealth = Max( (RRTurretHealth - Damage), 0);
			CheckTurretDead(3, RRTurretHealth, InstigatedBy, DamageType, HitLocation);
			break;
	}

	return ( TotalTurretHealth() <=0);
}

function TryToFindShieldHit(vector EndTrace, vector StartTrace, out TraceHitInfo HitInfo)
{
	local vector ShieldHitLocation, ShieldHitNormal;
	local int i;

	// Look for collision against an active shield;

	for (i=0;i<4;i++)
	{
		if (Shield[i] != None)
		{
			TraceComponent(ShieldHitLocation, ShieldHitNormal, Shield[i].CollisionComponent, EndTrace, StartTrace,, HitInfo);
			if (HitInfo.HitComponent != none)
			{
				return;
			}
		}
	}
}

simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int ShieldHitIndex, TurretHitIndex, i, TurretDamage;
	local UTVWeap_LeviathanTurretBase VWeap;
	local vector TurretMomentum;

	if ( Role < ROLE_Authority )
		return;

	//If I caused the damage
	if (InstigatedBy == Controller)
	{
		//but I'm not burning
		if(DamageType == None || (DamageType != None && DamageType != class'UTDmgType_VehicleExplosion'))
		{
			Damage = 0;
		}
	}

	if (HitInfo.HitComponent == None)	// Attempt to find it
	{
		TryToFindshieldHit(HitLocation, (HitLocation - 2000.f * Normal(Momentum)),  HitInfo);
	}

	// check to see if shield was hit
	ShieldHitIndex = -1;
	for ( i=0; i<4; i++ )
	{
		if ( TurretAlive(i) )
		{
			if (Shield[i] != None)
			{
				if ( HitInfo.HitComponent == Shield[i].CollisionComponent )
				{
					ShieldHitIndex = i;
					break;
				}
			}
		}
	}

	if ( ShieldHitIndex<0 )
	{
		// damage turret
		TurretHitIndex = CheckActiveTurret(HitLocation, MaxHitCheckDist);
		TurretDamage = Damage;
		TurretMomentum = Momentum;
		WorldInfo.Game.ReduceDamage(TurretDamage, self, instigatedBy, HitLocation, TurretMomentum, DamageType);
		AdjustDamage(TurretDamage, TurretMomentum, instigatedBy, HitLocation, DamageType, HitInfo);
		if (TurretHitIndex >= 0)
		{
			TurretTakeDamage(TurretHitIndex, TurretDamage, InstigatedBy, DamageType, HitLocation);
		}

		// damage main vehicle
		Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
	else if ( !WorldInfo.GRI.OnSameTeam(self, InstigatedBy) )
	{
		VWeap = UTVWeap_LeviathanTurretBase( Seats[ShieldHitIndex+1].Gun );

		if (VWeap != none)
		{
			VWeap.NotifyShieldHit(Damage);
			FlashShield( ShieldHitIndex );
		}
	}
}

simulated function PlaySpawnEffect()
{
	local PlayerController PC;

	super.PlaySpawnEffect();
	foreach WorldInfo.AllControllers(class'PlayerController', PC)
	{
		if(PC.GetTeamNum() == GetTeamNum())
		{
			PC.ReceiveLocalizedMessage( class'UTVehicleMessage', 3);
		}
	}
}
simulated function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor DamageCauser
)
{
	local int TurretIndex;
	local int Dist;
	local Float DmgPct;

	if ( Role < ROLE_Authority )
		return;

	TurretIndex = CheckActiveTurret(HurtOrigin, MaxHitCheckDist + DamageRadius);
	if ( TurretIndex >= 0 )
	{

		Dist = vSize( HurtOrigin - TurretCollision[TurretIndex].GetPosition() ) - MaxHitCheckDist;
		if ( Dist > 0 )
		{
			DmgPct = FMax(0,1 - Dist/DamageRadius);
		}
		else
		{
			DmgPct = 1.0;
		}

		TakeDamage(BaseDamage*DmgPct, InstigatedBy, HurtOrigin, Momentum * Normal( HurtOrigin - TurretCollision[TurretIndex].GetPosition() ), DamageType,, DamageCauser);
	}
	else
	{
		Super.TakeRadiusDamage(InstigatedBy, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bFullDamage, DamageCauser);
	}

}


simulated function int GetHealth(int SeatIndex)
{
	switch (SeatIndex)
	{
		case 0 : return Health; break;
		case 1 : return LFTurretHealth; break;
		case 2 : return RFTurretHealth; break;
		case 3 : return LRTurretHealth; break;
		case 4 : return RRTurretHealth; break;
	}

	return 0;
}



/*
simulated function VehicleCalcCamera(float DeltaTime, int SeatIndex, out vector out_CamLoc, out rotator out_CamRot, out vector CamStart, optional bool bPivotOnly)
{
	if (SeatIndex >= 1 && !UTPawn(Seats[SeatIndex].SeatPawn.Driver).bFixedView)
	{
		Mesh.GetSocketWorldLocationAndRotation( Seats[SeatIndex].CameraTag, out_CamLoc);
		out_CamRot = Seats[SeatIndex].SeatPawn.GetViewRotation();
		out_CamLoc +=  Vector(out_CamRot) * Seats[SeatIndex].CameraOffset;
	CamStart = out_CamLoc;
	}
	else
	{
		Super.VehicleCalcCamera(Deltatime, SeatIndex, out_CamLoc, out_CamRot, CamStart, bPivotOnly);
	}
}
*/
simulated native function vector GetTargetLocation(optional Actor RequestedBy, optional bool bRequestAlternateLoc) const;

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	local UTVehicle OtherVehicle;
	local Controller InstigatorController;
	local float Angle;
	local vector CollisionVelocity;

	if( OtherComponent == none )
	{
		return;
	}


	// if we hit a vehicle, and our velocity is in its general direction, crush it
	OtherVehicle = UTVehicle(OtherComponent.Owner);
	if (OtherVehicle != None)
	{
		CollisionVelocity = Mesh.GetRootBodyInstance().PreviousVelocity;
		Angle = Normal(CollisionVelocity) dot Normal(OtherVehicle.Location - Location);
		if (Angle > 0.0)
		{
			if (Controller != None)
			{
				InstigatorController = Controller;
			}
			else if (Instigator != None)
			{
				InstigatorController = Instigator.Controller;
			}

			OtherVehicle.TakeDamage(VSize(CollisionVelocity) * Angle, InstigatorController, RigidCollisionData.ContactInfos[0].ContactPosition, CollisionVelocity * Mass, class'UTDmgType_VehicleCollision',, self);
		}
	}

	Super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
}

state Deployed
{
	function CheckStability()
	{
		local int i, Count;
		local vector WheelLoc, XAxis, YAxis, ZAxis;

		GetAxes(Rotation, XAxis, YAxis, ZAxis);

		for (i = 0; i < Wheels.Length - 1; i++) // -1 because the very last wheel is a 'fake' wheel.
		{
			WheelLoc = Mesh.GetPosition() + (Wheels[i].WheelPosition >> Rotation);
			if (FastTrace(WheelLoc - (ZAxis * (Wheels[i].WheelRadius + Wheels[i].SuspensionTravel)), WheelLoc, vect(1,1,1)))
			{
				Count++;
			}
		}
		if(Count > 2)
		{
			SetPhysics(PHYS_RigidBody);
			GotoState('UnDeploying');
			return;
		}
	}
}

simulated function SetVehicleDeployed()
{
	Super.SetVehicleDeployed();
	CachedTurrets[2].bFixedWhenFiring = true;
	CachedTurrets[3].bFixedWhenFiring = true;
	Seats[0].CameraTag = 'BigGunCamera';
	Seats[0].GunSocket.Length = 1;
	Seats[0].GunSocket[0] = BigBeamSocket;
	Seats[0].MuzzleFlashLightClass = class'UTGame.UTLeviathanMuzzleFlashLight';
}

simulated function SetVehicleUndeployed()
{
	Super.SetVehicleUndeployed();
	CachedTurrets[2].bFixedWhenFiring = false;
	CachedTurrets[3].bFixedWhenFiring = false;
	Seats[0].CameraTag = 'DriverCamera';
	Seats[0].GunSocket.Length = 2;
	Seats[0].GunSocket[0] = 'Lt_DriverBarrel';
	Seats[0].GunSocket[1] = 'Rt_DriverBarrel';
	Seats[0].MuzzleFlashLightClass = class'UTGame.UTRocketMuzzleFlashLight';

}


simulated function TeamChanged()
{
	// NO SUPER, Leviathan materials are organized strangely.
	local MaterialInterface NewMaterial;
	local int i;

	if (Team < TeamMaterials.length && TeamMaterials[Team] != None)
	{
		NewMaterial = TeamMaterials[Team];
	}
	else if (TeamMaterials.length > 0 && TeamMaterials[0] != None)
	{
		NewMaterial = TeamMaterials[0];
	}

	if (NewMaterial != None)
	{
		if (DamageMaterialInstance[0] != None)
		{
			DamageMaterialInstance[0].SetParent(NewMaterial);
		}
		else
		{
			Mesh.SetMaterial(0, NewMaterial);
			if(DestroyedTurret != none)
			{
				DestroyedTurret.GibMeshComp.SetMaterial(1, NewMaterial);
			}
		}
	}

	if (Team < TeamMatSec.length && TeamMatSec[Team] != None)
	{
		NewMaterial = TeamMatSec[Team];
	}
	else if (TeamMatSec.length > 0 && TeamMatSec[0] != None)
	{
		NewMaterial = TeamMatSec[0];
	}

	if (NewMaterial != None)
	{
		if (DamageMaterialInstance[1] != None)
		{
			DamageMaterialInstance[1].SetParent(NewMaterial);
		}
		else
		{
			Mesh.SetMaterial(2, NewMaterial);
			if(DestroyedTurret != none)
			{
				DestroyedTurret.GibMeshComp.SetMaterial(2, NewMaterial);
			}
		}
	}

	Mesh.SetMaterial(0,TurretMaterial[Team==1?1:0]);
	for(i=3;i<6;++i)
	{
		Mesh.SetMaterial(i,TurretMaterial[Team==1?1:0]);
	}

	if(bPlayingSpawnEffect)
	{
		for(i=0;i<Mesh.Materials.Length && i<OriginalMaterials.Length;++i)
		{
			OriginalMaterials[i] = Mesh.Materials[i];
		}
	}

	UpdateDamageMaterial();
}

function bool IsArtillery()
{
	return true;
}

function bool ImportantVehicle()
{
	return true;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

event bool ContinueOnFoot()
{
	if (Super.ContinueOnFoot())
	{
		return true;
	}
	else
	{
		// if we have to stand around anyway, might as well deploy and blow stuff up
		if (UTBot(Controller) != None && !IsDeployed())
		{
			SetTimer(0.01, false, 'ServerToggleDeploy');
		}
		return false;
	}
}

function bool CanAttack(Actor Other)
{
	if (Super.CanAttack(Other))
	{
		// deploy to attack stationary targets
		if (UTBot(Controller) != None && !IsDeployed() && Other.IsStationary())
		{
			SetTimer(0.01, false, 'ServerToggleDeploy');
		}
		return true;
	}
	else
	{
		return false;
	}
}

function bool BotFire(bool bFinished)
{
	// don't let bot fire if we already decided to deploy, so it doesn't fail because of that
	return (IsTimerActive('ServerToggleDeploy') ? false : Super.BotFire(bFinished));
}

function bool TooCloseToAttack(Actor Other)
{
	// fire the nuke anyway
	return (!IsDeployed() && Super.TooCloseToAttack(Other));
}

function bool NeedToTurn(vector Targ)
{
	local int i;

	if (!Super.NeedToTurn(Targ))
	{
		return false;
	}
	// allow deployed
	else if (IsDeployed() && !IsFiring())
	{
		for (i = 0; i < ArrayCount(CachedTurrets); i++)
		{
			if (CachedTurrets[i].bIsInMotion)
			{
				return true;
			}
		}

		// make sure bot doesn't get stuck waiting to rotate when it'll never get there
		if (UTBot(Controller) != None && Controller.InLatentExecution(509)) // 509 == FinishRotation
		{
			Controller.StopLatentExecution();
		}
		return false;
	}
	else
	{
		return true;
	}
}

defaultproperties
{
	Health=6500
	StolenAnnouncementIndex=5

	COMOffset=(x=-20.0,y=0.0,z=0.0)
	UprightLiftStrength=280.0
	UprightTime=1.25
	UprightTorqueStrength=500.0
	bCanFlip=false
	GroundSpeed=600
	AirSpeed=850
	ObjectiveGetOutDist=2000.0
	MaxDesireability=2.0
	bSeparateTurretFocus=true
	bLookSteerOnNormalControls=true
	bLookSteerOnSimpleControls=true

	InnerExplosionShakeRadius=1500.0
	OuterExplosionShakeRadius=4000.0

	Begin Object Name=MyLightEnvironment
		NumVolumeVisibilitySamples=4
	End Object

	Begin Object Name=SVehicleMesh
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled1=TRUE,Untitled2=TRUE,Untitled4=TRUE)
	End Object

	Begin Object Class=UTVehicleSimCar Name=SimObject
		WheelSuspensionStiffness=50.0
		WheelSuspensionDamping=75.0
		WheelSuspensionBias=0.7

		ChassisTorqueScale=0.2
		LSDFactor=1.0
		WheelInertia=1.0

		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=30.0),(InVal=1500.0,OutVal=20.0)))
		SteerSpeed=50

		MaxBrakeTorque=8.0
		StopThreshold=500

		TorqueVSpeedCurve=(Points=((InVal=-600.0,OutVal=0.0),(InVal=-200.0,OutVal=10.0),(InVal=0.0,OutVal=16.0),(InVal=540.0,OutVal=10.0),(InVal=650.0,OutVal=0.0)))
		HardTurnMotorTorque=1.0
		EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=500.0),(InVal=599.0,OutVal=5000.0),(InVal=600.0,OutVal=3000.0),(InVal=949.0,OutVal=5000.0),(InVal=950.0,OutVal=3000.0),(InVal=1100.0,OutVal=5000.0)))
		EngineBrakeFactor=0.02
		FrontalCollisionGripFactor=0.18
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	SpawnRadius=425.0
	ExitRadius=350.0

	BaseEyeheight=0
	Eyeheight=0
	bLightArmor=false

	LFTurretHealth=1000
	RFTurretHealth=1000
	LRTurretHealth=1000
	RRTurretHealth=1000
	MaxTurretHealth=1000

	MaxHitCheckDist=140

	RespawnTime=120.0
	InitialSpawnDelay=+30.0
	bKeyVehicle=true
	StingerTurretTurnRate=+8192

	bStickDeflectionThrottle=true
	MaxDeploySpeed=300
	bAllowAbortDeploy=TRUE

	bEnteringUnlocks=false
	bAlwaysRelevant=true

	HUDExtent=500.0
	bFindGroundExit=false

	NonPreferredVehiclePathMultiplier=50.0
	bEjectKilledBodies=true
	bUseAlternatePaths=false

	HornSounds[1]=SoundCue'A_Vehicle_leviathan.Soundcues.A_Vehicle_leviathan_horn' // Big axon
	HornIndex=1
}
