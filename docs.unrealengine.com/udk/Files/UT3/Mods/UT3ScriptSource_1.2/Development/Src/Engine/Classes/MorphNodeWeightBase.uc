/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class MorphNodeWeightBase extends MorphNodeBase
	native(Anim)
	hidecategories(Object)
	abstract;


 
struct native MorphNodeConn
{
	/** Array of nodes attached to this connector. */
	var		array<MorphNodeBase>	ChildNodes;
	
	/** Name of this connector. */
	var		name					ConnName;
	
	/** Used in editor to draw line to this connector. */
	var		int						DrawY;
};
 
/** Array of connectors to which you can connect other MorphNodes. */
var		array<MorphNodeConn>	NodeConns;
