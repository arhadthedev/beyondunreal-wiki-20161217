//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Coder: Raven
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Console with RMusic_Player support
class RMusic_Console extends UTConsole;

function DrawLevelAction( canvas C )
{
	local RMusic_Player RMusic_Player;
	local PlayerPawn PP;

	if ( Viewport.Actor.Level.LevelAction == LEVACT_Loading ) // Loading Screen
	{
		PP = Root.GetPlayerOwner();
		if(PP != none)
		{
			foreach PP.GetEntryLevel().AllActors(class'RMusic_Player', RMusic_Player) break;

			if (RMusic_Player != none) RMusic_Player.RMusic_Stop();
		}	
	}
	Super.DrawLevelAction(C);
}