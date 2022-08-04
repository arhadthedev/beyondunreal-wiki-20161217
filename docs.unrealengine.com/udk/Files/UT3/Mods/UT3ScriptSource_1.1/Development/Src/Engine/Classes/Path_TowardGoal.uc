class Path_TowardGoal extends PathConstraint
	native(AI);



/** Goal trying to find path toward */
var Actor	GoalActor;

static function bool TowardGoal( Pawn P, Actor Goal )
{
	local Path_TowardGoal Con;

	if( P != None && Goal != None )
	{
		Con = new class'Path_TowardGoal';
		if( Con != None )
		{
			Con.GoalActor = Goal;
			P.AddPathConstraint( Con );
			return TRUE;
		}
	}

	return FALSE;
}

defaultproperties
{
}
