class RSkeletalMeshSample extends Keypoint;

var() string Bone;
var() string BoneStr;
var() bool bListBones;

function Trigger( actor Other, pawn EventInstigator )
{
	local bool bFound;
	local rotator Orientation;
	local vector Position;
	local float Length;
	local vector Size;
	local int numBones;
	local int i;
	local name BoneName;


	bFound = class'RSkeletalMeshEx'.static.BoneExists(SkeletalMesh(Mesh), Bone);

	BroadCastMessage(bFound);
	log(bFound,'bone');

	class'RSkeletalMeshEx'.static.GetBoneDetails(SkeletalMesh(Mesh), Bone, false, Orientation, Position, Length, Size);

	BroadCastMessage("Position (X,Y,Z): "$Position.X$", "$ Position.Y$", "$Position.Z$", Length: "$Length$", Size: "$Size.X$", "$Size.Y$", "$ Size.Z$", Orientation (R,P,Y): "$Orientation.Roll$", "$Orientation.Yaw$", "$Orientation.Pitch);
	log("Position (X,Y,Z): "$Position.X$", "$ Position.Y$", "$Position.Z$", Length: "$Length$", Size: "$Size.X$", "$Size.Y$", "$ Size.Z$", Orientation (R,P,Y): "$Orientation.Roll$", "$Orientation.Yaw$", "$Orientation.Pitch,'bone');
	if(!bListBones) return;
	numBones = class'RSkeletalMeshEx'.static.GetNumBones(SkeletalMesh(Mesh));
	BroadCastMessage("NumBones: "$numBones);
	log("NumBones: "$numBones,'bone');
	for(i=0; i<numBones; i++)
	{
		BoneName = class'RSkeletalMeshEx'.static.GetBoneNameByIndex(SkeletalMesh(Mesh), i);
		BroadCastMessage("BoneName: "$BoneName);
		log("BoneName: "$BoneName,'bone');
	}
}

defaultproperties
{
	bHidden=false
}