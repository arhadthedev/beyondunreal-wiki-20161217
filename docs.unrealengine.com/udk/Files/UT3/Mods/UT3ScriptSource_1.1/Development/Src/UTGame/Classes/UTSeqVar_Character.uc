/** takes a character name and converts it to the Controller of the player who is playing that character
 * always works on bots, only works on humans in the single player campaign
 */
class UTSeqVar_Character extends SeqVar_Object
	native(Sequence);

;

var() string CharacterName;

defaultproperties
{
	ObjName="Character"
	ObjCategory="Object"
}
