class BoneActor extends RSkeletalActor;

var() name RAttachActor;
var() string RBoneAttach;
var actor RAttachedActor;

function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A;

	foreach AllActors(class'Actor', A, RAttachActor)
	{
		break;
	}

	if(BoneIndex == -1)
	{
		AttachToBone(A, RBoneAttach);
		BroadCastMessage("Attached");
	}
	else
	{
		BroadCastMessage("Detached");
		DetachFromBone();
	}
}

       
defaultproperties
{
	bHidden=false
}