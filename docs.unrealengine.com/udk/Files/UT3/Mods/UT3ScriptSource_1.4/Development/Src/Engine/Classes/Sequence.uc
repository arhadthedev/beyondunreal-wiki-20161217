/**
 * Container object for all sequence objects, also responsible
 * for execution of objects.  Can contain nested Sequence objects
 * as well.
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class Sequence extends SequenceOp
	native(Sequence);

;

/** Dedicated file log for tracking all script execution */
var const pointer LogFile;

/** List of all scripting objects contained in this sequence */
var const export array<SequenceObject> SequenceObjects;

/** List of all currently active sequence objects (events, latent actions, etc) */
var const array<SequenceOp> ActiveSequenceOps;

/**
 *	List of any nested sequences, to recursively execute in UpdateOp
 *	Do not rely on this in the editor - it is really built and accuracte only when play begins.
 */
var transient const array<Sequence> NestedSequences;

/** List of events that failed to register on first pass */
var const array<SequenceEvent> UnregisteredEvents;

/**
 * Used to save an op to activate and the impulse index.
 */
struct native ActivateOp
{
	/** the sequecne op that last activated the sequence op referenced by 'Op' */
	var	SequenceOp	ActivatorOp;
	/** Op pending activation */
	var SequenceOp Op;
	/** Input link idx to activate on Op */
	var int InputIdx;
	/** Remaining delay (for use with DelayedActivatedOps) */
	var float RemainingDelay;
};

/** List of impulses that are currently delayed */
var const array<ActivateOp> DelayedActivatedOps;

/** Is this sequence currently enabled? */
var() private{private} bool bEnabled;


/** Default position of origin when opening this sequence in Kismet. */
var	int		DefaultViewX;
var	int		DefaultViewY;
var float	DefaultViewZoom;

/**
 * Fills supplied array with all sequence objects of the specified type.
 */
native noexport final function FindSeqObjectsByClass( class<SequenceObject> DesiredClass, bool bRecursive, out array<SequenceObject> OutputObjects ) const;

/* Reset() - reset to initial state - used when restarting level without reloading */
function Reset()
{
	local int i;
	local SequenceOp Op;

	// pass to the SequenceOps we contain
	for (i = 0; i < SequenceObjects.length; i++)
	{
		Op = SequenceOp(SequenceObjects[i]);
		if (Op != None)
		{
			Op.Reset();
		}
	}
}

native final function SetEnabled(bool bInEnabled);

defaultproperties
{
	ObjName="Sequence"
	InputLinks.Empty
	OutputLinks.Empty
	VariableLinks.Empty

	DefaultViewZoom=1.0
	bEnabled=TRUE
}
