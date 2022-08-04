/**
 * This class manages the UI editor windows.  It's responsible for initializing scenes when they are loaded/created and
 * managing the root scene client for all ui editors.
 * Created by the UIScene generic browser type and stored in the BrowserManager.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UISceneManager extends Object
	native
	transient
	config(Editor)
	inherits(FGlobalDataStoreClientManager,FExec,FCallbackEventDevice);

struct native transient UIResourceInfo
{
	/** pointer to an archetype for a UI resource, such as a widget, style, or state */
	var Object UIResource;

	/** the text that will be displayed in all menus and dialogs for this resource */
	var string FriendlyName;


};

struct native transient UIObjectResourceInfo extends UIResourceInfo
{

};

struct native transient UIStyleResourceInfo extends UIResourceInfo
{

};

struct native transient UIStateResourceInfo extends UIResourceInfo
{

};

struct native UIObjectToolbarMapping
{
	/** Name of the widget class to represent */
	var String WidgetClassName;

	/** Icon for the toolbar button */
	var String IconName;

	/** Tooltip for the toolbar button (Should be a localizable lookup) */
	var String Tooltip;

	/** Status bar text for the toolbar button (Should be a localizable lookup) */
	var String HelpText;
};

struct native UITitleRegions
{
	var float	RecommendedPercentage;
	var float	MaxPercentage;
};

/**
 * The UISkin currently providing styles to the scenes in the editor. Only one UISkin can be active at a time.
 */
var	transient 								UISkin								ActiveSkin;

/**
 * Manages all persistent global data stores.  Created when the UISceneManager is initialized.
 */
var	const transient							DataStoreClient						DataStoreManager;

/**
 * Holds an array of scene clients, which correspond to each scene that's been opened or created during this editing session.
 * Scene clients are not removed or deleted when their scene is closed
 */
var const transient 						array<EditorUISceneClient>			SceneClients;

/**
 * The list of placeable widgets types. Used to fill the various "add new widget" menus.  Built when the UISceneManager is initialized.
 */
var const transient							array<UIObjectResourceInfo>			UIWidgetResources;

/**
 * A list of mappings from widgets to information needed by the editor to display toolbar buttons corresponding to widgets. */
var const config							array<UIObjectToolbarMapping>		UIWidgetToolbarMaps;

/**
 * the list of useable UIStyle resources. Built when UISceneManager is initialized.
 */
var const transient							array<UIStyleResourceInfo>			UIStyleResources;

/**
 * the list of useable UIState resources.  Build when UISceneManager is initialized.
 */
var const transient	private{private}		array<UIStateResourceInfo>			UIStateResources;


/**
 * Quick lookup for friendly names for UIState resources.  Built when UISceneManager is initialized.
 */
var const transient							map{UClass*, FUIStateResourceInfo*}	UIStateResourceInfoMap;

/**
 * Variable that stores the max/recommended safe regions for the screen.
 */
var const config							UITitleRegions						TitleRegions;

/**
 * A pointer to the instance of WxDlgUIDataStoreBrowser
 */
var	transient	native	const private{private}	pointer							DlgUIDataStoreBrowser{class WxDlgUIDataStoreBrowser};



/**
 * Retrieves the list of UIStates which are supported by the specified widget.
 *
 * @param	out_SupportedStates		the list of UIStates supported by the specified widget class.
 * @param	WidgetClass				if specified, only those states supported by this class will be returned.  If not
 *									specified, all states will be returned.
 */
native final function GetSupportedUIStates( out array<UIStateResourceInfo> out_SupportedStates, optional class<UIScreenObject> WidgetClass ) const;

DefaultProperties
{

}
