/**
 * Base class for data providers which provide data for static game resources.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIResourceDataProvider extends UIPropertyDataProvider
	native(inherit)
	implements(UIListElementCellProvider)
	abstract;



/**
 * Allows a resource data provider instance to indicate that it should be unselectable in subscribed lists
 *
 * @return	FALSE to indicate that list elements which represent this data provider should be considered unselectable
 *			or otherwise disabled (though it will still appear in the list).
 */
event bool IsProviderDisabled();

DefaultProperties
{
}
