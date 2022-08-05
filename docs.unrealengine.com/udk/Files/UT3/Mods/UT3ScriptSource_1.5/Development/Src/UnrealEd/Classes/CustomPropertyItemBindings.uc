﻿/**
 * This class is responsible for tracking custom property item draw and input proxies.  It allows specifying a custom
 * draw or input proxy for a particular property, or for a particular property type.  This class is a singleton; to access
 * the values stored in this class, use UCustomPropertyItemBindings::StaticClass()->GetDefaultObject<UCustomPropertyItemBinding>();
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class CustomPropertyItemBindings extends Object
	native(Private)
	config(Editor);


/**
 * This struct is used for specifying custom draw or input proxies for a specific property.
 */
struct native PropertyItemCustomProxy
{
	/**
	 * The complete pathname for the property that this custom proxy should be applied to.  When the property window
	 * encounters a property with this path name, it will use the PropertyItemClassName to represent that property instead
	 * of the default property item class.
	 */
	var()		config			string							PropertyPathName;

	/**
	 * The complete path name for the class to use in the property item window for the associated property.
	 */
	var()		config			string							PropertyItemClassName;

	/**
	 * Only relevant when the property associated with this custom property item proxy is an array property.  Indicates that this
	 * this custom property item proxy should be used when creating the item which corresponds to the array header item, rather than the
	 * normal array header item.
	 */
	var()		config			bool							bReplaceArrayHeaders;

	/**
	 * Only relevant when the property associated with this custom property item proxy control is an array property.  Indicates that this
	 * custom property item proxy should not be used for individual array elements.
	 */
	var()		config			bool							bIgnoreArrayElements;

	/**
	 * The custom property item class specified by PropertyItemClassName.  This value is filled in the first time this
	 * PropertyItemCustomProxy's custom property item class is requested.
	 */
	var	transient				class							PropertyItemClass;
};

/**
 * This struct is used for specifying custom draw or input proxies for a specific property type.
 */
struct native PropertyTypeCustomProxy
{
	/**
	 * The name of the property that this custom proxy applies to (e.g. ObjectProperty, ComponentProperty, etc.).
	 */
	var()		config			name							PropertyName;

	/**
	 * The complete path name for the object class that this custom proxy should be used for (e.g. Engine.UITexture)
	 */
	var()		config			string							PropertyObjectClassPathName;

	/**
	 * The complete path name for the class to use in the property item window for the associated property.
	 */
	var()		config			string							PropertyItemClassName;

	/**
	 * Only relevant when the property associated with this custom property item proxy is an array property.  Indicates that this
	 * this custom property item proxy should be used when creating the item which corresponds to the array header item, rather than the
	 * normal array header item.
	 */
	var()		config			bool							bReplaceArrayHeaders;

	/**
	 * Only relevant when the property associated with this custom property item proxy control is an array property.  Indicates that this
	 * custom property item proxy should not be used for individual array elements.
	 */
	var()		config			bool							bIgnoreArrayElements;

	/**
	 * The custom property item class specified by PropertyItemClassName.  This value is filled in the first time this
	 * PropertyTypeCustomProxy's custom property item class is requested.
	 */
	var	transient				class							PropertyItemClass;
};

/**
 * This struct is used for specifying custom property window item classes for a specific property or unrealscript struct.
 */
struct native PropertyItemCustomClass
{
	/**
	 * The complete pathname for the property/script-struct that this property binding should be applied to.  When the property window
	 * encounters a property that has this path name, it will use the PropertyItemClassName to represent that property instead
	 * of the default property item class.
	 *
	 * If PropertyPathName corresponds to a script struct, the custom property item class will be used for all struct properties for that struct.
	 */
	var()		config			string							PropertyPathName;

	/**
	 * The name of the WxPropertyWindow_Item subclass to use in the property item window for the associated property.
	 */
	var()		config			string							PropertyItemClassName;

	/**
	 * Only relevant when the property associated with this custom property editing control is an array property.  Indicates that this
	 * this custom property item control should be used when creating the item which corresponds to the array header item, rather than the
	 * normal array header item.
	 */
	var()		config			bool							bReplaceArrayHeaders;

	/**
	 * Only relevant when the property associated with this custom property editing control is an array property.  Indicates that this
	 * custom property item control should not be used for individual array elements.
	 */
	var()		config			bool							bIgnoreArrayElements;

	/**
	 * A pointer to the WxPropertyWindow_Item class corresponding to PropertyItemClassName.  This value is filled the first
	 * time this PropertyItemCustomClass's custom property item class is requested.
	 */
	var	transient	native		pointer							WxPropertyItemClass{class wxClassInfo};
};

/**
 * This struct is used for specifying custom property window item classes for a specific property type.
 */
struct native PropertyTypeCustomClass
{
	/**
	 * The name of the property that this custom item class applies to (e.g. ObjectProperty, ComponentProperty, etc.).
	 */
	var()		config			name							PropertyName;

	/**
	 * The complete path name for the object class that this custom item class should be used for (e.g. Engine.UITexture)
	 */
	var()		config			string							PropertyObjectClassPathName;

	/**
	 * The name of the WxPropertyWindow_Item subclass to use in the property item window for the associated property.
	 */
	var()		config			string							PropertyItemClassName;

	/**
	 * Only relevant when the property associated with this custom property editing control is an array property.  Indicates that this
	 * this custom property item control should be used when creating the item which corresponds to the array header item, rather than the
	 * normal array header item.
	 */
	var()		config			bool							bReplaceArrayHeaders;

	/**
	 * Only relevant when the property associated with this custom property editing control is an array property.  Indicates that this
	 * custom property item control should not be used for individual array elements.
	 */
	var()		config			bool							bIgnoreArrayElements;

	/**
	 * A pointer to the WxPropertyWindow_Item class corresponding to PropertyItemClassName.  This value is filled the first
	 * time this PropertyTypeCustomClass's custom property item class is requested.
	 */
	var	transient	native		pointer							WxPropertyItemClass{class wxClassInfo};
};

/** custom property item classes, for specific properties */
var()			config			array<PropertyItemCustomClass>			CustomPropertyClasses;
/** custom property item classes, per property type */
var()			config			array<PropertyTypeCustomClass>			CustomPropertyTypeClasses;

/** custom draw proxy classes, for specific properties */
var()			config			array<PropertyItemCustomProxy>			CustomPropertyDrawProxies;
/** custom draw proxy classes, per property type */
var()			config			array<PropertyItemCustomProxy>			CustomPropertyInputProxies;

/** custom input proxy classes, for specific properties */
var()			config			array<PropertyTypeCustomProxy>			CustomPropertyTypeDrawProxies;
/** custom input proxy classes, per property type */
var()			config			array<PropertyTypeCustomProxy>			CustomPropertyTypeInputProxies;



DefaultProperties
{

}
