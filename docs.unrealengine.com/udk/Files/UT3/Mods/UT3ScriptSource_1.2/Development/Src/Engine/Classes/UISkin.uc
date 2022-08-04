/**
 * Represents a collection of UIStyles.
 * <p>
 * When a style is created, it is assigned a persistent STYLE_ID.  All styles for a particular widget are stored in a single
 * unreal package file.  The root object for this package is a UISkin object.  The resources required by the style
 * may also be stored in the skin file, or they might be located in another package.
 * <p>
 * A game UI is required to have at least one UISkin package that will serve as the default skin.  Only one
 * UISkin can be active at a time, and all custom UISkins are based on the default UISkin.  Custom UISkins may decide to
 * override a style completely by creating a new style that has the same STYLE_ID as the skin to be replaced, and placing
 * that skin into the StyleLookupTable under that STYLE_ID.  Any styles which aren't specifically overridden in the custom
 * UISkin are inherited from the default skin.
 *
 * By default, widgets will automatically be mapped to the customized version of the UIStyle contained in the custom
 * UISkin, but the user may choose to assign a completely different style to a particular widget.  This only changes
 * the style of that widget for that skin set and any UISkin that is based on the custom UISkin.  Custom UISkins can be
 * hierarchical, in that custom UISkins can be based on other custom UISkins.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UISkin extends UIDataStore
	native(inherit)
	nontransient;

/**
 * Associates an arbitrary
 */
struct native UISoundCue
{
	/**
	 * the name for this UISoundCue.  this name is used by widgets to reference this sound, and must match
	 * one of the values from the GameUISceneCient's list of available sound cue names
	 */
	var		name		SoundName;

	/** the actual sound that should be played */
	var		SoundCue	SoundToPlay;


};

//@todo - need a localized friendly name here

/** the styles stored in this UISkin */
var		const 	instanced	protected{protected}	array<UIStyle>					Styles;

/**
 * The group names used by the styles in the skin package
 */
var		const 				protected{protected}	array<string>					StyleGroups;

/** the UI sound cues contained in this UISkin */
var		const				protected{protected}	array<UISoundCue>				SoundCues;

/**
 * maps STYLE_ID to the UIStyle that corresonds to that STYLE_ID.  Used for quickly finding a UIStyle
 * based on a STYLE_ID.  Built at runtime as the UISkin serializes its list of styles
 */
var		const	native	transient			Map{struct FSTYLE_ID,class UUIStyle*}	StyleLookupTable;

/**
 * Maps StyleTag to the UIStyle that has that tag.  Used for quickly finding a UIStyle based on a style tag.
 * Built at runtime as the UISkin serializes its list of styles.
 */
var		const	native	transient			Map{FName,class UUIStyle*}				StyleNameMap;

/**
 * Contains the style group names for this style and all parent styles.
 */
var		const	native	transient			Map_Mirror								StyleGroupMap{TLookupMap<FString>};

/**
 * The cursors contained by this skin.  Maps a unique tag (i.e. Arrow) to a cursor resource.
 */
var		const	native	duplicatetransient	Map{FName,struct FUIMouseCursor}		CursorMap;

/**
 * Maps UI sound cue names to their corresponding sound cues.  Used for quick lookup of USoundCues based on the UI sound cue name.
 * Built at runtime from the SoundCues array.
 */
var		const	native	transient			Map{FName,class USoundCue*}				SoundCueMap;



/* == Natives == */

/**
 * Retrieve the list of styles available from this skin.
 *
 * @param	out_Styles					filled with the styles available from this UISkin, including styles contained by parent skins.
 * @param	bIncludeInheritedStyles		if TRUE, out_Styles will also contain styles inherited from parent styles which
 *										aren't explicitely overridden in this skin
 */
native final function GetAvailableStyles( out array<UIStyle> out_Styles, optional bool bIncludeInheritedStyles=true );

/**
 * Looks up the cursor resource associated with the specified name in this skin's CursorMap.
 *
 * @param	CursorName	the name of the cursor to retrieve.
 *
 * @return	a pointer to an instance of the resource associated with the cursor name specified, or NULL if no cursors
 *			exist that are using that name
 */
