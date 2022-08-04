/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class Interaction extends UIRoot
	native(UserInterface)
	transient;



/**
 * Provides script-only child classes the opportunity to handle input key events received from the viewport.
 * This delegate is ONLY called when input is being routed natively from the GameViewportClient
 * (i.e. NOT when unrealscript calls the InputKey native unrealscript function on this Interaction).
 *
 * @param	ControllerId	the controller that generated this input key event
 * @param	Key				the name of the key which an event occured for (KEY_Up, KEY_Down, etc.)
 * @param	EventType		the type of event which occured (pressed, released, etc.)
 * @param	AmountDepressed	for analog keys, the depression percent.
 * @param	bGamepad		input came from gamepad (ie xbox controller)
 *
 * @return	return TRUE to indicate that the input event was handled.  if the return value is TRUE, the input event will not
 *			be processed by this Interaction's native code.
 */
delegate bool OnReceivedNativeInputKey( int ControllerId, name Key, EInputEvent EventType, optional float AmountDepressed=1.f, optional bool bGamepad );

/**
 * Provides script-only child classes the opportunity to handle input axis events received from the viewport.
 * This delegate is ONLY called when input is being routed natively from the GameViewportClient
 * (i.e. NOT when unrealscript calls the InputKey native unrealscript function on this Interaction).
 *
 * @param	ControllerId	the controller that generated this input axis event
 * @param	Key				the name of the axis that moved  (KEY_MouseX, KEY_XboxTypeS_LeftX, etc.)
 * @param	Delta			the movement delta for the axis
 * @param	DeltaTime		the time (in seconds) since the last axis update.
 * @param	bGamepad		input came from gamepad (ie xbox controller)
 *
 * @return	return TRUE to indicate that the input event was handled.  if the return value is TRUE, the input event will not
 *			be processed by this Interaction's native code.
 */
delegate bool OnReceivedNativeInputAxis( int ControllerId, name Key, float Delta, float DeltaTime, optional bool bGamepad );

/**
 * Provides script-only child classes the opportunity to handle character input (typing) events received from the viewport.
 * This delegate is ONLY called when input is being routed natively from the GameViewportClient
 * (i.e. NOT when unrealscript calls the InputKey native unrealscript function on this Interaction).
 *
 * @param	ControllerId	the controller that generated this character input event
 * @param	Unicode			the character that was typed
 *
 * @return	return TRUE to indicate that the input event was handled.  if the return value is TRUE, the input event will not
 *			be processed by this Interaction's native code.
 */
delegate bool OnReceivedNativeInputChar( int ControllerId, string Unicode );

/**
 * Called once a frame to update the interaction's state.
 * @param	DeltaTime - The time since the last frame.
 */
event Tick(float DeltaTime);

/**
 * Called once a frame to allow the interaction to draw to the canvas
 * @param Canvas Canvas object to draw to
 */
event PostRender(Canvas Canvas);

/**
 * Called when the interaction is added to the GlobalInteractions array.
 */
native final noexport function Init();

/**
 * Called from native Init() after native initialization has been performed.
 */
delegate OnInitialize();

/**
 * default handler for OnInitialize delegate.  Here so that child classes can override the default behavior easily
 */
function Initialized();

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded();

/**
 * Called when a new player has been added to the list of active players (i.e. split-screen join)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was inserted
 * @param	AddedPlayer		the player that was added
 */
function NotifyPlayerAdded( int PlayerIndex, LocalPlayer AddedPlayer );

/**
 * Called when a player has been removed from the list of active players (i.e. split-screen players)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was located
 * @param	RemovedPlayer	the player that was removed
 */
function NotifyPlayerRemoved( int PlayerIndex, LocalPlayer RemovedPlayer );

defaultproperties
{
	OnInitialize=Initialized
}
