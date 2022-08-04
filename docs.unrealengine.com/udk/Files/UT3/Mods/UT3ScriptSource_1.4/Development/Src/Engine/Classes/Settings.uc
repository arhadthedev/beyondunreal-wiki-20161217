/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Base class for any type of settings that can be manipulated by the UI
 */
class Settings extends Object
	native
	abstract;

/** The types of advertisement of settings to use */
enum EOnlineDataAdvertisementType
{
	/** Don't advertise via the online service or QoS data */
	ODAT_DontAdvertise,
	/** Advertise via the online service only */
	ODAT_OnlineService,
	/** Advertise via the QoS data only */
	ODAT_QoS
};

/**
 * Structure used to represent a string setting that has a restricted and
 * localized set of value strings. For instance:
 *
 * GameType (id) Values = (0) Death Match, (1) Team Death Match, etc.
 *
 * This allows strings to be transmitted using only 8 bytes and each string
 * is correct for the destination language irrespective of sender's language
 */
struct native LocalizedStringSetting
{
	/** The unique identifier for this localized string */
	var int Id;
	/** The unique index into the list of localized strings */
	var int ValueIndex;
	/** How this setting should be presented to requesting clients: online or QoS */
	var EOnlineDataAdvertisementType AdvertisementType;
};

/** The supported data types that can be stored in the union */
enum ESettingsDataType
{
	/** Means the data in the OnlineData value fields should be ignored */
	SDT_Empty,
	/** 32 bit integer goes in Value1 only*/
	SDT_Int32,
	/** 64 bit integer stored in both value fields */
	SDT_Int64,
	/** Double (8 byte) stored in both value fields */
	SDT_Double,
	/** Unicode string pointer in Value2 with length in Value1 */
	SDT_String,
	/** Float (4 byte) stored in Value1 fields */
	SDT_Float,
	/** Binary data with count in Value1 and pointer in Value2 */
	SDT_Blob,
	/** Date/time structure. Date in Value1 and time Value2 */
	SDT_DateTime
};

/** Structure to hold arbitrary data of a given type */
struct native SettingsData
{
	/** Enum (byte) indicating the type of data held in the value fields */
	var const ESettingsDataType Type;
	/** This is a union of value types and should never be used in script */
	var const int Value1;
	/**
	 * This is a union of value types and should never be used in script
	 * NOTE: It's declared as a pointer for 64bit systems
	 */
	var const transient native pointer Value2{INT};

	
};

/**
 * Structure used to hold non-localized string data. Properties can be
 * arbitrary types.
 */
struct native SettingsProperty
{
	/** The unique id for this property */
	var int PropertyId;
	/** The data stored for the type */
	var SettingsData Data;
	/** How this setting should be presented to requesting clients: online or QoS */
	var EOnlineDataAdvertisementType AdvertisementType;

	
};

/** Maps an Id value to a string */
struct native StringIdToStringMapping
{
	/** Id for the given string */
	var const int Id;
	/** Human readable form of the Id */
	var const localized name Name;
	/** Whether this id is used to indicate a wildcard value or not */
	var const bool bIsWildcard;
};

/** Contains the meta information for a given context */
struct native LocalizedStringSettingMetaData
{
	/** Id for the given string */
	var const int Id;
	/** Human readable form of the Id */
	var const name Name;
	/** Localized text used for list column headers */
	var	const localized	string ColumnHeaderText;
	/** Holds the mappings of localized string setting values to their human readable form */
	var const array<StringIdToStringMapping> ValueMappings;
};

/** Maps an Id value to a string */
struct native IdToStringMapping
{
	/** Id for the given string */
	var const int Id;
	/** Human readable form of the Id */
	var const localized name Name;
};

/** Used to indicate how the data should be retrieved for the UI */
enum EPropertyValueMappingType
{
	/** The value is presented "as is" without mapping/manipulation */
	PVMT_RawValue,
	/** The property has a set of predefined values that are the only ones to choose from */
	PVMT_PredefinedValues,
	/** The property must exist within the min/max range specified */
	PVMT_Ranged,
	/** The property is mapped using id/name pairs */
	PVMT_IdMapped
};

