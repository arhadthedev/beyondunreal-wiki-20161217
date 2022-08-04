/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class Texture2D extends Texture
	native
	hidecategories(Object);

/**
 * A mip-map of the texture.
 */
struct native Texture2DMipMap
{
	var native TextureMipBulkData_Mirror Data{FTextureMipBulkData};	
	var native int SizeX;
	var native int SizeY;

	
};

/** The texture's mip-map data.												*/
var native const IndirectArray_Mirror Mips{TIndirectArray<FTexture2DMipMap>};

/** The width of the texture.												*/
var const int SizeX;

/** The height of the texture.												*/
var const int SizeY;

/** The format of the texture data.											*/
var const EPixelFormat Format;

/** The addressing mode to use for the X axis.								*/
var() TextureAddress AddressX;

/** The addressing mode to use for the Y axis.								*/
var() TextureAddress AddressY;

/** Whether the texture is currently streamable or not.						*/
var transient const bool						bIsStreamable;
/** Whether the current texture mip change request is pending cancelation.	*/
var transient const bool						bHasCancelationPending;
/**
 * Whether the texture has been loaded from a persistent archive. We keep track of this in order to not stream 
 * textures that are being re-imported over as they will have a linker but won't have been serialized from disk 
 * and are therefore not streamable.
 */
var transient const bool						bHasBeenLoadedFromPersistentArchive;

/** Override whether to fully stream even if texture hasn't been rendered.	*/
var transient bool								bForceMiplevelsToBeResident;
/** Global/ serialized version of ForceMiplevelsToBeResident.				*/
var() const bool								bGlobalForceMipLevelsToBeResident;
/** If > 0 overrides texture to fully stream in. Time is decremented by streaming code. */ 
var transient float								TimeToForceMipLevelsToBeResident;

/** Name of texture file cache texture mips are stored in, NAME_None if it is not part of one. */
var		name									TextureFileCacheName;

/** Number of miplevels the texture should have resident.					*/
var transient const int							RequestedMips;
/** Number of miplevels currently resident.									*/
var transient const int							ResidentMips;
/**
 * Thread safe counter indicating status of mip change request.	The below defines are mirrored in UnTex.h.
 *
 * >=  3 == TEXTURE_STATUS_REQUEST_IN_FLIGHT	- a request has been kicked off and is in flight
 * ==  2 == TEXTURE_READY_FOR_FINALIZATION		- initial request has completed and finalization needs to be kicked off
 * ==  1 == TEXTURE_FINALIZATION_IN_PROGRESS	- finalization has been kicked off and is in progress
 * ==  0 == TEXTURE_READY_FOR_REQUESTS			- there are no pending requests/ all requests have been fulfilled
 * == -1 == TEXTURE_PENDING_INITIALIZATION		- the renderer hasn't created the resource yet
 */
var native transient const ThreadSafeCounter	PendingMipChangeRequestStatus{mutable FThreadSafeCounter};

/**
 * Mirror helper structure for linked list of texture objects. The linked list should NOT be traversed by the
 * garbage collector, which is why Element is declared as a pointer.
 */
struct TextureLinkedListMirror
{
	var native const POINTER Element;
	var native const POINTER Next;
	var native const POINTER PrevLink;
};

/** This texture's link in the global streamable texture list. */
var private{private} native const duplicatetransient noimport TextureLinkedListMirror StreamableTexturesLink{TLinkedList<UTexture2D*>};

/** 
* Keep track of the first mip level stored in the packed miptail.
* it's set to highest mip level if no there's no packed miptail 
*/
var const int MipTailBaseIdx; 

/** memory used for directly loading bulk mip data */
var private const native transient pointer		ResourceMem{FTexture2DResourceMem};
/** keep track of first mip level used for ResourceMem creation */
var private const native transient int			FirstResourceMemMip;



defaultproperties
{
}
