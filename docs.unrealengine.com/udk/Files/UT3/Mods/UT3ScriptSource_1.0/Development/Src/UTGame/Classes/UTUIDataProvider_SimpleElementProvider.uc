/**
 * Dataprovider that provides a base implementation for a simple list element providers.  Needs to be subclassed to work completely.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIDataProvider_SimpleElementProvider extends UIDataProvider
	native(UI)
	implements(UIListElementCellProvider);



/** @return Returns the number of elements(rows) provided. */
native function int GetElementCount();
