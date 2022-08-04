/**
 * One animation sequence of keyframes. Contains a number of tracks of data.
 * The Outer of AnimSequence is expected to be its AnimSet.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class AnimSequence extends Object
	native(Anim)
	hidecategories(Object);

/*
 * Triggers an animation notify.  Each AnimNotifyEvent contains an AnimNotify object
 * which has its Notify method called and passed to the animation.
 */
struct native AnimNotifyEvent
{
	var()	float						Time;
	var()	editinline AnimNotify		Notify;
	var()	name						Comment;
};

/**
 * Raw keyframe data for one track.  Each array will contain either NumKey elements or 1 element.
 * One element is used as a simple compression scheme where if all keys are the same, they'll be
 * reduced to 1 key that is constant over the entire sequence.
 */
struct native RawAnimSequenceTrack
{
	/** Position keys. */
	var array<vector>	PosKeys;

	/** Rotation keys. */
	var array<quat>		RotKeys;

	/** Key times, in seconds. */
	var array<float>	KeyTimes;
};

/** Name of the animation sequence. Used in AnimNodeSequence. */
var		name									SequenceName;

/** Animation notifies, sorted by time (earliest notification first). */
var()	editinline array<AnimNotifyEvent>		Notifies;

/** Length (in seconds) of this AnimSequence if played back with a speed of 1.0. */
var		float									SequenceLength;

/** Number of raw frames in this sequence (not used by engine - just for informational purposes). */
var		int										NumFrames;

/** Number for tweaking playback rate of this animation globally. */
var()	float									RateScale;

/** 
 * if TRUE, disable interpolation between last and first frame when looping.
 */
var()	bool									bNoLoopingInterpolation;

/**
 * Raw uncompressed keyframe data.
 */
var		const  array<RawAnimSequenceTrack>		RawAnimData;

/**
 * Keyframe position data for one track.  Pos(i) occurs at Time(i).  Pos.Num() always equals Time.Num().
 */
struct native TranslationTrack
{
	var array<vector>	PosKeys;
	var array<float>	Times;
};

/**
 * Keyframe rotation data for one track.  Rot(i) occurs at Time(i).  Rot.Num() always equals Time.Num().
 */
struct native RotationTrack
{
	var array<quat>		RotKeys;
	var array<float>	Times;
};

/**
 * Translation data post keyframe reduction.  TranslationData.Num() is zero if keyframe reduction
 * has not yet been applied.
 */
var transient const array<TranslationTrack>		TranslationData;

/**
 * Rotation data post keyframe reduction.  RotationData.Num() is zero if keyframe reduction
 * has not yet been applied.
 */
var transient const array<RotationTrack>		RotationData;

/**
 * The compression scheme that was most recently used to compress this animation.
 * May be NULL.
 */
var() editinline editconst editoronly AnimationCompressionAlgorithm	CompressionScheme;

/**
 * Indicates animation data compression format.
 */
enum AnimationCompressionFormat
{
	ACF_None,
	ACF_Float96NoW,
	ACF_Fixed48NoW,
	ACF_IntervalFixed32NoW,
	ACF_Fixed32NoW,
	ACF_Float32NoW,
};

/** The compression format that was used to compress translation tracks. */
var const AnimationCompressionFormat		TranslationCompressionFormat;

/** The compression format that was used to compress rotation tracks. */
var const AnimationCompressionFormat		RotationCompressionFormat;

struct native CompressedTrack
{
	var array<byte>		ByteStream;
	var array<float>	Times;
	var float			Mins[3];
	var float			Ranges[3]; 
};

/**
 * An array of 4*NumTrack ints, arranged as follows:
 *   [0] Trans0.Offset
 *   [1] Trans0.NumKeys
 *   [2] Rot0.Offset
 *   [3] Rot0.NumKeys
 *   [4] Trans1.Offset
 *   . . .
 */
var			array<int>		CompressedTrackOffsets;

/**
 * ByteStream for compressed animation data.
 * All keys are currently stored at evenly-spaced intervals (ie no explicit key times).
 *
 * For a translation track of n keys, data is packed as n uncompressed float[3]:
 *
 * For a rotation track of n>1 keys, the first 24 bytes are reserved for compression info
 * (eg Fixed32 stores float Mins[3]; float Ranges[3]), followed by n elements of the compressed type.
 * For a rotation track of n=1 keys, the single key is packed as an FQuatFloat96NoW.
 */
var native	array<byte>		CompressedByteStream;



defaultproperties
{
	RateScale=1.0
}
