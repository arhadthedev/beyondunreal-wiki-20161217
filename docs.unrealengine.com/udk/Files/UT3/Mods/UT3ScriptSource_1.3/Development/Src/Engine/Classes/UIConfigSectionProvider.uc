/**
 * This datastore provides access to a single section in a config/loc file.  Provides read/write access to the keys
 * stored in this section.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIConfigSectionProvider extends UIConfigProvider
	within UIConfigFileProvider
	native(inherit)
	transient;

/** the name of the section associated with this provider */
var		transient		string		SectionName;



DefaultProperties
{

}
