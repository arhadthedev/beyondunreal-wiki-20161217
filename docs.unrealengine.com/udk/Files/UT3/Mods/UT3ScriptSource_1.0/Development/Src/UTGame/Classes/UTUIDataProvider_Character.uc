/**
 * Provides data for a UT3 customizable character.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIDataProvider_Character extends UIDataProvider
	native(UI)
	implements(UIListElementCellProvider);



var	CharacterInfo	CustomData;

/** @return Returns whether or not this provider should be filtered, by default it checks the platform flags. */
function native virtual bool IsFiltered();

defaultproperties
{

}
