//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Coder: Raven
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Implements AttachToBone function
#include "RSkeletalMeshEx.h"
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Attach RSkeletalActor to Attachment's Bone
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	Attachment	actor to attach
 * @param @input @required	BoneName	Bone name 
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	true if actor was attached
 */
void ARSkeletalActor::execAttachToBone( FFrame &Stack, void* Result)
{
	guard(ARSkeletalActor::execAttachToBone);
	P_GET_ACTOR(ABase);
	P_GET_STR(BoneName);
	P_FINISH;

	this->AttachedTarget = ABase;
	USkeletalMesh *SkeletalMesh = (USkeletalMesh *)this->AttachedTarget->Mesh;
	int i = 0;
	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	bool bFound = false;
	int idx = -1;
	
	for(i=0; i<BoneCount; i++)
	{
		if(FNameToFString(SkeletalMesh->RefSkeleton(i).Name) == BoneName)
		{
			bFound = true;
			idx = i;
		}
	}
	this->BoneIndex = idx;

	*reinterpret_cast< UBOOL * >(Result) = bFound;
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Updates actor position
 */
void ARSkeletalActor::PerformAttachmentUpdate()
{
	guard(ARSkeletalActor::PerformAttachmentUpdate);

	USkeletalMesh *SkeletalMesh = (USkeletalMesh *)this->AttachedTarget->Mesh;
	if(SkeletalMesh != NULL)
	{
		int BoneCount = SkeletalMesh->RefSkeleton.Num();
		if(BoneIndex < BoneCount)				
		{
			FMeshBone Bone = SkeletalMesh->RefSkeleton(this->BoneIndex);
			FVector Position = Bone.BonePos.Position;
			if(Bone.Depth > 0)
				Position = CollectPosition(Position, Bone, *SkeletalMesh);
			if(this->bUpdateRotation)
			{
				FQuat CurrentOrientation;
				CurrentOrientation = Bone.BonePos.Orientation;
				if(Bone.Depth > 0)
				{					
					CurrentOrientation = CollectOrientation(CurrentOrientation, Bone, *SkeletalMesh);
				}
				FCheckResult Hit;
				GetLevel()->MoveActor( this, FVector(0,0,0) , ( FQuatToFRot(CurrentOrientation) + this->RotationOffset), Hit, 0, 1, 1, 1 );	
			}
			GetLevel()->FarMoveActor( this, (Position + this->AttachedTarget->Location + this->LocationOffset) );
		}			
	}		

	unguard;
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Call PerformAttachmentUpdate
 * For use in UScript function Tick only 
 */
void ARSkeletalActor::execUpdateAttached( FFrame &Stack, void* Result)
{
	guard(ARSkeletalActor::execUpdateAttached);
	P_FINISH;

	if(this->BoneIndex != (int)-1 && this->AttachedTarget != NULL)
	{		
		USkeletalMesh *SkeletalMesh = (USkeletalMesh *)this->AttachedTarget->Mesh;
		if(SkeletalMesh != NULL)
		{
				this->PerformAttachmentUpdate();
		}			
	}		
	unguard;
} 
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Calls (if bDisableNativeUpdate is false).
 */
UBOOL ARSkeletalActor::Tick(FLOAT DeltaTime, enum ELevelTick TickType)
{
	guard(ARSkeletalActor::Tick);

	UBOOL TickDid = Super::Tick(DeltaTime, TickType);   
	
	if(TickDid == 0)
		return 0;

	if(this->BoneIndex != (int)-1 && this->AttachedTarget != NULL && !this->bDisableNativeUpdate)
	{
		this->PerformAttachmentUpdate();	
	}
	return TickDid;
	unguard;
} 
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Detaches actor
 */
void ARSkeletalActor::execDetachFromBone( FFrame &Stack, void* Result)
{
	guard(ARSkeletalActor::execDetachFromBone);
	P_FINISH;

	this->AttachedTarget = NULL;
	this->BoneIndex = -1;
	unguard;
}
IMPLEMENT_CLASS(ARSkeletalActor);