/** Contains the meta information needed to validate property data */
struct native SettingsPropertyPropertyMetaData
{
	/** Id for the given string */
	var const int Id;
	/** Human readable form of the Id */
	var const name Name;
	/** Localized text used for list column headers */
	var	const localized	string ColumnHeaderText;
	/** Whether the value is ID mapped or should be string-ized */
	var const EPropertyValueMappingType MappingType;
	/** Holds the mappings of value IDs to their human readable form */
	var const array<IdToStringMapping> ValueMappings;
	/** Holds a set of predefined values for a property when freeform editing isn't desired */
	var const array<SettingsData> PredefinedValues;
	/** The min value for this property */
	var const float MinVal;
	/** The max value for this property */
	var const float MaxVal;
	/** The amount that this range can be incremented/decremented by */
	var const float RangeIncrement;
};

/** The various localized string settings to use with the session */
var array<LocalizedStringSetting> LocalizedSettings;

/** The properties used by the derived settings class */
var array<SettingsProperty> Properties;

/** Used to map a localized string setting to a human readable string */
var array<LocalizedStringSettingMetaData> LocalizedSettingsMappings;

/** Used to map a property to a human readable string and validate its range */
var array<SettingsPropertyPropertyMetaData> PropertyMappings;



/**
 * Static function for setting members of the SettingsData union.
 *
 * @param Data the data structure to set the fields of
 * @param InString the string data to set in the union
 */
static native function SetSettingsDataString(out SettingsData Data,string InString);

/**
 * Static function for setting members of the SettingsData union
 *
 * @param Data the data structure to set the fields of
 * @param InFloat the float data to set in the union
 */
static native function SetSettingsDataFloat(out SettingsData Data,float InFloat);

/**
 * Static function for setting members of the SettingsData union
 *
 * @param Data the data structure to set the fields of
 * @param InInt the 32 bit integer data to set in the union
 */
static native function SetSettingsDataInt(out SettingsData Data,int InInt);

/**
 * Static function for setting members of the SettingsData union
 *
 * @param Data the data structure to set the fields of
 * @param InInt1 first half of the data to set
 * @param InInt2 second half of the data to set
 */
static native function SetSettingsDataDateTime(out SettingsData Data,int InInt1,int InInt2);

/**
 * Static function for setting members of the SettingsData union
 *
 * @param Data the data structure to set the fields of
 * @param InBlob the 8 bytes to copy into the union
 */
static native function SetSettingsDataBlob(out SettingsData Data,out array<byte> InBlob);

/**
 * Static function for setting members of the SettingsData union
 *
 * @param Data the data structure to set the fields of
 * @param Data2Copy the SettingsData object to copy
 */
static native function SetSettingsData(out SettingsData Data,out SettingsData Data2Copy);

/**
 * Empties an SettingsData structure
 *
 * @param Data the data structure to set the fields of
 */
static native function EmptySettingsData(out SettingsData Data);

/**
 * Static function for copying data out of the SettingsData union.
 *
 * @param Data the data structure to copy the data from
 */
static native function string GetSettingsDataString(out SettingsData Data);

/**
 * Static function for copying data out of the SettingsData union
 *
 * @param Data the data structure to copy the data from
 */
static native function float GetSettingsDataFloat(out SettingsData Data);

/**
 * Static function for copying data out of the SettingsData union
 *
 * @param Data the data structure to copy the data from
 */
static native function int GetSettingsDataInt(out SettingsData Data);

/**
 * Static function for copying data out the SettingsData union
 *
 * @param Data the data structure to copy the data from
 * @param OutBlob the buffer to copy the data into
 */
static native function GetSettingsDataBlob(out SettingsData Data,out array<byte> OutBlob);

/**
 * Static function for getting members of the SettingsData union
 *
 * @param Data the data structure to get the fields of
 * @param OutInt1 first half of the data to get
 * @param OutInt2 second half of the data to get
 */
static native function GetSettingsDataDateTime(out SettingsData Data,out int OutInt1,out int OutInt2);

