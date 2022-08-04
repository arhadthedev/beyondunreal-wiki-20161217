/**
 * This is the base class for all actions which interact with specific fields from a data provider.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIAction_DataStoreField extends UIAction_DataStore
	native(inherit)
	abstract;



/**
 * The scene to use for resolving the datastore markup in DataFieldMarkupString
 */
var()			UIScene			TargetScene;

/**
 * The data store markup string corresponding to the data field to resolve.
 */
var()			string			DataFieldMarkupString;

DefaultProperties
{
	bCallHandler=false
	bAutoActivateOutputLinks=false

	// replace the "Targets" variable link with link for selecting the scene to use for resolving the markup
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target Scene",PropertyName=TargetScene,MaxVars=1,bHidden=true)

	// add a variable link to allow designers to pipe the value of a GetDataStoreMarkup action to this action
	VariableLinks.Add((ExpectedType=class'SeqVar_String',LinkDesc="Markup String",PropertyName=DataFieldMarkupString,MaxVars=1))

	OutputLinks(0)=(LinkDesc="Failure")
}
