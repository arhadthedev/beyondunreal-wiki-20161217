/**
 * Generic browser type for editing UIObject archetypes which are not contained by UI prefabs.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class GenericBrowserType_UIArchetype extends GenericBrowserType_Archetype
	native;



/**
 * Points to the UISceneManager singleton stored in the BrowserManager.
 */
var	const transient	UISceneManager				SceneManager;

DefaultProperties
{
	Description="UI Prefabs"
}
