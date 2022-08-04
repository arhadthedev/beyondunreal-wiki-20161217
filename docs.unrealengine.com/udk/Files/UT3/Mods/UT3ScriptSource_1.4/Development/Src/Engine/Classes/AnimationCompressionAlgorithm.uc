/**
 * Baseclass for animation compression algorithms.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class AnimationCompressionAlgorithm extends Object
	abstract
	native(Anim)
	hidecategories(Object);

/** A human-readable name for this modifier; appears in editor UI. */
var		string		Description;

/** Compression algorithms requiring a skeleton should set this value to TRUE. */
var		bool		bNeedsSkeleton;

/** Format for bitwise compression of translation data. */
var		AnimSequence.AnimationCompressionFormat		TranslationCompressionFormat;

/** Format for bitwise compression of rotation data. */
var()	AnimSequence.AnimationCompressionFormat		RotationCompressionFormat;



defaultproperties
{
	Description="None"
	TranslationCompressionFormat=ACF_None
	RotationCompressionFormat=ACF_Float96NoW
}
