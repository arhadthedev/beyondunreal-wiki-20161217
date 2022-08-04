/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class FaceFXAsset extends Object
	hidecategories(Object)
	native;

/** 
 *  Default skeletal mesh to use when previewing this FaceFXAsset etc. 
 *  Is the one that was used as the basis for creating this Asset.
 */
var const editoronly SkeletalMesh DefaultSkelMesh;

/** Internal use.  FaceFX representation of this asset. */
var const native pointer FaceFXActor;
/** 
 *  Internal use.  Raw bytes of the FaceFX Actor for this asset. 
 *  This only stays loaded in the editor.
 */
var const native array<byte> RawFaceFXActorBytes;
/** 
 *  Internal use.  Raw bytes of the FaceFX Studio session for this asset. 
 *  This only stays loaded in the editor.
 */
var const native array<byte> RawFaceFXSessionBytes;

/**
 *	MorphTargetSets used when previewing this FaceFXAsset in FaceFX Studio.
 *  Note that these are only valid in the editor.
 */
var() editoronly array<MorphTargetSet>	PreviewMorphSets;

/**
 *  Array of currently mounted FaceFXAnimSets.
 *	We only track this if GIsEditor!
 */
var transient array<FaceFXAnimSet> MountedFaceFXAnimSets;

/**
 *  Array of SoundCue objects that the FaceFXAsset references.
 */
var array<SoundCue> ReferencedSoundCues;

/**
 *  Internal use.  The number of errors generated during load.
 */
var int NumLoadErrors;

/**
 *  Mounts the specified FaceFXAnimSet into this FaceFXAsset.
 */
native final function MountFaceFXAnimSet( FaceFXAnimSet AnimSet );

/**
 *  Internal use.  Unmounts the specified FaceFXAnimSet from this FaceFXAsset.
 */
native final function UnmountFaceFXAnimSet( FaceFXAnimSet AnimSet );

