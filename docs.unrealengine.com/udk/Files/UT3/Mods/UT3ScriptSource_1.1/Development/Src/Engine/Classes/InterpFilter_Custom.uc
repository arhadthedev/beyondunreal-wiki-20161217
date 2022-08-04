/** 
 * InterpFilter_Custom.uc: Filter class for filtering matinee groups.  
 * Used by the matinee editor to let users organize tracks/groups.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class InterpFilter_Custom extends InterpFilter
	native(Interpolation);



/** Which groups are included in this filter. */
var editoronly	array<InterpGroup>	GroupsToInclude;