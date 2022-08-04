/**
* Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
*
* Extended version of UIList for UT3.
*/
class UTUIList extends UIList
	native(UI);

/**
 * Optional component for rendering a background image for this list.  No value given by default.
 */
var(Presentation)	editinline	const	UIComp_DrawImage		BackgroundImageComponent;

/** Whether or not this list should be able to save out to its dataprovider. */
var transient bool bAllowSaving;



/**
 * Resolves this subscriber's data store binding and publishes this subscriber's value to the appropriate data store.
 *
 * @param	out_BoundDataStores	contains the array of data stores that widgets have saved values to.  Each widget that
 *								implements this method should add its resolved data store to this array after data values have been
 *								published.  Once SaveSubscriberValue has been called on all widgets in a scene, OnCommit will be called
 *								on all data stores in this array.
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	TRUE if the value was successfully published to the data store.
 */
native virtual function bool SaveSubscriberValue( out array<UIDataStore> out_BoundDataStores, optional int BindingIndex=INDEX_NONE );

DefaultProperties
{
	// No UT lists nav up or down, so disable these events.
	Begin Object Name=WidgetEventComponent
		DisabledEventAliases.Add(NavFocusUp)
		DisabledEventAliases.Add(NavFocusDown)
	End Object

	bAllowSaving=true
}
