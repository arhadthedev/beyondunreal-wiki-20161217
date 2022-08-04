﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Specific version of the menu list that draws a mesh in addition to an item background.
 */
class UTUICharacterPartMenuList extends UTUIMenuList
	native(UIFrontEnd)
	placeable;



/** Array of part meshes, generated by RegenerateOptions. */
struct native PartMeshInfo
{
	var SkeletalMeshComponent MeshComp;
	var vector Offset;
	var float Scale;
	var bool bHidden;
};
var transient array<PartMeshInfo>	Meshes;

/** Light for the mesh widget. */
var() LightComponent DefaultLight;

/** Light for the mesh widget. */
var() LightComponent DefaultLight2;

/** Scaling value for the mesh when it is selected. */
var() float SelectedMeshScale;

/** Scaling value for the mesh when it is not selected. */
var() float NormalMeshScale;

/** Extra rotation to be applied to all parts, used to tweak the viewing angle of the part. */
var vector PartRotation;

/** Whether or not to allow character parts to load, this will need to be set to true before the list will display any parts. */
var bool bAllowPartLoading;

/** Regenerates the list of objects and mesh components for this widget. */
native function RegenerateOptions();


/** Input handling callback. */
function bool ProcessInputKey( const out SubscribedInputEventParameters EventParms )
{
	if (EventParms.EventType == IE_Pressed || EventParms.EventType == IE_Repeat || EventParms.EventType == IE_DoubleClick)
	{
		if ( EventParms.InputAliasName == 'SelectionUp' )
		{
			PlayUISound('ListUp');
			return true;
		}
		else if ( EventParms.InputAliasName == 'SelectionDown' )
		{
			PlayUISound('ListDown');
			return true;
		}
	}

	return Super.ProcessInputKey(EventParms);
}

/**
 * Render the list.  At this point each cell should be sized, etc.
 */
event DrawPanel()
{
	local int DrawIndex;
	local float XPos, YPos;
	local float TimeSeconds,DeltaTime;
	local WorldInfo WI;

	// If the list is empty, exit right away.
	if ( List.Length == 0 )
	{
		return;
	}

	// Update whether the mouse cursor is over the menu.  We need to do this frequently because we currently
	// have no way of getting updates about the mouse cursor when it's *not* over the UI object; this means
	// there's no event-based way to be notified about a mouse *leaving* the menu
	UpdateMouseOverMenu();


	WI = UTUIScene( GetScene() ).GetWorldInfo();
	TimeSeconds = WI.RealTimeSeconds * WI.TimeDilation;
	DeltaTime = TimeSeconds - LastRenderTime;
	LastRenderTime = TimeSeconds;


	UpdateAnimation(DeltaTime * UTUIScene( GetScene() ).GetWorldInfo().TimeDilation);


	// FIXME: Big optimization if we don't have to recalc the
	// list size each frame.  We should only have to do this the resoltuion changes,
	// if we have added items to the list, or if the list is moving.  But for now this is
	// fine.

	bInvalidated = true;

	Canvas.Font = TextFont;

	SizeList();

	XPos = DefaultCellHeight * SelectionCellHeightMultiplier * ScrollWidthRatio;
	YPos = 0;

	// Draw selection bar first
	if(bTransitioning)
	{
		DrawSelectionBG(SelectionAlpha * (BarPosition-OldBarPosition) + OldBarPosition);
	}
	else
	{
		DrawSelectionBG(BarPosition);
	}

	// Draw all items
	DrawIndex = 0;
	for (DrawIndex = 0; DrawIndex < List.Length; DrawIndex++)
	{
		// Allow a delegate first crack at rendering, otherwise use the default
		// string rendered.

		if ( !OnDrawItem(self, DrawIndex, XPos, YPos) )
		{
			DrawItem(DrawIndex, XPos, YPos);
	    	List[DrawIndex].bWasRendered = true;
		}
	}
}

/**
 * Draws an item to the screen.  NOTE this function can assume that the item
 * being drawn is not the selected item
 */
function DrawItem(int ItemIndex, float XPos, out float YPos)
{
	local int Dist;
	local int TotalVisible;
	local float Angle, PreviousAngle, FinalAngle, AngleStep;
	local float WheelRadius;
	local float ScaleFactor;

	if(IsVisible()==false)
	{
		return;
	}

	TotalVisible=BubbleRadius*2+1;
	Dist = Selection-ItemIndex;

	// Scale small meshes up to a consistent size and big meshes down.
	ScaleFactor = 1.0f;
	if(Meshes[ItemIndex].MeshComp != None)
	{
		ScaleFactor = DefaultCellHeight / Meshes[ItemIndex].MeshComp.SkeletalMesh.Bounds.SphereRadius; 
	}

	AngleStep = (180.0/TotalVisible);

	Angle = Dist*AngleStep;
	Angle = Angle;

	Dist = OldSelection-ItemIndex;
	PreviousAngle = Dist*AngleStep;
	PreviousAngle = PreviousAngle;

	FinalAngle = (Angle-PreviousAngle)*SelectionAlpha+PreviousAngle;
	
	WheelRadius = DefaultCellHeight*SelectedMeshScale;

	Meshes[ItemIndex].bHidden = FinalAngle > 90.0f || FinalAngle < -90.0f;
	Meshes[ItemIndex].Offset.X = Sin(FinalAngle*PI/180.0)*WheelRadius;
	Meshes[ItemIndex].Offset.Y = 0;
	Meshes[ItemIndex].Offset.Z = -Cos(FinalAngle*PI/180.0)*WheelRadius+WheelRadius;
	Meshes[ItemIndex].Scale = (List[ItemIndex].TransitionAlpha*(SelectedMeshScale-NormalMeshScale) + NormalMeshScale)*ScaleFactor;

	//Super.DrawItem(ItemIndex, XPos, YPos);
}

/**
 * Draw the selection Bar
 */
function DrawSelectionBG(float YPos)
{
	
}

defaultproperties
{
	bHorizontalList=true;
	bSupports3DPrimitives=true
	bSupportsPrimaryStyle=false	// no style

	Begin Object Class=DirectionalLightComponent Name=WidgetLight
	End Object
	DefaultLight=WidgetLight

	DefaultCellHeight=70
	NormalMeshScale=1.0f
	SelectedMeshScale=3.0f
}