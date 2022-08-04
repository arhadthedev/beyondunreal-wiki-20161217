//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Coder: Raven
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Skeletal mesh extensions
class RSkeletalMeshEx extends Object native;

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
native static final function GetBoneDetails(SkeletalMesh SkeletalMesh, string BoneName, bool bNoRelative, out rotator Orientation, out vector Position, out float Length, out vector Size);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone position
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	bone position
 */
native static final function vector GetBoneLocation(SkeletalMesh SkeletalMesh, string BoneName, bool bNoRelative);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone orientation
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	Bone rotation
 */
native static final function rotator GetBoneRotation(SkeletalMesh SkeletalMesh, string BoneName, bool bNoRelative);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Check if bone exists
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name 
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	true if bone exists
 */
native static final function bool BoneExists(SkeletalMesh SkeletalMesh, string BoneName);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns number of bones in skeleton
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	True on success
 */
native static final function int GetNumBones(SkeletalMesh SkeletalMesh);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone name
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	index		bone index
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	True on success
 */
native static final function name GetBoneNameByIndex(SkeletalMesh SkeletalMesh, int index);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone index
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	BoneName	Bone name
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	bone index or -1 if bone can not found
 */
native static final function int GetBoneIndex(SkeletalMesh SkeletalMesh, string BoneName);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone position
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	index		bone index
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	bone position
 */
native static final function vector GetBoneLocationByIndex(SkeletalMesh SkeletalMesh, int index, bool bNoRelative);
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Returns bone orientation
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @param @input @required	SkeletalMesh	Skeletal mesh
 * @param @input @required	index		bone index
 * @param @input @required	bNoRelative	if true will not sum position/orientation of root bones
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @return	Bone rotation
 */
native static final function rotator GetBoneRotationByIndex(SkeletalMesh SkeletalMesh, int index, bool bNoRelative);