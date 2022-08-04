/**
 * Base class for all UI widgets.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIObject extends UIScreenObject
	native(UIPrivate)
	abstract;

`include(Core/Globals.uci)

/** Unique identifier for this widget */
var	noimport					WIDGET_ID						WidgetID;

/** Unique non-localized name for this widget which is used to reference the widget without needing to know its GUID */
var(Presentation) editconst		name							WidgetTag;

/** the UIObject that contains this widget in its Children array */
var const private duplicatetransient		UIObject			Owner;

/** The scene that owns this widget */
var	const private duplicatetransient		UIScene				OwnerScene;

/** Specifies the style data to use for this widget */
var								UIStyleReference				PrimaryStyle;

/**
 * Controls which widgets are given focus when this widget receives an event that changes
 * the currently focused widget.
 */
var(Focus)						UINavigationData				NavigationTargets;

/**
 * Allows the designer to specify where this widget occurs in the bound (i.e. tab, shift+tab) navigation network of this widget's parent.
 */
var(Focus)						int								TabIndex;

/**
 * The widgets that this widget should be docked to.  For the 'right' and 'bottom' faces, if the widget has
 * no dock target, it is considered docked to the 'left' and 'top' faces, respectively.
 */
var(Presentation) editconst		UIDockingSet					DockTargets;

/** Represents the bounding region available for the widget to render itself in.  Set through the docking system. */
var(Presentation) editconst private	const transient		float	RenderBounds[EUIWidgetFace.UIFACE_MAX];

/**
 * Represents the location of the corners of the widget including any tranforms, in absolute pixels (pixel space).  Starts
 * at the upper-left corner of the widget and goes clockwise.
 */
var(Presentation) editconst private const transient		Vector2D RenderBoundsVertices[EUIWidgetFace.UIFACE_MAX];

/** Rotation of the widget. */
var(Presentation)				UIRotation						Rotation;

/** Screenspace offset to apply to the widget's rendering. */
var(Presentation)				vector							RenderOffset;

/**
 * For widgets using percentage values, transforms the widget's bounds to negate the effects of rotation
 */
//var								Matrix							BoundsAdjustment;

/**
 * Stores a bitmask of flags which modify/define which operations may be performed to this widget (such as renaming, reparenting, selecting, etc.).
 *  Valid behavior flags are defined in UIRoot.uc, as consts which begin with PRIVATE_
 */
var private{private}			int								PrivateFlags;

/** used to differentiate tooltip bindings from others */
const	FIRST_DEFAULT_DATABINDING_INDEX=100;
const	TOOLTIP_BINDING_INDEX=100;
const	CONTEXTMENU_BINDING_INDEX=101;

/**
 * The tool tip for this widget; only relevant for widgets that implement the UIDataStoreSubscriber interface.
 */
var(Data)	private				UIDataStoreBinding				ToolTip;
var(Data)	private	editconst	UIDataStoreBinding				ContextMenuData;

// ===============================================
// ANIMATIONS
// ===============================================
/** Used as the parent in animation sequences */
var						UIObject								AnimationParent;

/** - The following is used in UTGame's UI animation system.
    - It is subject to change at any time.
  */

var transient vector AnimationPosition;

/** This is the stack of animations currently being applied to this UIObject */
var transient array<UIAnimSeqRef> AnimStack;



// ===============================================
// Components
// ===============================================
/**
 * List of objects/components contained by this widget which contain their own style references.  When this widget's style is resolved,
 * each element in this list will receive a notification to resolve its style references as well.
 *
 * Elements should be added to this list either from the native InitializeStyleSubscribers method [for native classes], the Initialized event
 * [for non-native classes], or the native PostEditChange method (when e.g. components are created or removed using the UI editor's property window).
 *
 * You should NEVER add elements to this array using defaultproperties, since interface properties will not be updated to point to the subobject/component
 * instance when this widget is created.
 */
var	transient		array<UIStyleResolver>			StyleSubscribers;

/**
 * Indicates that this widget should receive a call each tick with the location of the mouse cursor while it's the active control (NotifyMouseOver)
 * (caution: slightly degrades performance)
 */
var private{private}	bool						bEnableActiveCursorUpdates;

/**
 * Temp hack to allow widgets to remove "Primary Style" from the styles listed in the context menu for that widget if they no longer use it.
 * Will be removed once I am ready to deprecate the PrimaryStyle property.
 */
var	const			bool							bSupportsPrimaryStyle;

/**
 * Set to true to render an outline marking the widget's RenderBounds.
 */
var(Debug)			bool							bDebugShowBounds;

