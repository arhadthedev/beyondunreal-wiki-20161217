/**
 * This widget class is a container for widget archetypes.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Known issues:
 *	- copy/paste operations aren't propagated to UIPrefabInstances
 *	- [FIXED] changes to parent/child relationships aren't propagated to UIPrefabInstances, including adding/removing/reparenting
 *	- [FIXED] changes to custom input events (UUIEvent_MetaObject - WxDlgUIEvent_MetaObject) don't perform any change tracking/propagation
 *	- [FIXED] changes to PlayerInputMask don't seem to propagate correctly
 *	- need support for specifying "input alias => raw input key" mappings for widget archetypes (UIInputAliasStateMap/UIInputAliasClassMap/UIInputConfiguration)
 *	- reformatting doesn't occur for instanced UIList widgets or widgets which have UIComp_DrawString components (either when placing or updating).
 *	- modifying docking relationships using the docking editor doesn't propagate changes to instances.
 *	- most changes made through kismet editor (adding new seq. objects, removing objects, etc.) aren't propagated to instances at all
 */
class UIPrefab extends UIObject
	native(UIPrivate)
	notplaceable
	HideDropDown;



/**
 * This struct is used for various purposes to track information about a widget instance and an associated archetype.
 */
struct native transient ArchetypeInstancePair
{
	/** Holds a reference to a widget archetype */
	var	transient	UIObject	WidgetArchetype;

	/**
	 * Holds a reference to the widget instance; depending on where this struct is used, could be an instance of WidgetArchetype
	 * or might be e.g. the widget instance used to create WidgetArchetype (when creating a completely new UIPrefab).
	 */
	var transient	UIObject	WidgetInstance;

	/**
	 * Used to stores the RenderBounds of WidgetArchetype in cases where WidgetArchetype is not in the scene's children array.
	 */
	var	transient	float		ArchetypeBounds[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Used to stores the RenderBounds of WidgetInstance in cases where WidgetInstance is not in the scene's children array.
	 */
	var	transient	float		InstanceBounds[EUIWidgetFace.UIFACE_MAX];


};

/**
 * Version number for this prefab.  Each time a UIPrefab is saved, the PrefabVersion is incremented.  This number is used
 * to detect when UIPrefabInstances based on this prefab need to be updated.
 */
var					const int					PrefabVersion;

/**
 * Version number for this prefab when it was loaded from disk.  Used to determine whether a modification to a widget contained
 * in this prefab should increment the PrefabVersion (i.e. PrefabVersion should only be incremented if InternalPrefabVersion
 * matches PrefabVersion).
 */
var	private{private} const int					InternalPrefabVersion;

/** Snapshot of Prefab used for thumbnail in the browser. */
var		editoronly	const Texture2D				PrefabPreview;

/**
 * Used to track the number of calls to Pre/PostEditChange for widgets contained within this UIPrefab.  When PreEditChange
 * or PostEditChange is called on a widget contained within a UIPrefab, rather than calling the UObject version, it is
 * instead routed to the owning UIPrefab.
 *
 * When UIPrefab receives a call to PreEditChange, the UIPrefab calls SavePrefabInstances if ModificationCounter is 0, then
 * increments the counter.
 * When UIPrefab receives a call to PostEditChange, it decrements the counter and calls LoadPrefabInstances once it reaches 0.
 */
var		transient	const int					ModificationCounter;

DefaultProperties
{
}
