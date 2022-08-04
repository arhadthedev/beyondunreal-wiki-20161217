/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTGameInteraction extends UIInteraction
	native(UI);


/** Semaphore for blocking UI input. */
var int		BlockUIInputSemaphore;



/**
 * @return Whether or not we should process input.
 */
native final function bool ShouldProcessUIInput() const;

/**
 * Calls all of the UI input blocks and sees if we can unblock ui input.
 */
event ClearUIInputBlocks()
{
	BlockUIInputSemaphore = 0;
}

/** Tries to block the input for the UI. */
event BlockUIInput(bool bBlock)
{
	if(bBlock)
	{
		BlockUIInputSemaphore++;
	}
	else if(BlockUIInputSemaphore > 0)
	{
		BlockUIInputSemaphore--;
	}
}

/**
 * Merge 2 existing scenes together in to one
 *
 *@param	SourceScene	The Scene to merge
 *@param	SceneTarget		This optional param is the scene to merge in to.  If it's none, the currently active scene will
 *							be used.
 */
function bool MergeScene(UIScene SourceScene, optional UIScene SceneTarget)
{
	local UIScene TempScene;
	local array<UIObject> MergeChildren;
	local int i;
	local bool bResults;

	bResults = false;
	if ( SourceScene != none )
	{
		// Attempt to resolve the active scene

		if ( SceneTarget == none )
		{
			SceneTarget = SceneClient.GetActiveScene();
		}

		if ( SceneTarget != none )
		{
			if ( SceneClient.OpenScene(SourceScene,,TempScene) && TempScene != none )
			{
				// Get a list of the root children in the scene

				MergeChildren = TempScene.GetChildren(false);

				// Remove them from the temp scene and insert them in to the target scene

				for (i=0;i<MergeChildren.Length;i++)
				{
					TempScene.RemoveChild(MergeChildren[i]);
					SceneTarget.InsertChild(MergeChildren[i],,false);
				}

				// Close out the temp scene

				CloseScene(TempScene);
				bResults = true;
			}
		}
	}
	else
	{
		`log("Error: Attempting to Merge a null scene in to"@SceneTarget);
	}
	return bResults;
}


/* === Interaction interface === */

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded()
{
	Super.NotifyGameSessionEnded();

	// if a scene is closed before its opening animation completes, it can result in unmatched calls to BlockUIInput
	// which will prevent the game from processing any input; so if we don't have any scenes open, make sure the
	// semaphore is reset to 0
	if ( !SceneClient.IsUIActive(0x00000020) )
	{
		ClearUIInputBlocks();
	}
}



defaultproperties
{
	SceneClientClass=class'UTGameUISceneClient'
}
