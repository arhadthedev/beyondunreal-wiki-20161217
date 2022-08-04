/**
 *	AnimNodeEditInfo
 *	Allows you to register extra editor functionality for a specific AnimNode class.
 *	One of each class of these will be instanced for each AnimTreeEditor context.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class AnimNodeEditInfo extends Object
	native
	abstract;
	
var		const class<AnimNode>		AnimNodeClass;

