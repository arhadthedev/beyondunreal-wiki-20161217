/**
 * Contains a mapping of UIStyle_Data to the UIState each style is associated with.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIStyle extends UIRoot
	within UISkin
	native(UserInterface)
	PerObjectConfig;

/** Unique identifier for this style. */
var								STYLE_ID									StyleID;

/** Unique non-localized name for this style which is used to reference the style without needing to know its GUID */
var								name										StyleTag;

/** Friendly name for this style. */
var()	localized				string										StyleName;

/**
 * Group this style is assigned to.
 */
var const						string										StyleGroupName;

/** the style data class associated with this UIStyle */
var const						class<UIStyle_Data>							StyleDataClass;

/**
 * map of UIStates to style data associated with that state.
 */
var	const	native	transient	Map{class UUIState*,class UUIStyle_Data*}	StateDataMap;



/**
 * Returns the style data associated with the archetype for the UIState specified by StateObject.  If this style does not contain
 * any style data for the specified state, this style's archetype is searched, recursively.
 *
 * @param	StateObject	the UIState to search for style data for.  StateData is stored by archetype, so the StateDataMap
 *						is searched for each object in StateObject's archetype chain until a match is found or we arrive
 *						at the class default object for the state.
 *
 *
 * @return	a pointer to style data associated with the UIState specified, or NULL if there is no style data for the specified
 *			state in this style or this style's archetypes
 */
native final function UIStyle_Data GetStyleForState( UIState StateObject ) const;

/**
 * Returns the first style data object associated with an object of the class specified.  This function is not reliable
 * in that it can return different style data objects if there are multiple states of the same class in the map (i.e.
 * two archetypes of the same class)
 *
 * @param	StateClass	the class to search for style data for
 *
 * @return	a pointer to style data associated with the UIState specified, or NULL if there is no style data for the specified
 *			state in this style or this style's archetypes
 */
native final function UIStyle_Data GetStyleForStateByClass( class<UIState> StateClass ) const;

final event UIStyle_Data GetDefaultStyle()
{
	return GetStyleForStateByClass(class'UIState_Enabled');
}

DefaultProperties
{

}
