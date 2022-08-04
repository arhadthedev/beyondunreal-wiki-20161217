/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * This is a simple thumbnail label renderer that lists the object name
 * and the amount of memory used by the object. It is an example of how
 * you can use a different thumbnail label for different information
 */
class MemCountThumbnailLabelRenderer extends ThumbnailLabelRenderer
	native;

/**
 * An aggregated thumbnail label renderer component. Used when appending the
 * memory usage information to an existing label renderer's list.
 */
var ThumbnailLabelRenderer AggregatedLabelRenderer;


