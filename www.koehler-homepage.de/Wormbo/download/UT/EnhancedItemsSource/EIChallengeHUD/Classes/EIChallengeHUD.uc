//=============================================================================
// EIChallengeHUD.
//=============================================================================
class EIChallengeHUD extends EnhancedMutator;

#exec TEXTURE IMPORT NAME=BossDoll2 FILE=Textures\BossDoll2.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=Man2 FILE=Textures\Man2.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=Woman2 FILE=Textures\Woman2.PCX GROUP="Icons" MIPS=OFF FLAGS=2

var Pawn PawnOwner;
var bool bHideStatus;
var Texture ManShield, WomanShield, BossShield;
var bool bChaosUTFailed, bEITexturesFailed, bLoadedCustomHUDIcon;
var CustomHUDIcon CustomHUDIcon;

function PreBeginPlay();

simulated function Destroyed()
{
	Super.Destroyed();
	if ( CustomHUDIcon != None )
		CustomHUDIcon.Destroy();
}

simulated function PostRender(Canvas Canvas)
{
	CheckHUDConfig();
	if ( CustomHUDIcon != None ) {
		CustomHUDIcon.CheckCustomHUDConfig(Self);
		if ( CustomHUDIcon.AllowDrawCustomStatus(Self) )
			CustomHUDIcon.DrawCustomStatus(Canvas, Self);
	}
	else if ( AllowDrawStatus() )
		DrawStatus(Canvas);
	Super.PostRender(Canvas);
}

simulated function bool AllowDrawStatus()
{
	if ( MyChallengeHUD == None || MyChallengeHUD.bHideHUD || MyChallengeHUD.bShowInfo
			|| bHideStatus || (PawnOwner != None && PawnOwner.PlayerReplicationInfo != None
			&& PawnOwner.PlayerReplicationInfo.bIsSpectator)
			|| (PlayerOwner != None && PlayerOwner.bShowScores) || MyChallengeHUD.bForceScores )
		return false;
	return true;
}

simulated function CheckHUDConfig()
{
	MyChallengeHUD = ChallengeHUD(MyHUD);
	if ( !bLoadedCustomHUDIcon )
		LoadCustomHUDIcon();
	if ( MyChallengeHUD != None ) {
		if ( MyChallengeHUD.bHideAllWeapons && !bHideStatus ) {
			bHideStatus = True;
			MyChallengeHUD.bHideAllWeapons = False;
		}
		else if ( bHideStatus && !MyChallengeHUD.bHideStatus ) {
			bHideStatus = False;
			MyChallengeHUD.bHideStatus = True;
			MyChallengeHUD.WeaponScale = 1.0;
		}
		MyChallengeHUD.bHideStatus = True;
		PlayerOwner = MyChallengeHUD.PlayerOwner;
		PawnOwner = MyChallengeHUD.PawnOwner;
	}
	else if ( !bHideStatus ) {
		bHideStatus = True;
		log(Name$": No HUD.");
	}
}

simulated function LoadCustomHUDIcon()
{
	local string NextClass, NextDesc, BestMatch, BestHUDClass;
	local int i, k;
	local class<CustomHUDIcon> CustomHUDIconClass, LastHUDIconClass;
	local class<HUD> DesiredHUDClass;
	
	if ( class'PickupPlus'.default.bDebugMode )
		log("Loading custom HUD icon...", Name);
	GetNextIntDesc("EIChallengeHUD.CustomHUDIcon", i, NextClass, NextDesc);
	while ( NextClass != "" ) {
		k = InStr(NextDesc, ",");
		if ( k != -1 )
			NextDesc = Left(NextDesc, k);
		
		if ( string(MyHUD.Class) ~= NextDesc ) {	// exact class
			CustomHUDIconClass = class<CustomHUDIcon>(DynamicLoadObject(NextClass, class'Class', True));
			if ( CustomHUDIconClass != None )
				break;
		}
		else if ( ClassIsA(MyHUD.Class, NextDesc) ) {	// subclass
			DesiredHUDClass = class<HUD>(DynamicLoadObject(NextDesc, class'Class', True));
			if ( DesiredHUDClass != None && BestHUDClass != "" && ClassIsA(DesiredHUDClass, BestHUDClass) ) {
				BestMatch = NextClass;
				BestHUDClass = NextDesc;
			}
		}
		GetNextIntDesc("EIChallengeHUD.CustomHUDIcon", ++i, NextClass, NextDesc);
	}
	if ( CustomHUDIconClass == None && BestMatch != "" )
		CustomHUDIconClass = class<CustomHUDIcon>(DynamicLoadObject(BestMatch, class'Class', True));
	if ( CustomHUDIconClass != None ) {
		CustomHUDIcon = Spawn(CustomHUDIconClass, Self);
		if ( class'PickupPlus'.default.bDebugMode )
			log("Loaded:"@CustomHUDIcon, Name);
	}
	else if ( class'PickupPlus'.default.bDebugMode )
		log("No matching HUD icon found...", Name);
	
	bLoadedCustomHUDIcon = True;
}