/**
 * Searches the localized string setting array for the matching id and sets the value
 *
 * @param StringSettingId the string setting to set the value for
 * @param ValueIndex the value of the string setting
 * @param bShouldAutoAdd whether to add the context if it is missing
 */
native function SetStringSettingValue(int StringSettingId,int ValueIndex,bool bShouldAutoAdd);

/**
 * Searches the localized string setting array for the matching id and returns its value
 *
 * @param StringSettingId the string setting to find the value of
 * @param ValueIndex the out value that is set when found
 *
 * @return true if found, false otherwise
 */
native function bool GetStringSettingValue(int StringSettingId,out int ValueIndex);

/**
 * Searches the localized string setting array for the matching id and
 * returns the list of possible values
 *
 * @param StringSettingId the string setting to find the value of
 * @param Values the out value that is a list of value names and their ids
 *
 * @return true if found, false otherwise
 */
native function bool GetStringSettingValueNames(int StringSettingId,out array<IdToStringMapping> Values);

/**
 * Searches the localized string setting array for the matching name and sets the value
 *
 * @param StringSettingName the setting name to set the value for
 * @param ValueIndex the value of the string setting
 * @param bShouldAutoAdd whether to add the string setting if it is missing
 */
native function SetStringSettingValueByName(name StringSettingName,int ValueIndex,bool bShouldAutoAdd);

/**
 * Searches the localized string setting array for the matching name and returns its value
 *
 * @param StringSettingName the setting name to find the value of
 * @param ValueIndex the out value that is set when found
 *
 * @return true if found, false otherwise
 */
native function bool GetStringSettingValueByName(name StringSettingName,out int ValueIndex);

/**
 * Searches the context array for the matching string setting name and returns the id
 *
 * @param StringSettingName the name of the string setting being searched for
 * @param StringSettingId the id of the context that matches the name
 *
 * @return true if the seting was found, false otherwise
 */
native function bool GetStringSettingId(name StringSettingName,out int StringSettingId);

/**
 * Finds the human readable name for the localized string setting
 *
 * @param StringSettingId the id to look up in the mappings table
 *
 * @return the name of the string setting that matches the id or NAME_None if not found
 */
native function name GetStringSettingName(int StringSettingId);

/**
 * Finds the localized column header text for the string setting
 *
 * @param StringSettingId the id to look up in the mappings table
 *
 * @return the string to use as the list column header for the string setting that matches the id, or an empty string if not found.
 */
native function string GetStringSettingColumnHeader( int StringSettingId );

/**
 * Determines if the value for the specified setting is a wildcard option
 *
 * @param StringSettingId the id to check for being a wildcard
 *
 * @return true if the current value is a wildcard, false otherwise
 */
native function bool IsWildcardStringSetting(int StringSettingId);

/**
 * Finds the human readable name for a string setting's value. Searches the
 * string settings mappings for the specifc string setting and then searches
 * the set of values for the specific value index and returns that value's
 * human readable name
 *
 * @param StringSettingId the id to look up in the mappings table
 * @param ValueIndex the value index to find the string value of
 *
 * @return the name of the string setting value that matches the id & index or NAME_None if not found
 */
native function name GetStringSettingValueName(int StringSettingId,int ValueIndex);

/**
 * Finds the human readable name for a string setting's value. Searches the
 * string settings mappings for the specifc string setting and then searches
 * the set of values for the specific value index and returns that value's
 * human readable name
 *
 * @param StringSettingName the name of the string setting to find the string value of
 *
 * @return the name of the string setting value that matches the name or NAME_None if not found
 */
native function name GetStringSettingValueNameByName(name StringSettingName);

/**
 * Searches for the string setting by name and sets the value index to the
 * value contained in the string setting meta data
 *
 * @param StringSettingName the name of the string setting to find
 * @param NewValue the string value to use
 *
 * @return true if the string setting was found and the value was set, false otherwise
 */
native function bool SetStringSettingValueFromStringByName(name StringSettingName,const out string NewValue);

/**
 * Searches the property array for the matching property and returns the id
 *
 * @param PropertyName the name of the property being searched for
 * @param PropertyId the id of the context that matches the name
 *
 * @return true if the property was found, false otherwise
 */
