//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Coder: Raven
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Extends unreal skeletal mesh with new functions.
#include "RSkeletalMeshEx.h"
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone details
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @output @required	Orientation	bone orientation
 * @param @output @required	Position	bone position
 * @param @output @required	Length		bone length
 * @param @output @required	Size		bone size
 */
void URSkeletalMeshEx::execGetBoneDetails( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execGetBoneDetails);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_GET_STR(BoneName);
	P_GET_UBOOL(bNoRelative);
	P_GET_ROTATOR_REF(Orientation);
	P_GET_VECTOR_REF(Position);
	P_GET_FLOAT_REF(Length);
	P_GET_VECTOR_REF(Size);
	P_FINISH;

/**
	Dunno which thing is better. Whenever use RefSkeleton form UnSkeletalMesh
	or RefBones from SkeletalMesh->DefaultAnimation
*/

	int i = 0;
	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	FMeshBone Bone;
	for(i=0; i<BoneCount; i++)
	{
		if(FNameToFString(SkeletalMesh->RefSkeleton(i).Name) == BoneName)
		{
			Bone=SkeletalMesh->RefSkeleton(i);
		}
	}	
	*Length = Bone.BonePos.Length;
	FVector tmpSize;
	tmpSize.X = Bone.BonePos.XSize;
	tmpSize.Y = Bone.BonePos.YSize;
	tmpSize.Z = Bone.BonePos.ZSize;	
	*Size = tmpSize;
	if(Bone.Depth == 0 || bNoRelative)	
	{
		//if we're root bone
		Position->X = Bone.BonePos.Position.X;
		Position->Y = Bone.BonePos.Position.Y;
		Position->Z = Bone.BonePos.Position.Z;
		*Orientation = FQuatToFRot(Bone.BonePos.Orientation);
	}
	else
	{
		*Position = CollectPosition(Bone.BonePos.Position, Bone, *SkeletalMesh);
		FQuat CurrentOrientation;
		CurrentOrientation = CollectOrientation(Bone.BonePos.Orientation, Bone, *SkeletalMesh);
		*Orientation = FQuatToFRot( CurrentOrientation );
	}
	unguard;
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone position
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	bone position
 */
void URSkeletalMeshEx::execGetBoneLocation( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execGetBoneLocation);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_GET_STR(BoneName);
	P_GET_UBOOL(bNoRelative);
	P_FINISH;

	int i = 0;
	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	FMeshBone Bone;
	for(i=0; i<BoneCount; i++)
	{
		if(FNameToFString(SkeletalMesh->RefSkeleton(i).Name) == BoneName)
		{
			Bone=SkeletalMesh->RefSkeleton(i);
		}
	}

	FVector Position;
	if(Bone.Depth == 0 || bNoRelative)
	{
		//if we're root bone
		Position.X = Bone.BonePos.Position.X;
		Position.Y = Bone.BonePos.Position.Y;
		Position.Z = Bone.BonePos.Position.Z;
	}
	else
	{
		Position = CollectPosition(Bone.BonePos.Position, Bone, *SkeletalMesh);
	}
	*reinterpret_cast< FVector * >(Result) = Position;
	unguard;
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone orientation
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	Bone rotation
 */
void URSkeletalMeshEx::execGetBoneRotation( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execGetBoneRotation);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_GET_STR(BoneName);
	P_GET_UBOOL(bNoRelative);
	P_FINISH;

	int i = 0;
	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	FMeshBone Bone;
	for(i=0; i<BoneCount; i++)
	{
		if(FNameToFString(SkeletalMesh->RefSkeleton(i).Name) == BoneName)
		{
			Bone=SkeletalMesh->RefSkeleton(i);
		}
	}

	FRotator Orientation;
	if(Bone.Depth == 0 || bNoRelative)
	{
		Orientation = FQuatToFRot(Bone.BonePos.Orientation);
	}
	else
	{
		FQuat CurrentOrientation;
		CurrentOrientation = CollectOrientation(Bone.BonePos.Orientation, Bone, *SkeletalMesh);
		Orientation = FQuatToFRot( CurrentOrientation );
	}
	*reinterpret_cast< FRotator * >(Result) = Orientation;
	unguard;
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Check if bone exists
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name 
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	true if bone exists
 */
