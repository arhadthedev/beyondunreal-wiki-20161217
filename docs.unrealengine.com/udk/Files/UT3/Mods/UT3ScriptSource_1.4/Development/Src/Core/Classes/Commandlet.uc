﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * UnrealScript Commandlet (command-line applet) class.
 *
 * Commandlets are executed from the ucc.exe command line utility, using the
 * following syntax:
 *
 *     yourgame.exe package_name.commandlet_class_name [parm=value]...
 *
 * for example:
 *
 *     yourgame.exe Core.HelloWorldCommandlet
 *     yourgame.exe Editor.MakeCommandlet
 *
 * As a convenience, if a user tries to run a commandlet and the exact
 * name he types isn't found, then ucc.exe appends the text "commandlet"
 * onto the name and tries again.  Therefore, the following shortcuts
 * perform identically to the above:
 *
 *     yourgame.exe Core.HelloWorld
 *     yourgame.exe Editor.Make
 *
 * Commandlets are executed in a "raw" UnrealScript environment, in which
 * the game isn't loaded, the client code isn't loaded, no levels are
 * loaded, and no actors exist.
 */
class Commandlet
	extends Object
	abstract
	transient
	native;

/** Description of the commandlet's purpose */
var localized string HelpDescription;

/** Usage template to show for "ucc help" */
var localized string HelpUsage;

/** Hyperlink for more info */
var localized string HelpWebLink;

/** The name of the parameter the commandlet takes */
var localized array<string> HelpParamNames;

/** The description of the parameter */
var localized array<string> HelpParamDescriptions;

/**
 * Whether to load objects required in server, client, and editor context.  If IsEditor is set to false, then a
 * UGameEngine (or whatever the value of Engine.Engine.GameEngine is) will be created for the commandlet instead
 * of a UEditorEngine (or Engine.Engine.EditorEngine), unless the commandlet overrides the CreateCustomEngine method.
 */
var bool IsServer, IsClient, IsEditor;

/** Whether to redirect standard log to the console */
var bool LogToConsole;

/** Whether to show standard error and warning count on exit */
var bool ShowErrorCount;



/**
 * Entry point for your commandlet
 *
 * @param Params the string containing the parameters for the commandlet
 */
native event int Main( string Params );

defaultproperties
{
	IsServer=true
	IsClient=true
	IsEditor=true
	LogToConsole=false
	ShowErrorCount=true
}