/**
 * if bRenderBoundingRegion is TRUE, specifies the color to use for this widget.
 */
var(Debug)			color							DebugBoundsColor;



/* ==========================================================================================================
	UIObject interface.
========================================================================================================== */

/* == Delegates == */

/**
 * Called when this widget is created
 *
 * @param	CreatedWidget		the widget that was created
 * @param	CreatorContainer	the container that created the widget
 */
delegate OnCreate( UIObject CreatedWidget, UIScreenObject CreatorContainer );

/**
 * Called when the value of this UIObject is changed.  Only called for widgets that contain data values.
 *
 * @param	Sender			the UIObject whose value changed
 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
delegate OnValueChanged( UIObject Sender, int PlayerIndex );

/**
 * Called when this widget receives a call to RefreshSubscriberValue.
 *
 * @param	Sender				the widget that is refreshing their value
 * @param	BindingIndex		optional parameter for indicating which data store binding is being refreshed, for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0,
 *								while values greater than FIRST_DEFAULT_DATABINDING_INDEX correspond to tooltips and context
 *								menus.
 *
 * @return	TRUE to indicate that this widget is going to refresh its value manually.
 */
delegate bool OnRefreshSubscriberValue( UIObject Sender, int BindingIndex );

/**
 * Called when this widget is pressed.  Not implemented by all widget types.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
delegate OnPressed( UIScreenObject EventObject, int PlayerIndex );

/**
 * Called when the widget been pressed and the user is holding the button down.  Not implemented by all widget types.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
delegate OnPressRepeat( UIScreenObject EventObject, int PlayerIndex );

/**
 * Called when the widget is no longer being pressed.  Not implemented by all widget types.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
delegate OnPressRelease( UIScreenObject EventObject, int PlayerIndex );

/**
 * Called when the widget is no longer being pressed.  Not implemented by all widget types.
 *
 * The difference between this delegate and the OnPressRelease delegate is that OnClick will only be called on the
 * widget that received the matching key press. OnPressRelease will be called on whichever widget was under the cursor
 * when the key was released, which might not necessarily be the widget that received the key press.
 *
 * @param EventObject	Object that issued the event.
 * @param PlayerIndex	Player that performed the action that issued the event.
 *
 * @return	return TRUE to prevent the kismet OnClick event from firing.
 */
delegate bool OnClicked(UIScreenObject EventObject, int PlayerIndex);

/**
 * Called when the widget has received a double-click input event.  Not implemented by all widget types.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
delegate OnDoubleClick( UIScreenObject EventObject, int PlayerIndex );

/**
 * Called when this widget (or one of its children) becomes the ActiveControl.  Provides a way for child classes or
 * containers to easily override or short-circuit the standard tooltip that is normally shown.  If this delegate is
 * not assigned to any function, the default tool-tip will be displayed if this widget has a data store binding property
 * named "ToolTipBinding" which is bound to a valid data store.
 *
 * @param	Sender			the widget that will be displaying the tooltip
 * @param	CustomToolTip	to provide a custom tooltip implementation, fill in in this value and return TRUE.  The custom
 *							tool tip object will then be activated by native code.
 *
 * @return	return FALSE to prevent any tool-tips from being shown, including parents.
 */
delegate bool OnQueryToolTip( UIObject Sender, out UIToolTip CustomToolTip );

/**
 * Called when the user right-clicks (or whatever input key is configured to activate the ShowContextMenu UI input alias)
 * this widget.  Provides a way for widgets to customize the context menu that is used or prevent the context menu from being
 * shown entirely.
 *
 * For script customization of the context menu, a custom context menu object must be assigned to the CustomContextMenu variable.
 * It is possible to provide data for the context menu without creating or modifying any existing data stores.  First, get a reference
 * to the scene's default context menu (GetScene()->GetDefaultContextMenu()).  Add the desired elements to the scene's data store then
 * bind the context menu to that data field.
 *
 * @param	Sender				the widget that will be displaying the context menu
 * @param	PlayerIndex			index of the player that generated the input event that triggered the context menu display.
 * @param	CustomContextMenu	to provide a custom tooltip implementation, fill in in this value and return TRUE.  The custom
 *								context menu will then be activated by native code.
 *
 * @return	return FALSE to prevent a context menu from being shown, including any from parent widgets.  Return TRUE to indicate
 *			that the context menu for this widget can be displayed; if a value is not provided for CustomContextMenu,
 *			the default context menu will be displayed, using this widget's context menu data binding to generate the items.
 */
