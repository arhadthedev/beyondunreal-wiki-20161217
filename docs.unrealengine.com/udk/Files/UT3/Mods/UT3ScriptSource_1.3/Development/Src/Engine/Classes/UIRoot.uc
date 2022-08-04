/**
 * Base class for all classes that handle interacting with the user.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIRoot extends Object
	native(UserInterface)
	HideCategories(Object,UIRoot)
	abstract;

const TEMP_SPLITSCREEN_INDEX=0;

/**
 * Controls what types of interactions are allowed for a widget.  Ideally this would be an enum, but the values are used as a bitmask
 * (for UIObject.PrivateFlags) and unrealscript enums cannot be assigned values.
 */
const PRIVATE_NotEditorSelectable	= 0x001;	/** Not selectable in the scene editor.																									*/
const PRIVATE_TreeHidden			= 0x002;	/** Not viewable in the scene tree or layer tree, but children are.																						*/
const PRIVATE_NotFocusable			= 0x004;	/** Not eligible to receive focus; affects both editor and game																			*/
const PRIVATE_NotDockable			= 0x008;	/** Not able to be docked to another widget.																							*/
const PRIVATE_NotRotatable			= 0x010;	/** Not able to be rotated. @todo - not yet implemented.																				*/
const PRIVATE_ManagedStyle			= 0x020;	/** Indicates that this widget's styles are managed by its owner widgets - any style references set for this widget will not be saved.	*/
const PRIVATE_TreeHiddenRecursive	= 0x042;	/** Not visible in the scene tree or layer tree, including children																		*/
const PRIVATE_EditorNoDelete		= 0x080;	/** This widget is not deletable in the editor																							*/
const PRIVATE_EditorNoRename		= 0x100;	/** This widget is not renamable in the editor																							*/
const PRIVATE_EditorNoReparent		= 0x200;	/** This widget can not be reparented in the editor																						*/
const PRIVATE_PropagateState		= 0x400;	/** This widget will propagate certain states to its children, such as enabled and disabled												*/
const PRIVATE_KeepFocusedState		= 0x800;	/** only relevant if NotFocusable is set as well - don't remove the focused state from this widget's list of available states			*/

/** Combination flags */
const PRIVATE_Protected				= 0x380;	/** Combination of EditorNoDelete + EditorNoRename + EditorNoReparent																	*/

/** Aspect ratios */
const ASPECTRATIO_Normal		= 1.333333f;
const ASPECTRATIO_Monitor		= 1.25f;
const ASPECTRATIO_Widescreen	= 1.777778f;

/** The type of adjustment to apply to a material. */
enum EMaterialAdjustmentType
{
	/** no modification to material - if material is larger than target dimension, material is clipped */
	ADJUST_None<DisplayName=Clipped>,

	/** material will be scaled to fit the target dimension */
	ADJUST_Normal<DisplayName=Scaled>,

	/** material will be scaled to fit the target dimension, maintaining aspect ratio */
	ADJUST_Justified<DisplayName=Uniformly Scaled>,

	/** target's dimensions will be adjusted to match material dimension */
	ADJUST_Bound<DisplayName=Bound>,

	/** material will be stretched to fit target dimension */
	ADJUST_Stretch<DisplayName=Stretched>,
};

/** method to use for resolving a UIScreenValue */
enum EPositionEvalType
{
	/** no conversion */
	EVALPOS_None,

	/** the value should be evaluated as an actual pixel value */
	EVALPOS_PixelViewport,

	/** the value should be evaluated as a pixel offset from the owning widget's scene's position */
	EVALPOS_PixelScene,

	/** the value should be evaluated as a pixel offset from the owning widget's position */
	EVALPOS_PixelOwner,

	/** the value should be evaluated as a percentage of the viewport */
	EVALPOS_PercentageViewport,

	/** the value should be evaluated as a percentage of the owning widget's position */
	EVALPOS_PercentageOwner,

	/** the value should be evaluated as a percentage of the owning widget's scene */
	EVALPOS_PercentageScene,
};

/** method to use for resolving a UIAutoSizeRegion's values */
enum EUIExtentEvalType
{
	/** the value should be interpreted as an actual pixel value */
	UIEXTENTEVAL_Pixels<DisplayName=Pixels>,

	/** the value should be interpreted as a percentage of the owner's size */
	UIEXTENTEVAL_PercentSelf<DisplayName=Percentage of owning widget size>,

	/** the value should be interpreted as a percentage of the size of the owning widget's parent */
	UIEXTENTEVAL_PercentOwner<DisplayName=Percentage of widget parent size>,

	/** the value should be interpreted as a percentage of the scene's size */
	UIEXTENTEVAL_PercentScene<DisplayName=Percentage of scene>,

	/** the value should be interpreted as a percentage of the viewport's size */
	UIEXTENTEVAL_PercentViewport<DisplayName=Percentage of viewport>,
};

/** method to use for resolving dock padding values */
enum EUIDockPaddingEvalType
{
	/** the value should be interpreted as an actual pixel value */
	UIPADDINGEVAL_Pixels<DisplayName=Pixels>,

	/** the value should be interpreted as a percentage of the dock target's size */
	UIPADDINGEVAL_PercentTarget<DisplayName=Percentage of dock target size>,

	/** the value should be interpreted as a percentage of the owner's size */
	UIPADDINGEVAL_PercentOwner<DisplayName=Percentage of owning widget size>,

	/** the value should be interpreted as a percentage of the scene's size */
	UIPADDINGEVAL_PercentScene<DisplayName=Percentage of scene>,

	/** the value should be interpreted as a percentage of the viewport's size */
	UIPADDINGEVAL_PercentViewport<DisplayName=Percentage of viewport>,
};

/** the different types of auto-size extent values */
enum EUIAutoSizeConstraintType
{
	/** the minimum size that the region can be auto-sized to */
	UIAUTOSIZEREGION_Minimum<DisplayName=Minimum>,

	/** the maximum size that the region can be auto-sized to */
	UIAUTOSIZEREGION_Maximum<DisplayName=Maximum>,
};

/** Determines how text should be handled when the text overflows its bounds */
enum ETextClipMode
{
	/** all text is drawn, even if it is outside the bounding region */
	CLIP_None<DisplayName=Overdraw>,

	/** text outside the region should be clipped */
	CLIP_Normal<DisplayName=Clipped>,

	/** replace the last few visible characters with ellipsis to indicate that more text follows */
	CLIP_Ellipsis<DisplayName=Ellipsis>,

	/** wrap the text to the next line */
	CLIP_Wrap<DisplayName=Wrapped>,
};

/** Different types of autoscaling supported */
enum ETextAutoScaleMode
{
	/** No autoscaling */
	UIAUTOSCALE_None<DisplayName=Disabled>,

	/** scale the text to fit into the bounding region */
	UIAUTOSCALE_Normal<DisplayName=Standard>,

	/** same as UIAUTOSCALE_Normal, but maintains the same aspect ratio */
	UIAUTOSCALE_Justified<DisplayName=Justified (maintain aspect ratio)>,

	/** scaled based on the ratio between the resolution the content was authored at and the current resolution */
	UIAUTOSCALE_ResolutionBased<DisplayName=Resolution Scaled>,
};

/** used for specifying alignment for UIObjects and operations */
enum EUIAlignment
{
	/** left or top alignment */
	UIALIGN_Left<DisplayName=Left/Top>,

	/** center alignment */
	UIALIGN_Center<DisplayName=Center>,

	/** right or bottom alignment */
	UIALIGN_Right<DisplayName=Right/Bottom>,

	/** default alignment value */
	UIALIGN_Default<DisplayName=Inherit/Other>,
};

/** Represents the state of an item in a UIList. */
enum EUIListElementState
{
	/** normal element in the list */
	ELEMENT_Normal<DisplayName=Normal>,

	/** element corresponds to the list's index */
	ELEMENT_Active<DisplayName=Active>,

	/** element is current selected */
	ELEMENT_Selected<DisplayName=Selected>,

	/** the cursor is currently over the element */
	ELEMENT_UnderCursor<DisplayName=Under Cursor>,
};

/** The different states for a list column header */
enum EColumnHeaderState
{
	/** this column is not being used to sort list elements */
	COLUMNHEADER_Normal<DisplayName=Normal>,

	/** this column is used as the primary sort key for the list elements */
	COLUMNHEADER_PrimarySort<DislayName=Primary Sort>,

	/** this column is used as the secondary sort key for the list elements */
	COLUMNHEADER_SecondarySort<DipslayName=Secondary Sort>,
};