native function bool GetPropertyId(name PropertyName,out int PropertyId);

/**
 * Finds the human readable name for the property
 *
 * @param PropertyId the id to look up in the mappings table
 *
 * @return the name of the property that matches the id or NAME_None if not found
 */
native function name GetPropertyName(int PropertyId);

/**
 * Finds the localized column header text for the property
 *
 * @param PropertyId the id to look up in the mappings table
 *
 * @return the string to use as the list column header for the property that matches the id, or an empty string if not found.
 */
native function string GetPropertyColumnHeader( int PropertyId );

/**
 * Converts a property to a string. Searches by id
 *
 * @param PropertyId the id to look up in the mappings table
 *
 * @return the string form of the property value or an empty string if invalid/missing
 */
native function string GetPropertyAsString(int PropertyId);

/**
 * Converts a property to a string. Searches by name
 *
 * @param PropertyName the name of the property to find
 *
 * @return the string form of the property value or an empty string if invalid/missing
 */
native function string GetPropertyAsStringByName(name PropertyName);

/**
 * Searches for the property by name and sets the property to the value contained
 * in the string
 *
 * @param PropertyName the name of the property to find
 * @param NewValue the string value to use
 *
 * @return true if the property was found and the value was set, false otherwise
 */
native function bool SetPropertyFromStringByName(name PropertyName,const out string NewValue);

/**
 * Sets a property of type SDT_Float to the value specified. Does nothing
 * if the property is not of the right type.
 *
 * @param PropertyId the property to change the value of
 * @param Value the new value to assign
 */
native function SetFloatProperty(int PropertyId,float Value);

/**
 * Reads a property of type SDT_Float into the value specified. Does nothing
 * if the property is not of the right type.
 *
 * @param PropertyId the property to read the value of
 * @param Value the out value containing the property's value
 *
 * @return true if found and is the right type, false otherwise
 */
native function bool GetFloatProperty(int PropertyId,out float Value);

/**
 * Sets a property of type SDT_Int32 to the value specified. Does nothing
 * if the property is not of the right type.
 *
 * @param PropertyId the property to change the value of
 * @param Value the new value to assign
 */
native function SetIntProperty(int PropertyId,int Value);

/**
 * Reads a property of type SDT_Int32 into the value specified. Does nothing
 * if the property is not of the right type.
 *
 * @param PropertyId the property to change the value of
 * @param Value the out value containing the property's value
 *
 * @return true if found and is the right type, false otherwise
 */
native function bool GetIntProperty(int PropertyId,out int Value);

/**
 * Sets a property of type SDT_String to the value specified. Does nothing
 * if the property is not of the right type.
 *
 * @param PropertyId the property to change the value of
 * @param Value the new value to assign
 */
native function SetStringProperty(int PropertyId,string Value);

/**
 * Reads a property of type SDT_String into the value specified. Does nothing
 * if the property is not of the right type.
 *
 * @param PropertyId the property to change the value of
 * @param Value the out value containing the property's value
 *
 * @return true if found and is the right type, false otherwise
 */
native function bool GetStringProperty(int PropertyId,out string Value);

/**
 * Determines the property type for the specified property id
 *
 * @param PropertyId the property to change the value of
 *
 * @return the type of property, or SDT_Empty if not found
 */
native function ESettingsDataType GetPropertyType(int PropertyId);

/**
 * Using the specified array, updates the matching settings to the new values
 * in that array. Optionally, it will add settings that aren't currently part
 * of this object.
 *
 * @param Settings the list of settings to update
 * @param bShouldAddIfMissing whether to automatically add the setting if missing
 */
native function UpdateStringSettings(const out array<LocalizedStringSetting> Settings,bool bShouldAddIfMissing = true);

/**
 * Using the specified array, updates the matching properties to the new values
 * in that array. Optionally, it will add properties that aren't currently part
 * of this object.
 *
 * @param Props the list of properties to update
 * @param bShouldAddIfMissing whether to automatically add the property if missing
 */
native function UpdateProperties(const out array<SettingsProperty> Props,bool bShouldAddIfMissing = true);

