/**
 * This datastore provides access to a list of data providers which provide data for any file which is handled by
 * the engine's config cache system, such as .ini and .int files.
 *
 * There is one ConfigFileProvider for each ini/int file, and contains a list of providers for sections in that file.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIConfigFileProvider extends UIConfigProvider
	native(inherit)
	transient;

/** the list of sections in this config file */
var				transient		array<UIConfigSectionProvider>		Sections;

/** the name of the config file associated with this data provider */
var	noexport	transient		string								ConfigFileName;



DefaultProperties
{

}