/** general orientation for UIObjects */
enum EUIOrientation
{
	UIORIENT_Horizontal<DisplayName=Horizontal>,
	UIORIENT_Vertical<DisplayName=Vertical>,
};

/** The faces a widget may contain. */
enum EUIWidgetFace
{
	UIFACE_Left<DisplayName=Left>,
	UIFACE_Top<DisplayName=Top>,
	UIFACE_Right<DisplayName=Right>,
	UIFACE_Bottom<DisplayName=Bottom>,
};

/** The types of aspect ratio constraint adjustments supported */
enum EUIAspectRatioConstraint
{
	/** Indicates that no aspect ratio constraint adjustment is active */
	UIASPECTRATIO_AdjustNone<DisplayName=None>,

	/** Indicates that the width will be adjusted to be a product of the height (most common) */
	UIASPECTRATIO_AdjustWidth<DisplayName=Adjust Width>,

	/** Indicates that the height should be adjusted as a product of the width (rarely used) */
	//@todo ronp - not yet implemented
	UIASPECTRATIO_AdjustHeight<DisplayName=Adjust Height>,
};

/** The types of default textures the UI can use */
enum EUIDefaultPenColor
{
	UIPEN_White,
	UIPEN_Black,
	UIPEN_Grey,
};

/** Types of navigation targets */
enum ENavigationLinkType
{
	/** navigation link that was set programmatically by RebuildNavigationLinks */
	NAVLINK_Automatic,

	/** navigation link that was set by the designer in the UI Editor */
	NAVLINK_Manual,
};

/**
 * The types of split-screen input modes that are supported for UI scenes.  These control what a UIScene does when it
 * receives input from multiple gamepads at once.
 *
 * @note: the order of the values in this enum should not be changed.
 */
enum EScreenInputMode
{
	/**
	 * This scene doesn't process input at all.  Useful for optimizing input processing for scenes which don't process any input,
	 * such as HUD scenes.
	 */
	INPUTMODE_None,

	/**
	 * Simultaneous inputs are not supported in this scene.  Only input from the gamepad that is associated with
	 * this scene will be processed.  Input from other gamepads will be ignored and swallowed.
	 * This is the most common input mode.
	 */
	INPUTMODE_Locked,		// MIM_Bound

	/**
	 * Similar to INPUTMODE_Locked, except that input from gamepads not associated with this scene is passed to the
	 * next scene in the stack.
	 * Used for e.g. profile selection scenes where each player can open their own profile selection menu.
	 */
	INPUTMODE_MatchingOnly,	// MIM_NonBlocking

	/**
	 * Similar to INPUTMODE_Free, except that input is only accepted from active gamepads which are associated with a
	 * player.
	 * All input and focus is treated as though it came from the same gamepad, regardless of where it came from.
	 * Allows any active player to interact with this screen.
	 */
	INPUTMODE_ActiveOnly,	// MIM_Cooperative

	/**
	 * Any active gamepad can interact with this menu, even if it isn't associated with a player.
	 * Used for menus which allow additional players to become active, such as the character selection menu.
	 */
	INPUTMODE_Free,			// MIM_Unbound

	/**
	 * Input from any active gamepad will be processed by this scene.  The scene contains a unique set of controls
	 * for each active gamepad, and those controls only respond to input from the gamepad they're associated with.
	 * Used for scenes where all players should be able to interact with the same controls in the scene (such as a
	 * character selection menu in most fighting games)
	 */
	INPUTMODE_Simultaneous,	// MIM_Simultaneous
};

/**
 * Types of split-screen rendering layouts that scenes can use.
 */
enum ESplitscreenRenderMode
{
	/**
	 * The scene is always rendered using the full screen; it will span across the viewport regions for the splitscreen players.
	 */
	SPLITRENDER_Fullscreen<DisplayName=Fullscreen>,

	/**
	 * The scene is rendered according to the player associated with the scene.  If no player is associated with the scene, the scene
	 * will be rendered fullscreen.  If a player is associated with the scene (by specifying a PlayerOwner when opening the scene),
	 * the scene will be rendered within that player's viewport region.
	 */
	SPLITRENDER_PlayerOwner<DisplayName=Player Viewport>,
};

/**
 * Data field categorizations.
 */
enum EUIDataProviderFieldType
{
	/**
	 * this tag represents a bindable data field that corresponds to a simple data type
	 */
	DATATYPE_Property<DisplayName=Property>,

	/**
	 * this tag represents an internal data provider; cannot be bound to a widget
	 */
	DATATYPE_Provider<DisplayName=Internal Provider>,

	/**
	 * this tag represents a field that can only be represented by widgets that can display range values, such as
	 * sliders, progress bars, and spinners.
	 */
	DATATYPE_RangeProperty<DisplayName=Range Property>,

	/**
	 * this tag represents a bindable array data field; can be bound to lists or individual elements can be bound to widgets
	 */
	DATATYPE_Collection<DisplayName=Array>,

	/**
	 * this tag represents an array of internal data providers. Can be bound to lists or the properties for individual elements
	 * can be bound to widgets
	 */
	DATATYPE_ProviderCollection<DisplayName=Array Of Providers>,
};

/** Different presets to use for the rotation anchor's position */
enum ERotationAnchor
{
	/** Use the anchor's configured location */
	RA_Absolute,

	/** Position the anchor at the center of the widget's bounds */
	RA_Center,

	/**
	 * Position the anchor equidistant from the left, top, and bottom edges.  Useful for widgets which will be rotated
	 * by right angles because it keeps those faces in the same relative screen positions
	 */
	RA_PivotLeft,

	/**
	 * Position the anchor equidistant from the right, top, and bottom edges.  Useful for widgets which will be rotated
	 * by right angles because it keeps those faces in the same relative screen positions
	 */
	RA_PivotRight,

	/**
	 * Position the anchor equidistant from the left, top, and right edges.  Useful for widgets which will be rotated
	 * by right angles because it keeps those faces in the same relative screen positions
	 */
	RA_PivotTop,

	/**
	 * Position the anchor equidistant from the left, bottom, and right edges.  Useful for widgets which will be rotated
	 * by right angles because it keeps those faces in the same relative screen positions
	 */
	RA_PivotBottom,

	/** Position the anchor at the upper left corner of the widget's bounds */
	RA_UpperLeft,

	/** Position the anchor at the upper right corner of the widget's bounds */
	RA_UpperRight,

	/** Position the anchor at the lower left corner of the widget's bounds */
	RA_LowerLeft,

	/** Position the anchor at the lower right corner of the widget's bounds */
	RA_LowerRight,
};

/**
 * A unique identifier assigned to a widget.
 */
struct native WIDGET_ID extends GUID
{

};

/**
 * A unique ID number for a resource located in a UI skin package.  Used to lookup materials in skin files.
 */
struct native STYLE_ID extends GUID
{

};

/**
 * Contains information about a data value that must be within a specific range.
 */
struct native UIRangeData
{
	/** the current value of this UIRange */
	var(Range)	public{private}		float	CurrentValue;

	/**
	 * The minimum value for this UIRange.  The value of this UIRange must be greater than or equal to this value.
	 */
	var(Range)						float	MinValue;

	/**
	 * The maximum value for this UIRange.  The value of this UIRange must be less than or equal to this value.
	 */
	var(Range)						float	MaxValue;

	/**
	 * Controls the amount to increment or decrement this UIRange's value when used by widgets that support "nudging".
	 * If NudgeValue is zero, reported NudgeValue will be 1% of MaxValue - MinValue.
	 */
	var(Range)	public{private}		float	NudgeValue;

	/**
	 * Indicates whether the values in this UIRange should be treated as ints.
	 */
	var(Range)						bool	bIntRange;


};



/**
 * Contains the value for a property, as either text or an image.  Used for allowing script-only data provider classes to
 * resolve data fields parsed from UIStrings.
 */
struct native UIProviderScriptFieldValue
{
	/** the name of this resource; set natively after the list of available tags are retrieved from script */
	var	const	name		PropertyTag;

	/** the type of field this tag corresponds to */
	var			EUIDataProviderFieldType	PropertyType;

	/** If PropertyTag corresponds to data that should be represented as text, contains the value for this resource */
	var			string		StringValue;

	/** If PropertyTag correspondsd to data that should be represented as an image, contains the value for this resource */
	var			Surface		ImageValue;

	/** If PropertyTag corresponds to data that should be represented as a list of untyped data, contains the value of the selected elements */
	var			array<int>	ArrayValue;

	/** If PropertyTag corresponds to data that should be represented as value within a specific range, contains the value for this resource */
	var			UIRangeData	RangeValue;


};


