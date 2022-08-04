/**
 * Resonsible for how the data associated with this list is presented.  Updates the list's operating parameters
 * (CellHeight, CellWidth, etc.) according to the presentation type for the data contained by this list.
 *
 * Routes render messages from the list to the individual elements, adding any additional data necessary for the
 * element to understand how to render itself.  For example, a listdata component might add that the element being
 * rendered is the currently selected element, so that the element can adjust the way it renders itself accordingly.
 * For a tree-type list, the listdata component might add whether the element being drawn is currently open, has
 * children, etc.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_UTUIMenuListPresenter extends UIComp_ListPresenter
	within UIList
	native(UI)
	DependsOn(UIDataStorePublisher);



/** Size of the selected prefab item. */
var() int		SelectedItemHeight;

/** The prefab to use for the selected item. */
var() UIPrefab	SelectedItemPrefab;

/** The prefab to use for normal items. */
var() UIPrefab	NormalItemPrefab;

/** List of prefab widgets to replace with current selected item values. */
struct native PrefabMarkupReplace
{
	var() name	WidgetTag;	/** Tag of the widget we are going to replace the markup of. */
	var() name	CellTag;	/** Cell tag to use get the new value of the widget. */
};

var() array<PrefabMarkupReplace> PrefabMarkupReplaceList;

/** Struct to store info/references about the instanced prefab. */
struct native InstancedPrefabInfo
{
	var UIPrefabInstance PrefabInstance;
	var array<UIObject> ResolvedObjects;
};

/** Instances of prefabs for each of the items in the list. */
var transient array<InstancedPrefabInfo> InstancedPrefabs;

defaultproperties
{
	bDisplayColumnHeaders = false
	SelectedItemHeight = 50
}