delegate bool OnOpenContextMenu( UIObject Sender, int PlayerIndex, out UIContextMenu CustomContextMenu );

/**
 * Called when the system wants to close the currently active context menu.
 *
 * @param	ContextMenu		the context menu that is going to be closed
 * @param	PlayerIndex		the index of the player that generated the request for the context menu to be closed.
 *
 * @return	TRUE to allow the specified context menu to be closed; FALSE to prevent the context menu from being closed.
 *			Note that there are certain situations where the context menu will be closed regardless of the return value,
 *			such as when the scene which owns the context menu is being closed.
 */
delegate bool OnCloseContextMenu( UIContextMenu ContextMenu, int PlayerIndex );

/**
 * Called when the user selects a choice from a context menu.
 *
 * @param	ContextMenu		the context menu that called this delegate.
 * @param	PlayerIndex		the index of the player that generated the event.
 * @param	ItemIndex		the index [into the context menu's MenuItems array] for the item that was selected.
 */
delegate OnContextMenuItemSelected( UIContextMenu ContextMenu, int PlayerIndex, int ItemIndex );

/* == Events == */


/* == Natives == */
/**
 * Set the markup text for a default data binding to the value specified.
 *
 * @param	NewMarkupText	the new markup text for this widget, either a literal string or a data store markup string
 * @param	BindingIndex	indicates which data store binding to operate on.
 */
native final function SetDefaultDataBinding( string MarkupText, int BindingIndex );

/**
 * Returns the data binding's current value.
 *
 * @param	BindingIndex	indicates which data store binding to operate on.
 */
native final function string GetDefaultDataBinding( int BindingIndex ) const;

/**
 * Resolves the data binding's markup string.
 *
 * @param	BindingIndex	indicates which data store binding to operate on.
 *
 * @return	TRUE if a data store field was successfully resolved from the data binding
 */
native final function bool ResolveDefaultDataBinding( int BindingIndex );

/**
 * Returns the data store providing the data for all default data bindings.
 */
native final function GetDefaultDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Clears the reference to the bound data store, if applicable.
 *
 * @param	BindingIndex	indicates which data store binding to operate on.
 */
native final function ClearDefaultDataBinding( int BindingIndex );

/**
 * Generates a string which can be used to interact with temporary data in the scene data store specific to this widget.
 *
 * @param	Group	for now, doesn't matter, as only "ContextMenuItems" is supported
 *
 * @return	a data store markup string which can be used to reference content specific to this widget in the scene's
 *			data store.
 */
native function string GenerateSceneDataStoreMarkup( optional string Group="ContextMenuItems" ) const;


/** ===== Tool tips ===== */
/**
 * Returns the ToolTip data binding's current value after being resolved.
 */
native final function string GetToolTipValue();

/** ===== Rotation ===== */
/**
 * Determines whether this widget has any tranformation applied to it.
 *
 * @param	bIncludeParentTransforms	specify TRUE to check whether this widget's parents are transformed if this one isn't.
 */
native final function bool HasTransform( optional bool bIncludeParentTransforms=true ) const;

/**
 * Sets the location of the widget's rotation anchor, relative to the top-left of this widget's bounds.
 *
 * @param	AnchorPosition	New location for the widget's rotation anchor.
 * @param	InputType		indicates which format the AnchorPos value is in
 */
native final function SetAnchorPosition( vector NewAnchorPosition, optional EPositionEvalType InputType=EVALPOS_PixelViewport );

/**
 * Rotates the widget around the current anchor position by the amount specified.
 *
 * @param	RotationDelta		amount to rotate the widget by in DEGREES.
 * @param	bAccumulateRotation	if FALSE, set the widget's rotation to NewRotationAmount; if TRUE, increments the
 *								widget's rotation by NewRotationAmount
 */
native final function RotateWidget( rotator NewRotationAmount, optional bool bAccumulateRotation );

/**
 * Updates the widget's rotation matrix based on the widget's current rotation.
 */
native final function UpdateRotationMatrix();

/**
 * Returns the current location of the anchor.
 *
 * @param	bRelativeToWidget	specify TRUE to return the anchor position relative to the widget's upper left corner.
 *								specify FALSE to return the anchor position relative to the viewport's origin.
 * @param	bPixelSpace			specify TRUE to convert the anchor position into pixel space (only relevant if the widget is rotated)
 *
 * @return	a vector representing the position of this widget's rotation anchor.
 */
native final function vector GetAnchorPosition( optional bool bRelativeToWidget=true, optional bool bPixelSpace ) const;