/**
 * This extension of UIProviderScriptFieldValue is used when resolving values for markup text found in UIStrings.  This struct
 * allows data stores to provide the UIStringNode that should be used when rendering the value for the data field represented
 * this struct.
 */
struct native UIProviderFieldValue extends UIProviderScriptFieldValue
{
	/**
	 * Only used by native code; allows the data store to create and initialize string nodes manually, rather than allowing
	 * the calling code to create a UIStringNode based on the value of StringValue or ImageValue
	 */
	var	const	native	transient	pointer		CustomStringNode{struct FUIStringNode};


};


/**
 * Encapsulates a reference to a UIStyle.  UIStyleReference supports the following features:
 *
 * - when a UIStyleReference does not have a valid STYLE_ID, the default style for this style reference (as determined by
 *		DefaultStyleTag + RequiredStyleClass) is assigned as the value for ResolvedStyle, but the value of AssignedStyleID
 *		is not modified.
 * - when a UIStyleReference has a valid STYLE_ID for the value of AssignedStyleID, but there is no style with that STYLE_ID
 *		in the current skin, ResolvedStyle falls back to using the default style for this style reference, but the value of
 *		AssignedStyleID is not modified.
 * - once a UIStyleReference has successfully resolved a style and assigned it to ResolvedStyle, it will not re-resolve the
 *		style until the style reference has been invalidated (by calling Invalidate); attempting to change the ResolvedStyle
 *		of this style reference to a style not contained in the currently active skin invalidates the ResolvedStyle.
 */
struct native UIStyleReference
{
	/**
	 * Specifies the name of the style to use if this style reference doesn't have a valid STYLE_ID (which indicates that the designer
	 * hasn't specified a style for this style reference
	 */
	var									name					DefaultStyleTag;

	/** if non-null, limits the type of style that can be assigned to this style reference */
	var const							class<UIStyle_Data>		RequiredStyleClass;

	/**
	 * The STYLE_ID for the style assigned to this style reference in the game's default skin.  This value is assigned when the designer
	 * changes the style for a style reference in the UI editor.  This value can be overridden by UICustomSkins.
	 */
	var	const							STYLE_ID				AssignedStyleID;

	/** the style data object that was associated with AssignedStyleID in the currently active skin */
	var	const transient	public{private}	UIStyle					ResolvedStyle;



};

const DEFAULT_SIZE_X = 1024;
const DEFAULT_SIZE_Y = 768;

const SCENE_DATASTORE_TAG='SceneData';

const MAX_SUPPORTED_GAMEPADS=4;


/**
 * Represents a screen position, either as number of pixels or percentage.
 * Used for single dimension (point) values.
 */
struct native UIScreenValue
{
	/** the value, in either pixels or percentage */
	var()		float					Value;

	/** how this UIScreenValue should be evaluated */
	var()		EPositionEvalType		ScaleType;

	/** the orientation associated with this UIScreenValue.  Used for evaluating relative or percentage scaling types */
	var()		EUIOrientation			Orientation;



structdefaultproperties
{
	ScaleType=EVALPOS_PixelViewport
	Orientation=UIORIENT_Horizontal
}

};


/**
 * Very similar to UIScreenValue (which represents a point within a widget), this data structure is used for representing
 * a sub-region of the screen, in a single dimension
 */
struct native UIScreenValue_Extent
{
	/** the value, in either pixels or percentage */
	var()		float					Value;

	/** how this extent value should be evaluated */
	var()		EUIExtentEvalType		ScaleType;

	/** the orientation associated with this extent.  Used for evaluating percentage scaling types */
	var()		EUIOrientation			Orientation;



structdefaultproperties
{
	Value=0.f
	ScaleType=UIEXTENTEVAL_Pixels
	Orientation=UIORIENT_Horizontal
}
};

/**
 * Represents a screen position, either as number of pixels or percentage.
 * Used for double dimension (orientation) values.
 */
struct native UIScreenValue_Position
{
	var()		float					Value[EUIOrientation.UIORIENT_MAX];
	var()		EPositionEvalType		ScaleType[EUIOrientation.UIORIENT_MAX];



structdefaultproperties
{
	ScaleType[UIORIENT_Horizontal] = EVALPOS_PixelOwner;
	ScaleType[UIORIENT_Vertical] = EVALPOS_PixelOwner;
}
};

/**
 * Represents a widget's position onscreen, either as number of pixels or percentage.
 * Used for four dimension (bounds) values.
 */
