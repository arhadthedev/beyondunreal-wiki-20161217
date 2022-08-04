class SeqVar_Named extends SequenceVariable
	hidecategories(SequenceVariable)
	native(Sequence);

/**
 *	This is a special type of variable that can be used to connect to a variable anywhere in the level sequence.
 *	When play begins, it will search up parent sequences to find a variable of the corresponding type whose name matches FindVarName and connect to it.
 *	This makes it easy to have one instance of a variable that is used in many places throughout sequences without complex wiring through many layers.
 *	Similar to a global variable in C++.
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */



/** Class that this variable will act as. Set automaticall when connected to a SequenceOp variable connector. */
var class<SequenceVariable> ExpectedType;

/** Will search entire level's sequences (ie all subsequences) to find a variable whos VarName matches FindVarName. */
var() Name	FindVarName;

/** For use in Kismet, to indicate if this variable is ok. Updated in UpdateStatus. */
var	bool	bStatusIsOk;

defaultproperties
{
	ObjName="Named Variable"
}
