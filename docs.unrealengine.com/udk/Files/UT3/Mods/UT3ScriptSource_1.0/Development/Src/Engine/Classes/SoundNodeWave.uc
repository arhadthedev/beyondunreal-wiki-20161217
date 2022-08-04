/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
 
/** 
 * Sound node that contains sample data
 */
class SoundNodeWave extends SoundNode
	PerObjectConfig
	native( SoundNode )
	hidecategories( Object )
	editinlinenew;

enum EDecompressionType
{
	DTYPE_Setup,
	DTYPE_Invalid,
	DTYPE_Preview,
	DTYPE_Native,
	DTYPE_RealTime
};

enum ETTSSpeaker
{
	TTSSPEAKER_Paul,
	TTSSPEAKER_Harry,
	TTSSPEAKER_Frank,
	TTSSPEAKER_Dennis,
	TTSSPEAKER_Kit,
	TTSSPEAKER_Betty,
	TTSSPEAKER_Ursula,
	TTSSPEAKER_Rita,
	TTSSPEAKER_Wendy,
};

/** Platform agnostic compression quality. 1..100 with 1 being best compression and 100 being best quality */
var(Compression)		int								CompressionQuality<Tooltip=1 smallest size, 100 is best quality>;
/** If set, forces wave data to be decompressed during playback instead of upfront on platforms that have a choice. */
var(Compression)		bool							bForceRealtimeDecompression;

/** Whether to free the resource data after it has been uploaded to the hardware */
var		transient const bool							bDynamicResource;
/** Whether to free this resource after it has played - designed for TTS of log */
var		transient const bool							bOneTimeUse;

/** Set to true to speak SpokenText using TTS */
var(TTS)	bool										bUseTTS;
/** Speaker to use for TTS */
var(TTS)	ETTSSpeaker									TTSSpeaker;
/** A localized version of the text that is actually spoken in the audio. */
var(TTS)	localized string							SpokenText<ToolTip=The phonetic version of the dialog>;

/** Playback volume of sound 0 to 1 */
var(Info)	editconst const	float						Volume;
/** Playback pitch for sound 0.5 to 2.0 */
var(Info)	editconst const	float						Pitch;
/** Duration of sound in seconds. */
var(Info)	editconst const	float						Duration;
/** Number of channels of multichannel data; 1 or 2 for regular mono and stereo files */
var(Info)	editconst const	int							NumChannels;
/** Cached sample rate for displaying in the tools */
var(Info)	editconst const int							SampleRate;

/** Cached sample data size for tracking stats */
var			   const int								SampleDataSize;
/** Offsets into the bulk data for the source wav data */
var			   const	array<int>						ChannelOffsets;
/** Sizes of the bulk data for the source wav data */
var			   const	array<int>						ChannelSizes;
/** Uncompressed wav data 16 bit in mono or stereo - stereo not allowed for multichannel data */
var		native const	UntypedBulkData_Mirror			RawData{FByteBulkData};
/** Pointer to 16 bit PCM data - used to preview sounds */
var		native const	pointer							RawPCMData{SWORD};

/** Type of buffer this wave uses. Set once on load */
var		transient const	EDecompressionType				DecompressionType;
/** Async worker that decompresses the vorbis data on a different thread */
var		native const pointer							VorbisDecompressor{FAsyncVorbisDecompress};
/** Where the compressed vorbis data is decompressed to */
var		transient const	array<byte>						PCMData;

/** Cached ogg vorbis data. */
var		native const	UntypedBulkData_Mirror			CompressedPCData{FByteBulkData};
/** Cached cooked Xbox 360 data to speed up iteration times. */
var		native const	UntypedBulkData_Mirror			CompressedXbox360Data{FByteBulkData};
/** Cached cooked PS3 data to speed up iteration times. */
var		native const	UntypedBulkData_Mirror			CompressedPS3Data{FByteBulkData};

/** Resource index to cross reference with buffers */
var		transient const int								ResourceID;
/** Size of resource copied from the bulk data */
var		transient const int								ResourceSize;
/** Memory containing the data copied from the compressed bulk data */
var		native const pointer							ResourceData{void};

/**
 * A line of subtitle text and the time at which it should be displayed.
 */
struct native SubtitleCue
{
	/** The text too appear in the subtitle. */
	var() localized string	Text;

	/** The time at which the subtitle is to be displayed, in seconds relative to the beginning of the line. */
	var() localized float	Time;
};

/**
 * Subtitle cues.  If empty, use SpokenText as the subtitle.  Will often be empty,
 * as the contents of the subtitle is commonly identical to what is spoken.
 */
var(Subtitles) localized array<SubtitleCue>				Subtitles;

/** Provides contextual information for the sound to the translator. */
var(Subtitles) localized string							Comment<ToolTip=Contextual information for the sound to the translator>;

var(Subtitles)			 bool							bAlwaysLocalise<ToolTip=Localise this sound even if there are no subtitles>;

/** TRUE if this sound is considered mature. */
var(Subtitles) localized bool							bMature<ToolTip=For marking any adult language>;

/** TRUE if the subtitles have been split manually. */
var(Subtitles) localized bool							bManualWordWrap<ToolTip=Disable automatic generation of line breaks>;

defaultproperties
{
	Volume=0.75
	Pitch=1.0
	CompressionQuality=40
}

