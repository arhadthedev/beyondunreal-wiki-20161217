/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDrawMapPanel extends UTDrawPanel
	config(Input);

/** How much of the panel's height will be used for the map */
var() float MapSizePerc;
var transient bool bShowExtents;
var UTUIScene_Hud UTHudSceneOwner;
var transient bool bAllowTeleport;


/**
 * Called when a node is actually double-clicked on.
 *
 * @Param	Selected		The actor that was selected
 * @Param	SelectedBy		The UTPlayerController that selected the node
 */
delegate OnActorSelected(Actor Selected, UTPlayerController SelectedBy);

/**
 * Gather Data and setup the input delegates
 */
event PostInitialize()
{
	Super.PostInitialize();
	OnRawInputKey=InputKey;
	UTHudSceneOwner = UTUIScene_Hud( GetScene() );
}

/**
 * Setup Input subscriptions
 */
event GetSupportedUIActionKeyNames(out array<Name> out_KeyNames )
{
	out_KeyNames[out_KeyNames.Length] = 'SelectNode';
	out_KeyNames[out_KeyNames.Length] = 'SetHomeNode';
	out_KeyNames[out_KeyNames.Length] = 'SelectionUp';
	out_KeyNames[out_KeyNames.Length] = 'SelectionDown';
	out_KeyNames[out_KeyNames.Length] = 'SelectionLeft';
	out_KeyNames[out_KeyNames.Length] = 'SelectionRight';
}

function UTMapInfo GetMapInfo(optional out WorldInfo WI)
{
	WI = UTUIScene_Hud( GetScene() ).GetWorldInfo();
	if ( WI != none )
	{

		return UTMapInfo(WI.GetMapInfo());
	}

	return none;
}

/**
 * Called from native code.  This is the only point where Canvas is valid.
 * we use this moment to setup the color fading
 */
event DrawPanel()
{
	local UTMapInfo MI;
	local UTPlayerController PlayerOwner;
	local actor a;
	local int x,y,w,h;

	MI = GetMapInfo();
	PlayerOwner = UTHudSceneOwner.GetUTPlayerOwner();

	if ( MI != none && PlayerOwner != none )
	{
		A = GetActorUnderMouse(PlayerOwner);
		MI.WatchedActor = A;

		h = Canvas.ClipY * MapSizePerc;
		w = h;

		x = (Canvas.ClipX * 0.5) - (w * 0.5);
		y = (Canvas.ClipY * 0.5) - (h * 0.5);

	    MI.DrawMap(Canvas, PlayerOwner, x,y, w, h, true, 1.0 );
	}
}


/**
 * @Returns the node currently under the mouse cursor.
 */
function Actor GetActorUnderMouse(UTPlayerController PlayerOwner)
{
	local Vector CursorVector;
	local int X,Y;
	local int i;
	local float D;
	local WorldInfo WI;
	local UTMapInfo MI;
	local UTVehicle_Leviathan Levi;

	MI = GetMapInfo(WI);
	if ( WI != none && MI != none )
	{
		class'UIRoot'.static.GetCursorPosition( X, Y );

		// We can't use OrgX/OrgY here because they won't exist outside of the render loop

		CursorVector.X = X - GetPosition(UIFACE_Left, EVALPOS_PixelViewport, true);
		CursorVector.Y = Y - GetPosition(UIFACE_Top, EVALPOS_PixelViewport, true);

		for (i = 0; i < MI.Objectives.Length; i++)
		{
			D = VSize(MI.Objectives[i].HUDLocation - CursorVector);
			if ( !MI.Objectives[i].bIsDisabled && UTOnslaughtNodeObjective(MI.Objectives[i]) != none && D < 20 * MI.MapScale )
			{
				if ( PlayerOwner.WorldInfo.GRI.OnSameTeam(PlayerOwner,MI.Objectives[i]) )
				{
					return MI.Objectives[i];
				}
			}
		}

		foreach WI.DynamicActors(class	'UTVehicle_Leviathan',Levi)
		{
			D = VSize(Levi.HUDLocation - CursorVector);
			if ( D < 20 * MI.MapScale )
			{
				if (PlayerOwner.WorldInfo.GRI.OnSameTeam(PlayerOwner,Levi) )
				{
					return Levi;
				}
			}
		}
	}

	return none;
}