/**
 * Generates a matrix which contains a translation for this widget's position (from 0,0 screen space) as well as the widget's
 * current rotation, scale, etc.
 *
 * @param	bIncludeParentTransforms	if TRUE, the matrix will be relative to the parent widget's own transform matrix.
 *
 * @return	a matrix containing the translation and rotation values of this widget.
 *
 * @todo ronp - we REALLY need to cache this baby and update it any time the widget's position, anchor,
 *				rotation, scale, or parent changes.
 */
native final function Matrix GenerateTransformMatrix( optional bool bIncludeParentTransforms=true ) const;

/**
 * Returns this widget's current rotation matrix
 *
 * @param	bIncludeParentRotations	if TRUE, the matrix will be relative to the parent widget's own rotation matrix.
 */
native final function Matrix GetRotationMatrix( optional bool bIncludeParentRotations=true ) const;

/**
 * Called whenever the value of the UIObject is modified (for those UIObjects which can have values).
 * Calls the OnValueChanged delegate.
 *
 * @param	PlayerIndex		the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 * @param	NotifyFlags		optional parameter for individual widgets to use for passing additional information about the notification.
 */
native function NotifyValueChanged( optional int PlayerIndex=INDEX_NONE, optional int NotifyFlags=0 );

/**
 * Returns TRUE if TestWidget is in this widget's Owner chain.
 */
native final function bool IsContainedBy( UIObject TestWidget );

/**
 * Sets the docking target for the specified face.
 *
 * @param	SourceFace	the face of this widget to apply the changes to
 * @param	Target		the widget to dock to
 * @param	TargetFace	the face on the Target widget that SourceFace will dock to
 *
 * @return	TRUE if the changes were successfully applied.
 */
native function bool SetDockTarget( EUIWidgetFace SourceFace, UIScreenObject Target, EUIWidgetFace TargetFace );

/**
 * Sets the padding for the specified docking link.
 *
 * @param	SourceFace	the face of this widget to apply the changes to
 * @param	Padding		the amount of padding to use for this docking set.  Positive values will "push" this widget past the
 *						target face of the other widget, while negative values will "pull" this widget away from the target widget.
 * @param	PaddingInputType
 *						specifies how the Padding value should be interpreted.
 * @param	bModifyPaddingScaleType
 *						specify TRUE to change the DockPadding's ScaleType to the PaddingInputType.
 *
 * @return	TRUE if the changes were successfully applied.
 */
native function bool SetDockPadding( EUIWidgetFace SourceFace, float PaddingValue, optional EUIDockPaddingEvalType PaddingInputType=UIPADDINGEVAL_Pixels, optional bool bModifyPaddingScaleType );

/**
 * Combines SetDockTarget and SetDockPadding into a single function.
 *
 * @param	SourceFace	the face of this widget to apply the changes to
 * @param	Target		the widget to dock to
 * @param	TargetFace	the face on the Target widget that SourceFace will dock to
 * @param	Padding		the amount of padding to use for this docking set.  Positive values will "push" this widget past the
 *						target face of the other widget, while negative values will "pull" this widget away from the target widget.
 * @param	PaddingInputType
 *						specifies how the Padding value should be interpreted.
 * @param	bModifyPaddingScaleType
 *						specify TRUE to change the DockPadding's ScaleType to the PaddingInputType.
 *
 * @return	TRUE if the changes were successfully applied.
 */
native final function bool SetDockParameters( EUIWidgetFace SourceFace, UIScreenObject Target, EUIWidgetFace TargetFace, float PaddingValue, optional EUIDockPaddingEvalType PaddingInputType=UIPADDINGEVAL_Pixels, optional bool bModifyPaddingScaleType );

/**
 * Returns TRUE if this widget is docked to the specified widget.
 *
 * @param	TargetWidget	the widget to check for docking links to
 * @param	SourceFace		if specified, returns TRUE only if the specified face is docked to TargetWidget
 * @param	TargetFace		if specified, returns TRUE only if this widget is docked to the specified face on the target widget.
 */
native final function bool IsDockedTo( const UIScreenObject TargetWidget, optional EUIWidgetFace SourceFace=UIFACE_MAX, optional EUIWidgetFace TargetFace=UIFACE_MAX ) const;

/**
* Sets the actual navigation target for the specified face.  If the new value is different from the current value,
* requests the owning scene to update the navigation links for the entire scene.
*
* @param	Face			the face to set the navigation link for
* @param	NewNavTarget	the widget to set as the link for the specified face
*
* @return	TRUE if the nav link was successfully set.
*/
native final function bool SetNavigationTarget( EUIWidgetFace Face, UIObject NewNavTarget );

