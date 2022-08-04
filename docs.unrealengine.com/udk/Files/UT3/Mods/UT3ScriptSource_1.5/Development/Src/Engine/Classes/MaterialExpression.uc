/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpression extends Object within Material
	native
	abstract;

struct ExpressionInput
{
	var MaterialExpression	Expression;
	var int					Mask,
							MaskR,
							MaskG,
							MaskB,
							MaskA;
	var int					GCC64_Padding; // @todo 64: if the C++ didn't mismirror this structure (with MaterialInput), we might not need this
};

var int		EditorX,
			EditorY;

/** If TRUE, an preview of the expression is generated in realtime in the material editor. */
var() bool					bRealtimePreview;

/** Indicates that this is a 'parameter' type of expression and should always be loaded (ie not cooked away) because we might want the default parameter. */
var bool					bIsParameterExpression;

/** A reference to the compound expression this material expression belongs to. */
var const MaterialExpressionCompound	Compound;

/** A description that level designers can add (shows in the material editor UI). */
var() string				Desc;