/**
 * Determines if a given property is present for this object
 *
 * @param PropertyId the ID to check on
 *
 * @return TRUE if the property is part of this object, FALSE otherwise
 */
native function bool HasProperty(int PropertyId);

/**
 * Determines if a given localized string setting is present for this object
 *
 * @param SettingId the ID to check on
 *
 * @return TRUE if the setting is part of this object, FALSE otherwise
 */
native function bool HasStringSetting(int SettingId);

/**
 * Determines the mapping type for the specified property
 *
 * @param PropertyId the ID to get the mapping type for
 * @param OutType the out var the value is placed in
 *
 * @return TRUE if found, FALSE otherwise
 */
native function bool GetPropertyMappingType(int PropertyId,out EPropertyValueMappingType OutType);

/**
 * Determines the min and max values of a property that is clamped to a range
 *
 * @param PropertyId the ID to get the mapping type for
 * @param OutMinValue the out var the min value is placed in
 * @param OutMaxValue the out var the max value is placed in
 * @param RangeIncrement the amount the range can be adjusted by the UI in any single update
 * @param bFormatAsInt whether the range's value should be treated as an int.
 *
 * @return TRUE if found and is a range property, FALSE otherwise
 */
native function bool GetPropertyRange(int PropertyId,out float OutMinValue,out float OutMaxValue,out float RangeIncrement,out byte bFormatAsInt);

/**
 * Sets the value of a ranged property, clamping to the min/max values
 *
 * @param PropertyId the ID of the property to set
 * @param NewValue the new value to apply to the
 *
 * @return TRUE if found and is a range property, FALSE otherwise
 */
native function bool SetRangedPropertyValue(int PropertyId,float NewValue);

/**
 * Gets the value of a ranged property
 *
 * @param PropertyId the ID to get the value of
 * @param OutValue the out var that receives the value
 *
 * @return TRUE if found and is a range property, FALSE otherwise
 */
native function bool GetRangedPropertyValue(int PropertyId,out float OutValue);

/**
 * Scans the properties for the ones that need to be set via QoS data
 *
 * @param QoSProps the out array holding the list of properties to advertise via QoS
 */
native function GetQoSAdvertisedProperties(out array<SettingsProperty> QoSProps);

/**
 * Scans the string settings for the ones that need to be set via QoS data
 *
 * @param QoSSettings the out array holding the list of settings to advertise via QoS
 */
native function GetQoSAdvertisedStringSettings(out array<LocalizedStringSetting> QoSSettings);

/**
 * Appends databindings to the URL.
 *
 * @param OutURL	String to append bindings to.
 */
native function AppendDataBindingsToURL(out string URL);

/**
 * Appends properties to the URL.
 *
 * @param OutURL	String to append properties to.
 */
native function AppendPropertiesToURL(out string URL);

/**
 * Appends contexts to the URL.
 *
 * @param OutURL	String to append contexts to.
 */
native function AppendContextsToURL(out string URL);

/**
 * Builds an URL out of the string settings and properties
 *
 * @param URL the string to populate
 */
native function BuildURL(out string URL);

/**
 * Updates the game settings object from parameters passed on the URL
 *
 * @param URL the URL to parse for settings
 */
native function UpdateFromURL(const out string URL, GameInfo Game);


/**
 * Outputs the names of properties in the class which are databinding, and which can be manipulated using GetDataBindingValue and SetDataBindingValue.
 * Property types which are not returned are: Object, Delegate, Array and Struct
 */
native final function GetDataBindingProperties(out array<name> DataBindingProperties);

/**
 * Outputs the value of the specified databinding property, returning True if successful
 * NOTE: This has the same restrictions on property types as 'GetDataBindingProperties'
 * @param bIgnoreDefaults	If true, then the function returns false and does not output a value if the property is still at it's default value
 */
native final function bool GetDataBindingValue(name Property, out string Value, optional bool bIgnoreDefaults);

/**
 * Sets the value of the specified databinding property to the specified input value, returning True if successful
 * NOTE: This has the same restrictions on property types as 'GetDataBindingProperties'
 */
native final function bool SetDataBindingValue(name Property, string Value);
