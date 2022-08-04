class ScriptedTexture extends TextureRenderTarget2D
	native;

/** whether the texture needs to be redrawn. Render() will be called at the end of the tick, just before all other rendering. */
var transient bool bNeedsUpdate;

/** whether or not to clear the texture before the next call of the Render delegate  */
var transient bool bSkipNextClear;



/**
 * Called whenever bNeedsUpdate is true to update the texture. The texture is cleared to ClearColor prior to calling this function 
 * (unless bSkipNextClear is set to true).
 * bNeedsUpdate is reset before calling this function, so you can set it to true here to get another update next tick.
 * bSkipNextClear is reset to false before calling this function, so set it to true here whenever you want the next clear to be skipped
 */
delegate Render(Canvas C);

defaultproperties
{
	bNeedsUpdate=true
	bNeedsTwoCopies=false
	bSkipNextClear=false
}
