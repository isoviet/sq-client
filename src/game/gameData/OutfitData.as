package game.gameData
{
	public class OutfitData
	{
		static public var inited:Boolean = false;

		//OWNER
		static public const OWNER_SQUIRREL:int = 0;
		static public const OWNER_SHAMAN:int = 1;
		static public const OWNER_SCRAT:int = 2;
		static public const OWNER_SCRATTY:int = 3;
		static public const OWNER_MAX_TYPE:int = 4;

		//CHARACTER
		static public const CHARACTER_SQUIRREL:int = 0;
		static public const CHARACTER_SHAMAN:int = 1;
		static public const CHARACTER_RABBIT:int = 2;
		static public const CHARACTER_DRAGON:int = 3;
		static public const CHARACTER_MAX_TYPE:int = 4;

		//ACCESSORY TYPE
		static public const ACCESSORY_CLOAK:int = 0;
		static public const ACCESSORY_GLASSES:int = 1;
		static public const ACCESSORY_HANDS:int = 2;
		static public const ACCESSORY_NECK:int = 3;
		static public const ACCESSORY_TAIL:int = 4;
		static public const ACCESSORY_HAIRBAND:int = 5;

		//PACKAGE
		static public const SHAMAN_BLUE:int = -1;
		static public const SHAMAN_RED:int = -2;
		static public const SHAMAN_BLACK:int = -3;
		static public const TEAM_BLUE:int = -4;
		static public const TEAM_RED:int = -5;
		static public const CONTUSED_SQUIRREL:int = -6;
		static public const PERSIAN_MAN_ROCK:int = -7;
		static public const PERSIAN_WOMAN_ROCK:int = -8;
		static public const GRAVY:int = -9;
		static public const SLOW_FALL:int = -10;
		static public const SNOWBALL:int = -11;
		static public const UNDEAD:int = -12;

		static public const IRONMAN:int = 0;
		static public const ROBOCOP:int = 1;
		static public const ALTRONE:int = 2;
		static public const SUPERMAN_MAN:int = 3;
		static public const PIRATE:int = 4;
		static public const BLACK_BEARD:int = 5;
		static public const AMELIA:int = 6;
		static public const FLASH:int = 7;
		static public const PIKACHU:int = 8;
		static public const THRONE:int = 9;
		static public const ZOOM:int = 10;
		static public const CHESHIRE_CAT:int = 11;
		static public const BLACK_CAT:int = 12;
		static public const FAIRY_CAT:int = 13;
		static public const MYSTERIO:int = 14;
		static public const DORMAMMU:int = 15;
		static public const PHARAON_MAN:int = 16;
		static public const PHARAON_WOMAN:int = 17;
		static public const ANUBIS:int = 18;
		static public const TUTENSHTAIN:int = 19;
		static public const DEATH:int = 20;
		static public const SWEET_DEATH:int = 21;
		static public const BANSHEE:int = 22;
		static public const AID:int = 23;
		static public const SAILORMOON:int = 24;
		static public const FAIRY:int = 25;
		static public const ASSASSIN:int = 26;
		static public const TUXEDOMASK:int = 27;
		static public const HONEY_LEMON_WOMAN:int = 28;
		static public const SWEET_TOOTH:int = 29;
		static public const CHRONOS_MAN:int = 30;
		static public const PERSIA_MAN:int = 31;
		static public const LEPRECHAUN:int = 32;
		static public const HATTER:int = 33;
		static public const ELF:int = 34;
		static public const WIZARD_MAN:int = 35;
		static public const JUGGLER_MAN:int = 36;
		static public const TOOTHLESS:int = 37;
		static public const ZOMBIE:int = 38;
		static public const SKELETON:int = 39;
		static public const VAMPIRE:int = 40;
		static public const CTHULHU_MAN:int = 41;
		static public const SONIC:int = 42;
		static public const AMYROSE:int = 43;
		static public const ARMADILLO:int = 44;
		static public const STORM:int = 45;
		static public const HATSUNE:int = 46;
		static public const LEN:int = 47;
		static public const BUMBLEBEE:int = 48;
		static public const ARCEE:int = 49;
		static public const HIPSTER_WOMAN:int = 50;
		static public const HIPPIE_MAN:int = 51;
		static public const MOD:int = 52;
		static public const PARTY:int = 53;
		static public const CHAMPION:int = 54;
		static public const WOLF:int = 55;
		static public const VIKING:int = 56;
		static public const NINJA:int = 57;
		static public const FOOTPAD:int = 58;
		static public const SAMURAI:int = 59;
		static public const RAMBO:int = 60;
		static public const WENDIGO:int = 61;
		static public const RABBIT:int = 62;
		static public const VADER:int = 63;
		static public const CAPITAN_AMERICA:int = 64;
		static public const SPIDER:int = 65;
		static public const LOGAN:int = 66;
		static public const FROST_2014:int = 67;
		static public const SNOW_MAIDEN_2014:int = 68;
		static public const DEER:int = 69;
		static public const PARROT_MAN:int = 70;
		static public const IRBIS:int = 71;
		static public const BATMAN:int = 72;
		static public const CATWOMAN_BATMAN:int = 73;
		static public const CATWOMAN:int = 74;
		static public const JOKER:int = 75;
		static public const HARLEY_QUINN:int = 76;
		static public const SPARTAN_MAN:int = 77;
		static public const LEGION_RED:int = 78;
		static public const NAPOLEON:int = 79;
		static public const COP_MAN:int = 80;
		static public const ALCHEMIST:int = 81;
		static public const TOR:int = 82;
		static public const LOKI:int = 83;
		static public const SCRAT_METAL:int = 84;
		static public const SCRAT_DRAGON:int = 85;
		static public const SCRAT_JUGGLER:int = 86;
		static public const SCRAT_VAMPYRE:int = 87;
		static public const SCRAT_HATTER:int = 88;
		static public const SCRAT_SKELETON:int = 89;
		static public const SCRAT_PERSIA:int = 90;
		static public const SCRAT_ROBOCOP:int = 91;
		static public const SCRATTY_METAL:int = 92;
		static public const SCRATTY_DRAGON:int = 93;
		static public const SCRATTY_JUGGLER:int = 94;
		static public const SCRATTY_VAMPYRE:int = 95;
		static public const SCRATTY_HATTER:int = 96;
		static public const SCRATTY_SKELETON:int = 97;
		static public const SCRATTY_PERSIA:int = 98;
		static public const SCRATTY_FAIRY:int = 99;
		static public const GREEN_SHAMAN_MAN:int = 100;
		static public const BLUE_SHAMAN_MAN:int = 101;
		static public const PURPLE_SHAMAN_MAN:int = 102;
		static public const SHAMAN_DARK_RED:int = 103;
		static public const SHAMAN_DARK_PINK:int = 104;
		static public const FLOWER_SHAMAN:int = 105;
		static public const AIRBENDER_GREEN:int = 106;
		static public const AIRBENDER_BLUE:int = 107;
		static public const AIRBENDER_RED:int = 108;
		static public const AIRBENDER_VIOLET:int = 109;
		static public const PUPIL:int = 110;
		static public const SCRAT:int = 111;
		static public const SCRATTY:int = 112;
		static public const FAN:int = 113;
		static public const CRYSTAL_MAIDEN:int = 114;
		static public const SANTA_ELF:int = 115;
		static public const DOVAHKIIN:int = 116;
		static public const DRAGON_ICE:int = 117;
		static public const LICH_KING:int = 118;
		static public const RAFAEL:int = 119;
		static public const MC_TWIST:int = 120;
		static public const AMUR_MAN:int = 121;
		static public const AMUR_WOMAN:int = 122;
		static public const AMUR_GOLDEN_MAN:int = 123;
		static public const AMUR_GOLDEN_WOMAN:int = 124;

		static public const DEADPOOL:int = 125;
		static public const BUBBLEGUM:int = 126;

		static public const SHAMAN_SPRING:int = 127;
		static public const RAPUNZEL:int = 128;
		static public const DRUID:int = 129;
		static public const BEAR:int = 130;

		static public const EVA:int = 131;
		static public const STITCH:int = 132;
		static public const FARMER:int = 133;
		static public const HARLOCK:int = 134;
		static public const MINION:int = 135;

		static public const ORC:int = 136;
		static public const CHAPLIN:int = 137;

		static public const REAPER:int = int.MAX_VALUE;

		//ACCESSORIES
		static public const HIPSTER_MAN_GLASSES:int = 0;
		static public const HIPSTER_WOMAN_GLASSES:int = 1;
		static public const MAD_GLASSES:int = 2;
		static public const PUPIL_GLASS:int = 3;
		static public const STORM_GLASSES:int = 4;
		static public const THUNDER_GLASSES:int = 5;
		static public const BATMAN_CLOAK:int = 6;
		static public const FAIRY_WINGS:int = 7;
		static public const SAILOR_MOON_WINGS:int = 8;
		static public const SHADOW_CLOAK:int = 9;
		static public const VAMPIRE_CLOAK:int = 10;
		static public const ALCHEMIST_HAND:int = 11;
		static public const ASSASSIN_DAGGER:int = 12;
		static public const CAPTAIN_AMERICA_SHIELD:int = 13;
		static public const CAT_HANDS:int = 14;
		static public const CAT_WOMEN_WHIP:int = 15;
		static public const FAIRY_STUFF:int = 16;
		static public const HARD_SWEET:int = 17;
		static public const LEGION_KNIFE:int = 18;
		static public const LEPRECHAUN_HAND:int = 19;
		static public const LOKI_HAND:int = 20;
		static public const NAPOLEON_SWORD:int = 21;
		static public const NEW_YEAR_STUFF:int = 22;
		static public const NINJA_SWORD:int = 23;
		static public const OLYMPUS_TORCH:int = 24;
		static public const PERSIAN_SWORD:int = 25;
		static public const PHARAON_MAN_HANDS:int = 26;
		static public const PHARAON_WOMAN_HANDS:int = 27;
		static public const PUMPKIN_HAND:int = 28;
		static public const RAMBO_GUN:int = 29;
		static public const SAILOR_MOON_WAND:int = 30;
		static public const SPARTAN_SWORD:int = 31;
		static public const STICK:int = 32;
		static public const TOR_HAMMER:int = 33;
		static public const TUXEDO_MASK_HAND:int = 34;
		static public const VADER_SWORD:int = 35;
		static public const VIKING_HANDS:int = 36;
		static public const WAND:int = 37;
		static public const WOLF_STAFF:int = 38;
		static public const XMAS_MAN_STAFF:int = 39;
		static public const ASSASSIN_TAIL:int = 40;
		static public const BATMAN_TAIL:int = 41;
		static public const BIG_LEGO:int = 42;
		static public const CAT_WOMEN_TAIL:int = 43;
		static public const CHAMPION_TAIL:int = 44;
		static public const CHRONOS_TAIL:int = 45;
		static public const CUBE:int = 46;
		static public const CUTE_RABBIT_CARROT:int = 47;
		static public const DISC:int = 48;
		static public const EASTER_BASKET:int = 49;
		static public const ELF_SWORD:int = 50;
		static public const FAIRY_TAIL:int = 51;
		static public const ILLUSIONIST_MAN_TAIL:int = 52;
		static public const ILLUSIONIST_WOMAN_TAIL:int = 53;
		static public const IRON_MAN_TAIL:int = 54;
		static public const LEGO_SMALL:int = 55;
		static public const LEPRECHAUN_TAIL:int = 56;
		static public const MAY_RIBBON:int = 57;
		static public const NAPOLEON_TAIL:int = 58;
		static public const NEW_YEAR_TAIL:int = 59;
		static public const NINJA_TAIL:int = 60;
		static public const OLYMPUS_TAIL:int = 61;
		static public const PENDANT_HIPPIE:int = 62;
		static public const PERSIAN_TAIL:int = 63;
		static public const PHARAON_MAN_TAIL:int = 64;
		static public const PHARAON_WOMAN_TAIL:int = 65;
		static public const PIRATE_TAIL:int = 66;
		static public const POLICE_TAIL:int = 67;
		static public const PUPIL_TAIL:int = 68;
		static public const RAMBO_GRENADE:int = 69;
		static public const RIO_MAN_TAIL:int = 70;
		static public const SAILOR_MOON_TAIL:int = 71;
		static public const SAMURAI_TAIL:int = 72;
		static public const SNOW_MAIDEN_TAIL:int = 73;
		static public const SPIDER_HALLOWEEN_TAIL:int = 74;
		static public const SPIDER_TAIL:int = 75;
		static public const SUPERMAN_TAIL:int = 76;
		static public const SWEET_TEETH_TAIL:int = 77;
		static public const TIN:int = 78;
		static public const VAMPIRE_TAIL:int = 79;
		static public const VENDIGO_TAIL:int = 80;
		static public const VIKING_TAIL:int = 81;
		static public const WIZARD_TAIL:int = 82;
		static public const WOLF_TAIL:int = 83;
		static public const XMAS_GIRL_TAIL:int = 84;
		static public const CHAMPION_NECK:int = 85;
		static public const DEER_NECK:int = 86;
		static public const EASTER_STAR:int = 87;
		static public const ICE_SHARD:int = 88;
		static public const MEDAL_GOLD:int = 89;
		static public const OLYMPIC_MEDAL:int = 90;
		static public const PUPIL_NECK:int = 91;
		static public const RIO_GIRL_NECK:int = 92;
		static public const RIO_MAN_NECK:int = 93;
		static public const SKULL_NECK:int = 94;
		static public const ALCHEMIST_TAIL:int = 95;
		static public const VADER_COAT:int = 96;

		static public const CRYSTAL_MAIDEN_HANDS:int = 97;
		static public const CRYSTAL_MAIDEN_CLOAK:int = 98;
		static public const SANTA_ELF_TAIL:int = 99;

		static public const LICH_KING_CLOAK:int = 100;
		static public const LICH_KING_NECK:int = 101;
		static public const LICH_KING_HANDS:int = 102;

		static public const DOVAHKIIN_HANDS:int = 103;

		static public const OLYMPIC_TORCH:int = 104;
		static public const NEW_YEAR_ACCESSORY:int = 105;

		static public const RAFAEL_HANDS:int = 106;
		static public const MC_TWIST_TAIL:int = 107;

		static public const AMUR_TAIL:int = 108;
		static public const AMUR_HANDS:int = 109;
		static public const AMUR_MAN_CLOAK:int = 110;
		static public const AMUR_WOMAN_CLOAK:int = 111;
		static public const AMUR_GOLDEN_CLOAK:int = 112;
		static public const AMUR_HAIRBAND:int = 113;

		static public const DEADPOOL_CLOAK:int = 114;
		static public const DEADPOOL_HANDS:int = 115;

		static public const RAPUNZEL_HANDS:int = 116;
		static public const RAPUNZEL_HAIRBAND:int = 117;
		static public const RAPUNZEL_TAIL:int = 118;

		static public const DRUID_HANDS:int = 119;
		static public const DRUID_CLOAK:int = 120;
		static public const DRUID_TAIL:int = 121;

		static public const BEAR_HANDS:int = 122;
		static public const BEAR_NECK:int = 123;
		static public const BEAR_CLOAK:int = 124;

		static public const SPRING_HAIRBAND:int = 125;
		static public const SPRING_MAN_GLASSES:int = 126;
		static public const SPRING_WOMAN_GLASSES:int = 127;

		static public const ROCK_WINGS:int = 128;
		static public const ROCK_GLASSES:int = 129;
		static public const ROCK_GUITAR:int = 130;
		static public const ROCK_TAIL:int = 131;
		static public const ROCK_HAIRBAND:int = 132;

		static public const FARMER_HANDS:int = 133;
		static public const FARMER_TAIL:int = 134;
		static public const FARMER_HAIR:int = 135;

		static public const HARLOCK_CLOAK:int = 136;
		static public const HARLOCK_HANDS:int = 137;
		static public const HARLOCK_TAIL:int = 138;

		static public const MINION_GLASSES:int = 139;
		static public const MINION_HANDS:int = 140;
		static public const MINION_TAIL:int = 141;

		static public const FAIRY_CAT_NECK:int = 142;
		static public const FAIRY_CAT_TAIL:int = 143;
		static public const FAIRY_CAT_HAIRBAND:int = 144;

		static public const ELECTRO_CLOAK:int = 145;
		static public const ELECTRO_GLASSES:int = 146;
		static public const ELECTRO_TAIL:int = 147;
		static public const ELECTRO_HAIRBAND:int = 148;

		static public const SOLDIER_HAIRBAND:int = 149;

		static public const ORC_NECK:int = 150;
		static public const ORC_HANDS:int = 151;
		static public const ORC_TAIL:int = 152;

		static public const CHAPLIN_HAIRBAND:int = 153;
		static public const CHAPLIN_HANDS:int = 154;

		static public const SUMMER_HANDS:int = 155;
		static public const SUMMER_TAIL:int = 156;
		static public const SUMMER_NECK:int = 157;
		static public const SUMMER_HAIRBAND:int = 158;

		static public const FRUIT_GLASSES:int = 159;
		static public const FRUIT_HANDS:int = 160;
		static public const FRUIT_NECK:int = 161;
		static public const FRUIT_TAIL:int = 162;
		static public const FRUIT_HAIRBAND:int = 163;

		static public const AQUA_CLOAK:int = 164;
		static public const AQUA_GLASSES:int = 165;
		static public const AQUA_HANDS:int = 166;
		static public const AQUA_TAIL:int = 167;

		static public const SCHOOL_BACK:int = 168;
		static public const SCHOOL_GLASSES:int = 169;
		static public const SCHOOL_HANDS:int = 170;
		static public const SCHOOL_TAIL:int = 171;

		static private var package_in_outfit:Array = [];
		static public var perk_in_package:Array = [];

		static public var squirrel_outfits:Array = [];
		static public var shaman_outfits:Array = [];

		static public var shaman_packages:Object = {};
		static public var scrat_packages:Object = {};
		static public var scratty_packages:Object = {};

		static private var death_skins:Array = [];

		static public var skin_bones:Object = {};
		static public var accessories_bones:Object = {};

		static public var base_skins:Object = {};

		static public function get newestPackages():Array
		{
			return [packageToOutfit(ORC), packageToOutfit(CHAPLIN)];
		}

		static public function init():void
		{
			if (inited)
				return;
			inited = true;

			for (var i:int = 0; i < GameConfig.outfitCount; i++)
			{
				var outfitPackages:Array = GameConfig.getOutfitPackages(i);

				base_skins[outfitPackages[0]] = true;
				if (GameConfig.getOutfitRentCoinsPrice(i) != 0)
					switch (GameConfig.getOutfitCharacter(i))
					{
						case CHARACTER_SQUIRREL:
							squirrel_outfits.push(i);
							break;
						case CHARACTER_SHAMAN:
							shaman_outfits.push(i);
							break;
					}

				for (var j:int = 0; j < outfitPackages.length; j++)
				{
					package_in_outfit[outfitPackages[j]] = i;
					if (GameConfig.getOutfitCharacter(i) == CHARACTER_SHAMAN)
						shaman_packages[outfitPackages[j]] = true;
					if (outfitPackages[0] == SCRAT)
						scrat_packages[outfitPackages[j]] = true;
					if (outfitPackages[0] == SCRATTY)
						scratty_packages[outfitPackages[j]] = true;

					var perksArray:Array = GameConfig.getPackageSkills(outfitPackages[j]);
					for (var perkI:int = 0; perkI < perksArray.length; perkI++)
						perk_in_package[perksArray[perkI]] = outfitPackages[j];
				}
			}

			shaman_packages[SHAMAN_BLUE] = true;
			shaman_packages[SHAMAN_RED] = true;
			shaman_packages[SHAMAN_BLACK] = true;

			death_skins.push(BANSHEE, DEATH, SWEET_DEATH, AID);

			skin_bones[UNDEAD] = ["Undead"];
			skin_bones[SNOWBALL] = ["Snowball"];
			skin_bones[SLOW_FALL] = ["ClothesSlowFal"];
			skin_bones[GRAVY] = ["ClothesGravy"];
			skin_bones[PERSIAN_WOMAN_ROCK] = ["PersianWomanRock"];
			skin_bones[PERSIAN_MAN_ROCK] = ["PersianManRock"];
			skin_bones[CONTUSED_SQUIRREL]= ["Contused"];
			skin_bones[TEAM_RED] = ["RedTeamHat"];
			skin_bones[TEAM_BLUE] = ["BlueTeamHat"];
			skin_bones[SHAMAN_BLACK] = ["BlackShaman"];
			skin_bones[SHAMAN_RED] = ["RedShaman"];
			skin_bones[SHAMAN_BLUE] = ["BlueShaman"];

			skin_bones[CATWOMAN] = ['CatWomenHead','CatWomenShirt','CatWomenPants'];
			skin_bones[IRONMAN] = ['IronManHead','IronManShirt','IronManPants'];
			skin_bones[VIKING] = ['VikingHead','VikingBody'];
			skin_bones[SKELETON] = ['SkeletonHead','SkeletonBody'];
			skin_bones[NINJA] = ['NinjaHead','NinjaShirt','NinjaPants'];
			skin_bones[SAMURAI] = ['SamuraiHead','SamuraiShirt','SamuraiPants'];
			skin_bones[RABBIT] = ['CuteRabbitHat','CuteRabbitJumpers'];
			skin_bones[COP_MAN] = ['PoliceManHead','PoliceShirt','PolicePants'];
			skin_bones[MOD] = ['HatMod','ShirtMod','PantsModBlack','CoatMod'];
			skin_bones[LOGAN] = ['LoganWig','LoganJeans','LoganJacket'];
			skin_bones[LEGION_RED] = ['LegionSkirtRed','LegionHelmetRed','LegionArmor'];
			skin_bones[SPIDER] = ['Spiderman'];
			skin_bones[VADER] = ['DartVader','VaderArmorHigh','VaderArmorLow'];
			skin_bones[TOR] = ['TorHelmet','TorArmor','TorPants', 'TorArmorCloak'];
			skin_bones[FOOTPAD] = ['Gopnik','AdidasShort','AdidasShirt'];
			skin_bones[NAPOLEON] = ['NapoleonJacket','NapoleonPants','NapoleonHat'];
			skin_bones[ELF] = ['ElfHat','ElfShirt','ElfPants'];
			skin_bones[LOKI] = ['LokiHelmet','LokiCoat','LokiPants'];
			skin_bones[PARTY] = ['WhiteModHat','WhiteModShirt','WhiteModPants'];
			skin_bones[WIZARD_MAN] = ['WizardManHat','WizardCloak'];
			skin_bones[HIPSTER_WOMAN] = ['HipsterWomanHead','HipsterWomanTshirt','HipsterWomanPants','HipsterWomanTail'];
			skin_bones[SUPERMAN_MAN] = ['SupermanPack'];
			skin_bones[PIRATE] = ['PirateHat','PirateHead','PirateJacket','PiratePants'];
			skin_bones[RAMBO] = ['RemboHair','RemboAmmo','RemboPants'];
			skin_bones[JUGGLER_MAN] = ['IllusionistSuite','IllusionistManHat'];
			skin_bones[SPARTAN_MAN] = ['SpartanMan'];
			skin_bones[HATTER] = ['HatterJacket','HatterPants','HatterHat','HatterTail'];
			skin_bones[LEPRECHAUN] = ['LeprechaunJacket','LeprechaunPants','LeprechaunHat'];
			skin_bones[VAMPIRE] = ['VampireHead','VampireJacket','VampirePants'];
			skin_bones[PERSIA_MAN] = ['PersianPants','PersianManHair','PersianManTop'];
			skin_bones[PUPIL] = ['PupilShirt','PupilPants'];
			skin_bones[BATMAN] = ['Batman'];
			skin_bones[CATWOMAN_BATMAN] = ['Catwoman'];
			skin_bones[WOLF] = ['WolfHead','WolfTop','WolfPants'];
			skin_bones[PARROT_MAN] = ['RioManBody','RioManPants'];
			skin_bones[CHAMPION] = ['ChampionHat','ChampionShirt','ChampionPants'];
			skin_bones[HATSUNE] = ['MikuHair','MikuTop','MikuSkirt','MikuTail'];
			skin_bones[LEN] = ['LenHair','LenTop','LenPants','LenTail'];
			skin_bones[CHRONOS_MAN] = ['ChronosHead','ChronosTop','ChronosBottom'];
			skin_bones[CTHULHU_MAN] = ['CthulhuManHead','CthulhuBody'];
			skin_bones[SAILORMOON] = ['SailorMoonHair','SailorMoonDress'];
			skin_bones[TUXEDOMASK] = ['TuxedoMaskHat','TuxedoMaskBody','TuxedoMaskPants','TuxedoMaskTail'];
			skin_bones[SONIC] = ['SonicHead','SonicBody'];
			skin_bones[AMYROSE] = ['AmyRoseHead','AmyRoseBody'];
			skin_bones[BANSHEE] = ['Banshee'];
			skin_bones[BUMBLEBEE] = ['BumblebeeHead','BumblebeeShirt','BumblebeePants'];
			skin_bones[ARCEE] = ['ArceeHead','ArceeShirt','ArceePants'];
			skin_bones[PHARAON_MAN] = ['PharaonManHead','PharaonManShirt','PharaonManPants'];
			skin_bones[PHARAON_WOMAN] = ['PharaonWomanHead','PharaonWomanShirt','PharaonWomanPants'];
			skin_bones[STORM] = ['StormBody','StormPants','StormHead'];
			skin_bones[GREEN_SHAMAN_MAN] = ['ShamanGreen'];
			skin_bones[BLUE_SHAMAN_MAN] = ['ShamanBlue'];
			skin_bones[PURPLE_SHAMAN_MAN] = ['ShamanViolet'];
			skin_bones[HIPPIE_MAN] = ['HatHippies','HippieTShirt','HippieTrousers'];
			skin_bones[CAPITAN_AMERICA] = ['CaptainAmericaMask','CaptainAmericaPants','CaptainAmericaArmor'];
			skin_bones[JOKER] = ['JokerHead','JokerTop','JokerBottom'];
			skin_bones[HARLEY_QUINN] = ['HarliHead','HarliTop','HarliBottom'];
			skin_bones[WENDIGO] = ['VendigoHead','VendigoBody','VendigoPants','VendigoCloak'];
			skin_bones[SHAMAN_DARK_RED] = ['ShamanDarkRed'];
			skin_bones[SHAMAN_DARK_PINK] = ['ShamanPink'];
			skin_bones[AIRBENDER_GREEN] = ['GreenAirbender'];
			skin_bones[CHESHIRE_CAT] = ['Cheshire'];
			skin_bones[DEER] = ['DeerHead','DeerBody','DeerTail'];
			skin_bones[FROST_2014] = ['NewYearHead','NewYearBody'];
			skin_bones[FAIRY] = ['FairyHead','FairyBody'];
			skin_bones[SNOW_MAIDEN_2014] = ['SnowMaidenHead','SnowMaidenBody'];
			skin_bones[AIRBENDER_BLUE] = ['BlueAirbender'];
			skin_bones[AIRBENDER_RED] = ['RedAirbender'];
			skin_bones[AIRBENDER_VIOLET] = ['VioletAirbender'];
			skin_bones[HONEY_LEMON_WOMAN] = ['HoneyLemon'];
			skin_bones[TOOTHLESS] = ['Toothless'];
			skin_bones[PIKACHU] = ['Pikachu'];
			skin_bones[SCRAT] = [];
			skin_bones[SCRATTY] = [];
			skin_bones[SCRAT_METAL] = ['IronScrat'];
			skin_bones[SCRATTY_METAL] = ['IronScratty'];
			skin_bones[SCRAT_DRAGON] = ['ScratDragon'];
			skin_bones[SCRATTY_DRAGON] = ['ScrattyDragon'];
			skin_bones[SCRAT_JUGGLER] = ['ScratMagician'];
			skin_bones[SCRATTY_JUGGLER] = ['ScrattyMagician'];
			skin_bones[SCRAT_VAMPYRE] = ['ScratVampire'];
			skin_bones[SCRATTY_VAMPYRE] = ['ScrattyVampire'];
			skin_bones[SCRAT_HATTER] = ['ScratHatter'];
			skin_bones[SCRATTY_HATTER] = ['ScrattyHatter'];
			skin_bones[SCRAT_SKELETON] = ['ScratSkeleton'];
			skin_bones[SCRATTY_SKELETON] = ['ScrattySkeleton'];
			skin_bones[SCRAT_PERSIA] = ['ScratPersian'];
			skin_bones[SCRATTY_PERSIA] = ['ScrattyPersian'];
			skin_bones[SCRAT_ROBOCOP] = ['ScratRobocop'];
			skin_bones[SCRATTY_FAIRY] = ['ScrattyFairy'];
			skin_bones[ZOMBIE] = ['Zombie'];
			skin_bones[DEATH] = ['Death'];
			skin_bones[SWEET_DEATH] = ['SweetDeath'];
			skin_bones[IRBIS] = ['SnowLeopard'];
			skin_bones[ASSASSIN] = ['Assassin'];
			skin_bones[FLOWER_SHAMAN] = ['FlowerShaman'];
			skin_bones[SWEET_TOOTH] = ['SweetTeeth'];
			skin_bones[ARMADILLO] = ['Armadillo'];
			skin_bones[FLASH] = ['Flash'];
			skin_bones[ALCHEMIST] = ['AlchemistCap','AlchemistTop','AlchemistPants'];

			skin_bones[ROBOCOP] = ['Robocop'];
			skin_bones[ALTRONE] = ['Altrone'];
			skin_bones[BLACK_BEARD] = ['Blackbeard'];
			skin_bones[AMELIA] = ['Ameli'];
			skin_bones[BLACK_CAT] = ['BlackCat'];
			skin_bones[ZOOM] = ['Zoom'];
			skin_bones[THRONE] = ['Throne'];
			skin_bones[FAIRY_CAT] = ['FairyCat'];
			skin_bones[DORMAMMU] = ['Dormammu'];
			skin_bones[ANUBIS] = ['Anubis'];
			skin_bones[TUTENSHTAIN] = ['Tutenshtain'];
			skin_bones[AID] = ['Aid', 'AidHead'];
			skin_bones[REAPER] = ['Reaper'];
			skin_bones[FAN] = ['Fanat'];
			skin_bones[CRYSTAL_MAIDEN] = ['CrystalMaiden'];
			skin_bones[SANTA_ELF] = ['SantaElf'];
			skin_bones[DOVAHKIIN] = ['Dovahkiin'];
			skin_bones[DRAGON_ICE] = ['DragonIce'];
			skin_bones[LICH_KING] = ['LichKing'];
			skin_bones[RAFAEL] = ['Rafael'];
			skin_bones[MC_TWIST] = ['McTwist'];

			skin_bones[AMUR_MAN] = ['AmurMan'];
			skin_bones[AMUR_WOMAN] = ['AmurWoman'];
			skin_bones[AMUR_GOLDEN_MAN] = ['AmurGolden', 'AmurGoldenMan'];
			skin_bones[AMUR_GOLDEN_WOMAN] = ['AmurGolden', 'AmurGoldenWoman'];

			skin_bones[DEADPOOL] = ['Deadpool'];
			skin_bones[BUBBLEGUM] = ['Bubblegum'];

			skin_bones[SHAMAN_SPRING] = ['ShamanSpring'];
			skin_bones[RAPUNZEL] = ['Rapunzel'];
			skin_bones[DRUID] = ['Druid'];
			skin_bones[BEAR] = ['Bear'];

			skin_bones[EVA] = ['Eva'];
			skin_bones[STITCH] = ['Stitch'];
			skin_bones[FARMER] = ['Farmer'];
			skin_bones[HARLOCK] = ['Harlock'];
			skin_bones[MINION] = ['Minion'];
			skin_bones[CHAPLIN] = ['Chaplin'];
			skin_bones[ORC] = ['Orc'];

			accessories_bones[CAT_WOMEN_TAIL] = ['CatWomenTail'];
			accessories_bones[CAT_WOMEN_WHIP] = ['CatWomenWhip'];
			accessories_bones[IRON_MAN_TAIL] = ['IronManTail'];
			accessories_bones[VIKING_HANDS] = ['VikingHands'];
			accessories_bones[VIKING_TAIL] = ['VikingTail'];
			accessories_bones[NINJA_SWORD] = ['NinjaSword'];
			accessories_bones[NINJA_TAIL] = ['NinjaTail'];
			accessories_bones[SAMURAI_TAIL] = ['SamuraiTail'];
			accessories_bones[CUTE_RABBIT_CARROT] = ['CuteRabbitCarrot'];
			accessories_bones[POLICE_TAIL] = ['PoliceTail'];
			accessories_bones[LEGION_KNIFE] = ['LegionKnife'];
			accessories_bones[SPIDER_TAIL] = ['SpiderTail'];
			accessories_bones[VADER_COAT] = ['VaderCoat'];
			accessories_bones[VADER_SWORD] = ['VaderSword'];
			accessories_bones[TOR_HAMMER] = ['TorHammer'];
			accessories_bones[NAPOLEON_SWORD] = ['NapoleonSword'];
			accessories_bones[NAPOLEON_TAIL] = ['NapoleonTail'];
			accessories_bones[ELF_SWORD] = ['ElfSword'];
			accessories_bones[LOKI_HAND] = ['LokiHand'];
			accessories_bones[STICK] = ['Stick'];
			accessories_bones[DISC] = ['Disc'];
			accessories_bones[WAND] = ['Wand'];
			accessories_bones[WIZARD_TAIL] = ['WizardTail'];
			accessories_bones[HIPSTER_WOMAN_GLASSES] = ['HipsterWomanGlasses'];
			accessories_bones[HIPSTER_MAN_GLASSES] = ['HipsterManGlasses'];
			accessories_bones[PIRATE_TAIL] = ['PirateTail'];
			accessories_bones[RAMBO_GUN] = ['RemboGun'];
			accessories_bones[RAMBO_GRENADE] = ['RemboGrenade'];
			accessories_bones[ILLUSIONIST_MAN_TAIL] = ['IllusionistManTail'];
			accessories_bones[ILLUSIONIST_WOMAN_TAIL] = ['IllusionistWomanTail'];
			accessories_bones[LEPRECHAUN_HAND] = ['LeprechaunHand'];
			accessories_bones[LEPRECHAUN_TAIL] = ['LeprechaunTail'];
			accessories_bones[VAMPIRE_CLOAK] = ['VampireCloak'];
			accessories_bones[VAMPIRE_TAIL] = ['VampireBat'];
			accessories_bones[PERSIAN_TAIL] = ['PersianTail'];
			accessories_bones[PERSIAN_SWORD] = ['PersianSword'];
			accessories_bones[BATMAN_TAIL] = ['BatmanTail'];
			accessories_bones[BATMAN_CLOAK] = ['BatmanCloak'];
			accessories_bones[CAT_HANDS] = ['CatHands'];
			accessories_bones[WOLF_TAIL] = ['WolfTail'];
			accessories_bones[WOLF_STAFF] = ['WolfStaff'];
			accessories_bones[RIO_MAN_NECK] = ['RioManNeck'];
			accessories_bones[RIO_MAN_TAIL] = ['RioManTail'];
			accessories_bones[CHAMPION_NECK] = ['ChampionNeck'];
			accessories_bones[CHAMPION_TAIL] = ['ChampionTail'];
			accessories_bones[CHRONOS_TAIL] = ['ChronosTail'];
			accessories_bones[SAILOR_MOON_WINGS] = ['SailorMoonWings'];
			accessories_bones[SAILOR_MOON_WAND] = ['SailorMoonWand'];
			accessories_bones[SAILOR_MOON_TAIL] = ['SailorMoonTail'];
			accessories_bones[TUXEDO_MASK_HAND] = ['TuxedoMaskHand'];
			accessories_bones[CUBE] = ['Cube'];
			accessories_bones[PHARAON_MAN_TAIL] = ['PharaonManTail'];
			accessories_bones[PHARAON_MAN_HANDS] = ['PharaonManHands'];
			accessories_bones[PHARAON_WOMAN_TAIL] = ['PharaonWomanTail'];
			accessories_bones[PHARAON_WOMAN_HANDS] = ['PharaonWomanHands'];
			accessories_bones[STORM_GLASSES] = ['StormGlasses'];
			accessories_bones[THUNDER_GLASSES] = ['ThunderGlasses'];
			accessories_bones[CAPTAIN_AMERICA_SHIELD] = ['CaptainAmericaShield'];
			accessories_bones[VENDIGO_TAIL] = ['VendigoTail'];
			accessories_bones[DEER_NECK] = ['DeerNeck'];
			accessories_bones[NEW_YEAR_TAIL] = ['NewYearTail'];
			accessories_bones[NEW_YEAR_STUFF] = ['NewYearStuff'];
			accessories_bones[FAIRY_TAIL] = ['FairyTail'];
			accessories_bones[FAIRY_WINGS] = ['FairyWings'];
			accessories_bones[FAIRY_STUFF] = ['FairyStuff'];
			accessories_bones[SNOW_MAIDEN_TAIL] = ['SnowMaidenTail'];
			accessories_bones[ALCHEMIST_TAIL] = ['AlchemistTail'];
			accessories_bones[ALCHEMIST_HAND] = ['AlchemistHand'];
			accessories_bones[TIN] = ['Tin'];
			accessories_bones[PUPIL_NECK] = ['PupilNeck'];
			accessories_bones[PUPIL_TAIL] = ['PupilTail'];
			accessories_bones[PUPIL_GLASS] = ['PupilGlass'];
			accessories_bones[OLYMPIC_MEDAL] = ['OlympicMedal'];
			accessories_bones[LEGO_SMALL] = ['LegoSmall'];
			accessories_bones[BIG_LEGO] = ['BigLego'];
			accessories_bones[ICE_SHARD] = ['IceShard'];
			accessories_bones[OLYMPUS_TORCH] = ['OlympusTorch'];
			accessories_bones[EASTER_BASKET] = ['EasterBasket'];
			accessories_bones[MEDAL_GOLD] = ['MedalGold'];
			accessories_bones[EASTER_STAR] = ['EasterStar'];
			accessories_bones[MAY_RIBBON] = ['MayRibbon'];
			accessories_bones[HARD_SWEET] = ['HardSweet'];
			accessories_bones[MAD_GLASSES] = ['MadGlasses'];
			accessories_bones[PUMPKIN_HAND] = ['PumpkinHand'];
			accessories_bones[SHADOW_CLOAK] = ['ShadowCloak'];
			accessories_bones[SKULL_NECK] = ['SkullNeck'];
			accessories_bones[SPIDER_HALLOWEEN_TAIL] = ['SpiderHalloweenTail'];

			accessories_bones[OLYMPUS_TAIL] = ['OlympusTail'];
			accessories_bones[PENDANT_HIPPIE] = ['Pendant'];
			accessories_bones[XMAS_MAN_STAFF] = ['NewYearStuff'];
			accessories_bones[XMAS_GIRL_TAIL] = ['XmasGirlTail'];
			accessories_bones[RIO_GIRL_NECK] = ['RioGirlNeck'];

			accessories_bones[SPARTAN_SWORD] = ["SpartanManWeapon"];
			accessories_bones[ASSASSIN_DAGGER] = ["AssassinDagger"];
			accessories_bones[ASSASSIN_TAIL] = ["AssassinTail"];
			accessories_bones[SWEET_TEETH_TAIL] = ["SweetTeethTail"];
			accessories_bones[SUPERMAN_TAIL] = ["SupermanPackTail"];

			accessories_bones[CRYSTAL_MAIDEN_HANDS] = ["CrystalMaidenStaff"];
			accessories_bones[CRYSTAL_MAIDEN_CLOAK] = ["CrystalMaidenCloak"];

			accessories_bones[SANTA_ELF_TAIL] = ["SantaElfTail"];

			accessories_bones[LICH_KING_CLOAK] = ["LichKingCloak"];
			accessories_bones[LICH_KING_NECK] = ["LichKingNeck"];
			accessories_bones[LICH_KING_HANDS] = ["Frostmourne"];

			accessories_bones[DOVAHKIIN_HANDS] = ['DovahkiinMace'];

			accessories_bones[OLYMPIC_TORCH] = ['OlympusTorch'];
			accessories_bones[NEW_YEAR_ACCESSORY] = ['Amulet4'];

			accessories_bones[RAFAEL_HANDS] = ['RafaelHands'];
			accessories_bones[MC_TWIST_TAIL] = ['McTwistTail'];

			accessories_bones[AMUR_TAIL] = ['AmurTail'];
			accessories_bones[AMUR_HANDS] = ['AmurHands'];
			accessories_bones[AMUR_MAN_CLOAK] = ['AmurManCloak'];
			accessories_bones[AMUR_WOMAN_CLOAK] = ['AmurWomanCloak'];
			accessories_bones[AMUR_GOLDEN_CLOAK] = ['AmurGoldenCloak'];
			accessories_bones[AMUR_HAIRBAND] = ['AmurHairband'];

			accessories_bones[DEADPOOL_CLOAK] = ['DeadpoolCloak'];
			accessories_bones[DEADPOOL_HANDS] = ['DeadpoolHands'];

			accessories_bones[RAPUNZEL_HANDS] = ['RapunzelHands'];
			accessories_bones[RAPUNZEL_HAIRBAND] = ['RapunzelHairband'];
			accessories_bones[RAPUNZEL_TAIL] = ['RapunzelTail'];

			accessories_bones[DRUID_HANDS] = ['DruidHands'];
			accessories_bones[DRUID_CLOAK] = ['DruidCloak'];
			accessories_bones[DRUID_TAIL] = ['DruidTail'];

			accessories_bones[BEAR_HANDS] = ['BearHands'];
			accessories_bones[BEAR_NECK] = ['BearNeck'];
			accessories_bones[BEAR_CLOAK] = ['BearCloak'];

			accessories_bones[SPRING_HAIRBAND] = ['SpringHairband'];
			accessories_bones[SPRING_MAN_GLASSES] = ['SpringManGlasses'];
			accessories_bones[SPRING_WOMAN_GLASSES] = ['SpringWomanGlasses'];

			accessories_bones[ROCK_WINGS] = ['RockWings'];
			accessories_bones[ROCK_GLASSES] = ['RockGlasses'];
			accessories_bones[ROCK_GUITAR] = ['RockGuitar'];
			accessories_bones[ROCK_TAIL] = ['RockTail'];
			accessories_bones[ROCK_HAIRBAND] = ['RockHairband'];

			accessories_bones[FARMER_HANDS] = ['FarmerHands'];
			accessories_bones[FARMER_TAIL] = ['FarmerTail'];
			accessories_bones[FARMER_HAIR] = ['FarmerHair'];
			accessories_bones[HARLOCK_CLOAK] = ['HarlockCloak', 'HarlockCloakTop'];
			accessories_bones[HARLOCK_HANDS] = ['HarlockHands'];
			accessories_bones[HARLOCK_TAIL] = ['HarlockTail'];
			accessories_bones[MINION_GLASSES] = ['MinionGlasses'];
			accessories_bones[MINION_HANDS] = ['MinionHands'];
			accessories_bones[MINION_TAIL] = ['MinionTail'];
			accessories_bones[FAIRY_CAT_NECK] = ['FairyCatNeck'];
			accessories_bones[FAIRY_CAT_TAIL] = ['FairyCatTail'];
			accessories_bones[FAIRY_CAT_HAIRBAND] = ['FairyCatHairband'];

			accessories_bones[ELECTRO_CLOAK] = ['ElectroCloak', 'ElectroCloakTop'];
			accessories_bones[ELECTRO_GLASSES] = ['ElectroGlasses'];
			accessories_bones[ELECTRO_TAIL] = ['ElectroTail'];
			accessories_bones[ELECTRO_HAIRBAND] = ['ElectroHairband'];

			accessories_bones[SOLDIER_HAIRBAND] = ['SoldierHairband'];

			accessories_bones[ORC_TAIL] = ['OrcTail'];
			accessories_bones[ORC_HANDS] = ['OrcHands'];
			accessories_bones[ORC_NECK] = ['OrcNeck'];

			accessories_bones[CHAPLIN_HANDS] = ['ChaplinHands'];
			accessories_bones[CHAPLIN_HAIRBAND] = ['ChaplinHairband'];

			accessories_bones[SUMMER_HAIRBAND] = ['SummerHairband'];
			accessories_bones[SUMMER_HANDS] = ['SummerHands'];
			accessories_bones[SUMMER_NECK] = ['SummerNeck'];
			accessories_bones[SUMMER_TAIL] = ['SummerTail'];

			accessories_bones[FRUIT_GLASSES] = ['FruitGlasses'];
			accessories_bones[FRUIT_HANDS] = ['FruitHands'];
			accessories_bones[FRUIT_NECK] = ['FruitNeck'];
			accessories_bones[FRUIT_TAIL] = ['FruitTail'];
			accessories_bones[FRUIT_HAIRBAND] = ['FruitHairband'];

			accessories_bones[AQUA_CLOAK] = ['AquaCloak'];
			accessories_bones[AQUA_GLASSES] = ['AquaGlasses'];
			accessories_bones[AQUA_HANDS] = ['AquaHands'];
			accessories_bones[AQUA_TAIL] = ['AquaTail'];

			accessories_bones[SCHOOL_BACK] = ['SchoolBack'];
			accessories_bones[SCHOOL_GLASSES] = ['SchoolGlasses'];
			accessories_bones[SCHOOL_HANDS] = ['SchoolHands'];
			accessories_bones[SCHOOL_TAIL] = ['SchoolTail'];
		}

		static public function packageToOutfit(id:int):int
		{
			return package_in_outfit[id];
		}

		static public function perkToPackage(id:int):int
		{
			return perk_in_package[id];
		}

		static public function isShamanSkin(id:int):Boolean
		{
			return id in shaman_packages;
		}

		static public function isScratSkin(id:int):Boolean
		{
			return id in scrat_packages;
		}

		static public function isScrattySkin(id:int):Boolean
		{
			return id in scratty_packages;
		}

		static public function isBaseSkin(id:int):Boolean
		{
			return id in base_skins;
		}

		static public function getBaseSkin(id:int):int
		{
			return GameConfig.getOutfitPackages(packageToOutfit(id))[0];
		}

		static public function getSellingSkin(id:int):int
		{
			CONFIG::client
			{
				var skins:Array = GameConfig.getOutfitPackages(id).filter(function(item:int, index:int, parentArray:Array):Boolean
				{
					if (index || parentArray) {/*unused*/}
					return GameConfig.getPackageCoinsPrice(item) != 0;
				});
				for (var i:int = 0; i < skins.length; i++)
				{
					if (ClothesManager.haveItem(skins[i], ClothesManager.KIND_PACKAGES))
						continue;
					return skins[i];
				}
				return -1;
			}
			return -1;
		}

		static public function isDeathSkin(id:int):Boolean
		{
			return death_skins.indexOf(id) != -1;
		}

		static public function getOwnerById(id:int):int
		{
			if (isScratSkin(id))
				return OWNER_SCRAT;
			if (isScrattySkin(id))
				return OWNER_SCRATTY;
			if (isShamanSkin(id))
				return OWNER_SHAMAN;
			return OWNER_SQUIRREL;
		}

		static public function getScratsByArray(ids:Array):int
		{
			for (var i:int = 0; i < ids.length; i++)
			{
				if (getOwnerById(ids[i]) == OWNER_SCRAT)
					return OWNER_SCRAT;
				if (getOwnerById(ids[i]) == OWNER_SCRATTY)
					return OWNER_SCRATTY;
			}
			return OWNER_SQUIRREL
		}

		static public function getPerksByOutfit(id:int):Array
		{
			var skins:Array = GameConfig.getOutfitPackages(id);
			var answer:Array = [];
			for (var i:int = 0; i < skins.length; i++)
				answer = answer.concat(GameConfig.getPackageSkills(skins[i]));
			return answer;
		}

		static public function getExtraPerksSkinByOutfit(id:int):Array
		{
			var answer:Array = GameConfig.getOutfitPackages(id).concat();
			return answer.filter(function(item:int, index:int, array:Array):Boolean
			{
				return GameConfig.getPackageSkills(item).some(function(item:int, index:int, array:Array):Boolean
				{
					return item == 0;
				});
			});
		}

		static public function filterBuyable(item:int, index:int, parentArray:Array):Boolean
		{
			if (index || parentArray) {/*unused*/}
			return GameConfig.getPackageCoinsPrice(item) != 0;
		}

		static public function filterPerkBuyableOrSelf(item:int, index:int, parentArray:Array):Boolean
		{
			CONFIG::client
			{
				if (index || parentArray)
				{/*unused*/
				}
				if (item == 0)
					return false;
				var packageId:int = OutfitData.perkToPackage(item);
				var level:Boolean = GameConfig.getPackageSkillLevel(packageId, item) <= ClothesManager.getPackagesLevel(packageId);
				var have:Boolean = ClothesManager.haveItem(packageId, ClothesManager.KIND_PACKAGES);
				return (GameConfig.getPackageCoinsPrice(packageId) != 0) || (level && have);
			}
			return false;
		}
	}
}