function FindBestActor()
{
	local int i;
	local float Dist,BestDist;
	local UTGameObjective BestObj;
	local UTPlayerController PlayerOwner;
	local UTMapInfo MI;

	MI = GetMapInfo();

	PlayerOwner = UTHudSceneOwner.GetUTPlayerOwner();
	if ( PlayerOwner != none )
	{
    	if ( PlayerOwner.Pawn != none )
    	{
			for (i=0;i<MI.Objectives.Length;i++)
			{
				if ( !MI.Objectives[i].bIsDisabled && UTOnslaughtNodeObjective(MI.Objectives[i]) != none )
				{

					Dist = VSize(PlayerOwner.Pawn.Location - MI.Objectives[i].Location);
					if ( BestObj == none || Dist < BestDist && PlayerOwner.WorldInfo.GRI.OnSameTeam(PlayerOwner,MI.Objectives[i]) )
					{
						BestDist = Dist;
						BestObj = MI.Objectives[i];
					}
				}
			}
		}
		else
		{
			for (i=0;i<MI.Objectives.Length;i++)
			{
				if ( UTOnslaughtPowerCore(MI.Objectives[i]) != none && PlayerOwner.WorldInfo.GRI.OnSameTeam(PlayerOwner,MI.Objectives[i]) )
				{
					SetCurrentActor(MI.Objectives[i]);
					return;
				}
			}
		}
	}

	SetCurrentActor(BestObj);
}

function ChangeCurrentActor(Vector V, int PlayerIndex)
{
	local int i;
	local float Dist,BestDist;
	local Actor BestActor;
	local UTVehicle_Leviathan Levi;
	local float VD;
	local WorldInfo WI;
	local UTMapInfo MI;
	local UTPlayerController PC;

	PC = UTHudSceneOwner.GetUTPlayerOwner(PlayerIndex);

	MI = GetMapInfo(WI);

	if ( WI != none && MI != none )
	{
		if (MI.CurrentActor == none)
		{
			FindBestActor();
			return;
		}

		for (i=0;i<MI.Objectives.Length;i++)
		{
			if ( !MI.Objectives[i].bIsDisabled && UTOnslaughtNodeObjective(MI.Objectives[i]) != none
					&& MI.Objectives[i] != MI.CurrentActor && PC.WorldInfo.GRI.OnSameTeam(PC,MI.Objectives[i])  )
			{
	    		Dist = abs( VSize( MI.GetActorHudLocation(MI.CurrentActor) - MI.Objectives[i].HUDLocation ));
			    if (BestActor == none || BestDist > Dist)
			    {
			    	VD = V dot Normal(MI.Objectives[i].HudLocation - MI.GetActorHudLocation(MI.CurrentActor));
			    	if ( VD > 0.7 )
			    	{
	    				BestDist = Dist;
		            	BestActor = MI.Objectives[i];
		            }
			    }
			}

		}

		foreach WI.DynamicActors(class'UTVehicle_Leviathan', Levi)
		{
			if ( Levi != MI.CurrentActor && PC.WorldInfo.GRI.OnSameTeam(PC,Levi) )
			{
				Dist = abs( VSize( MI.GetActorHudLocation(MI.CurrentActor) - Levi.HUDLocation) );
			    if (BestActor == none || BestDist > Dist)
			    {
			    	VD = V dot Normal(Levi.HudLocation - MI.GetActorHudLocation(MI.CurrentActor));

			    	if ( VD > 0.7 )
			    	{
	    				BestDist = Dist;
		            	BestActor = Levi;
		            }
			    }
			}
		}

		if ( BestActor != none )
		{
			SetCurrentActor(BestActor);
		}
	}
}

