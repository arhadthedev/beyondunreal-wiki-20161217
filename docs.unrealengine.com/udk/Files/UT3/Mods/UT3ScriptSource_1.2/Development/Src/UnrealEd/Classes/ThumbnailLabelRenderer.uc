/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * This is an abstract base class that is used to define the interface that
 * UnrealEd will use when rendering a given object's thumbnail labels. This
 * is declared as a separate object so that label rendering can be customized
 * without having to support any other interfaces
 */
class ThumbnailLabelRenderer extends Object
	abstract
	native;