simulated function DrawStatus(Canvas Canvas)
{
	local float Scale, StatScale, H1, H2, X, Y, DamageTime,
		ChestAmount, ThighAmount, ShieldAmount, BeltAmount, GlovesAmount, BootsAmount;
	Local int ArmorAmount, CurAbs, i;
	local inventory Inv, BestArmor;
	local PickupPlus PInv;
	local bool bShield, bShieldSpecial, bInvisible;
	local bool bChestArmor, bThighArmor, bBoots, bBelt, bGloves, bHasDoll;
	local bool bChestSpecial, bThighSpecial, bJumpBoots, bBeltSpecial, bGlovesSpecial;
	local Bot BotOwner;
	local TournamentPlayer TPOwner;
	local texture Doll, DollBelt, Doll2;
	
	Scale = MyChallengeHUD.Scale;
	for (Inv = PlayerOwner.Inventory; Inv != None; Inv = Inv.Inventory) { 
		if ( !Inv.bDisplayableInv && !Inv.IsA('SpawnProtEffect') )
			continue;
		PInv = PickupPlus(Inv);
		if ( Inv.bIsAnArmor ) {
			if ( OtherIsA(Inv, 'UT_Shieldbelt') || OtherIsA(Inv, 'Shieldbelt') ) {
				ShieldAmount += Inv.Charge;
				BeltAmount += 10;
				bShield = True;
				bBelt = True;
			}
			else if ( OtherIsA(Inv, 'Thighpads') ) {
				ThighAmount += Inv.Charge;
				bThighArmor = True;
			}
			else if ( OtherIsA(Inv, 'Armor2') || OtherIsA(Inv, 'Armor') ) { 
				bChestArmor = True;
				ChestAmount += Inv.Charge;
			}
			else if ( Inv.IsA('Suits') ) {
				ThighAmount += Inv.Charge * 0.5;
				ChestAmount += Inv.Charge;
				BeltAmount += Inv.Charge * 0.5;
				BootsAmount += Inv.Charge * 0.5;
				GlovesAmount += Inv.Charge * 0.5;
				bThighArmor = True;
				bChestArmor = True;
				bBelt = True;
				bBoots = True;
				bGloves = True;
			}
			ArmorAmount += Inv.Charge;
		}
		else if ( Inv.IsA('SpawnProtEffect') )
			bShieldSpecial = True;
		else if ( OtherIsA(Inv, 'UT_Invisibility') || OtherIsA(Inv, 'Invisibility') )
			bInvisible = True;
		else if ( OtherIsA(Inv, 'UT_JumpBoots') || OtherIsA(Inv, 'c_JumpBoots') || OtherIsA(Inv, 'JumpBoots') )
			bJumpBoots = True;	// (UT AntiGrav Boots, Chaos UT SUPER Jump Boots, Unreal Jump Boots)
		else if ( OtherIsA(Inv, 'GravBelt') )
			bBeltSpecial = True;	// (Chaos UT Grav Belt)
		if ( PInv != None ) {
			if ( PInv.bMakesInvisible )
				bInvisible = True;
			if ( PInv.bIsChestArmor ) {
				bChestArmor = True;
				ChestAmount += PInv.GetCharge();
			}
			if ( PInv.bIsThighArmor ) {
				bThighArmor = True;
				ThighAmount += PInv.GetCharge();
			}
			if ( PInv.bIsShieldArmor ) {
				bShield = True;
				ShieldAmount += PInv.GetCharge();
			}
			if ( PInv.bIsBeltArmor ) {
				bBelt = True;
				BeltAmount += PInv.GetCharge();
			}
			if ( PInv.bIsGlovesArmor ) {
				bGloves = True;
				GlovesAmount += PInv.GetCharge();
			}
			if ( PInv.bIsBootsArmor ) {
				bBoots = True;
				BootsAmount += PInv.GetCharge();
			}
			if ( PInv.bIsShieldSpecial )
				bShieldSpecial = True;
			if ( PInv.bIsChestSpecial )
				bChestSpecial = True;
			if ( PInv.bIsThighSpecial )
				bThighSpecial = True;
			if ( PInv.bIsBeltSpecial )
				bBeltSpecial = True;
			if ( PInv.bIsGlovesSpecial )
				bGlovesSpecial = True;
			if ( PInv.bIsJumpBoots )
				bJumpBoots = True;
		}
		if ( i++ > 200 )
			break;	// can occasionally get temporary loops in netplay
	}

	TPOwner = TournamentPlayer(PawnOwner);
	if ( Canvas.ClipX < 400 )
		bHasDoll = false;
	else if ( TPOwner != None ) {
		Doll = TPOwner.StatusDoll;
		DollBelt = TPOwner.StatusBelt;
		bHasDoll = true;
	}
	else {
		BotOwner = Bot(PawnOwner);
		if ( BotOwner != None ) {
			Doll = BotOwner.StatusDoll;
			DollBelt = BotOwner.StatusBelt;
			bHasDoll = true;
		}
	}
	if ( bHasDoll ) { 							
		Doll2 = GetDollTexture(Doll);
		if ( Doll2 == Doll ) {
			// no special icon available for gloves and belt
			bBelt = False;
			bBeltSpecial = False;
			bGloves = False;
			bGlovesSpecial = False;
		}
		Canvas.Style = ERenderStyle.STY_Translucent;
		StatScale = MyChallengeHUD.Scale * MyChallengeHUD.StatusScale;
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Canvas.SetPos(X, 0);
		if ( PawnOwner.DamageScaling > 2.0 )
			Canvas.DrawColor = MyChallengeHUD.PurpleColor;
		else
			Canvas.DrawColor = MyChallengeHUD.HUDColor;
		if ( bInvisible && Canvas.DrawColor != MyChallengeHUD.BaseColor )
			Canvas.DrawColor = Canvas.DrawColor * 0.1 + MyChallengeHUD.BaseColor * 0.3;
		else if ( bInvisible )
			Canvas.DrawColor = Canvas.DrawColor * 0.3 + MyChallengeHUD.BlueColor * 0.1;
		Canvas.DrawTile(Doll2, 128 * StatScale, 256 * StatScale, 0, 0, 128.0, 256.0);
		
		// shield belt
		if ( bShield ) {
			ShieldAmount = FClamp(0.01 * ShieldAmount, 0.2, 1);
			Canvas.DrawColor = MyChallengeHUD.BaseColor * ShieldAmount;
			Canvas.DrawColor.B = 0;
			Canvas.SetPos(X, 0);
			Canvas.DrawIcon(DollBelt, StatScale);
		}
		
		// special items (jump boots, grav belt, etc.)
		Canvas.DrawColor = MyChallengeHUD.BaseColor - MyChallengeHUD.HUDColor;
		if ( bInvisible )
			Canvas.DrawColor = Canvas.DrawColor * 0.5;
		if ( bChestSpecial ) {
			Canvas.SetPos(X, 0);
			Canvas.DrawTile(Doll, 128 * StatScale, 80 * StatScale, 128, 0, 128, 80);
		}
		if ( bThighSpecial ) {
			Canvas.SetPos(X, 80 * StatScale);
			Canvas.DrawTile(Doll, 128 * StatScale, 52 * StatScale, 128, 80, 128, 52);
		}
		if ( bBeltSpecial ) {
			Canvas.SetPos(X + 28 * StatScale, 0);
			Canvas.DrawTile(Doll2, 42 * StatScale, 256 * StatScale, 156, 0, 42, 256);
		}
		if ( bGlovesSpecial ) {
			Canvas.SetPos(X, 0);
			Canvas.DrawTile(Doll2, 28 * StatScale, 256 * StatScale, 128, 0, 28, 256);
			Canvas.SetPos(X + 70 * StatScale, 0);
			Canvas.DrawTile(Doll2, 32 * StatScale, 256 * StatScale, 198, 0, 32, 256);
		}
		if ( bJumpBoots ) {
			Canvas.SetPos(X, 132 * StatScale);
			Canvas.DrawTile(Doll, 128 * StatScale, 64 * StatScale, 128, 132, 128, 64);
		}
		if ( bShieldSpecial ) {
			Canvas.SetPos(X, 0);
			Canvas.DrawIcon(GetSpecialShield(DollBelt), StatScale);
		}
		
		// armor items except shield belt (body armor, thigh pads, suits, etc.)
		if ( bChestArmor ) {
			ChestAmount = FMin(0.01 * ChestAmount, 1);
			Canvas.DrawColor = MyChallengeHUD.HUDColor * ChestAmount;
			Canvas.SetPos(X, 0);
			Canvas.DrawTile(Doll, 128 * StatScale, 80 * StatScale, 128, 0, 128, 80);
		}
		if ( bThighArmor ) {
			ThighAmount = FMin(0.02 * ThighAmount, 1);
			Canvas.DrawColor = MyChallengeHUD.HUDColor * ThighAmount;
			Canvas.SetPos(X, 80 * StatScale);
			Canvas.DrawTile(Doll, 128 * StatScale, 52 * StatScale, 128, 80, 128, 52);
		}
		if ( bBelt ) {
			BeltAmount = FMin(0.02 * BeltAmount, 1);
			Canvas.DrawColor = MyChallengeHUD.HUDColor * BeltAmount;
			Canvas.SetPos(X + 28 * StatScale, 0);
			Canvas.DrawTile(Doll2, 42 * StatScale, 256 * StatScale, 156, 0, 42, 256);
		}
		if ( bGloves ) {
			GlovesAmount = FMin(0.02 * GlovesAmount, 1);
			Canvas.DrawColor = MyChallengeHUD.HUDColor * GlovesAmount;
			Canvas.SetPos(X, 0);
			Canvas.DrawTile(Doll2, 28 * StatScale, 256 * StatScale, 128, 0, 28, 256);
			Canvas.SetPos(X + 70 * StatScale, 0);
			Canvas.DrawTile(Doll2, 32 * StatScale, 256 * StatScale, 198, 0, 32, 256);
		}
		if ( bBoots ) {
			BootsAmount = FMin(0.02 * BootsAmount, 1);
			Canvas.DrawColor = MyChallengeHUD.HUDColor * BootsAmount;
			Canvas.SetPos(X, 132 * StatScale);
			Canvas.DrawTile(Doll, 128 * StatScale, 64 * StatScale, 128, 132, 128, 64);
		}
		
		Canvas.Style = MyChallengeHUD.Style;
		if ( PlayerOwner == PawnOwner && Level.bHighDetailMode && !Level.bDropDetail ) {
			for (i = 0; i < 4; i++) {
				DamageTime = Level.TimeSeconds - MyChallengeHUD.HitTime[i];
				if ( DamageTime < 1 ) {
					Canvas.SetPos(X + MyChallengeHUD.HitPos[i].X * StatScale, MyChallengeHUD.HitPos[i].Y * StatScale);
					if ( MyChallengeHUD.HUDColor.G > 100 || MyChallengeHUD.HUDColor.B > 100 )
						Canvas.DrawColor = MyChallengeHUD.RedColor;
					else
						Canvas.DrawColor = (MyChallengeHUD.WhiteColor - MyChallengeHUD.HudColor) * FMin(1, 2 * DamageTime);
					Canvas.DrawColor.R = 255 * FMin(1, 2 * DamageTime);
					Canvas.DrawTile(Texture'BotPack.HudElements1', StatScale * MyChallengeHUD.HitDamage[i] * 25,
							StatScale * MyChallengeHUD.HitDamage[i] * 64, 0, 64, 25.0, 64.0);
				}
			}
		}
	}
}

