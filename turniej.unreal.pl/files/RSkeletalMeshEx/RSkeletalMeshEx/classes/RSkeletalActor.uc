//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Coder: Raven
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Skeletal actor
class RSkeletalActor extends Actor native;

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * native - configureable variables
 */
var() bool bUpdateRotation;		// if true, rotation will be updated also
var() bool bDisableNativeUpdate;	// if true, native update will be disabled
					// UpdateAttached will had to be called in order to update actor's location
var() rotator RotationOffset;
var() vector LocationOffset;					
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * native private variables
 */
var actor AttachedTarget;		// actor we're attached to
var int BoneIndex;			// bone we're attached to

replication
{
	reliable if( Role == ROLE_Authority )
		AttachedTarget, BoneIndex;
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Attach RSkeletalActor to Attachment's Bone
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	Attachment	actor to attach
 * @param @input @required	BoneName	Bone name
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	true if actor was attached
 */
native final function bool AttachToBone(Actor ABase, string Bone);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Updates actor (if bDisableNativeUpdate is true).
 * Has to be called in Tick
 */
native final function UpdateAttached();
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Detaches actor
 */
native final function DetachFromBone();

defaultproperties
{
	bDisableNativeUpdate=false
	bUpdateRotation=true
	BoneIndex=-1
}