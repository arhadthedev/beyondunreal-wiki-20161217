/**
 * Base class of any sequence object that can be executed, such
 * as SequenceAction, SequenceCondtion, etc.
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SequenceOp extends SequenceObject
	native(Sequence)
	abstract;

;

/** Is this operation currently active? */
var bool bActive;

/** Does this op use latent execution (can it stay active multiple updates?) */
var const bool bLatentExecution;

/**
 * Represents an input link for a SequenceOp, that is
 * connected via another SequenceOp's output link.
 */
struct native SeqOpInputLink
{
	/** Text description of this link */
	// @fixme - localization
	var string LinkDesc;

	/**
	 * Indicates whether this input is ready to provide data to this sequence operation.
	 */
	var bool bHasImpulse;

	/** Is this link disabled for debugging/testing? */
	var bool bDisabled;

	/** Is this link disabled for PIE? */
	var bool bDisabledPIE;

	/** Linked action that creates this input, for Sequences */
	var SequenceOp LinkedOp;

	// Temporary for drawing! Will think of a better way to do this! - James
	var int DrawY;
	var bool bHidden;

	var float ActivateDelay;


};
var array<SeqOpInputLink>		InputLinks;

/**
 * Individual output link entry, for linking an output link
 * to an input link on another operation.
 */
struct native SeqOpOutputInputLink
{
	/** SequenceOp this is linked to */
	var SequenceOp LinkedOp;

	/** Index to LinkedOp's InputLinks array that this is linked to */
	var int InputLinkIdx;
};

/**
 * Actual output link for a SequenceOp, containing connection
 * information to multiple InputLinks in other SequenceOps.
 */
struct native SeqOpOutputLink
{
	/** List of actual connections for this output */
	var array<SeqOpOutputInputLink> Links;

	/** Text description of this link */
	// @fixme - localization
	var string					LinkDesc;

	/**
	 * Indicates whether this link is pending activation.  If true, the SequenceOps attached to this
	 * link will be activated the next time the sequence is ticked
	 */
	var bool					bHasImpulse;

	/** Is this link disabled for debugging/testing? */
	var bool					bDisabled;

	/** Is this link disabled for PIE? */
	var bool					bDisabledPIE;

	/** Linked op that creates this output, for Sequences */
	var SequenceOp				LinkedOp;

	/** Delay applied before activating this output */
	var float					ActivateDelay;

	// Temporary for drawing! Will think of a better way to do this! - James
	var int						DrawY;
	var bool					bHidden;


};
var array<SeqOpOutputLink>		OutputLinks;

/**
 * Represents a variable linked to the operation for manipulation upon
 * activation.
 */
struct native SeqVarLink
{
	/** Class of variable that can be attached to this connector. */
	var class<SequenceVariable>	ExpectedType;

	/** SequenceVariables that we are linked to. */
	var array<SequenceVariable>	LinkedVariables;

	/** Text description of this variable's use with this op */
	// @fixme - localization
	var string					LinkDesc;

	/** Name of the linked external variable that creates this link, for sub-Sequences */
	var Name	LinkVar;

	/** Name of the property this variable is associated with */
	var Name	PropertyName;

	/** Is this variable written to by this op? */
	var bool	bWriteable;

	/** Should draw this connector in Kismet. */
	var bool	bHidden;

	/** Minimum number of variables that should be attached to this connector. */
	var int		MinVars;

	/** Maximum number of variables that should be attached to this connector. */
	var int		MaxVars;

	/** For drawing. */
	var int		DrawX;

	/** Cached property ref */
	var const	transient	Property	CachedProperty;



structdefaultproperties
{
	ExpectedType=class'Engine.SequenceVariable'
	MinVars = 1
	MaxVars = 255
}
};

/** All variables used by this operation, both input/output. */
var array<SeqVarLink>			VariableLinks;

/**
 * Represents an event linked to the operation, similar to a variable link.  Necessary
 * only since SequenceEvent does not derive from SequenceVariable.
 * @todo native interfaces - could be avoided by using interfaces, but requires support for native interfaces
 */
struct native SeqEventLink
{
	var class<SequenceEvent>	ExpectedType;
	var array<SequenceEvent>	LinkedEvents;
	// @fixme - localization
	var string					LinkDesc;

