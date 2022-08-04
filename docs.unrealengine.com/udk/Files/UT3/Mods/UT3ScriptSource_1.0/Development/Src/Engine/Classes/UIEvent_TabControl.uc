/**
 * Base class for all events activated by a UITabControl, UITabButton, or UITabPage.
 *
 * For this event class and its children, the EventActivator is the TabPage which generated this event.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UIEvent_TabControl extends UIEvent
	native(inherit)
	abstract;



/** the tab control that contained the page which generated this event */
var		UITabControl		OwnerTabControl;

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	if ( TargetObject == None )
	{
		return true;
	}

	if ( UITabControl(TargetObject) != None || TargetObject.ContainsChildOfClass(class'UITabControl') )
	{
		return true;
	}

	if ( UITabButton(TargetObject) != None || UITabPage(TargetObject) != None )
	{
		return true;
	}

	return false;
}

DefaultProperties
{
	ObjName="Tab Control Event"
	ObjCategory="Tab Control"

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Tab Page",bWriteable=true)
	VariableLinks.Add((ExpectedType=class'SeqVar_Object',LinkDesc="Owner Tab Control",PropertyName=OwnerTabControl,bWriteable=true,bHidden=true))
}