struct native UIScreenValue_Bounds
{
	/**
	 * The value for each face.  Can be a pixel or percentage value.
	 */
	var()	editconst public{private}		float							Value[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Specifies how the value for each face should be intepreted.
	 */
	var()	editconst public{private}		EPositionEvalType				ScaleType[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Indicates whether the position for each face has been modified since it was last resolved into screen pixels
	 * and applied to the owning widget's RenderBounds.  If this value is FALSE, it indicates that the RenderBounds for
	 * the corresponding face in the owning widget matches the position Value.  A value of TRUE indicates that the
	 * position Value for that face has been changed since it was last converted into RenderBounds.
	 */
	var		transient public{private}		byte							bInvalidated[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Specifies whether this position's values should be adjusted to constrain to the current aspect ratio.
	 *
	 * @fixme ronp - can't make editconst until we've exposed this to the position panel, context menu, and/or widget drag tools
	 */
	var()	/*editconst*/	public{private}		EUIAspectRatioConstraint		AspectRatioMode;



structdefaultproperties
{
	Value[UIFACE_Left]		= 0.0;
	Value[UIFACE_Top]		= 0.0;
	Value[UIFACE_Right]		= 1.0;
	Value[UIFACE_Bottom]	= 1.0;
	ScaleType[UIFACE_Left]	= EVALPOS_PercentageOwner;
	ScaleType[UIFACE_Top]	= EVALPOS_PercentageOwner;
	ScaleType[UIFACE_Right]	= EVALPOS_PercentageOwner;
	ScaleType[UIFACE_Bottom]= EVALPOS_PercentageOwner;
	bInvalidated[UIFACE_Left]	= 1;
	bInvalidated[UIFACE_Top]	= 1;
	bInvalidated[UIFACE_Right]	= 1;
	bInvalidated[UIFACE_Bottom]	= 1;
	AspectRatioMode=UIASPECTRATIO_AdjustNone;
}

};


/**
 * Data structure for describing the location of a widget's rotation pivot.  Defines a 2D point within a widget's bounds,
 * either in pixels or percentage, along with a z-depth value (in pixels)
 */
struct native UIAnchorPosition extends UIScreenValue_Position
{
	var()	/*editconst public{private}*/	float		ZDepth;


};

/**
 * Data structure for mapping a region on the screen.
 * Rather than representing an X,Y coordinate, this struct represents the beginning and end of a dimension (X1, X2)
 */
struct native ScreenPositionRange extends UIScreenValue_Position
{

};

struct native UIScreenValue_DockPadding
{
	/**
	 * The value for each face.  Can be in pixels or a percentage of the owning widget's bounding region, depending on the
	 * ScaleType for each face.
	 */
	var()	editconst public{private}		float							PaddingValue[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Specifies how the Value for each face should be intepreted.
	 */
	var()	editconst public{private}		EUIDockPaddingEvalType			PaddingScaleType[EUIWidgetFace.UIFACE_MAX];



structdefaultproperties
{
	PaddingValue[UIFACE_Left]		= 0.0;
	PaddingValue[UIFACE_Top]		= 0.0;
	PaddingValue[UIFACE_Right]		= 0.0;
	PaddingValue[UIFACE_Bottom]		= 0.0;
	PaddingScaleType[UIFACE_Left]	= UIPADDINGEVAL_Pixels;
	PaddingScaleType[UIFACE_Top]	= UIPADDINGEVAL_Pixels;
	PaddingScaleType[UIFACE_Right]	= UIPADDINGEVAL_Pixels;
	PaddingScaleType[UIFACE_Bottom]	= UIPADDINGEVAL_Pixels;
}

};

/**
 * Represents the constraint region for auto-sizing text.
 */
struct native UIScreenValue_AutoSizeRegion
{
	var()		float					Value[EUIAutoSizeConstraintType.UIAUTOSIZEREGION_MAX];
	var()		EUIExtentEvalType		EvalType[EUIAutoSizeConstraintType.UIAUTOSIZEREGION_MAX];



structdefaultproperties
{
	EvalType(UIAUTOSIZEREGION_Minimum)=UIEXTENTEVAL_Pixels
	EvalType(UIAUTOSIZEREGION_Maximum)=UIEXTENTEVAL_Pixels
}
};

/**
 * Data structure for representing the padding to apply to an auto-size region
 */
struct native AutoSizePadding extends UIScreenValue_AutoSizeRegion
{
};

/**
 * Defines parameters for auto-sizing a widget
 */
struct native AutoSizeData
{
	/** specifies the minimum and maximum values that the region can be auto-sized to */
	var()		UIScreenValue_AutoSizeRegion		Extent;

	/** the internal padding to apply to the region */
	var()		AutoSizePadding						Padding;

	/** whether auto-sizing is enabled for this dimension */
	var()		bool								bAutoSizeEnabled;


};

/**
 * Represents a sub-region within another render bounding region.
 */
struct native UIRenderingSubregion
{
	/** the size of the subregion; will be clamped to the size of the bounding region */
	var()	UIScreenValue_Extent	ClampRegionSize<DisplayName=Subregion Size>;

	/**
	 * Only relevant if ClampRegionAlignment is "Inherit/Other".  The offset for the sub-region, relative to the
	 * beginning of the bounding region.
	 */
	var()	UIScreenValue_Extent	ClampRegionOffset<DisplayName=Subregion Position>;

	/**
	 * the alignment for the sub-region; to enable "Subregion Position", this must be set to "Inherit/Other"
	 */
	var()	EUIAlignment			ClampRegionAlignment<DisplayName=Subregion Alignment>;

	/** Must be true to specify a subregion */
	var()	bool					bSubregionEnabled;

structdefaultproperties
{
	ClampRegionSize=(Value=1.f,ScaleType=UIEXTENTEVAL_PercentSelf)
	ClampRegionOffset=(ScaleType=UIEXTENTEVAL_PercentSelf)
	ClampRegionAlignment=UIALIGN_Default
}
};

/**
 * Represents a mapping of input key to widgets which contain EventComponents that respond to the associated input key.
 */
struct native transient InputEventSubscription
{
	/** The name of the key represented by this InputEventSubscription (i.e. KEY_XboxTypeS_LeftTrigger, etc.) */
	var		name						KeyName;

	/** a list of widgets which are eligible to process this input key event */
	var		array<UIScreenObject>		Subscribers;


};

/**
 * Represents a UIEvent that should be automatically added to all instances of a particular widget.
 */
struct native DefaultEventSpecification
{
	/** the UIEvent template to use when adding the event instance to a widget's EventProvider */
	var	UIEvent				EventTemplate;

	/**
	 * Optionally specify the state in which this event should be active.  The event will be added to
	 * the corresponding UIState instance's list of events, rather than the widget's list of events
	 */
	var	class<UIState>		EventState;
};

/**
 * Associates a UIAction with input key name.
 */
struct native InputKeyAction
{
	/** the input key name that will activate the action */
	var()	name					InputKeyName;

	/** the state (pressed, released, etc.) that will activate the action */
	var()	EInputEvent				InputKeyState;

	/** The actions to execute */
	var()	array<SequenceAction>	ActionsToExecute;



structdefaultproperties
{
	InputKeyState=IE_Released
}
};

/**
 * Specialized version of InputKeyAction used for constraining the input action to a particular UIState.
 */
struct native StateInputKeyAction extends InputKeyAction
{
	/**
	 * Allows an input action to be tied to a specific UIState. If NULL, the action will be active
	 * in all states that support UIEvent_ProcessInput.  If non-NULL, the input key will only be accepted
	 * when the widget is in the specified state.
	 */
	var()	class<UIState>	Scope;



structdefaultproperties
{
	Scope=class'UIState_Enabled'
}
};

/**
 * Tracks widgets which are currently in special states.
 */
struct native transient PlayerInteractionData
{
	/** The widget/scene that currently has focus */
	var		transient	UIObject			FocusedControl;

	/** The widget/scene that last had focus */
	var		transient	UIObject			LastFocusedControl;


};

/**
 * Contains information about how to propagate focus between parent and child widgets.
 */
struct native UIFocusPropagationData
{
	/**
	 * Specifies the child widget that should automatically receive focus when this widget receives focus.
	 * Set automatically when RebuildNavigationLinks() is called on the owning widget.
	 */
	var()	const	editconst	transient	UIObject	FirstFocusTarget;


	/**
	 * Specifies the child widget which will automatically receive focus when this widget receives focus and the user
	 * is navigating backwards through the scene (i.e. Shift+Tab).
	 * Set automatically when RebuildNavigationLinks() is called on the owning widget.
	 */
	var()	const	editconst	transient	UIObject	LastFocusTarget;

	/**
	 * Specifies the sibling widget that is next in the tab navigation system for this widget's parent.
	 * Set automatically when RebuildNavigationLinks() is called on the owning widget.
	 */
	var()	const	editconst	transient	UIObject	NextFocusTarget;

	/**
	 * Specifies the sibling widget that is previous in the tab navigation system for this widget's parent.
	 * Set automatically when RebuildNavigationLinks() is called on the owning widget.
	 */
	var()	const	editconst	transient	UIObject	PrevFocusTarget;

	/**
	 * Indicates that this widget is currently becoming the focused control.  Used for preventing KillFocus from clobbering this
	 * pending focus change if one of this widget's children is the currently focused control (since killing focus on a child of this
	 * widget would normally cause this widget to lose focus as well
	 */
	var							transient	bool		bPendingReceiveFocus;


};

/**
 * Defines the navigation links for a widget.
 */
struct native UINavigationData
{
	/**
	 * The widgets that will receive focus when the user presses the corresonding direction.  For keyboard navigation, pressing
	 * "tab" will set focus to the widget in the UIFACE_Right slot, pressing "shift+tab" will set focus to the widget in the
	 * UIFACE_Left slot.
	 *
	 * Filled in at runtime when RebuildNavigationLinks is called.
	 */
	var()	editconst	transient	UIObject			NavigationTarget[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Allows the designer to override the auto-generated focus target for each face.  If a value is set for NavigationTarget,
	 * that widget will always be set as the value for CurrentNavTarget for that face.
	 */
	var()	editconst				UIObject			ForcedNavigationTarget[EUIWidgetFace.UIFACE_MAX];

	/**
	 * By default, a NULL value for the forced nav taget indicates that the nav target for that face should be automatically
	 * calculated.  bNullOverride indicates that a value of NULL *is* the designer specified nav target.
	 */
	var()							byte				bNullOverride[EUIWidgetFace.UIFACE_MAX];


};

/**
 * Defines the desired docking behavior for all faces of a single widget
 */
struct native UIDockingSet
{
	/**
	 * The widget that is associated with this docking set.  Set by InitializeDockingSet().
	 */
	var		const							UIObject			OwnerWidget;

	/**
	 * The widget that will be docked against.
	 * If this value is NULL, it means that docking isn't enabled for this face
	 * If this value points to OwnerWidget, it means that the face is docked to the owner scene.
	 */
	var()	editconst	private{private}	UIObject			TargetWidget[EUIWidgetFace.UIFACE_MAX];

	/**
	 * The amount of padding to use for docking each face.  Positive values are considered "inside" padding,
	 * while negative values are considered "outside" padding.
	 */
	var()	editconst	private{private}	UIScreenValue_DockPadding			DockPadding;

	/**
	 * Controls whether the width of this widget should remain constant when adjusting the position of the left or right
	 * face as a result of docking.  Only relevant when either the left or right faces are docked.
	 */
	var()				public{private}		bool				bLockWidthWhenDocked;

	/**
	 * Controls whether the height of this widget should remain constant when adjusting the position of the top or bottom
	 * face as a result of docking.  Only relevant when either the top or bottom faces are docked.
	 */
	var()				public{private}		bool				bLockHeightWhenDocked;

	/** The face on the TargetWidget that this docking set applies to. */
	var()	editconst	private{private}	EUIWidgetFace		TargetFace[EUIWidgetFace.UIFACE_MAX];

	/** tracks whether each face has been resolved (via UpdateDockingSet).  Reset whenever ResolveScenePositions is called */
	var		transient						byte				bResolved[EUIWidgetFace.UIFACE_MAX];

	/**
	 * set to 1 when this node is in the process of being added to the scene's docking stack; used to easily
	 * track down circular relationships between docking sets
	 */
	var		transient						byte				bLinking[EUIWidgetFace.UIFACE_MAX];



structdefaultproperties
{
	TargetFace(UIFACE_Left)=UIFACE_MAX
	TargetFace(UIFACE_Top)=UIFACE_MAX
	TargetFace(UIFACE_Right)=UIFACE_MAX
	TargetFace(UIFACE_Bottom)=UIFACE_MAX
}
};

/**
 * A widget/face pair.  Used by the docking system to track the order in which widget face positions should be evaluated
 */
struct native UIDockingNode
{
	/** the widget that this docking node is associated with */
	var()			UIObject						Widget;

	/** the face on the Widget that should be updated when this docking node is processed */
	var()			EUIWidgetFace					Face;


};


/**
 * Data structure for representation the rotation of a UI Widget.
 */
struct native UIRotation
{
	/** the UE representation of the rotation of the widget */
	var()					rotator						Rotation;

	/**
	 * Transform matrix to use for rendering the widget.
	 */
	var	transient			matrix						TransformMatrix;

	/** point used for the origin in rotation animations */
	var()					UIAnchorPosition			AnchorPosition;

	/** defines whether the AnchorPosition is used or one of the presets */
	var()					ERotationAnchor				AnchorType;



structdefaultproperties
{
	TransformMatrix=(XPlane=(X=1,Y=0,Z=0,W=0),YPlane=(X=0,Y=1,Z=0,W=0),ZPlane=(X=0,Y=0,Z=1,W=0),WPlane=(X=0,Y=0,Z=0,W=1))
	AnchorType=RA_Center

	// this should already be the default scaletype, but no harm in making sure
	AnchorPosition=(ScaleType[UIORIENT_Horizontal]=EVALPOS_PixelOwner,ScaleType[UIORIENT_Vertical]=EVALPOS_PixelOwner)
}
};

/**
 * Contains information about a UI data store binding, including the markup text used to reference the data store and
 * the resolved value of the markup text.
 *
 * @NOTE: if you move this struct declaration to another class, make sure to update UUIObject::GetDataBindingProperties()
 */
struct native UIDataStoreBinding
{
	/**
	 * The UIDataStoreSubscriber that contains this UIDataStoreBinding
	 */
	var		const	transient		UIDataStoreSubscriber		Subscriber;

	/**
	 * Indicates which type of data fields can be used in this data store binding
	 */
	var()	const	editconst		EUIDataProviderFieldType	RequiredFieldType;

	/**
	 * A datastore markup string which resolves to a property/data type exposed by a UI data store.
	 *
	 * @note: cannot be editconst until we have full editor support for manipulating markup strings (e.g. inserting embedded
	 * markup, etc.)
	 */
	var()	const	/*editconst*/		string					MarkupString;

	/**
	 * Used to differentiate multiple data store properties in a single class.
	 */
	var		const	transient		int							BindingIndex;

	/** the name of the data store resolved from MarkupString */
	var		const	transient		name						DataStoreName;

	/** the name of the field resolved from MarkupString; must be a field supported by ResolvedDataStore */
	var		const	transient		name						DataStoreField;

	/** a pointer to the data store resolved from MarkupString */
	var		const	transient		UIDataStore					ResolvedDataStore;



structdefaultproperties
{
	BindingIndex=INDEX_NONE
	RequiredFieldType=DATATYPE_MAX
}
};

/**
 * Pairs a unique name with a UIStyleResolver reference.
 *
 * not currently used.
 */
struct transient native UIStyleSubscriberReference
{
	/**
	 * A unique name for identifying this StyleResolver - usually the name of the property referencing this style resolver
	 * Used for differentiating styles from multiple UIStyleResolvers of the same class.
	 */
	var		name				SubscriberId;

	/** the reference to the UIStyleResolver object */
	var		UIStyleResolver		Subscriber;


};

/**
 * Container used for identifying UIStyleReference properties from multiple UIStyleResolvers of the same class
 */
struct transient native StyleReferenceId
{
	/** The tag to use for this UIStyleResolver's properties */
	var		name		StyleReferenceTag;

	/** the actual UIStyleReference property */
	var		Property		StyleProperty;


};

/** Defines a group of attributes that can be applied to text, such as bold, italic, underline, shadow, etc. */
struct native UITextAttributes
{
	var()		bool					Bold<ToolTip=Not yet implemented>;
	var()		bool					Italic<ToolTip=Not yet implemented>;
	var()		bool					Underline<ToolTip=Not yet implemented>;
	var()		bool					Shadow<ToolTip=Not yet implemented>;
	var()		bool					Strikethrough<ToolTip=Not yet implemented>;


};

/** Describes the parameters for adjusting a material to match the dimensions of a target region. */
struct native UIImageAdjustmentData
{
	/** size of buffer zone for constraining the image adjustment */
	var()			ScreenPositionRange				ProtectedRegion<DisplayName=Gutter|ToolTip=Controls the size of the region that should be ignored by any scaling>;

	/** the type of adjustment to perform to the image for each orientation */
	var()			EMaterialAdjustmentType			AdjustmentType<DisplayName=Scale Type|ToolTip=Controls how the image should be fitted to the bounding region>;

	/** alignment within the region */
	var()			EUIAlignment					Alignment<DisplayName=Image Alignment|ToolTip=Controls how the image will be aligned within the bounding region>;



structdefaultproperties
{
	AdjustmentType=ADJUST_Normal
}
};

/** Coordinates for mapping a piece of a texture atlas */
struct native TextureCoordinates
{
	var()	float		U, V, UL, VL;


};

struct native UIStringCaretParameters
{
	/** Controls whether a caret is displayed at all */
	var()			bool				bDisplayCaret;

	/**
	 * Determines which color pen (from GameUISceneClient's DefaultUITextures) is used to render the caret
	 */
	var()			EUIDefaultPenColor	CaretType;

	/** Specifies the width of the caret, in pixels */
	var()			float				CaretWidth;

	/** the tag of the style to use for displaying this caret */
	var()			name				CaretStyle;

	/**
	 * The current position of the caret in the string
	 */
	var	transient	int					CaretPosition;

	/**
	 * For carets that use parametized materials, the MaterialInterface that was created for this caret
	 */
	var	transient	MaterialInterface	CaretMaterial;

structdefaultproperties
{
	CaretType=UIPEN_White
	CaretWidth=1.0f
	CaretStyle=DefaultCaretStyle
}
};

/**
 * General purpose data structure for grouping all parameters needed when rendering or sizing a string/image
 */
struct native transient RenderParameters
{
	/** a pixel value representing the horizontal screen location to begin rendering the string */
	var		float				DrawX;

	/** a pixel value representing the vertical screen location to begin rendering the string */
	var		float				DrawY;

	/** a pixel value representing the width of the area available for rendering the string */
	var		float				DrawXL;

	/** a pixel value representing the height of the area available for rendering the string */
	var		float				DrawYL;

	/**
	 * A value between 0.0 and 1.0, which represents how much the width/height should be scaled,
	 * where 1.0 represents 100% scaling.
	 */
	var		Vector2D			Scaling;

	/** the font to use for rendering/sizing the string */
	var		Font				DrawFont;

	/** The alignment for the string we are drawing. */
	var     EUIAlignment		TextAlignment[EUIOrientation.UIORIENT_MAX];

	/**
	 * Only used when rendering string nodes that contain images.
	 * Represents the size to use for rendering the image
	 */
	var		Vector2D			ImageExtent;

	/** the coordinates to use to render images */
	var		TextureCoordinates	DrawCoords;

	/** Horizontal spacing adjustment between characters and vertical spacing adjustment between wrapped lines */
	var		Vector2D			SpacingAdjust;

	/** the current height of the viewport; needed to support multifont */
	var		float				ViewportHeight;



};

/**
 * Container for text autoscaling values.
 */
struct native TextAutoScaleValue
{
	/**
	 * the minimum and maximum amount of scaling that can be applied to the text; these values must be set in order for
	 * auto-scaling to be used in conjunction with any type of string formatting (i.e. wrapping, clipping, etc.).  Negative
	 * values will be ignored and a value of 0 indicates that MinScale is not enabled.
	 */
	var()				float	MinScale<DisplayName=Min Scale Value>;

	/** Allows text to be scaled to fit within the bounding region */
	var()	ETextAutoScaleMode	AutoScaleMode<DisplayName=Auto Scaling|ToolTip=Scales the text so that it fits into the bounding region>;

structdefaultproperties
{
	AutoScaleMode=UIAUTOSCALE_None
	MinScale=0.6
}


};

/**
 * This struct contains properties which override values in a style.
 */
struct native UIStyleOverride
{
	/**
	 * Color to use for rendering the string or image.  Values for each color range from 0.0 to 1.0, where
	 * 0.0 means "none of this color" and 1.0 means "full-color".  Use values higher than 1.0 to create a
	 * "bloom" effect behind the text.  Give DrawColor.A a value higher than 1.0 in order to bloom all colors
	 * uniformly. (requires UI post processing to be enabled - UISceneClient.bEnablePostProcess and the owning
	 * scene's bEnableScenePostProcessing properties must both be set to TRUE).
	 *
	 */
	var()				LinearColor			DrawColor<DisplayName=Draw Color|EditCondition=bOverrideDrawColor>;

	/**
	 * Provides a simple way for overriding the opacity of the text regardless of the DrawColor's Alpha value
	 * A value of 0.0 means "completely transparent"; a value of 1.0 means "completely opaque".  Use values greater
	 * than 1.0 to bloom the DrawColor uniformly. (requires UI post processing to be enabled -
	 * UISceneClient.bEnablePostProcess and the owning scene's bEnableScenePostProcessing properties must both be
	 * set to TRUE).
	 */
	var()				float				Opacity<DisplayName=Opacity|EditCondition=bOverrideOpacity>;

	/**
	 * The amount of padding to apply for each orientation, in pixels.  Padding will be scaled against the value of the
	 * DEFAULT_SIZE_Y const (currently 1024).
	 */
	var()				float				Padding[EUIOrientation.UIORIENT_MAX]<DisplayName=Padding|EditCondition=bOverridePadding>;

	/** indicates whether the draw color has been customized */
	var		public{private}	bool			bOverrideDrawColor;

	/** Allow us to override the final alpha */
	var		public{private}	bool			bOverrideOpacity;

	/** Indicates whether the padding has been customized */
	var		public{private}	bool			bOverridePadding;

	structdefaultproperties
	{
		DrawColor=(R=1.f,B=1.f,G=1.f,A=1.f)
		Opacity=1.f
	}

	
};

/**
 * This struct is used to override values from a text style.
 */
struct native UITextStyleOverride extends UIStyleOverride
{
	/** The font to use for rendering text */
	var()				Font				DrawFont<DisplayName=Draw Font|EditCondition=bOverrideDrawFont>;

	/** Attributes to apply to the text, such as bold, italic, etc. */
	var()				UITextAttributes	TextAttributes<DisplayName=Attributes|EditCondition=bOverrideAttributes>;

	/** Text alignment within the bounding region */
	var()				EUIAlignment		TextAlignment[EUIOrientation.UIORIENT_MAX]<DisplayName=Text Alignment|EditCondition=bOverrideAlignment>;

	/**
	 * Determines what happens when the text doesn't fit into the bounding region.
	 */
	var() 				ETextClipMode		ClipMode<DisplayName=Clip Mode|ToolTip=Controls how the string is formatted when it doesn't fit into the bounding region|EditCondition=bOverrideClipMode>;

	/** Determines how the nodes of this string are ordered when the string is being clipped */
	var()				EUIAlignment		ClipAlignment<DisplayName=Clip Alignment|ToolTip=Determines which part of the string should be clipped when it doesn't fit into the bounding region only relevant is wrap mode is Clipped or wrapped)|EditCondition=bOverrideClipAlignment>;

	/** Allows text to be scaled to fit within the bounding region */
	var()				TextAutoScaleValue	AutoScaling<DisplayName=Auto Scaling|ToolTip=Scales the text so that it fits into the bounding region|EditCondition=bOverrideAutoScale>;

	/** Scale for rendering text */
	var()				float				DrawScale[EUIOrientation.UIORIENT_MAX]<DisplayName=Text Scale|EditCondition=bOverrideScale>;

	/** Sets the horizontal spacing adjustment between characters (in pixels), as well as the vertical spacing adjustment between lines of wrapped text (in pixels). */
	var()				float				SpacingAdjust[EUIOrientation.UIORIENT_MAX]<DisplayName=Spacing Adjust|EditCondition=bOverrideSpacingAdjust>;

	/** indicates whether the draw font has been customized */
	var		public{private}	bool			bOverrideDrawFont;

	/** indicates whether the coordinates have been customized */
	var		public{private}	bool			bOverrideAttributes;

	/** indicates whether the formatting has been customized */
	var		public{private}	bool			bOverrideAlignment;

	/** indicates whether the clipping mode has been customized */
	var		public{private}	bool			bOverrideClipMode;

	/** indicates whether the clip alignment has been customized */
	var		public{private}	bool			bOverrideClipAlignment;

	/** indicates whether the autoscale mode has been customized */
	var		public{private}	bool			bOverrideAutoScale;

	/** indicates whether the scale factor has been customized */
	var		public{private}	bool			bOverrideScale;

	/** indicates whether the spacing adjust has been customized */
	var		public{private}	bool			bOverrideSpacingAdjust;


	structdefaultproperties
	{
		DrawScale(UIORIENT_Horizontal)=1.f
		DrawScale(UIORIENT_Vertical)=1.f
	}

	
};

/**
 * Contains data for overriding the corresponding data in an image style.
 */
struct native UIImageStyleOverride extends UIStyleOverride
{
	/** if DefaultImage points to a texture atlas, represents the coordinates to use for rendering this image */
	var()			TextureCoordinates		Coordinates<DisplayName=UV Coordinates|EditCondition=bOverrideCoordinates>;

	/** Information about how to modify the way the image is rendered. */
	var()			UIImageAdjustmentData	Formatting[EUIOrientation.UIORIENT_MAX]<EditCondition=bOverrideFormatting>;

	/** indicates whether the coordinates have been customized */
	var		public{private}	bool			bOverrideCoordinates;

	/** indicates whether the formatting has been customized */
	var		public{private}	bool			bOverrideFormatting;

	
};

/**
 * Container for all data contained by UI styles.  Used for applying inline modifications to UIString nodes,
 * such as changing the font, draw color, or attributes
 *
 * @todo - support for embedded markup, such as <font>blah blah<font>blah blah</font></font>
 */
struct native transient UICombinedStyleData
{
	/** color to use for rendering text */
	var	LinearColor					TextColor;

	/** color to use for rendering images */
	var LinearColor					ImageColor;

	/** padding to use for rendering text */
	var	float						TextPadding[EUIOrientation.UIORIENT_MAX];

	/** padding to use for rendering images */
	var float						ImagePadding[EUIOrientation.UIORIENT_MAX];

	/** the font to use when rendering text */
	var	Font						DrawFont;

	/** the material to use when rendering images if the image material cannot be loaded or isn't set */
	var	Surface						FallbackImage;

	/** the coordinates to use if FallbackImage is a texture atlas */
	var	TextureCoordinates			AtlasCoords;

	/** attributes to apply to this style's font */
	var	UITextAttributes			TextAttributes;

	/** text alignment within the bounding region */
	var	EUIAlignment				TextAlignment[EUIOrientation.UIORIENT_MAX];

	/** determines how strings that overrun the bounding region are handled */
	var	ETextClipMode				TextClipMode;

	/** Determines how the nodes of this string are ordered when the string is being clipped */
	var	EUIAlignment				TextClipAlignment;

	/** Information about how to modify the way the image is rendered. */
	var	UIImageAdjustmentData		AdjustmentType[EUIOrientation.UIORIENT_MAX];

	/** Allows text to be scaled to fit within the bounding region */
	var	TextAutoScaleValue			TextAutoScaling;

	/** text scale to use when rendering text */
	var Vector2D					TextScale;

	/** Horizontal spacing adjustment between characters and vertical spacing between wrapped lines of text */
	var Vector2D					TextSpacingAdjust;

	/** indicates whether this style data container has been initialized */
	var	const	private{private}	bool	bInitialized;

	structdefaultproperties
	{
		TextScale=(X=1.f,Y=1.f)
		TextClipMode=CLIP_MAX
	}

	
};

/**
 * This struct contains data about the current modifications that are being applied to a string as it is being parsed, such as any inline styles, fonts, or attributes.
 */
struct native transient UIStringNodeModifier
{
	/**
	 * The current style data to apply to each new string node that is created
	 *
	 * @note: when data stores need to access additional fields of this member, add accessors to this struct rather than removing the private access specifier
	 */
	var	const	transient	public{private}		UICombinedStyleData		CustomStyleData;

	/**
	 * Optional style data that this UIStringNodeModifier was initialized from.  If BaseStyleData is not valid, there must be at least one
	 * UIStyle in the ModifierStack.
	 */
	var	const	transient	public{private}		UICombinedStyleData		BaseStyleData;

	/**
	 * Contains data about a custom inline style, along with the inline fonts that have been activated while this style was
	 * the current style.  Handles proper interaction between nested font and style inline markup.
	 */
	struct native transient ModifierData
	{
		/**
		 * the style for this data block.  Refers to either the UIString's DefaultStringStyle, or a style resolved from
		 * an inline style markup reference (i.e. Styles:SomeStyle)
		 */
		var	const	transient	UIStyle_Data	Style;

		/**
		 * The fonts that have been resolved from inline font markup while this style was the current style.
		 */
		var	const	transient	array<Font>		InlineFontStack;
	};

	var	const	transient	private{private}	array<ModifierData>		ModifierStack;

	/**
	 * The current menu state of the widget that owns the source UIString.
	 */
	var	const	transient	private{private}	UIState					CurrentMenuState;

	//@todo - Attribute stack, etc.


};

/**
 * Represents a single text block (or inline image), where all of the text is the same style/font,etc.
 * Able to calculate its extend at any time
 */
struct native transient UIStringNode
{
	/**
	 * The vtable for this struct.
	 */
	var		native	const	transient	noexport	pointer		VfTable;

	/**
	 * The data store that was resolved from this string nodes markup.  NULL if this string node doesn't
	 * contain data store markup text.
	 */
	var				const	transient	UIDataStore				NodeDataStore;

	/**
	 * For slave nodes (such as nodes that were created as a result of wrapping or nested markup resolution), the original
	 * node which contains the markup source text for this entire group of nodes.
	 */
	var		native	const	transient	pointer					ParentNode{FUIStringNode};

	/**
	 * The original text that is represented by this string node.  For example, for a UITextNode that represents
	 * some bold text, the original text would look like:
	 * <b>some text</b>
	 * For an image node, the original text might look like:
	 * <img={SOME_ID}>
	 *
	 * @fixme - hmmm, should this be changed to be a UIDataStoreBinding instead?
	 */
	var()	string		SourceText;

	/**
	 * Represents the width and height of this string node in pixels.  Can be calculated dynamically based on
	 * the content of the node, or set by the parent UIString to some preconfigured value.
	 */
	var()	vector2D	Extent;

	/**
	 * A value between 0.0 and 1.0, which represents the amount of scaling the apply to the node's Extent,
	 * where 1.0 represents 100% scaling.  Typically only specified per-node for image nodes.
	 */
	var()	vector2D	Scaling;

	/**
	 * if TRUE, this node should be the last node on the current line
	 */
	var		bool		bForceWrap;



structdefaultproperties
{
	Scaling=(X=1.f,Y=1.f)
}
};

/**
 * Specialized text node for rendering text in a UIString.
 */
struct native transient UIStringNode_Text extends UIStringNode
{
	/**
	 * This is the string that will actually be drawn.  It doesn't contain any markup (that's stored in OriginalText),
	 * and is the string that is used to determine the extent of this string.
	 */
	var()	string								RenderedText;

	/**
	 * The style property values to use for rendering this node.  Initialized based on the default text style of the parent
	 * UIString, then customized by any attribute markup in the source text for this node.
	 */
	var	public{protected}	UICombinedStyleData	NodeStyleParameters;


};

/**
 * Specialized text node for rendering images in a UIString.
 */
struct native transient UIStringNode_Image extends UIStringNode
{
	/**
	 * The extent to use for this image node.  If this value is zero, the image node uses the size of the image
	 * to calculate its extent
	 */
	var()	Vector2D				ForcedExtent;

	/** Texture coordinates to use when rendering the image node's texture. If the TextureCoordinates struct is all zero, the entire texture will be drawn. */
	var()	TextureCoordinates		TexCoords;

	/**
	 * A pointer to the image being displayed by this text node.  The RenderedImage's ImageStyle will be
	 * initialized from the parent UIString's default image style, then customized by any attribute markup
	 * found in the source text for this node.
	 */
	var()	UITexture				RenderedImage;


};

/**
 * This node type is created when a string node's resolved value contains embedded markup text.  This node stores the original markup
 * text and the data store that was resolved from the original markup.
 */
struct native transient UIStringNode_NestedMarkupParent extends UIStringNode
{

};

/**
 * This node is created when when a string node's resolved value is wrapped into multiple lines (or otherwise formatted).
 * This node stores the source and render text from the pre-formatted node, but is never rendered.
 */
struct native transient UIStringNode_FormattedNodeParent extends UIStringNode_Text
{

};

/**
 * Used by UUIString::WrapString to track information about each line that is generated as the result of wrapping.
 */
struct native transient WrappedStringElement
{
	/** the string associated with this line */
	var	string		Value;

	/** the size (in pixels) that it will take to render this string */
	var Vector2D	LineExtent;


};

/**
 * Contains information about a mouse cursor resource that can be used ingame.
 */
struct native export UIMouseCursor
{
	/** the tag of the style to use for displaying this cursor */
	var()	name			CursorStyle;

	/** The actual cursor resource */
	var()	UITexture		Cursor;
};

/**
 * This struct contains all data used by the various UI input processing methods.
 */
struct native transient InputEventParameters
{
	/**
	 * Index [into the Engine.GamePlayers array] for the player that generated this input event.  If PlayerIndex is not
	 * a valid index for the GamePlayers array, it indicates that this input event was generated by a gamepad that is not
	 * currently associated with an active player
	 */
	var	const transient	int				PlayerIndex;

	/**
	 * The ControllerId that generated this event.  Not guaranteed to be a ControllerId associated with a valid player.
	 */
	var	const transient	int				ControllerId;

	/**
	 * Name of the input key that was generated, such as KEY_Left, KEY_Enter, etc.
	 */
	var	const transient	name			InputKeyName;

	/**
	 * The type of input event generated (i.e. IE_Released, IE_Pressed, IE_Axis, etc.)
	 */
	var	const transient	EInputEvent		EventType;

	/**
	 * For input key events generated by analog buttons, represents the amount the button was depressed.
	 * For input axis events (i.e. joystick, mouse), represents the distance the axis has traveled since the last update.
	 */
	var	const transient	float			InputDelta;

	/**
	 * For input axis events, represents the amount of time that has passed since the last update.
	 */
	var	const transient	float			DeltaTime;

	/**
	 * For PC input events, tracks whether the corresponding modifier keys are pressed.
	 */
	var	const transient bool			bAltPressed, bCtrlPressed, bShiftPressed;


};

/**
 * Contains additional data for an input event which a widget has registered for (via UUIComp_Event::RegisterInputEvents).is
 * in the correct state capable of processing is registered to handle.the data for a Stores the UIInputAlias name translated from a combination of input key, input event type, and modifier keys.
 */
struct native transient SubscribedInputEventParameters extends InputEventParameters
{
	/**
	 * Name of the UI input alias determined from the current input key, event type, and active modifiers.
	 */
	var	const transient	name			InputAliasName;


};

/**
 * Contains information for simulating a button press input event in response to axis input.
 */
struct native UIAxisEmulationDefinition
{
	/**
	 * The axis input key name that this definition represents.
	 */
	var	name	AxisInputKey;

	/**
	 * The axis input key name that represents the other axis of the joystick associated with this axis input.
	 * e.g. if AxisInputKey is MouseX, AdjacentAxisInputKey would be MouseY.
	 */
	var	name	AdjacentAxisInputKey;

	/**
	 * Indicates whether button press/release events should be generated for this axis key
	 */
	var	bool	bEmulateButtonPress;

	/**
	 * The button input key that this axis input should emulate.  The first element corresponds to the input key
	 * that should be emulated when the axis value is positive; the second element corresponds to the input key
	 * that should be emulated when the axis value is negative.
	 */
	var	name	InputKeyToEmulate[2];
};

struct native export RawInputKeyEventData
{
	/** the name of the key (i.e. 'Left' [KEY_Left], 'LeftMouseButton' [KEY_LeftMouseButton], etc.) */
	var		name	InputKeyName;

	/**
	 * a bitmask of values indicating which modifier keys are associated with this input key event, or which modifier
	 * keys are excluded.  Bit values are:
	 *	0: Alt active (or required)
	 *	1: Ctrl active (or required)
	 *	2: Shift active (or required)
	 *	3: Alt excluded
	 *	4: Ctrl excluded
	 *	5: Shift excluded
	 *
	 * (key states)
	 *	6: Pressed
	 *	7: Released
	 */
	var		byte	ModifierKeyFlags;

structdefaultproperties
{
	ModifierKeyFlags=56		//	1<<3 + 1<<4 + 1<<5 (alt, ctrl, shift excluded)
}


};

/**
 * Stores a list of input key names that should be linked to an input action alias key (i.e. NAV_Left, NAV_Right)
 * Used by the UI system to handle input events in a platform & game agnostic way.
 */
struct native export UIInputActionAlias
{
	/** the name of an input action alias that the UI responds to */
	var name			InputAliasName;

	/**
	 * the input key names (e.g. KEY_Left, KEY_Right) and modifier which will trigger this input alias
	 */
	var	array<RawInputKeyEventData>	LinkedInputKeys;
};

/**
 * Combines an input alias name with the modifier flag bitmask required to activate it.
 */
struct native transient export UIInputAliasValue
{
	/**
	 * a bitmask representing the modifier key state required to activate this input alias
	 */
	var	byte	ModifierFlagMask;

	/** the name of the input alias */
	var	name	InputAliasName;


};

/**
 * A TMultiMap wrapper which maps input key names (i.e. KEY_Left) to a list of input action alias data.
 */
struct native export UIInputAliasMap
{
	/**
	 * A mapping from input key data (name + modifier key) <==> input alias triggered by that input key event
	 * Used to retrieve the input action alias for a given input key when input events are received.
	 */
	var const native transient MultiMap_Mirror			InputAliasLookupTable{TMultiMap< FName, FUIInputAliasValue >};


};

/**
 * Defines the list of key mappings supported in a paticular widget state.
 */
struct native export UIInputAliasStateMap
{
	/** the path name for the state class to load */
	var	string										StateClassName;

	/** The widget state that this map contains input aliases for. */
	var class<UIState>								State;

	/** the input action aliases that this widget state supports */
	var array<UIInputActionAlias>					StateInputAliases;
};

/**
 * Defines the UIInputActionAliases that are supported by a particular widget class for each state.
 *
 * @todo ronp - add support for specifying "input alias => raw input key" mappings for widget archetypes
 */
struct native UIInputAliasClassMap
{
	/** the name of the widget class to load */
	var	string																	WidgetClassName;

	/** the widget class that this UIInputAliasMap contains input aliases for */
	var class<UIScreenObject>													WidgetClass;

	/** the states that this widget class supports */
	var array<UIInputAliasStateMap>												WidgetStates;

	/**
	 * Runtime lookup map to find a input alias map.  Maps a UIState class <=> (map of input key name (KEY_Left) + modifier keys <=> input key alias (UIKEY_Clicked)).
	 * Used for quickly unregistering input keys when a state goes out of scope.
	 */
	var const native transient Map{UClass*,  FUIInputAliasMap}					StateLookupTable;

	/**
	 * Runtime lookup map to find a state input struct.  Maps a UIState class => (map of input key alias (UIKEY_Clicked) => input key name (KEY_Left))
	 * Used for quickly registering input keys when a state enters scope - since multiple input keys can be mapped to a single input key alias, and
	 * each input key alias name must be checked against the list of disabled input aliases, storing this reverse lookup table allows us to check only
	 * once for each input alias.
	 */
	var const native transient Map{UClass*,  TArray<const FUIInputAliasStateMap*>}	StateReverseLookupTable;

	
};





/**
 * @return Returns the current platform the game is running on.
 */
static final function bool IsConsole( optional EConsoleType ConsoleType=CONSOLE_Any )
{
	return class'WorldInfo'.static.IsConsoleBuild(ConsoleType);
}

/**
 * Returns the UIInteraction instance currently controlling the UI system, which is valid in game.
 *
 * @return	a pointer to the UIInteraction object currently controlling the UI system.
 */
native static final noexport function UIInteraction GetCurrentUIController();

/**
 * Returns the game's scene client.
 *
 * @return 	a pointer to the UGameUISceneClient instance currently managing the scenes for the UI System.
 */
native static final noexport function GameUISceneClient GetSceneClient();

/**
 * Wrapper for returns the orientation associated with the specified face.
 *
 * @note: noexport because the C++ version is static too.
 */
native static final noexport function EUIOrientation GetFaceOrientation( EUIWidgetFace Face );

/**
 * Returns the current position of the mouse or joystick cursor.
 *
 * @param	CursorX		receives the X position of the cursor
 * @param	CursorY		receives the Y position of the cursor
 * @param	Scene		if specified, provides access to an FViewport through the scene's SceneClient that can be used
 *						for retrieving the mouse position when not in the game.
 *
 * @return	TRUE if the cursor position was retrieved correctly.
 */
native static final noexport function bool GetCursorPosition( out int CursorX, out int CursorY, const optional UIScene Scene );

/**
 * Returns the current position of the mouse or joystick cursor.
 *
 * @param	CursorXL	receives the width of the cursor
 * @param	CursorYL	receives the height of the cursor
 *
 * @return	TRUE if the cursor size was retrieved correctly.
 */
native static final noexport function bool GetCursorSize( out float CursorXL, out float CursorYL );

/**
 * Changes the value of GameViewportClient.bUIMouseCaptureOverride to the specified value.  Used by widgets that process
 * dragging to ensure that the widget receives the mouse button release event.
 *
 * @param	bCaptureMouse	whether to capture all mouse input.
 */
native static final noexport function SetMouseCaptureOverride( bool bCaptureMouse );

/**
 * Returns a matrix which includes the translation, rotation and scale necessary to transform a point from origin to the
 * the specified widget's position onscreen.  This matrix can then be passed to ConditionalUpdateTransform() for primitives
 * in use by the UI.
 *
 * @param	Widget	the widget to generate the matrix for
 * @param	bIncludeAnchorPosition	specify TRUE to include translation to the widget's anchor; if FALSE, the translation will move
 *									the point to the widget's upper left corner (in local space)
 * @param	bIncludeRotation		specify FALSE to remove the widget's rotation from the resulting matrix
 * @param	bIncludeScale			specify FALSE to remove the viewport's scale from the resulting matrix
 *
 * @return	a matrix which can be used to translate from origin (0,0) to the widget's position, including rotation and viewport scale.
 *
 * @note: noexport because we want this method to be static in C++ as well.
 */
native static final noexport function Matrix GetPrimitiveTransform( UIObject Widget, optional bool bIncludeAnchorPosition, optional bool bIncudeRotation=true, optional bool bIncludeScale=true ) const;

/**
 * Sets the string value of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to set the value of.
 * @param InFieldValue			Value to set the datafield's value to.
 * @param OwnerScene			Owner scene for the datastore, used when dealing with scene specific datastores.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was set, FALSE otherwise.
 */
native static final function bool SetDataStoreFieldValue(string InDataStoreMarkup, const out UIProviderFieldValue InFieldValue, optional UIScene OwnerScene, optional LocalPlayer OwnerPlayer);


/**
 * Sets the string value of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to set the value of.
 * @param InStringValue			Value to set the datafield's string value to.
 * @param OwnerScene			Owner scene for the datastore, used when dealing with scene specific datastores.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was set, FALSE otherwise.
 */
static function bool SetDataStoreStringValue(string InDataStoreMarkup, string InStringValue, optional UIScene OwnerScene, optional LocalPlayer OwnerPlayer)
{
	local UIProviderFieldValue FieldValue;

	FieldValue.StringValue = InStringValue;
	FieldValue.PropertyType = DATATYPE_Property;

	return SetDataStoreFieldValue(InDataStoreMarkup, FieldValue, OwnerScene, OwnerPlayer);
}


/**
 * Gets the field value struct of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to retrieve the value of.
 * @param OutFieldValue			Variable to store the result field value in.
 * @param OwnerScene			Owner scene for the datastore, used when dealing with scene specific datastores.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was retrieved, FALSE otherwise.
 */
native static final function bool GetDataStoreFieldValue(string InDataStoreMarkup, out UIProviderFieldValue OutFieldValue, optional UIScene OwnerScene, optional LocalPlayer OwnerPlayer);

/**
 * Gets the string value of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to retrieve the value of.
 * @param OutStringValue		Variable to store the result string in.
 * @param OwnerScene			Owner scene for the datastore, used when dealing with scene specific datastores.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was retrieved, FALSE otherwise.
 */
static function bool GetDataStoreStringValue(string InDataStoreMarkup, out string OutStringValue, optional UIScene OwnerScene=none, optional LocalPlayer OwnerPlayer=none)
{
	local UIProviderFieldValue FieldValue;
	local bool Result;

	if(GetDataStoreFieldValue(InDataStoreMarkup, FieldValue, OwnerScene, OwnerPlayer))
	{
		OutStringValue = FieldValue.StringValue;
		Result = TRUE;
	}

	return Result;
}


/**
 * Generates a unique tag that can be used in the scene's data store as the data field name for a widget's
 * context menu items.
 *
 * @param	SourceWidget	the widget to generate the unique tag for
 *
 * @return	a string guaranteed to be unique which represents the source widget.
 */
static final function string ConvertWidgetIDToString( UIObject SourceWidget )
{
	local string Result;

	if ( SourceWidget != None )
	{
		// the widget's ID is guaranteed to be unique
		Result
			= ToHex(SourceWidget.WidgetId.A)
			$ ToHex(SourceWidget.WidgetId.B)
			$ ToHex(SourceWidget.WidgetId.C)
			$ ToHex(SourceWidget.WidgetId.D);
	}

	return Result;
}

defaultproperties
{
}
