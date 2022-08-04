/**
 * Copyright 1998-2007 Epic Games, Inc.
 *
 * A font object, containing information about a set of glyphs.
 * The glyph bitmaps are stored in the contained textures, while
 * the font database only contains the coordinates of the individual
 * glyph.
 */
class Font extends Object
	hidecategories(object)
	dependsOn(FontImportOptions)
	native;


// This is the character that RemapChar will return if the specified character doesn't exist in the font
const NULLCHARACTER = 127;

/** this struct is serialized using binary serialization so any changes to it require a package version bump */
struct immutable native FontCharacter
{
	var() int StartU;
	var() int StartV;
	var() int USize;
	var() int VSize;
	var() editconst BYTE TextureIndex;
	var() int VerticalOffset;

	
};


/** List of characters in the font.  For a MultiFont, this will include all characters in all sub-fonts!  Thus,
    the number of characters in this array isn't necessary the number of characters available in the font */
var() editinline array<FontCharacter> Characters;

/** Textures that store this font's glyph image data */
//NOTE: Do not expose this to the editor as it has nasty crash potential
var array<Texture2D> Textures;

/** When IsRemapped is true, this array maps unicode values to entries in the Characters array */
var private const native Map{WORD,WORD} CharRemap;

/** True if font is 'remapped'.  That is, the character array is not a direct mapping to unicode values.  Instead,
    all characters are indexed indirectly through the CharRemap array */
var int IsRemapped;

/** Default horizontal spacing between characters when rendering text with this font */
var() int Kerning;

/** Options used when importing this font */
var() FontImportOptionsData ImportOptions;

/** Number of characters in the font, not including multiple instances of the same character (for multi-fonts).
    This is cached at load-time or creation time, and is never serialized. */
var transient int NumCharacters;




/**
 * Calulate the index for the texture page containing the multi-font character set to use, based on the specified screen resolution.
 *
 * @param	HeightTest	the height (in pixels) of the viewport being rendered to.
 *
 * @return	the index of the multi-font "subfont" that most closely matches the specified resolution.  this value is used
 *			as the value for "ResolutionPageIndex" when calling other font-related methods.
 */
native function int GetResolutionPageIndex(float HeightTest) const;

/**
 * Calculate the amount of scaling necessary to match the multi-font subfont which most closely matches the specified resolution.
 *
 * @param	HeightTest	the height (in pixels) of the viewport being rendered to.
 *
 * @return	the percentage scale required to match the size of the multi-font's closest matching subfont.
 */
native function float GetScalingFactor(float HeightTest) const;

/**
 * Determine the height of the mutli-font resolution page which will be used for the specified resolution.
 *
 * @param	ViewportHeight	the height (in pixels) of the viewport being rendered to.
 */
native final function virtual float GetAuthoredViewportHeight( float ViewportHeight ) const;

/**
 * @return	the height (in pixels) of the tallest character in this font.
 *
 * @param	HeightTest	the height (in pixels) of the viewport being rendered to; if not specified
 */
native function float GetMaxCharHeight() const;

