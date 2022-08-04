//=============================================================================
// Input
// Object that maps key events to key bindings
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class Input extends Interaction
	native(UserInterface)
	config(Input)
    transient;

struct native KeyBind
{
	var config name		Name;
	var config string	Command;
	var config bool		Control,
						Shift,
						Alt;

};

var config array<KeyBind>				Bindings;

/** list of keys which this interaction handled a pressed event for */
var const array<name>					PressedKeys;

var const EInputEvent					CurrentEvent;
var const float							CurrentDelta;
var const float							CurrentDeltaTime;

var native const Map{FName,void*}		NameToPtr;
var native const init array<pointer>	AxisArray{FLOAT};



/**
 * Resets this input object, flushing all pressed keys and clearing all player 'input' variables.
 */
native function ResetInput();

native function string GetBind(Name Key);

exec function SetBind(name BindName,string Command)
{
	local KeyBind	NewBind;
	local int		BindIndex;

	for(BindIndex = Bindings.Length-1;BindIndex >= 0;BindIndex--)
		if(Bindings[BindIndex].Name == BindName)
		{
			Bindings[BindIndex].Command = Command;
			SaveConfig();
			return;
		}

	NewBind.Name = BindName;
	NewBind.Command = Command;
	Bindings[Bindings.Length] = NewBind;
	SaveConfig();
}

