/**
 * This class acts as a cosmetic container for grouping widgets in the UI editor.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UILayer extends UILayerBase
	native(Private);



/**
 * Represents a single node in the UI editor layer brower.
 */
struct native UILayerNode
{
	/**
	 * Indicates whether this layer node is active.  Locked layer nodes cannot be selected in the UI editor window
	 */
	var		const	private{private}	bool		bLocked;

	/**
	 * Indicates whether this layer node is visible.  Hidden layer nodes are not rendered in the UI editor window.
	 */
	var		const	private{private}	bool		bVisible;

	/**
	 * The object associated with this layer node.  Only UILayer and UIObject are valid.
	 */
	var		const	private{private}	Object		LayerObject;

	/**
	 * The UILayer that contains this layer node.
	 */
	var		const	private{private}	UILayer		ParentLayer;



structdefaultproperties
{
	bVisible=true
}
};

/** The designer-specified friendly name for this layer */
var		string					LayerName;

/** the child nodes of this layer */
var		array<UILayerNode>		LayerNodes;

/**
 * Inserts the specified node at the specified location
 *
 * @param	NodeToInsert	the layer node that should be inserted into this UILayer's LayerNodes array
 * @param	InsertIndex		if specified, the index where the new node should be inserted into the LayerNodes array. if not specified
 *							the new node will be appended to the end of the array.
 *
 * @return	TRUE if the node was successfully inserted into this UILayer's list of child nodes.
 */
native final function bool InsertNode( const out UILayerNode NodeToInsert, optional int InsertIndex=INDEX_NONE );

/**
 * Removes the specified node
 *
 * @param	ExistingNode	the layer node that should be removed from this UILayer's LayerNodes array
 *
 * @return	TRUE if the node was successfully removed from this UILayer's list of child nodes.
 */
native final function bool RemoveNode( const out UILayerNode ExistingNode );

/**
 * Finds the index [into the LayerNodes array] for a child node that contains the specified object as its layer object.
 *
 * @param	NodeObject	the child layer object to look for.
 *
 * @return	the index into the LayerNodes array for the child node which contains the specified object as its layer object,
 *			or INDEX_NONE if no child nodes were found that containc the specified object as its layer object.
 */
native final function int FindNodeIndex( const Object NodeObject ) const;

DefaultProperties
{

}