simulated function Texture GetDollTexture(Texture Doll)
{
	if ( Doll == Texture'Botpack.Icons.Man' )
		return Texture'EIChallengeHUD.Icons.Man2';
	if ( Doll == Texture'Botpack.Icons.Woman' )
		return Texture'EIChallengeHUD.Icons.Woman2';
	if ( Doll == Texture'Botpack.Icons.BossDoll' )
		return Texture'EIChallengeHUD.Icons.BossDoll2';
}

simulated function Texture GetSpecialShield(Texture BeltIcon)
{
	local Texture Temp;
	
	switch (BeltIcon.Name) {
	case 'ManBelt':
		if ( ManShield == None && !bEITexturesFailed )
			ManShield = Texture(DynamicLoadObject("EITextures.MSpawnProt_a01", class'Texture', True));
		if ( ManShield == None && !bChaosUTFailed ) {
			bEITexturesFailed = True;
			ManShield = Texture(DynamicLoadObject("Chaostex.SpawnProt_a01", class'Texture', True));
		}
		if ( ManShield == None ) {
			bChaosUTFailed = True;
			return BeltIcon;
		}
		else
			return ManShield;
		break;
	case 'WomanBelt':
		if ( WomanShield == None && !bEITexturesFailed )
			WomanShield = Texture(DynamicLoadObject("EITextures.FSpawnProt_a01", class'Texture', True));
		if ( WomanShield == None ) {
			bEITexturesFailed = True;
			return BeltIcon;
		}
		else
			return WomanShield;
		break;
	case 'BossBelt':
		if ( BossShield == None && !bEITexturesFailed )
			BossShield = Texture(DynamicLoadObject("EITextures.BSpawnProt_a01", class'Texture', True));
		if ( BossShield == None ) {
			bEITexturesFailed = True;
			return BeltIcon;
		}
		else
			return BossShield;
		break;
	default:
		return BeltIcon;
		break;
	}
}

defaultproperties
{
     bAlwaysRelevant=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     bPendingHUDRegistration=True
}
