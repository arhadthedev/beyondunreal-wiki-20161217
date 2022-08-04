/**
 * UTOnslaughtFlagBase.
 *
 * Onslaught levels may have a UTOnslaughtFlagBase placed near each powercore that will spawn the orb (UTOnslaughtFlag)
 * They may also have additional flag bases placed near nodes that the orb will return to instead if it is closer
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTOnslaughtFlagBase extends UTOnslaughtNodeEnhancement
	native(Onslaught)
	abstract;

var UTOnslaughtFlag myFlag;
var SkeletalMeshComponent Mesh;

/** when this changes, the flag was returned, so play returned effects */
var repnotify bool bPlayOrbBuilding;

/** whether this flag base is used in the current link setup */
var protected bool bEnabled;

var ParticleSystemComponent BallEffect;
var ParticleSystem TeamEmitters[3];

var	Material BaseMaterials[3];
var Material BallMaterials[3];

var SoundCue CreateSound;

var class<UTOnslaughtFlag> FlagClass;

/** skel control used to scale the orb when it should/shouldn't be visible */
var SkelControlSingleBone OrbScaleControl;
/** main animation node on our Mesh so we can keep track of what animation was playing */
var UTAnimNodeSequence AnimPlayer;



replication
{
	if (bNetDirty)
		myFlag, bPlayOrbBuilding;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if (ROLE == ROLE_Authority)
	{
		SpawnFlag();
	}
}

/** Disable this orb spawner */
function DisableOrbs()
{
	bEnabled = false;
	SetHidden(true);
	SetCollision(false, false);
}

/** spawn a flag if we're a core flag base and enabled */
function SpawnFlag()
{
	if (bEnabled && UTOnslaughtPowerCore(ControllingNode) != None && ControllingNode.FlagBase == self)
	{
		if (myFlag == None)
		{
			// spawn a flag for flag bases owned by powercores
			myFlag = Spawn(FlagClass, self);
			myFlag.HomeBase = self;
			myFlag.StartingHomeBase = self;
		}
	}
	else if (myFlag != None)
	{
		// we shouldn't have a flag in this case, so destroy it
		myFlag.Destroy();
	}
}

/** called to tell us if we should be enabled in the current link setup */
function SetEnabled(bool bNewEnabled)
{
	bEnabled = bNewEnabled;
	SetHidden(!bEnabled);
	SetCollision(bEnabled);
	SpawnFlag();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role == ROLE_Authority && myFlag != None && ControllingNode != None)
	{
		myFlag.SetTeam(GetTeamNum());
	}

	BallEffect.DeactivateSystem();
	UpdateTeamEffects();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	if (SkelComp == Mesh)
	{
		OrbScaleControl = SkelControlSingleBone(Mesh.FindSkelControl('CellScaler'));
		AnimPlayer = UTAnimNodeSequence(Mesh.FindAnimNode('Player'));
	}
}

simulated function UpdateTeamEffects()
{
	local int EffectIndex;

	EffectIndex = Min(DefenderTeamIndex, 2);

	BallEffect.SetTemplate(TeamEmitters[EffectIndex]);
	Mesh.SetMaterial(0,BaseMaterials[EffectIndex]);
	Mesh.SetMaterial(1,BallMaterials[EffectIndex]);
}

function SetControllingNode(UTOnslaughtNodeObjective NewControllingNode)
{
	Super.SetControllingNode(NewControllingNode);

	if (myFlag != None)
	{
		myFlag.SetTeam(GetTeamNum());
		UTGameReplicationInfo(WorldInfo.GRI).SetFlagHome(GetTeamNum());
	}
	ControllingNode.FlagBase = self;
}

