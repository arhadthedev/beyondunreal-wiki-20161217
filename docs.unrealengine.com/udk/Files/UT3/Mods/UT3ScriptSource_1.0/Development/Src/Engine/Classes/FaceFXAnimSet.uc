/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class FaceFXAnimSet extends Object
	hidecategories(Object)
	native;

/** 
 *  Default FaceFXAsset to use when editing this FaceFXAnimSet etc. 
 *  Is the one that was used as the basis for creating this AnimSet.
 */
var() editoronly const FaceFXAsset DefaultFaceFXAsset;

/** Internal use.  FaceFX representation of this AnimSet. */
var const native pointer InternalFaceFXAnimSet;
/** 
 *  Internal use.  Raw bytes of the FaceFX AnimSet. 
 *  This only stays loaded in the editor.
 */
var const native array<byte> RawFaceFXAnimSetBytes;
/** 
 *  Internal use.  Raw bytes of the FaceFX Studio mini session for this AnimSet. 
 *  This only stays loaded in the editor.
 */
var const native array<byte> RawFaceFXMiniSessionBytes;

/**
 *  Array of SoundCue objects that the FaceFXAnimSet references.
 */

var array<SoundCue> ReferencedSoundCues;

/**
 *  Internal use.  The number of errors generated during load.
 */
var int NumLoadErrors;

