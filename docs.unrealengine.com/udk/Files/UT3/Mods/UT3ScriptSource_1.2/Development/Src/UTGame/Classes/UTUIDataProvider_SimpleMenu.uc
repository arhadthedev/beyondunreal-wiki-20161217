/**
 * Provides options for a simple menu in UT3.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIDataProvider_SimpleMenu extends UTUIResourceDataProvider
	native(UI)
	PerObjectConfig;



/** Field name for this menu. */
var config name FieldName;

/** Options for this menu. */
var config array<string> Options;
