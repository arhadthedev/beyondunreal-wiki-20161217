/**
 * Represents a set of actors based on Actor.Group vs GroupName.
 */
class SeqVar_Group extends SeqVar_Object
	native(Sequence);

;

var() Name GroupName;

/** Has the list been cached? */
var transient bool bCachedList;
/** List of actors w/ matching Group, @note using Object simply for GetObjectRef(), typing isn't really important here */
var transient array<Object> Actors;

defaultproperties
{
	ObjName="Group"
	ObjCategory="Object"
}