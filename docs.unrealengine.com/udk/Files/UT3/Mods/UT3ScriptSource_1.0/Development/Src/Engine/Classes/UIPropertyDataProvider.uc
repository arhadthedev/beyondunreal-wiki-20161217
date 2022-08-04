/**
 * Base class for data providers which provide data pulled directly from member UProperties.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIPropertyDataProvider extends UIDataProvider
	native(inherit)
	abstract;

/**
 * the list of property classes for which values cannot be automatically derived; if your script-only child class has a member
 * var of one of these types, you'll need to provide the value yourself via the GetCustomPropertyValue event
 */
var const	array<class<Property> >		ComplexPropertyTypes;



/**
 * Gets the value for the property specified.  Child classes only need to override this function if it contains data fields
 * which do not correspond to a member property in the class, or if the data corresponds to a complex data type, such as struct,
 * array, etc.
 *
 * @param	PropertyValue	[in] the name of the property to get the value for.
 *							[out] should be filled with the value for the specified property tag.
 * @param	ArrayIndex		optional array index for use with data collections
*
 * @return	return TRUE if either the StringValue or ImageValue fields of PropertyValue were set by script.
 */
event bool GetCustomPropertyValue( out UIProviderScriptFieldValue PropertyValue, optional int ArrayIndex=INDEX_NONE );

DefaultProperties
{
	ComplexPropertyTypes(0)=class'StructProperty'
	ComplexPropertyTypes(1)=class'MapProperty'
	ComplexPropertyTypes(2)=class'ArrayProperty'
	ComplexPropertyTypes(3)=class'DelegateProperty'
}