/**
* Sets the designer-specified navigation target for the specified face.  When navigation links for the scene are rebuilt,
* the designer-specified navigation target will always override any auto-calculated targets.  If the new value is different from the current value,
* requests the owning scene to update the navigation links for the entire scene.
*
* @param	Face				the face to set the navigation link for
* @param	NavTarget			the widget to set as the link for the specified face
* @param	bIsNullOverride		if NavTarget is NULL, specify TRUE to indicate that this face's nav target should not
*								be automatically calculated.
*
* @return	TRUE if the nav link was successfully set.
*/
native final function bool SetForcedNavigationTarget( EUIWidgetFace Face, UIObject NavTarget, bool bIsNullOverride=FALSE );

/**
 * Determines whether this widget can become the focused control. In the case of this widget we don't want it to gain focus.
 *
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player to check focus availability
 *
 * @return	TRUE if this widget (or any of its children) is capable of becoming the focused control.
 */
native function bool CanAcceptFocus( optional int PlayerIndex=0 ) const;

/**
 * Checks to see if the specified private behavior is set. Valid behavior flags are defined in UIRoot.uc, as consts which begin with PRIVATE_
 *
 * @param	Behavior	the flag of the private behavior that is being checked
 *
 * @return	TRUE if the specified flag is set and FALSE if not.
 */
native final function bool IsPrivateBehaviorSet( int Behavior ) const;

/**
 * Set the specified private behavior for this UIObject. Valid behavior flags are defined in UIRoot.uc, as consts which begin with PRIVATE_
 *
 * @param	Behavior	the flag of the private behavior that is being set
 * @param	Value		whether the flag is being enabled or disabled
 * @param	bRecurse	specify TRUE to apply the flag in all children of this widget as well.
 */
native final function SetPrivateBehavior( int Behavior, bool Value, optional bool bRecurse );

/**
 * Change the value of bEnableActiveCursorUpdates to the specified value.
 */
native function SetActiveCursorUpdate( bool bShouldReceiveCursorUpdates );

/**
 * Returns the value of bEnableActiveCursorUpdates
 */
native final function bool NeedsActiveCursorUpdates() const;

/**
 * Gets the minimum and maximum values for the widget's face positions after rotation (if specified) has been applied.
 *
 * @param	MinX				The minimum x position of this widget.
 * @param	MaxX				The maximum x position of this widget.
 * @param	MinY				The minimum y position of this widget.
 * @param	MaxY				The maximum y position of this widget.
 * @param	bIncludeRotation	Indicates whether the widget's rotation should be applied to the extent values.
 */
native final function GetPositionExtents( out float MinX, out float MaxX, out float MinY, out float MaxY, optional bool bIncludeRotation ) const;

/**
 * Gets the minimum or maximum value for the specified widget face position after rotation has been applied.
 *
 * @param	bIncludeRotation	Indicates whether the widget's rotation should be applied to the extent values.
 */
native final function float GetPositionExtent( EUIWidgetFace Face, optional bool bIncludeRotation ) const;

/**
 * Adds the specified StyleResolver to the list of StyleSubscribers
 *
 * @param	StyleSubscriberId	the name to associate with this UIStyleResolver; used for differentiating styles from
 *								multiple UIStyleResolvers of the same class
 * @param	Subscriber			the UIStyleResolver to add.
 */
native final function AddStyleSubscriber( const out UIStyleResolver Subscriber );

/**
 * Removes the specified StyleResolver from the list of StyleSubscribers.
 *
 * @param	Subscriber		the subscriber to remove
 * @param	SubscriberId	if specified, Subscriber will only be removed if its SubscriberId matches this value.
 */
native final function RemoveStyleSubscriber( const out UIStyleResolver Subscriber );

/**
 * Returns the index [into the StyleSubscriber's array] for the specified UIStyleResolver, or INDEX_NONE if Subscriber
 * is NULL or is not found in the StyleSubscriber's array.
 *
 * @param	Subscriber		the subscriber to find
 * @param	SubscriberId	if specified, it will only be considered a match if the SubscriberId associated with Subscriber matches this value.
 */
native final function int FindStyleSubscriberIndex( const out UIStyleResolver Subscriber );

/**
 * Returns the index [into the StyleSubscriber's array] for the subscriber which has a StyleResolverTag that matches the specified value
 * or INDEX_NONE if StyleSubscriberId is None or is not found in the StyleSubscriber's array.
 *
 * @param	StyleSubscriberId	the tag associated with the UIStyleResolver to find
 */