native final function UITexture	GetCursorResource( name CursorName );

/**
 * Adds a new sound cue mapping to this skin's list of UI sound cues.
 *
 * @param	SoundCueName	the name to use for this UISoundCue.  should correspond to one of the values of the UIInteraction.SoundCueNames array.
 * @param	SoundToPlay		the sound cue that should be associated with this name; NULL values are OK.
 *
 * @return	TRUE if the sound mapping was successfully added to this skin; FALSE if the specified name was invalid or wasn't found in the UIInteraction's
 *			array of available sound cue names.
 */
native final function bool AddUISoundCue( name SoundCueName, SoundCue SoundToPlay );

/**
 * Removes the specified sound cue name from this skin's list of UISoundCues
 *
 * @param	SoundCueName	the name of the UISoundCue to remove.  should correspond to one of the values of the UIInteraction.SoundCueNames array.
 *
 * @return	TRUE if the sound mapping was successfully removed from this skin or this skin didn't contain any sound cues using that name;
 */
native final function bool RemoveUISoundCue( name SoundCueName );

/**
 * Retrieves the SoundCue associated with the specified UISoundCue name.
 *
 * @param	SoundCueName	the name of the sound cue to find.  should correspond to the SoundName for a UISoundCue contained by this skin
 * @param	out_UISoundCue	will receive the value for the sound cue associated with the sound cue name specified; might be NULL if there
 *							is no actual sound cue associated with the sound cue name specified, or if this skin doesn't contain a sound cue
 *							using that name (use the return value to determine which of these is the case)
 *
 * @return	TRUE if this skin contains a UISoundCue that is using the sound cue name specified, even if that sound cue name is not assigned to
 *			a sound cue object; FALSE if this skin doesn't contain a UISoundCue using the specified name.
 */
native final function bool GetUISoundCue( name SoundCueName, out SoundCue out_UISoundCue );

/**
 * Retrieves the list of UISoundCues contained by this UISkin.
 */
native final function GetSkinSoundCues( out array<UISoundCue> out_SoundCues );

/**
 * @return	TRUE if the specified group name exists and was inherited from this skin's base skin; FALSE if the group name
 *			doesn't exist or belongs to this skin.
 */
native final function bool IsInheritedGroupName( string StyleGroupName ) const;

/**
 * Adds a new style group to this skin.
 *
 * @param	StyleGroupName	the style group name to add
 *
 * @return	TRUE if the group name was successfully added.
 */
native final function bool AddStyleGroupName( string StyleGroupName );

/**
 * Removes a style group name from this skin.
 *
 * @param	StyleGroupName	the group name to remove
 *
 * @return	TRUE if this style group was successfully removed from this skin.
 */
native final function bool RemoveStyleGroupName( string StyleGroupName );

/**
 * Renames a style group in this skin.
 *
 * @param	OldStyleGroupName	the style group to rename
 * @param	NewStyleGroupName	the new name to use for the style group
 *
 * @return	TRUE if the style group was successfully renamed; FALSE if it wasn't found or couldn't be renamed.
 */
native final function bool RenameStyleGroup( string OldStyleGroupName, string NewStyleGroupName );

/**
 * Gets the group name at the specified index
 *
 * @param	Index	the index [into the skin's StyleGroupMap] of the style to get
 *
 * @return	the group name at the specified index, or an empty string if the index is invalid.
 */
native final function string GetStyleGroupAtIndex( int Index ) const;

/**
 * Finds the index for the specified group name.
 *
 * @param	StyleGroupName	the group name to find
 *
 * @return	the index [into the skin's StyleGroupMap] for the specified style group, or INDEX_NONE if it wasn't found.
 */
native final function int FindStyleGroupIndex( string StyleGroupName ) const;

/**
 * Retrieves the full list of style group names.
 *
 * @param	StyleGroupArray	recieves the array of group names
 * @param	bIncludeInheritedGroupNames		specify FALSE to exclude group names inherited from base skins.
 */
native final function GetStyleGroups( out array<string> StyleGroupArray, optional bool bIncludeInheritedGroups=true ) const;

DefaultProperties
{
	Tag=Styles
}