	// Temporary for drawing! - James
	var int						DrawX;
	var bool					bHidden;

	structdefaultproperties
	{
		ExpectedType=class'Engine.SequenceEvent'
	}
};
var array<SeqEventLink>			EventLinks;

/**
 * The index [into the Engine.GamePlayers array] for the player that this action is associated with.  Currently only used in UI sequences.
 */
var	transient	noimport int	PlayerIndex;

/** Number of times that this Op has had Activate called on it. Used for finding often-hit ops and optimising levels. */
var transient int				ActivateCount;

/** indicates whether all output links should be activated when this op has finished executing */
var				bool			bAutoActivateOutputLinks;

/** used when searching for objects to avoid unnecessary recursion */
var transient duplicatetransient const protected{protected} int SearchTag;

/**
 * Determines whether this sequence op is linked to any other sequence ops through its variable, output, event or (optionally)
 * its input links.
 *
 * @param	bConsiderInputLinks		specify TRUE to check this sequence ops InputLinks array for linked ops as well
 *
 * @return	TRUE if this sequence op is linked to at least one other sequence op.
 */
native final function bool HasLinkedOps( optional bool bConsiderInputLinks ) const;

/**
 * Gets all SequenceObjects that are contained by this SequenceObject.
 *
 * @param	out_Objects		will be filled with all ops that are linked to this op via
 *							the VariableLinks, OutputLinks, or InputLinks arrays. This array is NOT cleared first.
 * @param	ObjectType		if specified, only objects of this class (or derived) will
 *							be added to the output array.
 * @param	bRecurse		if TRUE, recurse into linked ops and add their linked ops to
 *							the output array, recursively.
 */
native final function GetLinkedObjects( out array<SequenceObject> out_Objects, optional class<SequenceObject> ObjectType, optional bool bRecurse );

/**
 * Returns all the objects linked via SeqVar_Object, optionally specifying the
 * link to filter by.
 * @fixme - localization
 */
native noexport final function GetObjectVars(out array<Object> objVars,optional string inDesc);
// @fixme - localization
native noexport final function GetBoolVars(out array<BYTE> boolVars,optional string inDesc);

/** returns all linked variables that are of the specified class or a subclass
 * @param VarClass the class of variable to return
 * @param OutVariable (out) the returned variable for each iteration
 * @param InDesc (optional) if specified, only variables connected to the link with the given description are returned
 @fixme - localization
 */
native noexport final iterator function LinkedVariables(class<SequenceVariable> VarClass, out SequenceVariable OutVariable, optional string InDesc);

/**
 * Called when this event is activated.
 */
event Activated();

/**
 * Called when this event is deactivated.
 */
event Deactivated();

/**
 * Copies the values from member variables contained by this sequence op into any VariableLinks attached to that member variable.
 */
native final virtual function PopulateLinkedVariableValues();	// ApplyPropertiesToVariables

/**
 * Copies the values from all VariableLinks to the member variable [of this sequence op] associated with that VariableLink.
 */
native final virtual function PublishLinkedVariableValues();	// ApplyVariablesToProperties

/* Reset() - reset to initial state - used when restarting level without reloading */
function Reset();

/** utility to try to get a Pawn out of the given Actor (tries looking for a Controller if necessary) */
function Pawn GetPawn(Actor TheActor)
{
	local Pawn P;
	local Controller C;

	P = Pawn(TheActor);
	if (P != None)
	{
		return P;
	}
	else
	{
		C = Controller(TheActor);
		return (C != None) ? C.Pawn : None;
	}
}

/** utility to try to get a Controller out of the given Actor (tries looking for a Pawn if necessary) */
function Controller GetController(Actor TheActor)
{
	local Pawn P;
	local Controller C;

	C = Controller(TheActor);
	if (C != None)
	{
		return C;
	}
	else
	{
		P = Pawn(TheActor);
		return (P != None) ? P.Controller : None;
	}
}

defaultproperties
{
    // define the base input link required for this op to be activated
	InputLinks(0)=(LinkDesc="In")
	// define the base output link that this action generates (always assumed to generate at least a single output)
	OutputLinks(0)=(LinkDesc="Out")

	bAutoActivateOutputLinks=true

	PlayerIndex=-1
}