native final function int FindStyleSubscriberIndexById( name StyleSubscriberId );

/**
* Sets a style in the widget using the name of the style.
*
* @param	StyleResolverTagToSet	the tag associated with the UIStyleResolver to set
* @param	StyleFriendlyName		the name of the style to set the widget to
*
* @return	TRUE if the style was successfully applied to this widget
*/
native final function bool SetWidgetStyleByName( name StyleResolverTagToSet, name StyleFriendlyName );


/**
 * Resolves the style references contained by this widget from the currently active skin.
 *
 * @param	bClearExistingValue		if TRUE, style references will be invalidated first.
 *
 * @return	TRUE if all style references were successfully resolved.
 */
native final noexport function bool ResolveStyles(optional bool bClearExistingValue);


/** --------- Animations ------------- */

/**
 * Itterate over the AnimStack and tick each active sequence
 *
 * @Param DeltaTime			How much time since the last call
 */

native function TickAnim(FLOAT DeltaTime);


/* == Unrealscript == */

/**
 * Returns the scene that owns this widget
 */
final function UIScene GetScene()
{
	return OwnerScene;
}

/**
 * Returns the owner of this widget
 */
final function UIObject GetOwner()
{
	return Owner;
}

/**
 * Returns the scene or widget that contains this widget in its Children array.
 */
function UIScreenObject GetParent()
{
	local UIScreenObject Result;

	Result = GetOwner();
	if ( Result == None )
	{
		Result = GetScene();
	}

	return Result;
}


function LogRenderBounds( int Indent )
{
`if(`notdefined(FINAL_RELEASE))
	local int i;
	local string IndentString;

	for ( i = 0; i < Indent; i++ )
	{
		IndentString $= " ";
	}

	`log(IndentString $ "'" $ WidgetTag $ "': (" $ RenderBounds[0] $ "," $ RenderBounds[1] $ "," $ RenderBounds[2] $ "," $ RenderBounds[3] $ ") Pos:(" $ Position.Value[0] $ "," $ Position.Value[1] $ "," $ Position.Value[2] $ "," $ Position.Value[3] $ ")");
	for ( i = 0; i < Children.Length; i++ )
	{
		Children[i].LogRenderBounds(Indent + 3);
	}
`endif
}

/** Kismet Action Handlers */
function OnSetDatastoreBinding( UIAction_SetDatastoreBinding Action )
{
	local UIDataStoreSubscriber Subscriber;

	Subscriber = Self;
	if ( Subscriber != None )
	{
		Subscriber.SetDataStoreBinding(Action.NewMarkup, Action.BindingIndex);
	}
}
// ===============================================
// ANIMATIONS
// ===============================================

/**
 * Note these are accessor functions for the animation system.  They should
 * be subclassed.
 */

native function AnimSetOpacity(float NewOpacity);
native function AnimSetVisibility(bool bIsVisible);
native function AnimSetColor(LinearColor NewColor);
native function AnimSetPosition(Vector NewPosition);
native function AnimSetRelPosition(Vector NewPosition, Vector InitialPosition);
native function AnimSetRotation(Rotator NewRotation);
native function AnimSetScale(float NewScale);
native function AnimSetLeft(float NewLeft);
native function AnimSetTop(float NewTop);
native function AnimSetRight(float NewRight);
native function AnimSetBottom(float NewBottom);

/**
 * Play an animation on this UIObject
 *
 * @Param AnimName			The Name of the Animation to play
 * @Param AnimSeq			Optional, A Sequence Template.  If that's set, we use it instead
 * @Param PlaybackRate  	Optional, How fast to play back the sequence
 * @Param InitialPosition	Optional, Where in the sequence should we start
 *
 */
