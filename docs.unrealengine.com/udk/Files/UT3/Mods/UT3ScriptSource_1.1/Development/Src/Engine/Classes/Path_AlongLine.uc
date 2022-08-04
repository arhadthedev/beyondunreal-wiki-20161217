class Path_AlongLine extends PathConstraint
	native(AI);



/** Direction to move in */
var Vector	Direction;

static function bool AlongLine( Pawn P, Vector Dir )
{
	local Path_AlongLine Con;

	if( P != None && !IsZero( Dir ) )
	{
		Con = new class'Path_AlongLine';
		if( Con != None )
		{
			Con.Direction = Dir;
			P.AddPathConstraint( Con );
			return TRUE;
		}
	}

	return FALSE;
}

defaultproperties
{
}