event actor GetBestViewTarget()
{
	if (myFlag.Holder != none)
		return myFlag.Holder;

	else if (!myFlag.bHome)
		return MyFlag;
	else
		return self;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bPlayOrbBuilding')
	{
		if ( bPlayOrbBuilding )
		{
			BuildOrb();
		}
		else
		{
			HideOrb();
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function ActivateEmitter()
{
	BallEffect.SetActive(true);
}

simulated function SetOrbScale(float Scaling)
{
	if (OrbScaleControl != None)
	{
		OrbScaleControl.BoneScale = Scaling;
	}
}

simulated function BuildOrb()
{
	bPlayOrbBuilding = true;
	bForceNetUpdate = TRUE;

	// might already be playing 'Loading' due to OrbHomeStatusChanged() notification
	if (AnimPlayer.AnimSeqName != 'Loading' || !AnimPlayer.bPlaying)
	{
		Mesh.PlayAnim('Loading');
	}
	PlaySound(CreateSound, true);
}

simulated function HideOrb()
{
	bPlayOrbBuilding = false;
	bForceNetUpdate = TRUE;

	BallEffect.DeActivateSystem();
	if (AnimPlayer.AnimSeqName != 'Loading' || !AnimPlayer.bPlaying)
	{
		SetOrbScale(1.0);
		Mesh.PlayAnim('SingleFrame',, true);
	}
	else
	{
		SetOrbScale(0.0);
	}
}

/** updates animation to match orb status */
simulated function UpdateAnimation()
{
	if (myFlag != None && myFlag.bHome)
	{
		if (AnimPlayer.AnimSeqName != 'Loading')
		{
			Mesh.PlayAnim('Loading');
		}
		else if (!AnimPlayer.bPlaying)
		{
			HideOrb();
			ShowFlag();
		}
	}
	else
	{
		SetOrbScale(1.0);
		if (AnimPlayer.AnimSeqName != 'SingleFrame')
		{
			Mesh.PlayAnim('SingleFrame');
		}
	}
}

/** called by the orb on its homebase when it leaves/returns (remote clients only) */
simulated function OrbHomeStatusChanged()
{
	if (myFlag == None || !myFlag.bHome || myFlag.bFinishedPreBuild)
	{
		UpdateAnimation();
	}
}

simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	UpdateAnimation();
}

simulated function ShowFlag()
{
	myFlag.SetHidden(False);
}

/**
 * Handle flag events.
 */
function ObjectiveChanged()
{
	local PlayerController PC;

	// Look to change the spectator
	foreach WorldInfo.AllControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget == self) || (PC.ViewTarget == myFlag) || ((PC.ViewTarget != None) && (PC.ViewTarget == myFlag.Holder)) )
			PC.SetViewTarget(GetBestViewTarget());
	}
}

function UTCarriedObject GetFlag()
{
	return myFlag;
}

event Bump(Actor Other, PrimitiveComponent OtherComp, vector HitNormal)
{
	local Pawn P;
	local AIController Bot;
	local vector Cross, Dir, DesiredDir, TraceHitLocation, TraceHitNormal, Extent;

	// tell AI to move away if it runs into the blocking portion of the orb spawner
	if (Mesh != None && Mesh.CollideActors && Mesh.BlockActors)
	{
		P = Pawn(Other);
		if (P != None)
		{
			Bot = AIController(P.Controller);
			if (Bot != None && !Bot.bAdjusting)
			{
				Extent = P.GetCollisionExtent();
				Extent.Z *= 0.5; // so don't hit bottom part
				if (TraceComponent(TraceHitLocation, TraceHitNormal, Mesh, P.Location + Normal(P.Velocity) * 10.0, P.Location, Extent))
				{
					DesiredDir = (Bot.Destination - P.Location);
					Cross = DesiredDir cross vect(0,0,1);
					Dir = 1.20 * CylinderComponent.CollisionRadius * Normal(Cross);
					if ((Cross dot DesiredDir) < 0.0)
					{
						Dir *= -1.0;
					}
					if (FRand() < 0.3)
					{
						Dir *= -2.0;
					}
					Bot.bAdjusting = true;
					Bot.AdjustLoc = Location + Dir;
				}
			}
		}
	}
}

defaultproperties
{
	IconHudTexture=None
}
