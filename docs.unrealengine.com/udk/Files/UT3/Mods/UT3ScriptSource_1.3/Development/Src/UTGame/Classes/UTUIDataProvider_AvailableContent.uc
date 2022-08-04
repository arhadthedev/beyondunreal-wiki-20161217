/**
 * Dataprovider that returns a row for each available content package.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_AvailableContent extends UTUIDataProvider_SimpleElementProvider
	native(UI);



/** Struct that defines a content package */
struct native AvailableContentPackage
{
	var string ContentName;
	var string ContentFriendlyName;
	var string ContentDescription;
};
var transient array<AvailableContentPackage> Packages;

/** @return Returns the number of elements(rows) provided. */
native function int GetElementCount();

/** Parses a string for downloadable content. */
native function ParseContentString(string ContentStr);

DefaultProperties
{
	
}