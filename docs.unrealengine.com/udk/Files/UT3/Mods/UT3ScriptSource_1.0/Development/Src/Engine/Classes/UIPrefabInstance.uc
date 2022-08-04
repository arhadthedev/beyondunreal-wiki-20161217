/**
 * This widget class is a container for widgets which are instances of a UIPrefab.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIPrefabInstance extends UIObject
	native(UIPrivate)
	notplaceable
	HideDropDown;



/** The prefab that this is an instance of. */
var		const	archetype		UIPrefab				SourcePrefab;

/**
 * The version for this UIPrefabInstance.  When the value of PrefabInstanceVersion does not match the value of SourcePrefab's
 * PrefabVersion, it indicates that SourcePrefab has been updated since the last time this UIPrefabInstance was updated.
 */
var		const		int						PrefabInstanceVersion;

/**
 * Mapping from archetypes in the source prefab (TemplatePrefab) to instances of those archetypes in this PrefabInstance.
 * Should only ever contain UIScreenObject-derived objects;  Used by UpdatePrefabInstance to determine the archetypes which
 * were added to SourcePrefab since the last time this UIPrefabInstance was updated, as well as tracking which widgets have
 * been removed from this UIPrefabInstance by the user.
 *
 * This map holds references to all objects in the UIPrefab and UIPrefabInstance, including any components and subobjects.
 * A NULL key indicates that the widget was removed from the UIPrefab; the instance associated with the NULL key will be removed
 * 	from the UIPrefabInstance's list of children the next time that UpdateUIPrefabInstance is called.
 * A NULL value indicates that the user manually removed an instanced widget from the UIPrefabInstance.  When this UIPrefabInstance
 *	is updated, that widget archetype will not be re-instanced.
 */
var		const native Map{UObject*,UObject*}	ArchetypeToInstanceMap;

///** Kismet sequence that was created for this PrefabInstance. */
//var		const		Sequence				SequenceInstance;

/** Contains the epic+licensee version that this PrefabInstance's package was saved with. */
var	editoronly	const			int			PI_PackageVersion;
var	editoronly	const			int			PI_LicenseePackageVersion;

var	editoronly	const			int			PI_DataOffset;	// the offset into PI_Bytes for this UIPrefabInstance's property data
var	editoronly	const	array<byte>			PI_Bytes;
var	editoronly	const	array<object>		PI_CompleteObjects;
var	editoronly	const	array<object>		PI_ReferencedObjects;
var	editoronly	const	array<string>		PI_SavedNames;
var	const native	Map{UObject*,INT}		PI_ObjectMap;

/**
 * Converts all widgets in this UIPrefabInstance into normal widgets and removes the UIPrefabInstance from the scene.
 */
native final function DetachFromSourcePrefab();

defaultproperties
{
	// the defaults for the PrefabInstance file versions MUST be -1 (@see UUIPrefabInstance::Copy*Archive)
	PI_PackageVersion=INDEX_NONE
	PI_LicenseePackageVersion=INDEX_NONE
}