function SetCurrentActor(Actor NewCurrentActor)
{
	local UTMapInfo MI;

	MI = GetMapInfo();
	if ( MI != none )
	{
		MI.CurrentActor = NewCurrentActor;
	}

}

function bool InputKey( const out InputEventParameters EventParms )
{
	local UTPlayerController PC;
	local UTUIScene UTS;

	UTS = UTUIScene(GetScene());
	if ( UTS != none )
	{
		PC = UTS.GetUTPlayerOwner();
		if ( PC != none )
		{
			if (EventPArms.EventType == IE_Released && EventPArms.InputKeyName == 'LeftMouseButton')
			{
				PickActorUnderCursor(EventParms.PlayerIndex);
				return true;
			}
			else if (EventParms.EventType == IE_DoubleClick && EventParms.InputKeyName == 'LeftMouseButton')
			{
				if ( PickActorUnderCursor(EventParms.PlayerIndex) != none )
				{
					SelectActor(PC);
				}

				return true;
			}
			else if ( EventParms.EventType == IE_Released && (EventParms.InputKeyName == 'Enter' || EventParms.InputKeyName == 'XBoxTypeS_A') )
			{
				SelectActor(PC);
			}

		}

		if ( EventParms.EventType == IE_Pressed || EventParms.EventType == IE_Repeat )
		{
			if ( EventParms.InputKeyName == 'Left' || EventParms.InputKeyName == 'NumPadFour' ||
					EventParms.InputKeyName == 'XBoxTypeS_DPad_Left' || EventParms.InputKeyName == 'GamePad_LeftStick_Left' )
			{
				ChangeCurrentActor( Vect(-1,0,0),EventParms.PlayerIndex);
				return true;
			}

			else if ( EventParms.InputKeyName == 'Right' || EventParms.InputKeyName == 'NumPadSix' ||
						EventParms.InputKeyName == 'XBoxTypeS_DPad_Right' || EventParms.InputKeyName == 'GamePad_LeftStick_Right' )
			{
				ChangeCurrentActor( Vect(1,0,0),EventParms.PlayerIndex );
				return true;
			}

			else if ( EventParms.InputKeyName == 'Up' || EventParms.InputKeyName == 'NumPadEight' ||
						EventParms.InputKeyName == 'XBoxTypeS_DPad_Up' || EventParms.InputKeyName == 'GamePad_LeftStick_Up' )
			{
				ChangeCurrentActor( Vect(0,-1,0),EventParms.PlayerIndex );
				return true;
			}

			else if ( EventParms.InputKeyName == 'Down' || EventParms.InputKeyName == 'NumPadTwo' ||
						EventParms.InputKeyName == 'XBoxTypeS_DPad_Down' || EventParms.InputKeyName == 'GamePad_LeftStick_Down' )
			{
				ChangeCurrentActor( Vect(0,1,0),EventParms.PlayerIndex );
				return true;
			}
		}

	}

	return false;
}

/**
 * Look under the mouse cursor and pick the node that is there
 */
function Actor PickActorUnderCursor(int PlayerIndex)
{
	local Actor ActorUnderCursor;
	local UTPlayerController PC;

	PC = UTHudSceneOwner.GetUTPlayerOwner(PlayerIndex);

	ActorUnderCursor = GetActorUnderMouse(PC);
	if ( ActorUnderCursor != none )
	{
		SetCurrentActor(ActorUnderCursor);
	}

	return ActorUnderCursor;
}

/**
 * The player has attempted to select a node, Look it up and pass it along to the delegate if it exists
 */

function SelectActor(UTPlayerController UTPC)
{
	local UTMapInfo MI;
	MI = GetMapInfo();
	`log("### SelectActor:"@MI@MI.CurrentActor);
	if ( MI != none && MI.CurrentActor != none )
	{
		`log("### OnActorSelected");
		OnActorSelected( MI.CurrentActor, UTPC );
	}
}

defaultproperties
{
	DefaultStates.Add(class'Engine.UIState_Active')
	MapSizePerc=0.9
}
