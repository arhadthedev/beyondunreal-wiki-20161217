/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * A PostProcessEffect operates on an input render target and writes to an output target
 * These effects can be chained together in a PostProcessChain
 * Derive your own effects from this class
 */
class PostProcessEffect extends Object
	native
	dependson(Scene)
	hidecategories(Object);

/** Whether to apply the effect in the Editor */
var()	bool bShowInEditor;
/** Whether to apply the effect in the Game */
var()	bool bShowInGame;
/** Controls whether the effect should take its settings from the world's post process settings. */
var() bool bUseWorldSettings;
/** Name of the effect, used by e.g. FindEffectByName */
var() Name EffectName;

/** Variables for post process Editor support */
var		int		NodePosY;
var		int		NodePosX;
var		int		DrawWidth;
var		int		DrawHeight;
var		int		OutDrawY;
var		int		InDrawY;

/** controls which scene DPG to render this post-process effect in (mirrors ESceneDepthPriorityGroup) */
var() ESceneDepthPriorityGroup SceneDPG;

/** If true, the effect should be rendered after lighting and not at the end of the DPG. */
var bool bAffectsLightingOnly;



defaultproperties
{
	SceneDPG=SDPG_PostProcess
	bShowInEditor=TRUE
	bShowInGame=TRUE
	bAffectsLightingOnly=FALSE
}
