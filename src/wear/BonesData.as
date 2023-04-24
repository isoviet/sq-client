package wear
{
	public class BonesData
	{
		static public const EARS_BONE:String = "Ears";
		static public const HEAD_BONE:String = "Head";
		static public const CAP_BONE:String = "Cap";
		static public const FOR_CAP_BONE:String = "forCap";
		static public const GLASSES_BONE:String = "Glasses";
		static public const RIGHT_FOOT_BONE:String = "Right_foot";
		static public const LEFT_FOOT_BONE:String = "Left_foot";
		static public const LEFT_HAUNCH_BONE:String = "Left_haunch";
		static public const PANTS_HAUNCH_BONE:String = "Pants_haunch";
		static public const T_SHIRT_BONE:String = "T-shirt";
		static public const STOMACH_BONE:String = "Stomach";
		static public const TAIL_BONE:String = "Tail";
		static public const LEFT_SLEEV_BONE:String = "Left_sleev";

		static public const TAIL_ACCESSORY_01:String = "Tail_accessory_01";
		static public const TAIL_ACCESSORY_02:String = "Tail_accessory_02";
		static public const TAIL_ACCESSORY_03:String = "Tail_accessory_03";

		//TODO сделать прямой номер на массив
		static public const DATA:Object = {
			"Undead": {
				'id': -12,
				'hiddenBones': [TAIL_BONE]
			},
			"Snowball": {'id': -11},
			"ClothesSlowFal": {'id': -10},
			"ClothesGravy": {'id': -9},
			"PersianWomanRock": {'id': -8},
			"PersianManRock": {'id': -7},
			"Contused": {'id': -6},
			"RedTeamHat": {'id': -5},
			"BlueTeamHat": {'id': -4},
			"BlackShaman": {'id': -3},
			"RedShaman": {'id': -2},
			"BlueShaman": {'id': -1},

			"Tin": {'id': 2},
			"HatMod": {'id': 4},
			"ShirtMod": {'id': 5},
			"DartVader": {'id': 10},
			"Gopnik": {'id': 26},
			"AdidasShort": {'id': 27},
			"HatHippies": {'id': 40},
			"HippieTShirt": {'id': 41},
			"HippieTrousers": {'id': 43},
			"Pendant": {'id': 44},
			"PantsModBlack": {'id': 45},
			"CoatMod": {'id': 46},
			"LoganWig": {'id': 47},
			"LoganJeans": {'id': 48},
			"LoganJacket": {'id': 49},
			"LegionSkirtRed": {'id': 54},
			"LegionHelmetRed": {'id': 57},
			"LegionKnife": {'id': 59},
			"LegionArmor": {'id': 60},
			"TorHelmet": {'id': 61},
			"TorHammer": {'id': 62},
			"TorArmor": {'id': 63},
			"TorPants": {'id': 64},
			"TorArmorCloak": {'id': 64},
			"CaptainAmericaShield": {id: 65},
			"CaptainAmericaMask": {id: 66},
			"CaptainAmericaPants": {id: 67},
			"CaptainAmericaArmor": {id: 68},
			"VaderArmorHigh": {'id': 69},
			"VaderArmorLow": {'id': 70},
			"VaderCoat": {'id': 71},
			"VaderSword": {'id': 72},
			"CuteRabbitHat": {'id': 73},
			"CuteRabbitJumpers": {'id': 74},
			"CuteRabbitCarrot": {'id': 75},
			"Spiderman": {'id': 77},
			"SpiderTail": {'id': 80},
			"CatWomenHead": {'id': 81},
			"CatWomenShirt": {'id': 82},
			"CatWomenPants": {'id': 83},
			"CatWomenTail": {'id': 84},
			"CatWomenWhip": {'id': 85},
			"IronManHead": {'id': 87},
			"IronManShirt": {'id': 88},
			"IronManPants": {'id': 89},
			"IronManTail": {'id': 90},
			"Zombie": {'id': 92},
			"PoliceManHead": {'id': 93},
			"PoliceShirt": {'id': 95},
			"PolicePants": {'id': 96},
			"PoliceTail": {'id': 97},
			"NinjaHead": {'id': 98},
			"NinjaSword": {'id': 99},
			"NinjaShirt": {'id': 100},
			"NinjaPants": {'id': 101},
			"NinjaTail": {'id': 102},
			"SkeletonHead": {'id': 103},
			"SkeletonBody": {'id': 104},
			"VikingHead": {'id': 106, 'hiddenBones': [EARS_BONE]},
			"VikingHands": {'id': 107},
			"VikingBody": {'id': 108},
			"VikingTail": {'id': 109},
			"SamuraiHead": {'id': 115},
			"SamuraiShirt": {'id': 116},
			"SamuraiPants": {'id': 117},
			"SamuraiTail": {'id': 118},
			"Death": {
				'id': 134,
				'hiddenBones': [LEFT_FOOT_BONE, RIGHT_FOOT_BONE, LEFT_HAUNCH_BONE, STOMACH_BONE]
			},
			"SweetDeath": {
				'id': 144,
				'hiddenBones': [LEFT_FOOT_BONE, RIGHT_FOOT_BONE, LEFT_HAUNCH_BONE, STOMACH_BONE]
			},
			"AdidasShirt": {'id': 157},
			"NapoleonJacket": {'id': 159},
			"NapoleonPants": {'id': 160},
			"NapoleonHat": {'id': 161},
			"NapoleonSword": {'id': 162},
			"NapoleonTail": {'id': 163},
			"ElfHat": {'id': 165},
			"ElfShirt": {'id': 166},
			"ElfPants": {'id': 167},
			"ElfSword": {'id': 168},
			"LokiHelmet": {
				'id': 170,
				'hiddenBones': [EARS_BONE]
			},
			"LokiHand": {'id': 171},
			"LokiCoat": {'id': 172},
			"LokiPants": {'id': 173},
			"WhiteModHat": {'id': 175},
			"Stick": {'id': 176},
			"WhiteModShirt": {'id': 177},
			"WhiteModPants": {'id': 178},
			"Disc": {'id': 179},
			"LegoSmall": {'id': 196},
			"BigLego": {'id': 197},
			"WizardManHat": {'id': 198},
			"WizardCloak": {'id': 200},
			"Wand": {'id': 201},
			"WizardTail": {'id': 202},
			"HipsterWomanHead": {'id': 210},
			"HipsterWomanTshirt": {'id': 211},
			"HipsterWomanPants": {'id': 212},
			"HipsterWomanTail": {'id': 213},
			"HipsterWomanGlasses": {'id': 214},
			"HipsterManGlasses": {'id': 219},
			"PirateHat": {'id': 220},
			"PirateHead": {'id': 221},
			"PirateJacket": {'id': 222},
			"PiratePants": {'id': 223},
			"PirateTail": {'id': 224},
			"SpartanMan": {'id': 226},
			"SpartanManWeapon": {'id': 226},
			"SupermanPack": {'id': 228},
			"SupermanPackTail": {'id': 228},
			"IronScrat": {'id': 230},
			"IronScratty": {'id': 231},
			"ScratDragon": {'id': 232},
			"ScrattyDragon": {'id': 233},
			"RemboHair": {'id': 234},
			"RemboAmmo": {'id': 235},
			"RemboPants": {'id': 236},
			"RemboGun": {'id': 237},
			"RemboGrenade": {'id': 238},
			"ScratMagician": {'id': 239},
			"ScrattyMagician": {'id': 240},
			"IllusionistSuite": {'id': 241},
			"IllusionistManHat": {'id': 242},
			"IllusionistManTail": {'id': 243},
			"IllusionistWomanTail": {'id': 245},
			"HatterHat": {'id': 246},
			"HatterJacket": {'id': 247},
			"HatterPants": {'id': 248},
			"HatterTail": {'id': 249},
			"LeprechaunJacket": {'id': 250},
			"LeprechaunPants": {'id': 251},
			"LeprechaunHand": {'id': 252},
			"LeprechaunHat": {'id': 253},
			"LeprechaunTail": {'id': 254},
			"VampireHead": {'id': 255},
			"VampireCloak": {'id': 256},
			"VampireJacket": {'id': 257},
			"VampirePants": {'id': 258},
			"VampireBat": {'id': 259},
			"PersianPants": {'id': 260},
			"PersianTail": {'id': 261},
			"PersianSword": {'id': 262},
			"PersianManHair": {'id': 263},
			"PersianManTop": {'id': 265},
			"PupilNeck": {'id': 268},
			"PupilShirt": {'id': 269},
			"PupilTail": {'id': 270},
			"PupilGlass": {'id': 271},
			"PupilPants": {'id': 273},
			"Batman": {'id': 274},
			"BatmanTail": {'id': 275},
			"BatmanCloak": {'id': 276},
			"Catwoman": {
				'id': 279,
				'zOrderBones': {'Pants_haunch': T_SHIRT_BONE}
			},
			"CatHands": {'id': 281},
			"ScratVampire": {'id': 284},
			"ScrattyVampire": {'id': 285},
			"ScratHatter": {'id': 286},
			"ScrattyHatter": {'id': 287},
			"ScratSkeleton": {'id': 288},
			"ScrattySkeleton": {'id': 289},
			"ScratPersian": {'id': 290},
			"ScrattyPersian": {'id': 291},
			"WolfHead": {'id': 292},
			"WolfTop": {'id': 293},
			"WolfPants": {'id': 294},
			"WolfTail": {'id': 295},
			"WolfStaff": {'id': 296},
			"XmasGirlTail": {'id': 302},
			"IceShard": {'id': 303},
			"RioManBody": {'id': 304},
			"RioManNeck": {'id': 305},
			"RioManPants": {'id': 306},
			"RioGirlNeck": {
				'id': 308
			},
			"RioManTail": {'id': 310},
			"OlympusTail": {'id': 315},
			"OlympusTorch": {'id': 316},
			"ChampionHat": {'id': 317},
			"ChampionNeck": {'id': 318},
			"ChampionPants": {'id': 319},
			"ChampionShirt": {'id': 320},
			"ChampionTail": {'id': 321},
			"MedalGold": {'id': 322},
			"MikuHair": {'id': 323},
			"MikuTop": {'id': 324},
			"MikuSkirt": {'id': 325},
			"MikuTail": {'id': 326},
			"LenHair": {'id': 327},
			"LenTop": {'id': 328},
			"LenPants": {'id': 329},
			"LenTail": {'id': 330},
			"ChronosHead": {'id': 331},
			"ChronosTop": {'id': 333},
			"ChronosBottom": {'id': 334},
			"ChronosTail": {'id': 335},
			"CthulhuManHead": {
				'id': 336,
				'hiddenBones': [HEAD_BONE]
			},
			"CthulhuBody": {'id': 338},
			"EasterBasket": {'id': 339},
			"EasterStar": {'id': 340},
			"ScratRobocop": {'id': 341},
			"ScrattyFairy": {'id': 342},
			"SailorMoonHair": {'id': 343},
			"SailorMoonDress": {'id': 344},
			"SailorMoonWings": {'id': 345},
			"SailorMoonWand": {'id': 346},
			"SailorMoonTail": {'id': 347},
			"TuxedoMaskHat": {'id': 348},
			"TuxedoMaskBody": {'id': 349},
			"TuxedoMaskPants": {'id': 350},
			"TuxedoMaskHand": {'id': 351},
			"TuxedoMaskTail": {'id': 352},
			"MayRibbon": {'id': 353},
			"SonicHead": {'id': 354},
			"SonicBody": {'id': 355},
			"AmyRoseHead": {'id': 356},
			"AmyRoseBody": {'id': 357},
			"HardSweet": {'id': 359},
			"Banshee": {
				'id': 360,
				'hiddenBones': [LEFT_FOOT_BONE, RIGHT_FOOT_BONE, LEFT_HAUNCH_BONE]
			},
			"BumblebeeHead": {
				'id': 361,
				'hiddenBones': [HEAD_BONE]
			},
			"BumblebeePants": {'id': 362},
			"BumblebeeShirt": {'id': 363},
			"ArceeHead": {
				'id': 364,
				'hiddenBones': [HEAD_BONE]
			},
			"ArceePants": {'id': 365},
			"ArceeShirt": {'id': 366},
			"Cube": {'id': 367},
			"PharaonManHead": {'id': 368},
			"PharaonManShirt": {'id': 369},
			"PharaonManPants": {'id': 370},
			"PharaonManTail": {'id': 371},
			"PharaonManHands": {'id': 372},
			"PharaonWomanHead": {'id': 373},
			"PharaonWomanShirt": {'id': 374},
			"PharaonWomanPants": {'id': 375},
			"PharaonWomanTail": {'id': 376},
			"PharaonWomanHands": {'id': 377},
			"StormBody": {'id': 378},
			"StormPants": {'id': 379},
			"StormGlasses": {'id': 380},
			"StormHead": {'id': 381},
			"ThunderGlasses": {'id': 384},
			"ShamanGreen": {'id': 386},
			"ShamanBlue": {'id': 388},
			"ShamanViolet": {'id': 390},
			"JokerHead": {
				'id': 392,
				'hiddenBones': [HEAD_BONE]
			},
			"JokerTop": {'id': 393},
			"JokerBottom": {'id': 394},
			"HarliHead": {
				'id': 395,
				'hiddenBones': [HEAD_BONE]
			},
			"HarliTop": {'id': 396},
			"HarliBottom": {'id': 397},
			"MadGlasses": {'id': 398},
			"PumpkinHand": {'id': 399},
			"ShadowCloak": {'id': 400},
			"SkullNeck": {'id': 401},
			"SpiderHalloweenTail": {'id': 402},
			"VendigoHead": {'id': 404},
			"VendigoBody": {'id': 405},
			"VendigoPants": {'id': 406},
			"VendigoCloak": {'id': 407},
			"VendigoTail": {'id': 408},
			"ShamanDarkRed": {'id': 411},
			"ShamanPink": {'id': 412},
			"GreenAirbender": {'id': 413},
			"OlympicMedal": {'id': 414},
			"Cheshire": {
				'id': 416,
				'hiddenBones': [HEAD_BONE, TAIL_BONE]
			},
			"DeerHead": {'id': 418},
			"DeerBody": {'id': 419},
			"DeerTail": {'id': 420},
			"DeerNeck": {'id': 421},
			"NewYearHead": {'id': 422},
			"NewYearBody": {'id': 423},
			"NewYearTail": {'id': 424},
			"NewYearStuff": {'id': 425},
			"FairyHead": {'id': 426},
			"FairyBody": {'id': 427},
			"FairyTail": {'id': 428},
			"FairyWings": {'id': 429},
			"FairyStuff": {'id': 430},
			"SnowMaidenHead": {'id': 431},
			"SnowMaidenBody": {'id': 432},
			"SnowMaidenTail": {'id': 433},
			"Amulet4": {'id': 437},
			"BlueAirbender": {'id': 438},
			"RedAirbender": {'id': 439},
			"VioletAirbender": {'id': 440},
			"HoneyLemon": {'id': 443},
			"Toothless": {
				'id': 444,
				'hiddenBones': [TAIL_BONE, HEAD_BONE, EARS_BONE],
				'zOrderBones': {'Cloak': LEFT_SLEEV_BONE}
			},
			"Pikachu": {
				'id': 445,
				'hiddenBones': [TAIL_BONE, EARS_BONE]
			},
			"SnowLeopard": {'id': 446},
			"Assassin": {'id': 447},
			"AssassinDagger": {'id': 447},
			"AssassinTail": {'id': 447},
			"FlowerShaman": {'id': 448},
			"SweetTeeth": {'id': 449},
			"SweetTeethTail": {'id': 449},
			"Armadillo": {'id': 450},
			"Fanat": {'id': 451},
			"Flash": {'id': 452},
			"AlchemistCap": {'id': 453},
			"AlchemistTail": {'id': 454},
			"AlchemistTop": {'id': 455},
			"AlchemistPants": {'id': 456},
			"AlchemistHand": {'id': 457},

			"Robocop": {'id': 457},
			"Altrone": {'id': 457},

			"Ameli": {'id': 501},
			"Blackbeard": {'id': 501},
			"BlackCat": {
				'id': 501,
				'hiddenBones': [HEAD_BONE, TAIL_BONE]
			},
			"Throne": {
				'id': 501,
				'hiddenBones': [EARS_BONE]
			},
			"Zoom": {'id': 501},
			"FairyCat": {
				'id': 501,
				'hiddenBones': [HEAD_BONE, TAIL_BONE]
			},
			"Dormammu": {'id': 501},
			"Anubis": {
				'id': 501,
				'hiddenBones': [EARS_BONE]
			},
			"Tutenshtain": {'id': 501},
			"Aid": {'id': 501},
			"AidHead": {
				'id': 502,
				'zOrderBones': {'Cap': FOR_CAP_BONE}
			},
			"Reaper": {'id': 501},

			"CrystalMaiden": {'id': 501},
			"SantaElf": {'id': 501},
			"Dovahkiin": {
				'id': 501,
				'hiddenBones': [EARS_BONE]
			},
			"DovahkiinMace": {'id': 501},
			"DragonIce": {
				'id': 501,
				'hiddenBones': [TAIL_BONE, HEAD_BONE, EARS_BONE],
				'zOrderBones': {'Cloak': LEFT_SLEEV_BONE}
			},
			"LichKing": {'id': 501},

			"SantaElfTail": {'id': 501},

			"CrystalMaidenStaff": {'id': 501},
			"CrystalMaidenCloak": {'id': 501},

			"LichKingCloak": {'id': 501},
			"LichKingNeck": {'id': 501},
			"Frostmourne": {'id': 501},
			"Rafael": {
				'id': 601,
				'hiddenBones': [EARS_BONE]
			},
			"McTwist": {
				'id': 601,
				'hiddenBones': [TAIL_BONE, EARS_BONE]
			},
			"RafaelHands": {'id': 601},
			"McTwistTail": {'id': 601},

			"AmurMan": {'id': 601},
			"AmurWoman": {'id': 601},
			"AmurGoldenMan": {'id': 601},
			"AmurGoldenWoman": {'id': 601},
			"AmurGolden": {'id': 601},
			"AmurTail": {'id': 601},
			"AmurHands": {'id': 601},
			"AmurManCloak": {'id': 601},
			"AmurWomanCloak": {'id': 601},
			"AmurGoldenCloak": {'id': 601},
			"AmurHairband": {
				'id': 601
			},
			"Deadpool": {'id': 601},
			"Bubblegum": {'id': 601},
			"DeadpoolCloak": {'id': 601},
			"DeadpoolHands": {'id': 601},

			"ShamanSpring": {'id': 601},
			"Rapunzel": {'id': 601},
			"Druid": {'id': 601},
			"Bear": {
				'id': 601,
				'hiddenBones': [TAIL_BONE, EARS_BONE,
					TAIL_ACCESSORY_01,
					TAIL_ACCESSORY_02,
					TAIL_ACCESSORY_03]
			},

			"RapunzelHands": {'id': 601},
			"RapunzelHairband": {
				'id': 601
			},
			"RapunzelTail": {'id': 601},

			"DruidHands": {'id': 601},
			"DruidCloak": {'id': 601},
			"DruidTail": {'id': 601},

			"BearHands": {'id': 601},
			"BearNeck": {'id': 601},
			"BearCloak": {'id': 601},

			"SpringHairband": {
				'id': 601
			},
			"SpringManGlasses": {'id': 601},
			"SpringWomanGlasses": {'id': 601},

			"RockWings": {'id': 602},
			"RockGlasses": {'id': 603},
			"RockGuitar": {'id': 604},
			"RockTail": {'id': 605},
			"RockHairband": {
				'id': 606
			},
			"Eva": {
				'id': 701,
				'hiddenBones': [EARS_BONE]
			},
			"Stitch": {
				'id': 701,
				'hiddenBones': [TAIL_BONE, EARS_BONE,
					TAIL_ACCESSORY_01,
					TAIL_ACCESSORY_02,
					TAIL_ACCESSORY_03]
			},
			"Farmer": {'id': 701},
			"Harlock": {'id': 701},
			"Minion": {'id': 701},

			"FarmerHands": {'id': 701},
			"FarmerTail": {'id': 701},
			"FarmerHair": {'id': 701},
			"HarlockCloak": {'id': 701},
			"HarlockCloakTop": {'id': 701},
			"HarlockNeck": {'id': 701},
			"HarlockHands": {'id': 701},
			"HarlockTail": {'id': 701},
			"MinionGlasses": {'id': 701},
			"MinionHands": {'id': 701},
			"MinionTail": {'id': 701},
			"FairyCatNeck": {'id': 701},
			"FairyCatTail": {'id': 701},
			"FairyCatHairband": {'id': 701},

			"ElectroCloak": {'id': 701},
			"ElectroCloakTop": {'id': 701},
			"ElectroGlasses": {'id': 701},
			"ElectroTail": {'id': 701},
			"ElectroHairband": {'id': 701},
			"SoldierHairband": {'id': 701},

			"Chaplin": {'id': 701},
			"ChaplinHands": {'id': 701},
			"ChaplinHairband": {'id': 701},
			"OrcTail": {'id': 701},
			"OrcNeck": {'id': 701},
			"OrcHands": {'id': 701},
			"Orc": {'id': 701},

			"SummerHairband": {'id': 701},
			"SummerHands": {'id': 701},
			"SummerNeck": {'id': 701},
			"SummerTail": {'id': 701},

			"FruitGlasses": {'id': 701},
			"FruitHands": {'id': 701},
			"FruitNeck": {'id': 701},
			"FruitTail": {'id': 701},
			"FruitHairband": {'id': 701},

			"AquaCloak": {'id': 701},
			"AquaGlasses": {'id': 701},
			"AquaHands": {'id': 701},
			"AquaTail": {'id': 701},
			"SchoolBack": {'id': 701},
			"SchoolGlasses": {'id': 701},
			"SchoolHands": {'id': 701},
			"SchoolTail": {'id': 701}
		};

		static public function getObject(name:String):Object
		{
			if (name in DATA)
				return DATA[name];
			return null;
		}
	}
}