/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class Prefab extends Object
	native(Prefab);

/** Version number of this prefab. */
var		const int						PrefabVersion;

/** Array of archetypes, one for each object in the prefab. */
var		const array<Object>				PrefabArchetypes;

/** Array of archetypes that used to be in this Prefab, but no longer are. */
var		const array<Object>				RemovedArchetypes;

/** The Kismet sequence that associated with this Prefab. */
var		const Sequence					PrefabSequence;

/** Snapshot of Prefab used for thumbnail in the browser. */
var		editoronly const Texture2D		PrefabPreview;