event PlayUIAnimation(name AnimName, optional UIAnimationSeq AnimSeqTemplate,
						optional float PlaybackRate=1.0,optional bool bLoop, optional float InitialPosition=0.0)
{
	local UIAnimationSeq TargetAnimSeq;
	local GameUISceneClient SClient;
	local int Idx;

	SClient = GetSceneClient();
	if ( SClient == none )
	{
		return;
	}


	// If we are already on the stack, just reset us
	if ( AnimName != '' )
	{
		`log("Playing animation '" $ AnimName $ "' on " $ WidgetTag $ ":" @ PlaybackRate $ "," @ bLoop $ "," @ InitialPosition,,'DevUIAnimation');
		for (Idx=0;Idx<AnimStack.Length;Idx++)
		{
			if ( AnimStack[Idx].SeqRef.SeqName == AnimName )
			{
				AnimStack[Idx].PlaybackRate = PlaybackRate;
				AnimStack[Idx].bIsPlaying = true;
				AnimStack[Idx].bIsLooping = bLoop;
				AnimStack[Idx].LoopCount = 0;

				AnimStack[Idx].AnimTime = AnimStack[Idx].SeqRef.SeqDuration * InitialPosition;

				// Force the first frame, whatever it may be.
				TickAnim(0.0);

/*
				// Apply the first frame of each track

	            for (i=0;i<AnimStack[Idx].SeqRef.Tracks.Length; i++)
	            {
	            	TargetObj = AnimStack[Idx].SeqRef.Tracks[i].TargetWidget;
					AnimStack[Idx].SeqRef.ApplyAnimation( TargetObj == none ? self : TargetObj, i, 0.0, 0, 0);
				}

				AnimStack[Idx].AnimTime = 0.0f;
*/
				`log("Animation found at" @ Idx,,'DevUIAnimation');
				SClient.AnimSubscribe(self);
				return;
			}
		}
	}


	if ( AnimSeqTemplate != none )
	{
		TargetAnimSeq = AnimSeqTemplate;
	}
	else
	{
		TargetAnimSeq = SClient.AnimLookupSequence(AnimName);
	}

	if ( TargetAnimSeq != none && TargetAnimSeq.Tracks.Length > 0 )
	{
		Idx = AnimStack.Length;
		AnimStack.length = AnimStack.length + 1;
		AnimStack[Idx].SeqRef = TargetAnimSeq;
		AnimStack[Idx].PlaybackRate = PlaybackRate;
		AnimStack[Idx].bIsPlaying = true;
		AnimStack[Idx].bIsLooping = bLoop;
		AnimStack[Idx].LoopCount = 0;
		AnimStack[Idx].InitialRenderOffset = RenderOffset;
		AnimStack[Idx].InitialRotation = Rotation.Rotation;

		AnimStack[Idx].AnimTime = TargetAnimSeq.SeqDuration * InitialPosition;
		// Apply the first frame of each track

		TickAnim(0.0);
/*
	for (i=0;i<TargetAnimSeq.Tracks.Length; i++)
	{
		TargetObj = self;

		// If this track affects a child widget, then cache a reference
		// to it here.

			if (TargetAnimSeq.Tracks[i].TrackWidgetTag != '')
			{
				TargetObj = FindChild(TargetAnimSeq.Tracks[i].TrackWidgetTag,true);
				if ( TargetObj != none )
				{
					TargetAnimSeq.Tracks[i].TargetWidget = TargetObj;
				}
				else
				{
					`log("UIAnimation - "$AnimName$" could not find Target Widget "$TargetAnimSeq.Tracks[i].TargetWidget);

					// Reset the TargetObj to the parent

					TargetObj = self;
				}
			}

			TargetAnimSeq.ApplyAnimation(TargetObj, i, 0.0, 0, 0);
		}

		AnimStack[Idx].AnimTime = 0.0f;
*/
		SClient.AnimSubscribe(self);
	}
	else
	{
		`log("UIAnimation - Attempted to play unknown sequence '"$AnimName$"' on "@WidgetTag);
	}
}

/**
 * Stop an animation that is playing.
 *
 * @Param AnimName		The Name of the animation to play
 * @Param AnimSeq		Optional sequence to use.  In case you don't know the name
 * @Param bFinalize		If true, we will force the end frame
 */
event StopUIAnimation(name AnimName, optional UIAnimationSeq AnimSeq, optional bool bFinalize)
{
	local int i, Idx, FIdx;
	local UIAnimationSeq Seq;
	local UIObject TargetWidget;

	for ( Idx=0; Idx < AnimStack.Length; Idx++)
	{
		if ((AnimName != '' && AnimStack[Idx].SeqRef.SeqName == AnimName)
		||	(AnimSeq != none && AnimStack[Idx].SeqRef == AnimSeq) )
		{
			`log("Stopping animation" @ Idx @ "for" @ PathName(Self) $ ":" @ `showvar(AnimName) @ `showobj(AnimSeq) @ `showvar(bFinalize),,'DevUIAnimation');
			if (bFinalize)
			{
				Seq = AnimStack[Idx].SeqRef;
				for (i=0; i<Seq.Tracks.Length; i++)
				{

					FIdx = Seq.Tracks[i].KeyFrames.Length - 1;
					if ( Seq.Tracks[i].KeyFrames[FIdx].TimeMark < 1.0 )
					{
						FIdx = 0;
					}

					if (Seq.Tracks[i].TargetWidget != none )
					{
						TargetWidget = Seq.Tracks[i].TargetWidget;
					}
					else
					{
						TargetWidget = self;
					}

					Seq.ApplyAnimation(TargetWidget, i, 1.0, FIdx, FIdx, AnimStack[Idx]);
				}
			}
			UIAnimEnd(Idx);
		}
	}
}

/**
 * Clears the animation from the stack.  Stopping an animation (either naturally or by
 * force) doesn't remove the effects.  In those cases you need to clear the animation
 * from the stack.
 *
 * NOTE: This only affects position and rotation animations.  All other animations
 * 		 are destructive and can't be easilly reset.
 *
 * @Param AnimName		The Name of the animation to play
 * @Param AnimSeq		Optional sequence to use.  In case you don't know the name
 */

event ClearUIAnimation(name AnimName, optional UIAnimationSeq AnimSeq)
{
	local int Idx;

	`log("Clearing animations for" @ PathName(Self) $ ":" @ `showvar(AnimName) @ `showobj(AnimSeq),,'DevUIAnimation');
	for ( Idx=0; Idx < AnimStack.Length; Idx++)
	{
		if ((AnimName != '' && AnimStack[Idx].SeqRef.SeqName == AnimName)
		||	(AnimSeq != none && AnimStack[Idx].SeqRef == AnimSeq) )
		{
			// If we are playing, turn us off
			if ( AnimStack[Idx].bIsPlaying )
			{
				StopUIAnimation('',AnimStack[Idx].SeqRef,false);
			}

			AnimStack.Remove(Idx--,1);
		}
	}

}

/**
 * AnimEnd is always called when an animation stops playing either by ending, or
 * when StopAnim is called on it.  It's responsible for unsubscribing from the scene client
 * and performing any housekeeping
 */
event UIAnimEnd(int SeqIndex)
{
	local int i;
	local bool bRemove;

	if ( SeqIndex >= 0 && SeqIndex < AnimStack.Length )
	{
		// Notify anyone listening
		OnUIAnimEnd( Self, SeqIndex, AnimStack[SeqIndex].SeqRef);

		// Notify the Scene
		GetScene().AnimEnd( Self, SeqIndex, AnimStack[SeqIndex].SeqRef);

		// Turn it off

		AnimStack[SeqIndex].bIsPlaying = false;
		AnimStack[SeqIndex].bIsLooping = false;

		// Look at out anim stack.  If we don't have any active animations,
		// remove unsubscribe us.

		bRemove = true;
		for (i=0;i<AnimStack.Length;i++)
		{
			if ( AnimStack[i].bIsPlaying )
			{
				bRemove = false;
				break;
			}
		}

		if ( bRemove )
		{
			// Unsubscribe
			GetSceneClient().AnimUnSubscribe( self );
		}
		else
		{
			`log("Can't unsubscribe" @ PathName(Self) @ "because it still has active animations:" @ AnimStack.Length,,'DevUIAnimation');
		}
	}
	else
	{
		`warn("Invalid animation sequence index specified in call to UIAnimEnd for" @ PathName(Self) $ ":" @ SeqIndex);
	}
}

/**
 * If set, this delegate is called whenever an animation is finished
 */

delegate OnUIAnimEnd(UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq);


DefaultProperties
{
	Opacity=1.f
	TabIndex=-1
	PrimaryStyle=(DefaultStyleTag="DefaultComboStyle")
	bSupportsPrimaryStyle=true
	DebugBoundsColor=(R=255,B=255,G=128,A=255)
	ToolTip=(RequiredFieldType=DATATYPE_Property,BindingIndex=TOOLTIP_BINDING_INDEX)
	ContextMenuData=(RequiredFieldType=DATATYPE_Collection,BindingIndex=CONTEXTMENU_BINDING_INDEX)

	// default to Identity matrix
//	BoundsAdjustment=(XPlane=(X=1,Y=0,Z=0,W=0),YPlane=(X=0,Y=1,Z=0,W=0),ZPlane=(X=0,Y=0,Z=1,W=0),WPlane=(X=0,Y=0,Z=0,W=1))

	// Events
	Begin Object Class=UIEvent_Initialized Name=WidgetInitializedEvent
		OutputLinks(0)=(LinkDesc="Output")
		ObjClassVersion=4
	End Object

	Begin Object Class=UIComp_Event Name=WidgetEventComponent
		DefaultEvents.Add((EventTemplate=WidgetInitializedEvent))
	End Object
	EventProvider=WidgetEventComponent
}
