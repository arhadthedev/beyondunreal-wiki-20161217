class ScriptedTexture extends TextureRenderTarget2D
	native;

/** whether the texture needs to be redrawn. Render() will be called at the end of the tick, just before all other rendering. */
var transient bool bNeedsUpdate;



/** called whenever bNeedsUpdate is true to update the texture. The texture is cleared to ClearColor prior to calling this function.
 * bNeedsUpdate is reset before calling this function, so you can set it to true here to get another update next tick.
 */
delegate Render(Canvas C);

defaultproperties
{
	bNeedsUpdate=true
	bNeedsTwoCopies=false
}
