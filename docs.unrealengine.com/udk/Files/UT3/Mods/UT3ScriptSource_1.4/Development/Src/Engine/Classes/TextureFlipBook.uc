/**
 * TextureFlipBook
 * FlipBook texture support base class.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class TextureFlipBook extends Texture2D
	native
	hidecategories(Object)
	inherits(FTickableObject);

// TextureFlipBook

/** Time into the movie in seconds.																*/
var				const	transient	float				TimeIntoMovie;
/** Time that has passed since the last frame. Will be adjusted by decoder to combat drift.		*/
var				const	transient	float				TimeSinceLastFrame;

/** The horizontal scale factor																	*/
var				const	transient	float				HorizontalScale;
/** The vertical scale factor																	*/
var				const	transient	float				VerticalScale;

/** Whether the movie is currently paused.														*/
var				const				bool				bPaused;
/** Whether the movie is currently stopped.														*/
var				const				bool				bStopped;
/** Whether the movie should loop when it reaches the end.										*/
var(FlipBook)						bool				bLooping;
/** Whether the movie should automatically start playing when it is loaded.						*/
var(FlipBook)						bool				bAutoPlay;

/** The horizontal and vertical sub-image count													*/
var(FlipBook)						int					HorizontalImages;
var(FlipBook)						int					VerticalImages;

/** FlipBookMethod
 *
 * This defines the order by which the images should be 'flipped through'
 *	TFBM_UL_ROW		Start upper-left, go across to the the right, go to
 *				    the next row down left-most and repeat.
 *	TFBM_UL_COL		Start upper-left, go down to the bottom, pop to the
 *					top of the next column to the right and repeat.
 *	TFBM_UR_ROW		Start upper-right, go across to the the left, go to
 *				    the next row down right-most and repeat.
 *	TFBM_UR_COL		Start upper-right, go down to the bottom, pop to the
 *					top of the next column to the left and repeat.
 *	TFBM_LL_ROW		Start lower-left, go across to the the right, go to
 *				    the next row up left-most and repeat.
 *	TFBM_LL_COL		Start lower-left, go up to the top, pop to the
 *					bottom of the next column to the right and repeat.
 *	TFBM_LR_ROW		Start lower-right, go across to the the left, go to
 *				    the next row up left-most and repeat.
 *	TFBM_LR_COL		Start lower-right, go up to the top, pop to the
 *					bottom of the next column to the left and repeat.
 *	TFBM_RANDOM		Randomly select the next image
 *
 */
enum TextureFlipBookMethod
{
 	TFBM_UL_ROW,
 	TFBM_UL_COL,
 	TFBM_UR_ROW,
 	TFBM_UR_COL,
 	TFBM_LL_ROW,
 	TFBM_LL_COL,
 	TFBM_LR_ROW,
 	TFBM_LR_COL,
	TFBM_RANDOM
};
var(FlipBook)						TextureFlipBookMethod	FBMethod;

/** The time to display a single frame															*/
var(FlipBook)						float					FrameRate;
var				private				float					FrameTime;

/** The current sub-image row																	*/
var				const	transient	int						CurrentRow;
/** The current sub-image column																*/
var				const	transient	int						CurrentColumn;

/** The current sub-image row for the render-thread												*/
var				const	transient	float					RenderOffsetU;
/** The current sub-image column for the render-thread											*/
var				const	transient	float					RenderOffsetV;
/** Command fence used to shut down properly													*/
var		native	const	pointer								ReleaseResourcesFence{FRenderCommandFence};

/** Plays the movie and also unpauses.															*/
native function Play();
/** Pauses the movie.																			*/
native function Pause();
/** Stops movie playback.																		*/
native function Stop();
/** Sets the current frame of the 'movie'.														*/
native function SetCurrentFrame(int Row, int Col);



defaultproperties
{
	bStopped=false
	bLooping=true
	bAutoPlay=true
	FrameRate=4
	FrameTime=0.25
	CurrentRow=0
	CurrentColumn=0
	HorizontalImages=1
	VerticalImages=1
	FBMethod=TFBM_UL_ROW
	AddressX=TA_Clamp
	AddressY=TA_Clamp
}
