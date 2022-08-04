/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTWalkerBody_Scavenger extends UTWalkerBody
	native(Vehicle)
	abstract;

//var	RB_Handle			PawnGrabber[3];
var bool				bIsInBallMode;

/** Have the feet been released by a jump or ballmode */
var bool				bAreFeetReleased;

/** Names of the anim nodes for playing the step anim for a leg.  Used to fill in FootStepAnimNode array. */
var const name			BallAnimNodeName[NUM_WALKER_LEGS];
/** Refs to AnimNodes used for playing step animations */
var AnimNode			BallAnimNode[NUM_WALKER_LEGS];
/** ref to AnimNode for extending/retracting the legs */
var AnimNodeBlendList	RetractionBlend;

/** The beams attaching the legs to the shield */
var ParticleSystemComponent LegAttachBeams[NUM_WALKER_LEGS];
var ParticleSystemComponent OrbConnectionEffect[NUM_WALKER_LEGS];

/** Names of the top leg bones.  LegAttachBeams will terminate here. */
var protected const name	TopLegSocketName[NUM_WALKER_LEGS];
/** Name of beam endpoint parameter in the particle system */
var protected const name	LegAttachBeamEndPointParamName;
/** radius around the body in which the arm attachments will rotate */
var float ShieldRadius;

/** These keep the previous location of the legs and body so that we don't have to do expensive line traces if we have actually not moved their position **/
var protected vector PreviousCenterOfWalkerLocation;
var protected vector PreviousLegLocation[NUM_WALKER_LEGS];

/** Spin Attack desired/current orientation normals */
var Vector DesiredSurfaceNormal;
var Vector CurrentSurfaceNormal;

/** Spin Attack current absolute accrued rotation */
var int SpinRotation;
/** Spin Attack rate of speed */
var int	SpinRate;

var name RetractionBlendName;
var name SphereCenterName;



/** Set physics to Phys_None */
native function SetPhysicsOff();

/** Set physics back to rigid bodies */
native function SetPhysicsOn();

function PlayDying()
{
	if(!bIsInBallMode)
	{
		UTVehicle_Scavenger(WalkerVehicle).BallStatus.bIsInBallmode = TRUE;
		UTVehicle_Scavenger(WalkerVehicle).BallStatus.bBoostOnTransition = FALSE;
		UTVehicle_Scavenger(WalkerVehicle).BallModeTransition();
	}
}

function PostBeginPlay()
{
	local int Idx;

	Super.PostBeginPlay();

	for (Idx=0; Idx<NUM_WALKER_LEGS; ++Idx)
	{
		// cache refs to footstep anims
		BallAnimNode[Idx] = SkeletalMeshComponent.FindAnimNode(FootStepAnimNodeName[Idx]);
	}

	//Blend node between extended/retracted/walking legs
	RetractionBlend = AnimNodeBlendList(SkeletalMeshComponent.FindAnimNode(RetractionBlendName));
}

simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	local int LegIdx;

	if (SeqNode.AnimSeqName == 'retractlegs')
	{
		SkeletalMeshComponent.PhysicsWeight = 0.f;

        //No more constraints, shoulders are free to move as needed
		for (LegIdx=0; LegIdx<NUM_WALKER_LEGS; ++LegIdx)
		{
			FootConstraints[LegIdx].ReleaseComponent();
			ShoulderSkelControl[LegIdx].SetSkelControlActive(FALSE);
			IgnoreFoot[LegIdx] = 1;
		}
		
		bAreFeetReleased = TRUE;

		Cloak(true);
	}
	else if (SeqNode.AnimSeqName == 'extendlegs')
	{
        //Legs are all the way back out
		SetPhysicsOn();
	}
	else
	{
		Super.OnAnimEnd(SeqNode, PlayedTime, ExcessTime);
	}
}

simulated function RetractLegs()
{
    //Legs are beginning to retract
	//Transition to the retraction animation
	RetractionBlend.SetActiveChild(1, 0.1);
	RetractionBlend.Children[1].Anim.PlayAnim(false, 1.2f);

	//Legs are hidden after the animation is finished
    SetPhysicsOff();
}

simulated function ExtendLegs()
{
	//Transition from retracting legs to extending legs immediately
	RetractionBlend.SetActiveChild(2, 0.0f);

	//Transition back to the walking animation
	RetractionBlend.Children[2].Anim.PlayAnim(FALSE, 1.0f);
	RetractionBlend.SetActiveChild(0, 0.5);

	//Unhide the legs
	Cloak(FALSE);
}

simulated event OnJump()
{
	local int LegIdx;

	//Disable the legs from their constraints
	for (LegIdx=0; LegIdx<3; LegIdx++)
	{
		IgnoreFoot[LegIdx] = 1;
	}

	bAreFeetReleased = TRUE;
}

simulated event OnLanded()
{
	//Catchall in case we never have a downward velocity on jump or the jump is too short
	if (bAreFeetReleased && !UTVehicle_Scavenger(WalkerVehicle).BallStatus.bIsInBallmode &&
		FootConstraints[0].GrabbedComponent == None && 
		FootConstraints[1].GrabbedComponent == None && 
		FootConstraints[2].GrabbedComponent == None)
	{
		InitFeetOnLanding();
		bAreFeetReleased = FALSE;
	}
}

simulated event Cloak(bool bIsEnabled)
{
	SetHidden(bIsEnabled);
}

defaultproperties
{
	bHasCrouchMode=FALSE

	MinStepDist=100.f
	MaxLegReach=475.f
	LegSpreadFactor=0.65f

	CustomGravityScale=0.f
	FootEmbedDistance=16.0

	LandedFootDistSq=2500.0f

	FootStepAnimNodeName[0]="Leg0 Step"
	FootStepAnimNodeName[1]="Leg1 Step"
	FootStepAnimNodeName[2]="Leg2 Step"

	FootPosVelAdjScale[WalkerLeg_Rear]=0.15f
	FootPosVelAdjScale[WalkerLeg_FrontLeft]=0.15f
	FootPosVelAdjScale[WalkerLeg_FrontRight]=0.15f

	FootStepStartLift=300.f
	FootStepEndLift=100.f

	StepStageTimes(0)=0.45f		// foot pickup and move forward
	StepStageTimes(1)=0.1f		// foot stab to ground at destination
	StepStageTimes(2)=0.5f		// wait for foot to reach dest before forcibly ending step

	BaseLegDirLocal[WalkerLeg_Rear]=(X=-1.f,Y=0.f,Z=0.f)
	BaseLegDirLocal[WalkerLeg_FrontLeft]=(X=0.5f,Y=-0.866025f,Z=0.f)
	BaseLegDirLocal[WalkerLeg_FrontRight]=(X=0.5f,Y=0.866025f,Z=0.f)

	MaxFootStepEffectDist=3000.0
}
