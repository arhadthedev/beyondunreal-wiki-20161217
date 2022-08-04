/**
 * Copyright 2004-2006 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionStaticComponentMaskParameter extends MaterialExpressionParameter
	native(Material)
	collapsecategories
	hidecategories(Object);

var() name			ParameterName;
var ExpressionInput	Input;
var() bool	DefaultR,
			DefaultG,
			DefaultB,
			DefaultA;

//the override that will be set when this expression is being compiled from a static permutation
var const native transient pointer InstanceOverride{const FStaticComponentMaskParameter};



