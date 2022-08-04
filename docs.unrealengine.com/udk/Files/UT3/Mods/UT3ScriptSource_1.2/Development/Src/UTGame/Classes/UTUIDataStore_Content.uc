/**
 * Specific derivation of UIDataStore to expose downloadable content data to the UI.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataStore_Content extends UIDataStore
	native(inherit)
	implements(UIListElementProvider)
	transient;

/** Reference to the dataprovider that will provide general stats details for a stats row. */
var transient UTUIDataProvider_InstalledContent InstalledContentProvider;

/** Reference to the dataprovider that will provide content that is available for download. */
var transient UTUIDataProvider_AvailableContent AvailableContentProvider;



/** 
 * @param FieldName		Name of the field to return the provider for.
 *
 * @return Returns a stats element provider given its field name. 
 */
event UTUIDataProvider_SimpleElementProvider GetElementProviderFromName(name FieldName)
{
	if(FieldName=='AvailableContent')
	{
		return AvailableContentProvider;
	}
	else if(FieldName=='InstalledContent')
	{
		return InstalledContentProvider;
	}

	return None;
}

defaultproperties
{
	Tag=UTContent
}