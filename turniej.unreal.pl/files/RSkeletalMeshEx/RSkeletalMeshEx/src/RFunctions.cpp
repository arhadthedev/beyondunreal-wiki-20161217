//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Coder: Raven
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SkeletalMesh/FQuat/FString related functions
#include "RSkeletalMeshEx.h"
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Sums up bones orientation
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	Collected		already summed orientations
 * @param @input @required	Bone			next bone
 * @param @input @required	SkeletalMesh	current skeletal mesh
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	orientation
 */
FQuat CollectOrientation(FQuat Collected, FMeshBone Bone, USkeletalMesh SkeletalMesh)
{
	FQuat Current;
	
	Current = Collected+Bone.BonePos.Orientation;
	if(Bone.Depth == 0)
		return Current;
	else
	{
		return ( Current +  CollectOrientation(Current, SkeletalMesh.RefSkeleton(Bone.ParentIndex), SkeletalMesh) );
	}
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Sums up bones position
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	Collected		already summed positions
 * @param @input @required	Bone			next bone
 * @param @input @required	SkeletalMesh	current skeletal mesh
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	position
 */
FVector CollectPosition(FVector Collected, FMeshBone Bone, USkeletalMesh SkeletalMesh)
{
	FVector Current;
	
	Current = Collected+Bone.BonePos.Position;
	if(Bone.Depth == 0)
		return Current;
	else
	{
		FVector Next;
		Next = CollectPosition(Current, SkeletalMesh.RefSkeleton(Bone.ParentIndex), SkeletalMesh);
		Next += Current;	

		return Current;
	}
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Converts quaternion to FRotator
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * UScript version by Astyanax, 
 * converted to C++ by Raven
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	Q		quaternion to convert
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	FRotator
 */
FRotator FQuatToFRot(FQuat Q)
{
	float sinPitchR, cosPitchR, sinYawR, cosYawR, sinRollR, cosRollR;
	FRotator FRot;
	float UUdivPI = 10430.37835;


	sinPitchR = 2.0 * ( Q.X * Q.W - Q.Y * Q.Z );
	cosPitchR = appSqrt( 1 - sinPitchR * sinPitchR );
	FRot.Pitch = (int)appAtan2( sinPitchR, cosPitchR ) * UUdivPI;

	if( cosPitchR == 0 )
	{	// Argh no! Gimbal Lock!
		sinYawR = 2.0 * ( Q.X * Q.Y - Q.Z * Q.W );
		cosYawR = 2.0 * ( Q.Y * Q.Z + Q.X * Q.W );
		FRot.Yaw = (int)appAtan2( sinYawR, cosYawR ) * UUdivPI;
		FRot.Roll = 0;
		// Yaw seems to be 32768 off if Pitch is 49152. This is a quick
		// fix as I'm too lazy to search for the error.
		if( sinPitchR < 0 )
			FRot.Yaw += 32768;
	}
	else
	{
		sinYawR = 2.0 * ( Q.X * Q.Z + Q.Y * Q.Y ) / cosPitchR;
		cosYawR = ( 1.0 - 2.0 * Q.X * Q.X - 2.0 * Q.Y * Q.Y ) / cosPitchR;
		FRot.Yaw = (int)appAtan2( sinYawR, cosYawR ) * UUdivPI;
		sinRollR = 2.0 * ( Q.X * Q.Y + Q.Z * Q.W ) / cosPitchR;
		cosRollR = ( 1.0 - 2.0 * Q.X * Q.X - 2.0 * Q.Z * Q.Z ) / cosPitchR;
		FRot.Roll = (int)appAtan2( sinRollR, cosRollR ) * UUdivPI;
	}

	return FRot;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Converts FName to FString
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	A	name to convert
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	FString
 */
FString FNameToFString(FName A)
{	
	FString tmpStr(*A);
	return tmpStr;
}