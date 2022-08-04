/**
 * This class stores options global to the entire editor.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UnrealEdOptions extends Object
	Config(Editor)
	native;





/** A category to store a list of commands. */
struct native EditorCommandCategory
{
	var name Parent;
	var name Name;
};

/** A parameterless exec command that can be bound to hotkeys and menu items in the editor. */
struct native EditorCommand
{
	var name Parent;
	var name CommandName;
	var string ExecCommand;
	var string Description;
};

/** Categories of commands. */
var config array<EditorCommandCategory> EditorCategories;

/** Commands that can be bound to in the editor. */
var config array<EditorCommand> EditorCommands;

/** Pointer to the key bindings object that actually stores key bindings for the editor. */
var UnrealEdKeyBindings	EditorKeyBindings;

/** Mapping of command name's to array index. */
var native map{FName, INT}	CommandMap;

defaultproperties
{
	Begin Object Class=UnrealEdKeyBindings Name=EditorKeyBindingsInst
	End Object
	EditorKeyBindings=EditorKeyBindingsInst
}