void URSkeletalMeshEx::execBoneExists( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execBoneExists);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_GET_STR(BoneName);
	P_FINISH;

	int i = 0;
	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	bool found = false;
	for(i=0; i<BoneCount; i++)
	{
		if(FNameToFString(SkeletalMesh->RefSkeleton(i).Name) == BoneName)
		{
			found = true;
		}
	}
	*reinterpret_cast< UBOOL * >(Result) = found;
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns number of bones in skeleton
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	True on success
 */
void URSkeletalMeshEx::execGetNumBones( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execGetNumBones);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_FINISH;

	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	*reinterpret_cast< int * >(Result) = BoneCount;
	unguard;
}


/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone name
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	index		bone index
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	True on success
 */
void URSkeletalMeshEx::execGetBoneNameByIndex( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execGetBoneNameByIndex);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_GET_INT(index);
	P_FINISH;

	int BoneCount = SkeletalMesh->RefSkeleton.Num();

	FName BoneName;

	if(index >= BoneCount) BoneName = FName(TEXT("none"));
	else BoneName = SkeletalMesh->RefSkeleton(index).Name;

	*reinterpret_cast< FName * >(Result) = BoneName;
	unguard;
}


/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone index
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	bone index or -1 if bone can not found
 */
void URSkeletalMeshEx::execGetBoneIndex( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execGetBoneIndex);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_GET_STR(BoneName);
	P_FINISH;

	int i = 0;
	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	int index = -1;
	for(i=0; i<BoneCount; i++)
	{
		if(FNameToFString(SkeletalMesh->RefSkeleton(i).Name) == BoneName)
		{
			index = i;
		}
	}
	*reinterpret_cast< int * >(Result) = index;
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone position
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	index		bone index
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	bone position
 */
void URSkeletalMeshEx::execGetBoneLocationByIndex( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execGetBoneLocationByIndex);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_GET_INT(index);
	P_GET_UBOOL(bNoRelative);
	P_FINISH;

	int i = 0;
	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	FMeshBone Bone;

	FVector Position = FVector(0,0,0);
	if(index < BoneCount)
	{
		Bone=SkeletalMesh->RefSkeleton(index);
		if(Bone.Depth == 0 || bNoRelative)
		{
			//if we're root bone
			Position.X = Bone.BonePos.Position.X;
			Position.Y = Bone.BonePos.Position.Y;
			Position.Z = Bone.BonePos.Position.Z;
		}
		else
		{
			Position = CollectPosition(Bone.BonePos.Position, Bone, *SkeletalMesh);
		}
	}
	*reinterpret_cast< FVector * >(Result) = Position;
	unguard;
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone orientation
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	index		bone index
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	Bone rotation
 */
void URSkeletalMeshEx::execGetBoneRotationByIndex( FFrame &Stack, void* Result)
{
	guard(URSkeletalMeshEx::execGetBoneRotationByIndex);
	P_GET_OBJECT(USkeletalMesh,SkeletalMesh);
	P_GET_INT(index);
	P_GET_UBOOL(bNoRelative);
	P_FINISH;

	int i = 0;
	int BoneCount = SkeletalMesh->RefSkeleton.Num();
	FMeshBone Bone;

	FRotator Orientation = FRotator(0,0,0);
	if(index < BoneCount)
	{	
		if(Bone.Depth == 0 || bNoRelative)
		{
			Orientation = FQuatToFRot(Bone.BonePos.Orientation);
		}
		else
		{
			FQuat CurrentOrientation;
			CurrentOrientation = CollectOrientation(Bone.BonePos.Orientation, Bone, *SkeletalMesh);
			Orientation = FQuatToFRot( CurrentOrientation );
		}
	}
	*reinterpret_cast< FRotator * >(Result) = Orientation;
	unguard;
}

IMPLEMENT_CLASS(URSkeletalMeshEx);
