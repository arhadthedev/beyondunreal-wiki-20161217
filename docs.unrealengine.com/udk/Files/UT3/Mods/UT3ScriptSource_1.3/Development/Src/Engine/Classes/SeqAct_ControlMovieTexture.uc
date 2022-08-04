class SeqAct_ControlMovieTexture extends SequenceAction;

var() TextureMovie MovieTexture;

event Activated()
{
	if (MovieTexture != None)
	{
		if (InputLinks[0].bHasImpulse)
		{
			MovieTexture.Play();
		}
		else if (InputLinks[1].bHasImpulse)
		{
			MovieTexture.Stop();
		}
		else if (InputLinks[2].bHasImpulse)
		{
			MovieTexture.Pause();
		}
	}
}

defaultproperties
{
	ObjCategory="Cinematic"
	ObjName="Control Movie Texture"
	bCallHandler=false
	InputLinks(0)=(LinkDesc="Play")
	InputLinks(1)=(LinkDesc="Stop")
	InputLinks(2)=(LinkDesc="Pause")
	VariableLinks.Empty()
}
