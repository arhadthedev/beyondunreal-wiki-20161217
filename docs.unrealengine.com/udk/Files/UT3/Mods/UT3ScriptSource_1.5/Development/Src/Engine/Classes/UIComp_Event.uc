/**
 * Provides a list of events that a widget can process.  The outer for a UIComp_Event MUST be a UIScreenObject.
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_Event extends UIComponent
	native(inherit);

/**
 * Events which should be implemented for this widget by default.  For example, a button should respond to
 * mouse clicks without requiring the designer to attach a UIEvent_ProcessClick event to every button.
 * To accomplish this, in the UIButton class's defaultproperties you would define a UIEvent_ButtonClick object
 * using a subobject definition, then add that event to the DefaultEvents array for the EventProvider of the UIButton class.
 * Since this property will almost always have values assigned in defaults (via the subobject definition for this object)
 * it isn't marked instanced (see the @note in the next comment).  Instead, these objects will be manually instanced when
 * a new widget is created.
 */
var					array<UIRoot.DefaultEventSpecification>			DefaultEvents;

/**
 * The sequence that contains the events implemented for this widget.
 *
 * @note: do not give this variable a default value, or each time a UIComp_Event object is loaded from disk,
 * StaticConstructObject (well, really InitProperties) will construct an object of this type that will be
 * immediately overwritten when the UIComp_Event object is serialized from disk.
 */
var	instanced		UISequence										EventContainer;

/**
 * The UIEvent responsible for routing input key events to kismet actions.  Created at runtime whenever input keys
 * are registered with the owning wiget.
 */
var	transient		UIEvent_ProcessInput							InputProcessor;

/** List of disabled UI event aliases that will not have their input subscribed. */
var						array<name>					DisabledEventAliases;



/**
 * Adds the input events for the specified state to the owning scene's InputEventSubscribers
 *
 * @param	InputEventOwner		the state that contains the input keys that should be registered with the scene
 * @param	PlayerIndex			the index of the player to register the input keys for
 */
native final function RegisterInputEvents( UIState InputEventOwner, int PlayerIndex );

/**
 * Removes the input events for the specified state from the owning scene's InputEventSubscribers
 *
 * @param	InputEventOwner		the state that contains the input keys that should be removed from the scene
 * @param	PlayerIndex			the index of the player to unregister input keys for
 */
native final function UnregisterInputEvents( UIState InputEventOwner, int PlayerIndex );

DefaultProperties
{
}
