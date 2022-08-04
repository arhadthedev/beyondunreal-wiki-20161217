About

I've wrote extended skeletal animation support. Features:

    * returns bone details (position, orientation, etc)
    * returns whenever bone exists or not
    * returns number of bones
    * returns bone name by index
    * implements AttachToBone function

RSkeletalMeshEx

This object holds all SkeletalMesh related functions.

Static functions

function GetBoneDetails

native static final function GetBoneDetails(SkeletalMesh SkeletalMesh, string BoneName, bool bNoRelative, out rotator Orientation, out vector Position, out float Length, out vector Size);

Returns bone details as output parameters

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)
    * string BoneName - bone name. Eg. "Bip01 R Finger1"
    * bool bNoRelative - if false, it'll also take all root bones position/orientation into account

output parameters

    * rotator Orientation - bone rotation
    * vector Position - bone position
    * float Length - bone lenght
    * vector Size - bone size


function GetBoneLocation

native static final function vector GetBoneLocation(SkeletalMesh SkeletalMesh, string BoneName, bool bNoRelative);

Returns bone position

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)
    * string BoneName - bone name. Eg. "Bip01 R Finger1"
    * bool bNoRelative - if false, it'll also take all root bones


function GetBoneRotation

native static final function rotator GetBoneRotation(SkeletalMesh SkeletalMesh, string BoneName, bool bNoRelative);

Returns bone orientation

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)
    * string BoneName - bone name. Eg. "Bip01 R Finger1"
    * bool bNoRelative - if false, it'll also take all root bones

function BoneExists

native static final function bool BoneExists(SkeletalMesh SkeletalMesh, string BoneName);

Returns whenever given bone exists or not

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)
    * string BoneName - bone name. Eg. "Bip01 R Finger1"

function GetNumBones

native static final function int GetNumBones(SkeletalMesh SkeletalMesh);

Returns number of bones in given skeletal mesh

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)


function GetBoneNameByIndex

native static final function name GetBoneNameByIndex(SkeletalMesh SkeletalMesh, int index);

Returns bone name

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)
    * int index - bone index (use GetNumBones to have list of all bones)

function GetBoneIndex

native static final function int GetBoneIndex(SkeletalMesh SkeletalMesh, string BoneName);

Returns bone index or -1 if bone can not be found.

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)
    * string BoneName - bone name. Eg. "Bip01 R Finger1"

function GetBoneLocationByIndex

native static final function vector GetBoneLocationByIndex(SkeletalMesh SkeletalMesh, int index, bool bNoRelative);

Returns bone position

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)
    * int index - bone index (use GetNumBones to have list of all bones)
    * bool bNoRelative - if false, it'll also take all root bones


function GetBoneRotationByIndex

native static final function rotator GetBoneRotationByIndex(SkeletalMesh SkeletalMesh, int index, bool bNoRelative);

Returns bone orientation

input parameters:

    * SkeletalMesh - skeletal mesh. Can look like: SkeletalMesh(Mesh)
    * int index - bone index (use GetNumBones to have list of all bones)
    * bool bNoRelative - if false, it'll also take all root bones


RSkeletalActor

This actor implements AttachToBone function.

Variables

    * bool bUpdateRotation - if true, rotation will also be updated
    * bool bDisableNativeUpdate - if true, native update will be disabled. In order to update location you'll have to yse UpdateAttached function.
    * rotator RotationOffset - rotation offset (relative to bone rotation)
    * vector LocationOffset - location offset (relative to bone location)

Functions

AttachToBone

native final function bool AttachToBone(Actor ABase , string Bone);

When called will attach itself into ABase bone.

input parameters:

    * Actor ABase - actor we'll be attached to
    * string BoneName - bone name. Eg. "Bip01 R Finger1"

UpdateAttached

native final function UpdateAttached();

Updates actor location (can be used only if bDisableNativeUpdate is true)

DetachFromBone

native final function DetachFromBone();

If called will detach itself from attached actor.

Native files (.h and .cpp)

    * ./inc
          o ARSkeletalActor.h - header file for ARSkeletalActor.cpp
          o RFunctions.h - header file for RFunctions.cpp
          o RSkeletalMeshEx.h - header file for all .cpp files
          o RSkeletalMeshExClasses.h - UCC generated header
    * ./src
          o ARSkeletalActor.cpp - implements AttachToBone functions
          o RFunctions.cpp - implements all conversion code and useful functions
          o RSkeletalMeshEx.cpp - implements linking UScript and C++
          o URSkeletalMeshEx.cpp - implements all skeletalmesh functions

Changelog

    * v 0.0.3
          o RSkeletalMeshEx has three new static functions (GetBoneIndex, GetBoneLocationByIndex, GetBoneRotationByIndex)
    * v 0.0.2
          o added native class RSkeletalActor which implements AttachToBone function
    * v 0.0.1 (first public release)
          o added function GetBoneRotation and GetBoneLocation
Credits

    * Raven - whole code :)
    * Astyanax - quaternion to rotator function (found somewhere at BU)
    * Smirftsch - being patient to my noob C++ questions :P
    * .:..: - for help with AttachToBone update stuff
