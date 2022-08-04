class Goal_AtActor extends PathGoalEvaluator
	native(AI);
	


/** Actor to reach */
var Actor GoalActor;
/** Within this acceptable distance */
var float GoalDist;

static function bool AtActor( Pawn P, Actor Goal, optional float Dist )
{
	local Goal_AtActor	Eval;
	local Pawn			GoalPawn;
	local Controller	GoalController;
	local float			AnchorDist;

	if( P != None )
	{
		GoalPawn = Pawn(Goal);
		GoalController = Controller(Goal);
		if( GoalController != None )
		{
			if( GoalController.Pawn != None )
			{
				GoalPawn = GoalController.Pawn;
			}
			else
			{
				Goal = None;
			}
		}
		if( GoalPawn != None )
		{
			Goal = GoalPawn.GetBestAnchor( GoalPawn, GoalPawn.Location, FALSE, FALSE, AnchorDist );
		}

		if( Goal != None )
		{
			Eval = new class'Goal_AtActor';
			if( Eval != None )
			{
				Eval.GoalActor = Goal;
				Eval.GoalDist  = Dist;
				P.AddGoalEvaluator( Eval );
				return TRUE;
			}
		}
	}

	return FALSE;
}

defaultproperties
{
}