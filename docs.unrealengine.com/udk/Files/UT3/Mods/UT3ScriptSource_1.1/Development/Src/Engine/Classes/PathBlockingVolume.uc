/** this volume only blocks the path builder - it has no gameplay collision */
class PathBlockingVolume extends Volume
	native
	placeable;



defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
		AlwaysLoadOnClient=false
		AlwaysLoadOnServer=false
	End Object

	bWorldGeometry=true
	bCollideActors=false
	bBlockActors=true
}
