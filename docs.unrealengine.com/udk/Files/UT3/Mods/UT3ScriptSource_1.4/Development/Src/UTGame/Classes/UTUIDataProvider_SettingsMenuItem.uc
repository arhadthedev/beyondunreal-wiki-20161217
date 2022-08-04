/**
 * Provides menu items for the settings menu.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_SettingsMenuItem extends UTUIResourceDataProvider
	native(UI)
	PerObjectConfig;



/** Friendly displayable name to the player. */
var localized string FriendlyName;

/** Localized description of the map */
var localized string Description;

/** Only valid for front-end menus - will be hidden ingame */
var	config bool	bFrontEndOnly;

