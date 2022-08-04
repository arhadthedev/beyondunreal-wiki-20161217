/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactory extends Object
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew
	config(Editor)
	abstract;



/** class to spawn during gameplay; only used if NewActorClass is left at the default */
var class<Actor> GameplayActorClass;

/** Name used as basis for 'New Actor' menu. */
var string			MenuName;

/** Indicates how far up the menu item should be. The higher the number, the higher up the list.*/
var config int		MenuPriority;

/** Actor subclass this ActorFactory creates. */
var	class<Actor>	NewActorClass;

/** Whether to appear on menu (or this Factory only used through scripts etc.) */
var bool			bPlaceable;

/** If this is associated with a specific game, don't display
	If this is empty string, display for all games */
var string			SpecificGameName;


defaultproperties
{
	MenuName="Add Actor"
	NewActorClass=class'Engine.Actor'
	bPlaceable=true
}
