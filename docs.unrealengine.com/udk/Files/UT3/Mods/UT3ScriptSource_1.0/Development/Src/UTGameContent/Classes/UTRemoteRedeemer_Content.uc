/**
* Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
*/
class UTRemoteRedeemer_Content extends UTRemoteRedeemer
	notplaceable;

defaultproperties
{
	Begin Object Class=AudioComponent Name=AmbientSoundComponent
		bStopWhenOwnerDestroyed=true
		bShouldRemainActiveIfDropped=true
	End Object
	PawnAmbientSound=AmbientSoundComponent
	Components.Add(AmbientSoundComponent)

	Begin Object Class=StaticMeshComponent Name=WRocketMesh
		StaticMesh=StaticMesh'WP_AVRiL.Mesh.S_WP_AVRiL_Missile'
		CullDistance=20000
		Scale=3.0
		Translation=(X=32.0)
		CollideActors=false
		BlockRigidBody=false
		BlockActors=false
		bOwnerNoSee=true
		bUseAsOccluder=FALSE
	End Object
	Components.Add(WRocketMesh)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+020.000000
		CollisionHeight=+012.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
		Translation=(X=40.0)
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=UTParticleSystemComponent Name=TrailComponent
		bOwnerNoSee=true
		SecondsBeforeInactive=1.0f
	End Object
	Trail=TrailComponent
	Components.Add(TrailComponent)

	RemoteRole=ROLE_SimulatedProxy
	NetPriority=3
	bNetTemporary=false
	bUpdateSimulatedPosition=true
	bSimulateGravity=false
	Physics=PHYS_Flying
	AirSpeed=1000.0
	AccelRate=2000.0
	bCanTeleport=false
	bDirectHitWall=true
	bCollideActors=false
	bCollideWorld=true
	bBlockActors=false
	BaseEyeHeight=0.0
	EyeHeight=0.0
	bStasis=false
	bCanCrouch=false
	bCanClimbLadders=false
	bCanPickupInventory=false
	bNetInitialRotation=true
	bSpecialHUD=true
	bCanUse=false
	bAttachDriver=false
	DriverDamageMult=1.0
	RedeemerProjClass=class'UTProj_Redeemer'
	LandMovementState=PlayerFlying

	CameraEffect=PostProcessChain'UN_LensTypes.RedeemerPostProcess'
	TeamCameraMaterials[0]=MaterialInterface'UN_LensTypes.Materials.MI_FX_RedeemerCam_Red'
	TeamCameraMaterials[1]=MaterialInterface'UN_LensTypes.Materials.MI_FX_RedeemerCam_Blue'
}
