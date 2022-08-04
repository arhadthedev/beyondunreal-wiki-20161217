/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * A compound material expression representing several material expressions collapsed
 * into one node.  An editor-only concept; this node does not generate shader code.
 */
class MaterialExpressionCompound extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** Array of material expressions encapsulated by this node. */
var const array<MaterialExpression>		MaterialExpressions;

/** Textual descrption for this compound expression; appears in the expression title. */
var() string							Caption;

/** IF TRUE, the nodes encapsulated by compound expression are drawn in the material editor. */
var() bool								bExpanded;
 

