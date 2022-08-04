/**
 * Base class for all Kismet related objects.
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SequenceObject extends Object
	native(Sequence)
	abstract
	hidecategories(Object);



/** Class vs instance version, for offering updates in the Kismet editor */
var const int ObjClassVersion, ObjInstanceVersion;

/** Sequence that contains this object */
var const noimport Sequence ParentSequence;

/** Visual position of this object within a sequence */
var		int						ObjPosX, ObjPosY;

/** Text label that describes this object */
var		string					ObjName;

/**
 * Editor category for this object.  Determines which kismet submenu this object
 * should be placed in
 */
var 	string					ObjCategory;

/** Color used to draw the object */
var		color					ObjColor;

/** User editable text comment */
var()	string					ObjComment;

/** Whether or not this object is deletable. */
var		bool					bDeletable;

/** Should this object be drawn in the first pass? */
var		bool					bDrawFirst;

/** Should this object be drawn in the last pass? */
var		bool					bDrawLast;

/** Cached drawing dimensions */
var		int						DrawWidth, DrawHeight;

/** Should this object display ObjComment when activated? */
var()	bool					bOutputObjCommentToScreen;

/** Should we suppress the 'auto' comment text - values of properties flagged with the 'autocomment' metadata string. */
var()	bool					bSuppressAutoComment;

/** Writes out the specified text to a dedicated scripting log file.
 * @param LogText the text to print
 * @param bWarning true if this is a warning message.
 * 	Warning messages are also sent to the normal game log and appear onscreen if Engine's configurable bOnScreenKismetWarnings is true
 */
native final function ScriptLog(string LogText, optional bool bWarning = true);

/** Returns the current world's WorldInfo, useful for spawning actors and such. */
native final function WorldInfo GetWorldInfo();

/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return true;
}

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return false;
}

defaultproperties
{
	bDeletable=true
	ObjClassVersion=1
	ObjName="Undefined"
	ObjColor=(R=255,G=255,B=255,A=255)
	bSuppressAutoComment=true
}
