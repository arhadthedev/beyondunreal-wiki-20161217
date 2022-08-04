class RegularPawn extends xPawn;
var xUtil.PlayerRecord PlayerSetup;
var string PlayerClassName;

var float ReceivedDamageScaling;

replication
{
 reliable if( Role==ROLE_Authority )
		PlayerClassName;

}

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	rec = GetPlayerRecord(rec);

 Species = rec.Species;
	RagdollOverride = rec.Ragdoll;
	Species.static.Setup(self,rec);
	ResetPhysicsBasedAnim();
}

simulated function xUtil.PlayerRecord GetPlayerRecord(xUtil.PlayerRecord PlayerSetup) {

		LOG("Switching "$PlayerReplicationInfo.PlayerName$" to "$PlayerClassName);



		if(PlayerClassName ~= "Sniper") {
			PlayerSetup.MeshName="HumanFemaleA.MercFemaleC";
   PlayerSetup.Species=class'xGame.SPECIES_Merc';
   PlayerSetup.BodySkinName="PlayerSkins.MercFemaleCBodyA";
   PlayerSetup.FaceSkinName="PlayerSkins.MercFemaleCHeadA";
   PlayerSetup.Sex="Female";
   RequiredEquipment[1]="XWeapons.AssaultRifle";
   RequiredEquipment[2]="UTClassic.ClassicSniperRifle";
   GroundSpeed=550;
   ReceivedDamageScaling=1.10;
			}

		if(PlayerClassName ~= "Infantry") {
				PlayerSetup.MeshName="HumanMaleA.MercMaleC";
    PlayerSetup.Species=class'xGame.Species_Merc';
    PlayerSetup.BodySkinName="PlayerSkins.MercMaleCBodyA";
    PlayerSetup.FaceSkinName="PlayerSkins.MercMaleCHeadA";
    PlayerSetup.Sex="Male";
    RequiredEquipment[1]="XWeapons.AssaultRifle";
    RequiredEquipment[2]="XWeapons.MiniGun";
    ReceivedDamageScaling=0.95;
			}

		if(PlayerClassName ~= "Heavy Arms") {
		  PlayerSetup.MeshName="Jugg.JuggMaleB";
    PlayerSetup.Species=class'xGame.Species_Night';
    PlayerSetup.BodySkinName="PlayerSkins.JuggMaleBBodyA";
    PlayerSetup.FaceSkinName="PlayerSkins.JuggMaleBHeadA";
    PlayerSetup.Sex="Male";
    RequiredEquipment[1]="XWeapons.AssaultRifle";
    RequiredEquipment[2]="XWeapons.RocketLauncher";
    GroundSpeed=400;
				ReceivedDamageScaling=0.85;
  }

  if(PlayerClassName ~= "Human Captain") {
		  PlayerSetup.MeshName="XanRobots.XanM02";
    PlayerSetup.Species=class'xGame.SPECIES_Bot';
    PlayerSetup.BodySkinName="UT2004PlayerSkins.XanM2v2_Body";
    PlayerSetup.FaceSkinName="UT2004PlayerSkins.XanM2v2_Head";
    PlayerSetup.Sex="Male";
    RequiredEquipment[1]="XWeapons.AssaultRifle";
    RequiredEquipment[2]="XWeapons.FlakCannon";
  }

  if(PlayerClassName ~= "Trooper") {
		  PlayerSetup.MeshName="SkaarjAnims.Skaarj2";
    PlayerSetup.Species=class'xGame.SPECIESSkaarj';
    PlayerSetup.BodySkinName="UT2004PlayerSkins.Skaarj2_Body_Rage";
    PlayerSetup.FaceSkinName="UT2004PlayerSkins.Skaarj2_Head_Rage";
    PlayerSetup.Sex="Male";
    RequiredEquipment[1]="XWeapons.AssaultRifle";
  	 RequiredEquipment[2]="XWeapons.LinkGun";
    GroundSpeed=550;
    ReceivedDamageScaling=1.10;
  }

  if(PlayerClassName ~= "Specialist") {
		  PlayerSetup.MeshName="SkaarjAnims.Skaarj3";
    PlayerSetup.Species=class'xGame.SPECIESSkaarj';
    PlayerSetup.BodySkinName="UT2004PlayerSkins.Skakruk_Body";
    PlayerSetup.FaceSkinName="UT2004PlayerSkins.Skakruk_Head";
    PlayerSetup.Sex="Male";
    RequiredEquipment[1]="XWeapons.AssaultRifle";
  	 RequiredEquipment[2]="XWeapons.ShockRifle";
    ReceivedDamageScaling=0.95;
  }

  if(PlayerClassName ~= "Assault") {
		  PlayerSetup.MeshName="SkaarjAnims.SkaarjUT2004";
    PlayerSetup.Species=class'xGame.SPECIESSkaarj';
    PlayerSetup.BodySkinName="UT2004PlayerSkins.Skaarj_Body_Tats";
    PlayerSetup.FaceSkinName="UT2004PlayerSkins.Skaarj_Head_Tats";
    PlayerSetup.Sex="Male";
    RequiredEquipment[1]="XWeapons.AssaultRifle";
  	 RequiredEquipment[2]="Onslaught.ONSMineLayer";
    GroundSpeed=400;
    ReceivedDamageScaling=0.75;
  }


  if(PlayerClassName ~= "Skaarj Captain") {
		  PlayerSetup.MeshName="SkaarjAnims.Skaarj4";
    PlayerSetup.Species=class'xGame.SPECIESSkaarj';
    PlayerSetup.BodySkinName="UT2004PlayerSkins.Skaarj4_Body";
    PlayerSetup.FaceSkinName="UT2004PlayerSkins.Skaarj4_Head";
    PlayerSetup.Sex="Male";
    RequiredEquipment[1]="Onslaught.ONSGrenadeLauncher";
  	 RequiredEquipment[2]="XWeapons.LinkGun";
  }

  return PlayerSetup;
}

defaultproperties {
 ControllerClass=class'RegularBot'
 ReceivedDamageScaling=1.0
}
