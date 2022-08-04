/**
 * Game resource data stores provide access to available game resources, such as the available gametypes, maps, or mutators
 * The data for each type of game resource is provided through a data provider and is specified in the .ini file for that
 * data provider class type using the PerObjectConfig paradigm.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIDataStore_GameResource extends UIDataStore
	native(inherit)
	implements(UIListElementProvider)
	Config(Game);

struct native GameResourceDataProvider
{
	/** the tag that is used to access this provider, i.e. Players, Teams, etc. */
	var	config		name							ProviderTag;

	/** the name of the class associated with this data provider */
	var	config		string							ProviderClassName;

	/** the UIDataProvider class that exposes the data for this data field tag */
	var	transient	class<UIResourceDataProvider>	ProviderClass;
};

/** the list of data providers supported by this data store that correspond to list element data */
var	config								array<GameResourceDataProvider>		ElementProviderTypes;

/** collection of list element provider instances that are associated with each ElementProviderType */
var	const	private	native	transient	MultiMap_Mirror						ListElementProviders{TMultiMap<FName,class UUIResourceDataProvider*>};



DefaultProperties
{
	Tag=GameResources
}
