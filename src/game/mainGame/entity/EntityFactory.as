package game.mainGame.entity
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import game.mainGame.entity.battle.BouncingPoise;
	import game.mainGame.entity.battle.BouncingPoiseRespawn;
	import game.mainGame.entity.battle.ExtraDamageRespawn;
	import game.mainGame.entity.battle.GhostPoise;
	import game.mainGame.entity.battle.GhostPoiseRespawn;
	import game.mainGame.entity.battle.GodModeRespawn;
	import game.mainGame.entity.battle.GravityPoise;
	import game.mainGame.entity.battle.GravityPoiseRespawn;
	import game.mainGame.entity.battle.GrenadePartPoise;
	import game.mainGame.entity.battle.GrenadePoise;
	import game.mainGame.entity.battle.GrenadePoiseRespawn;
	import game.mainGame.entity.battle.MedicKitRespawn;
	import game.mainGame.entity.battle.SpikePoise;
	import game.mainGame.entity.battle.SpikePoiseRespawn;
	import game.mainGame.entity.cast.BodyDestructor;
	import game.mainGame.entity.cast.DragTool;
	import game.mainGame.entity.cast.Hammer;
	import game.mainGame.entity.editor.AntimagicBody;
	import game.mainGame.entity.editor.BlackShamanBody;
	import game.mainGame.entity.editor.BlueTeamBody;
	import game.mainGame.entity.editor.Branch;
	import game.mainGame.entity.editor.ButtonSensor;
	import game.mainGame.entity.editor.ClickButton;
	import game.mainGame.entity.editor.CollectionPoint;
	import game.mainGame.entity.editor.CoverIce;
	import game.mainGame.entity.editor.Helper;
	import game.mainGame.entity.editor.HelperLearning;
	import game.mainGame.entity.editor.HintArrowObject;
	import game.mainGame.entity.editor.IslandBig;
	import game.mainGame.entity.editor.IslandLessSmall;
	import game.mainGame.entity.editor.IslandMedium;
	import game.mainGame.entity.editor.IslandSmall;
	import game.mainGame.entity.editor.MagicFlow;
	import game.mainGame.entity.editor.Mount;
	import game.mainGame.entity.editor.MountIce;
	import game.mainGame.entity.editor.MountSliced;
	import game.mainGame.entity.editor.OneWayWildBalk;
	import game.mainGame.entity.editor.PlanetBody;
	import game.mainGame.entity.editor.PlatformAcidBody;
	import game.mainGame.entity.editor.PlatformBlockBody;
	import game.mainGame.entity.editor.PlatformBridgeBody;
	import game.mainGame.entity.editor.PlatformDesertSandBody;
	import game.mainGame.entity.editor.PlatformGlassBlock;
	import game.mainGame.entity.editor.PlatformGroundBody;
	import game.mainGame.entity.editor.PlatformGroundWildBody;
	import game.mainGame.entity.editor.PlatformHerbBody;
	import game.mainGame.entity.editor.PlatformIceGroundBody;
	import game.mainGame.entity.editor.PlatformLavaBody;
	import game.mainGame.entity.editor.PlatformLiquidAcidBody;
	import game.mainGame.entity.editor.PlatformMetalBlock;
	import game.mainGame.entity.editor.PlatformOilBody;
	import game.mainGame.entity.editor.PlatformSandBody;
	import game.mainGame.entity.editor.PlatformSeaShore;
	import game.mainGame.entity.editor.PlatformSpaceShipPiece;
	import game.mainGame.entity.editor.PlatformSpikesBody;
	import game.mainGame.entity.editor.PlatformSpikesWildBody;
	import game.mainGame.entity.editor.PlatformSwampBody;
	import game.mainGame.entity.editor.PlatformTarBody;
	import game.mainGame.entity.editor.PlatformWoodenBlock;
	import game.mainGame.entity.editor.Pusher;
	import game.mainGame.entity.editor.Pyramid;
	import game.mainGame.entity.editor.RectGravity;
	import game.mainGame.entity.editor.RedShamanBody;
	import game.mainGame.entity.editor.RedTeamBody;
	import game.mainGame.entity.editor.RespawnPoint;
	import game.mainGame.entity.editor.Ribs;
	import game.mainGame.entity.editor.ScriptedTimer;
	import game.mainGame.entity.editor.Sensor;
	import game.mainGame.entity.editor.SensorRect;
	import game.mainGame.entity.editor.ShamanBody;
	import game.mainGame.entity.editor.SquirrelBody;
	import game.mainGame.entity.editor.Stone;
	import game.mainGame.entity.editor.Trunk;
	import game.mainGame.entity.editor.ZombieBody;
	import game.mainGame.entity.editor.decorations.DecorationAmphora;
	import game.mainGame.entity.editor.decorations.DecorationAppleTree;
	import game.mainGame.entity.editor.decorations.DecorationBush;
	import game.mainGame.entity.editor.decorations.DecorationCactus1;
	import game.mainGame.entity.editor.decorations.DecorationCactus2;
	import game.mainGame.entity.editor.decorations.DecorationCloud;
	import game.mainGame.entity.editor.decorations.DecorationCrystal1;
	import game.mainGame.entity.editor.decorations.DecorationCrystal2;
	import game.mainGame.entity.editor.decorations.DecorationCrystal3;
	import game.mainGame.entity.editor.decorations.DecorationDandelion;
	import game.mainGame.entity.editor.decorations.DecorationDesertCloud1;
	import game.mainGame.entity.editor.decorations.DecorationDesertCloud2;
	import game.mainGame.entity.editor.decorations.DecorationEagle;
	import game.mainGame.entity.editor.decorations.DecorationFern;
	import game.mainGame.entity.editor.decorations.DecorationFirTree;
	import game.mainGame.entity.editor.decorations.DecorationFirTreeSnowed;
	import game.mainGame.entity.editor.decorations.DecorationFountain;
	import game.mainGame.entity.editor.decorations.DecorationGlassTree;
	import game.mainGame.entity.editor.decorations.DecorationGlassUnicorn;
	import game.mainGame.entity.editor.decorations.DecorationHedgehog;
	import game.mainGame.entity.editor.decorations.DecorationMushrooms;
	import game.mainGame.entity.editor.decorations.DecorationOwl;
	import game.mainGame.entity.editor.decorations.DecorationPine;
	import game.mainGame.entity.editor.decorations.DecorationPlasmaLamp1;
	import game.mainGame.entity.editor.decorations.DecorationPlasmaLamp2;
	import game.mainGame.entity.editor.decorations.DecorationRobot;
	import game.mainGame.entity.editor.decorations.DecorationSarcophagus;
	import game.mainGame.entity.editor.decorations.DecorationScrapMetal;
	import game.mainGame.entity.editor.decorations.DecorationSingleStone;
	import game.mainGame.entity.editor.decorations.DecorationSkull;
	import game.mainGame.entity.editor.decorations.DecorationStatue;
	import game.mainGame.entity.editor.decorations.DecorationTorch;
	import game.mainGame.entity.editor.decorations.DecorationTwoStones;
	import game.mainGame.entity.editor.decorations.DecorationWoodLog;
	import game.mainGame.entity.editor.decorations.Sea.DecorationOctopus;
	import game.mainGame.entity.editor.decorations.Sea.DecorationPalmTree;
	import game.mainGame.entity.editor.decorations.Sea.DecorationPinguin;
	import game.mainGame.entity.editor.decorations.Sea.DecorationPinkFish;
	import game.mainGame.entity.editor.decorations.Sea.DecorationYellowFish;
	import game.mainGame.entity.editor.decorations.mountains.DecorationFirTreeSnow;
	import game.mainGame.entity.editor.decorations.mountains.DecorationHedgehogIce;
	import game.mainGame.entity.editor.decorations.mountains.DecorationIceTree;
	import game.mainGame.entity.editor.decorations.mountains.DecorationSnowman;
	import game.mainGame.entity.editor.decorations.wild.DecorationWild0;
	import game.mainGame.entity.editor.decorations.wild.DecorationWild1;
	import game.mainGame.entity.editor.decorations.wild.DecorationWild2;
	import game.mainGame.entity.editor.decorations.wild.DecorationWild3;
	import game.mainGame.entity.editor.decorations.wild.DecorationWild4;
	import game.mainGame.entity.iceland.IceBlock;
	import game.mainGame.entity.iceland.IceBlockGenerator;
	import game.mainGame.entity.iceland.NYSnowGenerator;
	import game.mainGame.entity.iceland.NYSnowReceiver;
	import game.mainGame.entity.joints.JointDistance;
	import game.mainGame.entity.joints.JointDrag;
	import game.mainGame.entity.joints.JointGum;
	import game.mainGame.entity.joints.JointHoney;
	import game.mainGame.entity.joints.JointLinear;
	import game.mainGame.entity.joints.JointPrismatic;
	import game.mainGame.entity.joints.JointPulley;
	import game.mainGame.entity.joints.JointRope;
	import game.mainGame.entity.joints.JointRopeToSquirrel;
	import game.mainGame.entity.joints.JointSticky;
	import game.mainGame.entity.joints.JointToBody;
	import game.mainGame.entity.joints.JointToBodyFixed;
	import game.mainGame.entity.joints.JointToBodyMotor;
	import game.mainGame.entity.joints.JointToBodyMotorCCW;
	import game.mainGame.entity.joints.JointToWorld;
	import game.mainGame.entity.joints.JointToWorldFixed;
	import game.mainGame.entity.joints.JointToWorldMotor;
	import game.mainGame.entity.joints.JointToWorldMotorCCW;
	import game.mainGame.entity.joints.JointWeld;
	import game.mainGame.entity.magic.AidBridge;
	import game.mainGame.entity.magic.AmericaShield;
	import game.mainGame.entity.magic.AnubisObelisk;
	import game.mainGame.entity.magic.AssassinDagger;
	import game.mainGame.entity.magic.Banana;
	import game.mainGame.entity.magic.BananaSmall;
	import game.mainGame.entity.magic.BearBag;
	import game.mainGame.entity.magic.Blizzard;
	import game.mainGame.entity.magic.CloudNinja;
	import game.mainGame.entity.magic.EasterChicken;
	import game.mainGame.entity.magic.EvaHologram;
	import game.mainGame.entity.magic.FarmerField;
	import game.mainGame.entity.magic.GoldSack;
	import game.mainGame.entity.magic.GrowingPlant;
	import game.mainGame.entity.magic.Gum;
	import game.mainGame.entity.magic.HarlockFlag;
	import game.mainGame.entity.magic.HarpoonBodyBat;
	import game.mainGame.entity.magic.HarpoonBodyBubblegum;
	import game.mainGame.entity.magic.HarpoonBodyCat;
	import game.mainGame.entity.magic.HipstersCocktail;
	import game.mainGame.entity.magic.IceDragon;
	import game.mainGame.entity.magic.Lego;
	import game.mainGame.entity.magic.MagicianCard;
	import game.mainGame.entity.magic.McTwistTimeWarp;
	import game.mainGame.entity.magic.Muffin;
	import game.mainGame.entity.magic.NapoleonBouncer;
	import game.mainGame.entity.magic.NewYearSnowman;
	import game.mainGame.entity.magic.PirateBarrel;
	import game.mainGame.entity.magic.PirateCannon;
	import game.mainGame.entity.magic.RapunzelLight;
	import game.mainGame.entity.magic.SailorMoonPlanet;
	import game.mainGame.entity.magic.SamuraiSakura;
	import game.mainGame.entity.magic.SantaBox;
	import game.mainGame.entity.magic.ShadowBomb;
	import game.mainGame.entity.magic.SheepBomb;
	import game.mainGame.entity.magic.SkeletonSkullObject;
	import game.mainGame.entity.magic.SmokeBomb;
	import game.mainGame.entity.magic.SpiderWeb;
	import game.mainGame.entity.magic.StickyBomb;
	import game.mainGame.entity.magic.StitchLazer;
	import game.mainGame.entity.magic.SupermanSignView;
	import game.mainGame.entity.magic.SurpriseBox;
	import game.mainGame.entity.magic.ThroneHologram;
	import game.mainGame.entity.magic.TornadoPharaon;
	import game.mainGame.entity.magic.TuxedoMaskRose;
	import game.mainGame.entity.magic.ZombieSavePoint;
	import game.mainGame.entity.quicksand.Quicksand;
	import game.mainGame.entity.shaman.DeathCloud;
	import game.mainGame.entity.shaman.DrawBlock;
	import game.mainGame.entity.shaman.GravityBlock;
	import game.mainGame.entity.shaman.IceCube;
	import game.mainGame.entity.shaman.LifeTimeBalkLong;
	import game.mainGame.entity.shaman.LifetimeBalk;
	import game.mainGame.entity.shaman.OneWayBalk;
	import game.mainGame.entity.shaman.PortalGB;
	import game.mainGame.entity.shaman.PortalGR;
	import game.mainGame.entity.shaman.PortalGreen;
	import game.mainGame.entity.shaman.Rune;
	import game.mainGame.entity.shaman.ShamanBodyDestructor;
	import game.mainGame.entity.shaman.ShamanPointer;
	import game.mainGame.entity.shaman.ShamanTotem;
	import game.mainGame.entity.shaman.StormCloud;
	import game.mainGame.entity.simple.AcornBody;
	import game.mainGame.entity.simple.BalanceWheel;
	import game.mainGame.entity.simple.Balk;
	import game.mainGame.entity.simple.BalkGlass;
	import game.mainGame.entity.simple.BalkGlassLong;
	import game.mainGame.entity.simple.BalkIce;
	import game.mainGame.entity.simple.BalkIceLong;
	import game.mainGame.entity.simple.BalkLong;
	import game.mainGame.entity.simple.BalkLongSteel;
	import game.mainGame.entity.simple.BalkSteel;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.BeamEmitter;
	import game.mainGame.entity.simple.BeamReceiver;
	import game.mainGame.entity.simple.BlueHollowBody;
	import game.mainGame.entity.simple.Bomb;
	import game.mainGame.entity.simple.BoostZone;
	import game.mainGame.entity.simple.Bouncer;
	import game.mainGame.entity.simple.Box;
	import game.mainGame.entity.simple.BoxBig;
	import game.mainGame.entity.simple.BoxBigSteel;
	import game.mainGame.entity.simple.BoxGlass;
	import game.mainGame.entity.simple.BoxIce;
	import game.mainGame.entity.simple.BoxIceBig;
	import game.mainGame.entity.simple.BoxSteel;
	import game.mainGame.entity.simple.BubbleBody;
	import game.mainGame.entity.simple.BubblesEmitter;
	import game.mainGame.entity.simple.Bungee;
	import game.mainGame.entity.simple.BungeeBullet;
	import game.mainGame.entity.simple.BungeeHarpoon;
	import game.mainGame.entity.simple.BurstBody;
	import game.mainGame.entity.simple.Centrifuge;
	import game.mainGame.entity.simple.CentrifugeDisc;
	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.entity.simple.CollectionMirageElement;
	import game.mainGame.entity.simple.Conveyor;
	import game.mainGame.entity.simple.DragonFlamer;
	import game.mainGame.entity.simple.FirCone;
	import game.mainGame.entity.simple.FirConeRight;
	import game.mainGame.entity.simple.FireBall;
	import game.mainGame.entity.simple.FlyWayPoint;
	import game.mainGame.entity.simple.GunPoise;
	import game.mainGame.entity.simple.Holes;
	import game.mainGame.entity.simple.HollowBody;
	import game.mainGame.entity.simple.HomingGun;
	import game.mainGame.entity.simple.HoppingBall;
	import game.mainGame.entity.simple.Hydrant;
	import game.mainGame.entity.simple.Magnet;
	import game.mainGame.entity.simple.Net;
	import game.mainGame.entity.simple.NutsDisintegrator;
	import game.mainGame.entity.simple.OlympicCoin;
	import game.mainGame.entity.simple.Poise;
	import game.mainGame.entity.simple.PoiseInvisible;
	import game.mainGame.entity.simple.PoiseInvisibleRight;
	import game.mainGame.entity.simple.PoiseRight;
	import game.mainGame.entity.simple.PortalBB;
	import game.mainGame.entity.simple.PortalBBDirected;
	import game.mainGame.entity.simple.PortalBR;
	import game.mainGame.entity.simple.PortalBRDirected;
	import game.mainGame.entity.simple.PortalBlue;
	import game.mainGame.entity.simple.PortalBlueDirected;
	import game.mainGame.entity.simple.PortalRB;
	import game.mainGame.entity.simple.PortalRBDirected;
	import game.mainGame.entity.simple.PortalRR;
	import game.mainGame.entity.simple.PortalRRDirected;
	import game.mainGame.entity.simple.PortalRed;
	import game.mainGame.entity.simple.PortalRedDirected;
	import game.mainGame.entity.simple.RedHollowBody;
	import game.mainGame.entity.simple.SeaGrass;
	import game.mainGame.entity.simple.Snowballs;
	import game.mainGame.entity.simple.StickyBall;
	import game.mainGame.entity.simple.SunflowerBody;
	import game.mainGame.entity.simple.Tornado;
	import game.mainGame.entity.simple.Trampoline;
	import game.mainGame.entity.simple.Trap;
	import game.mainGame.entity.simple.TreeBody;
	import game.mainGame.entity.simple.Vine;
	import game.mainGame.entity.simple.WeightBody;
	import game.mainGame.entity.simple.Wheel;
	import game.mainGame.entity.water.Water;

	import avmplus.getQualifiedClassName;

	public class EntityFactory
	{
		static private var entityCollection:Array = [
			Box,
			BoxBig,
			Balk,
			BalkLong,
			BalloonBody,
			PortalBlue,
			PortalRed,
			Poise,
			PoiseRight,
			ShamanBody,
			SquirrelBody,
			HollowBody,
			AcornBody,
			IslandSmall,
			IslandMedium,
			IslandBig,
			JointToWorldFixed,
			JointToWorld,
			JointToBodyFixed,
			JointToBody,
			null,
			PoiseRight,
			BalkIce,
			BalkIceLong,
			BoxIce,
			BoxIceBig,
			PlatformSandBody,
			PlatformHerbBody,
			PlatformGroundBody,
			CoverIce,
			SunflowerBody,
			TreeBody,
			IslandLessSmall,
			JointToBodyMotor,
			JointToBodyMotorCCW,
			JointToWorldMotor,
			JointToWorldMotorCCW,
			JointDistance,
			JointPrismatic,
			JointPulley,
			JointWeld,
			JointLinear,
			WeightBody,
			Mount,
			MountIce,
			MountSliced,
			Stone,
			BodyDestructor,
			PortalBlueDirected,
			PortalRedDirected,
			Branch,
			Trunk,
			Holes,
			Trampoline,
			PlatformBridgeBody,
			PlatformLavaBody,
			PlatformSwampBody,
			Sensor,
			HintArrowObject,
			Helper,
			Water,
			DecorationAppleTree,
			DecorationBush,
			DecorationCloud,
			DecorationFirTree,
			DecorationFirTreeSnowed,
			DecorationMushrooms,
			DecorationOwl,
			FirCone,
			FirConeRight,
			PlatformAcidBody,
			PlatformSpikesBody,
			JointRope,
			ScriptedTimer,
			SensorRect,
			JointGum,
			Gum,
			ButtonSensor,
			ClickButton,
			SeaGrass,
			DecorationPinguin,
			DecorationYellowFish,
			DecorationPinkFish,
			DecorationOctopus,
			DecorationPalmTree,
			PlatformSeaShore,
			JointDrag,
			DragTool,
			PlanetBody,
			Pusher,
			RectGravity,
			BoxSteel,
			BoxBigSteel,
			BalkSteel,
			BalkLongSteel,
			PlatformSpaceShipPiece,
			SpikePoise,
			RedTeamBody,
			BlueTeamBody,
			RedShamanBody,
			SpikePoiseRespawn,
			null,
			SpiderWeb,
			CollectionElement,
			null,
			DragonFlamer,
			DecorationEagle,
			DecorationFern,
			DecorationHedgehog,
			DecorationHedgehogIce,
			DecorationIceTree,
			DecorationPine,
			DecorationSingleStone,
			DecorationFirTreeSnow,
			DecorationSnowman,
			DecorationDandelion,
			DecorationWoodLog,
			DecorationTwoStones,
			CloudNinja,
			Snowballs,
			HelperLearning,
			FlyWayPoint,
			null,
			JointRopeToSquirrel,
			null,
			null,
			BlueHollowBody,
			RedHollowBody,
			BlackShamanBody,
			GrowingPlant,
			Lego,
			PortalBB,
			PortalRB,
			PortalBR,
			PortalRR,
			PortalBBDirected,
			PortalRBDirected,
			PortalBRDirected,
			PortalRRDirected,
			HipstersCocktail,
			PoiseInvisible,
			PoiseInvisibleRight,
			MedicKitRespawn,
			BouncingPoise,
			GhostPoise,
			BouncingPoiseRespawn,
			GhostPoiseRespawn,
			GravityPoise,
			GravityPoiseRespawn,
			GrenadePoise,
			GrenadePoiseRespawn,
			GrenadePartPoise,
			GodModeRespawn,
			ExtraDamageRespawn,
			Bomb,
			MagicianCard,
			GoldSack,
			Tornado,
			Quicksand,
			DecorationDesertCloud1,
			DecorationDesertCloud2,
			DecorationCactus1,
			DecorationCactus2,
			DecorationSkull,
			DecorationAmphora,
			DecorationStatue,
			PlatformDesertSandBody,
			PlatformBlockBody,
			Pyramid,
			Ribs,
			CollectionMirageElement,
			DecorationSarcophagus,
			DecorationTorch,
			DecorationFountain,
			BurstBody,
			HarpoonBodyBat,
			HarpoonBodyCat,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			DeathCloud,
			null,
			Blizzard,
			ShamanPointer,
			PlatformLiquidAcidBody,
			Bouncer,
			OneWayBalk,
			LifetimeBalk,
			LifeTimeBalkLong,
			ShamanBodyDestructor,
			GravityBlock,
			ShamanTotem,
			DrawBlock,
			PortalGreen,
			PortalGB,
			PortalGR,
			StormCloud,
			IceCube,
			Rune,
			EasterChicken,
			SailorMoonPlanet,
			TuxedoMaskRose,
			PlatformWoodenBlock,
			PlatformMetalBlock,
			DecorationScrapMetal,
			DecorationRobot,
			DecorationPlasmaLamp1,
			DecorationPlasmaLamp2,
			Wheel,
			Vine,
			Net,
			PlatformTarBody,
			PlatformOilBody,
			BoostZone,
			BubblesEmitter,
			BubbleBody,
			Trap,
			Hammer,
			Bungee,
			BungeeHarpoon,
			BungeeBullet,
			TornadoPharaon,
			null,
			null,
			null,
			null,
			SurpriseBox,
			DecorationCrystal1,
			DecorationCrystal2,
			DecorationCrystal3,
			DecorationGlassTree,
			DecorationGlassUnicorn,
			BalkGlass,
			BalkGlassLong,
			BoxGlass,
			PlatformGlassBlock,
			Centrifuge,
			CentrifugeDisc,
			NutsDisintegrator,
			StickyBall,
			HoppingBall,
			Magnet,
			HomingGun,
			GunPoise,
			Conveyor,
			Hydrant,
			BeamEmitter,
			BeamReceiver,
			AntimagicBody,
			MagicFlow,
			OlympicCoin,
			BalanceWheel,
			IceBlock,
			IceBlockGenerator,
			NYSnowGenerator,
			NYSnowReceiver,
			PlatformIceGroundBody,
			NewYearSnowman,
			IceDragon,
			StickyBomb,
			SmokeBomb,
			JointSticky,
			FireBall,
			RespawnPoint,
			AssassinDagger,
			PlatformGroundWildBody,
			PlatformSpikesWildBody,
			OneWayWildBalk,
			ZombieBody,
			DecorationWild0,
			DecorationWild1,
			DecorationWild2,
			DecorationWild3,
			DecorationWild4,
			Muffin,
			SheepBomb,
			ShadowBomb,
			CollectionPoint,
			NapoleonBouncer,
			PirateCannon,
			PirateBarrel,
			ThroneHologram,
			SupermanSignView,
			SkeletonSkullObject,
			ZombieSavePoint,
			McTwistTimeWarp,
			SamuraiSakura,
			HarpoonBodyBubblegum,
			AmericaShield,
			RapunzelLight,
			BearBag,
			JointHoney,
			AnubisObelisk,
			AidBridge,
			EvaHologram,
			StitchLazer,
			FarmerField,
			HarlockFlag,
			Banana,
			BananaSmall,
			SantaBox
		];

		static private var images:Dictionary = new Dictionary();

		static public function init():void
		{
			images[ShamanBody] = {'icon': ShamanIcon, 'width': 24, 'height': 35, 'name': "Шаман", 'title': gls("Шаман")};
			images[SquirrelBody] = {'icon': HeroIcon, 'width': 29, 'height': 30, 'name': "Белка", 'title': gls("Белка")};
			images[RedTeamBody] = {'icon': RedTeamIcon, 'width': 25, 'height': 33, 'name': "Красная белка", 'title': gls("Красная белка")};
			images[BlueTeamBody] = {'icon': BlueTeamIcon, 'width': 25, 'height': 33, 'name': "Синяя белка", 'title': gls("Синяя белка")};
			images[RedShamanBody] = {'icon': RedShamanIcon, 'width': 24, 'height': 35, 'name': "Красный шаман", 'title': gls("Красный шаман")};
			images[HollowBody] = {'icon': Hollow, 'width': 36, 'height': 33, 'name': "Дупло", 'title': gls("Дупло")};
			images[BlueHollowBody] = {'icon': HollowBlue, 'width': 36, 'height': 33, 'name': "Синее дупло", 'title': gls("Синее дупло")};
			images[RedHollowBody] = {'icon': HollowRed, 'width': 36, 'height': 33, 'name': "Красное дупло", 'title': gls("Красное дупло")};
			images[AcornBody] = {'icon': AcornsVector, 'x': 17, 'y': 20, 'width': 40, 'height': 40, 'name': "Орехи", 'title': gls("Орехи")};
			images[BlackShamanBody] = {'icon': BlackShamanIcon, 'width': 24, 'height': 35, 'name': "Чёрный шаман", 'title': gls("Чёрный шаман")};

			images[FlyWayPoint] = {'icon': FlyWayPointView, 'x': 10, 'y': 10, 'width': 20, 'height': 20, 'name': "Точка траектории полёта", 'title': gls("Точка траектории полёта")};
			images[IslandSmall] = {'icon': Island3, 'width': 33, 'height': 18, 'name': "Маленький остров", 'title': gls("Маленький остров")};
			images[IslandMedium] = {'icon': Island2, 'width': 40, 'height': 18, 'name': "Средний остров", 'title': gls("Средний остров")};
			images[IslandBig] = {'icon': Island1, 'width': 43, 'height': 17, 'name': "Большой остров", 'title': gls("Большой остров")};

			images[Box] = {'icon': Box1, 'width': 20, 'height': 20, 'name': "Ящик", 'title': gls("Ящик")};
			images[BoxBig] = {'icon': Box2, 'width': 29, 'height': 29, 'name': "Большой ящик", 'title': gls("Большой ящик")};
			images[Balk] = {'icon': Balk1, 'width': 27, 'height': 5, 'name': "Палка", 'title': gls("Палка")};
			images[BalkLong] = {'icon': Balk2, 'width': 42, 'height': 5, 'name': "Длинная палка", 'title': gls("Длинная палка")};

			images[BoxSteel] = {'icon': SteelBoxView, 'width': 20, 'height': 20, 'x': 10, 'y': 10, 'name': "Ящик метал.", 'title': gls("Ящик метал.")};
			images[BoxBigSteel] = {'icon': SteelBoxBigView, 'width': 29, 'height': 29, 'x': 15, 'y': 15, 'name': "Большой ящик метал.", 'title': gls("Большой ящик метал.")};
			images[BalkSteel] = {'icon': SteelBalkView, 'width': 27, 'height': 5, 'x': 14.5, 'y': 2.5, 'name': "Палка метал.", 'title': gls("Палка метал.")};
			images[BalkLongSteel] = {'icon': SteelBalkLongView, 'width': 42, 'height': 5, 'x': 21, 'y': 2.5, 'name': "Длинная палка метал.", 'title': gls("Длинная палка метал.")};
			images[BalloonBody] = {'icon': BalloonIcon, 'width': 22, 'height': 31, 'name': "Шарик", 'title': gls("Шарик")};

			images[PortalBlue] = {'icon':PortalB, x: 13, y: 13, 'width': 32, 'height': 32, 'name': "Синий портал", 'title': gls("Синий портал")};
			images[PortalRed] = {'icon':PortalA, x: 13, y: 13, 'width': 32, 'height': 32, 'name': "Красный портал", 'title': gls("Красный портал")};
			images[PortalBB] = {'icon':PortalBB, 'width': 32, 'height': 32, 'name': "Синий портал для синего шамана", 'title': gls("Синий портал для синего шамана")};
			images[PortalRB] = {'icon':PortalRB, 'width': 32, 'height': 32, 'name': "Красный портал для синего шамана", 'title': gls("Красный портал для синего шамана")};
			images[PortalBR] = {'icon':PortalBR, 'width': 32, 'height': 32, 'name': "Синий портал для красного шамана", 'title': gls("Синий портал для красного шамана")};
			images[PortalRR] = {'icon':PortalRR, 'width': 32, 'height': 32, 'name': "Красный портал для красного шамана", 'title': gls("Красный портал для красного шамана")};
			images[PortalBlueDirected] = {'icon': PortalBlueDirected, x: 26, y: 13, 'width': 42, 'height': 28, 'name': "Синий направленный портал", 'title': gls("Синий направленный портал")};
			images[PortalRedDirected] = {'icon': PortalRedDirected, x: 26, y: 13, 'width': 42, 'height': 28, 'name': "Красный направленный портал", 'title': gls("Красный направленный портал")};
			images[PortalBBDirected] = {'icon':PortalBBDirected, 'width': 32, 'height': 32, 'name': "Синий направленный портал для синего шамана", 'title': gls("Синий направленный портал для синего шамана")};
			images[PortalRBDirected] = {'icon':PortalRBDirected, 'width': 32, 'height': 32, 'name': "Красный направленный портал для синего шамана", 'title': gls("Красный направленный портал для синего шамана")};
			images[PortalBRDirected] = {'icon':PortalBRDirected, 'width': 32, 'height': 32, 'name': "Синий направленный портал для красного шамана", 'title': gls("Синий направленный портал для красного шамана")};
			images[PortalRRDirected] = {'icon':PortalRRDirected, 'width': 32, 'height': 32, 'name': "Красный направленный портал для красного шамана", 'title': gls("Красный направленный портал для красного шамана")};

			images[Poise] = {'icon': PoiseL, 'name': "Ядро влево", 'title': gls("Ядро влево")};
			images[Gum] = {'icon': PoiseL, 'name': "Жвачка", 'title': gls("Жвачка")};
			images[PoiseRight] = {'icon': PoiseL, 'x': 25, 'y': 30, 'name': "Ядро", 'angle': 180, 'title': gls("Ядро")};
			images[PoiseInvisible] = {'icon': PoiseL, 'name': "Ядро невидимое влево", 'title': gls("Ядро невидимое влево"), 'alpha': 0.4};
			images[PoiseInvisibleRight] = {'icon': PoiseL, 'x': 25, 'y': 30, 'name': "Ядро невидимое", 'angle': 180, 'title': gls("Ядро невидимое"), 'alpha': 0.4};
			images[BalkIce] = {'icon': IceBalk1, 'width': 27, 'height': 5, 'name': "Ледяная палка", 'title': gls("Ледяная палка")};
			images[BalkIceLong] = {'icon': IceBalk2, 'width': 42, 'height': 5, 'name': "Длинная ледяная палка", 'title': gls("Длинная ледяная палка")};
			images[BoxIce] = {'icon': IceBox1, 'width': 20, 'height': 20, 'x': -4, 'y': -3, 'name': "Ледяной ящик", 'title': gls("Ледяной ящик")};
			images[BoxIceBig] = {'icon': IceBox2, 'width': 29, 'height': 29, 'x': -3, 'y': -2, 'name': "Большой ледяной ящик", 'title': gls("Большой ледяной ящик")};
			images[PlatformGroundBody] = {'icon': PlatformGround, 'width': 41, 'height': 29, 'name': "Земля", 'title': gls("Земля")};
			images[PlatformHerbBody] = {'icon': PlatformHerb, 'x': 0, 'y': 0, 'width': 31, 'height': 32, 'name': "Трава", 'title': gls("Трава")};
			images[PlatformSandBody] = {'icon': Sand1, 'width': 41, 'height': 29, 'name': "Песок", 'title': gls("Песок")};
			images[CoverIce] = {'icon': Ice, 'image': Ice, 'width': 40, 'height': 26, 'name': "Лёд", 'title': gls("Лёд")};
			images[SunflowerBody] = {'icon': Sunflower, 'width': 28, 'height': 33, 'name': "Знак опасности", 'title': gls("Знак опасности")};
			images[TreeBody] = {'icon': Tree, 'x': 0, 'y': 0, 'width': 35, 'height': 33, 'name': "Дерево", 'title': gls("Дерево")};
			images[IslandLessSmall] = {'icon': Island4, 'width': 25, 'height': 17, 'name': "Очень маленький остров", 'title': gls("Очень маленький остров")};
			images[WeightBody] = {'icon': Weight, 'width': 35 * 0.8, 'height': 43 * 0.8, 'name': "Гиря", 'title': gls("Гиря")};
			images[Mount] = {'icon': MountView, 'x': 15, 'y': 15, 'width':  45 * 0.7, 'height': 45 * 0.7, 'name': "Гора", 'title': gls("Гора")};
			images[MountIce] = {'icon': MountIcedView, 'x': 18, 'y': 15, 'width': 35, 'height': 35, 'name': "Ледяная гора", 'title': gls("Ледяная гора")};
			images[MountSliced] = {'icon': MountSlicedView, 'x': 20, 'y': 15, 'width': 45 * 0.9, 'height': 33 * 0.9, 'name': "Плоская гора", 'title': gls("Плоская гора")};
			images[Stone] = {'icon': StoneView, x: 15.7, y: 15.5, 'width': 31.5, 'height': 31, 'name': "Камень", 'title': gls("Камень")};

			images[JointToWorldFixed] = {'icon': PinLimited, 'x': 10, 'y': 10, 'name': "Связка к миру фиксированная", 'title': gls("Связка к миру фиксированная")};
			images[JointToWorld] = {'icon': PinUnlimited, 'x': 6, 'y': 6, 'name': "Связка к миру", 'title': gls("Связка к миру")};
			images[JointToBodyFixed] = {'icon': JointToBodyFixedImage, 'x': 6, 'y': 6, 'name': "Связка к объекту фиксированная", 'title': gls("Связка к объекту фиксированная")};
			images[JointToBody] = {'icon': JointToBodyImage, 'x': 6, 'y': 6, 'name': "Связка к объекту", 'title': gls("Связка к объекту")};
			images[JointDrag] = {'icon': JointDragView, 'x': 6, 'y': 6, 'name': "Связь телекинез", 'title': gls("Связь телекинез")};

			images[JointToBodyMotor] = {'icon': JointToBodyMotorImage, 'x': 12, 'y': 12, 'name': "Мотор к объекту по ЧС", 'title': gls("Мотор к объекту по ЧС")};
			images[JointToBodyMotorCCW] = {'icon': JointToBodyMotorImage, 'scaleX': true, 'x': 12, 'y': 12, 'name': "Мотор к объекту против ЧС", 'title': gls("Мотор к объекту против ЧС")};
			images[JointToWorldMotor] = {'icon': JointToWorldMotorImage, 'x': 12, 'y': 12, 'name': "Мотор к миру по ЧС", 'title': gls("Мотор к миру по ЧС")};
			images[JointToWorldMotorCCW] = {'icon': JointToWorldMotorImage, 'scaleX': true, 'x': 12, 'y': 12, 'name': "Мотор к миру против ЧС", 'title': gls("Мотор к миру против ЧС")};

			images[JointDistance] = {'icon': RopeJointView, 'width': 45, 'height': 9, 'x': 23, 'y': 5, 'name': "Резинка", 'title': gls("Резинка")};
			images[JointRope] = {'icon': RopeJointView, 'width': 45, 'height': 9, 'x': 23, 'y': 5, 'name': "Верёвка", 'title': gls("Верёвка")};
			images[JointPulley] = {'icon': PulleyJointView, 'width': 35, 'height': 32, 'x': 16, 'y': 15, 'name': "Блочная связка", 'title': gls("Блочная связка")};
			images[JointWeld] = {'icon': WeldJointView, 'width': 37, 'height': 9, 'x': 18, 'y': 5, 'name': "Жёсткая связка", 'title': gls("Жёсткая связка")};
			images[JointPrismatic] = {'icon': WeldJointView, 'width': 37, 'height': 9, 'x': 18, 'y': 5, 'name': "Подвижная фиксирующая связка", 'title': gls("Подвижная фиксирующая связка")};
			images[JointLinear] = {'icon': WeldJointView, 'width': 37, 'height': 9, 'x': 18, 'y': 5, 'name': "Подвижная связка", 'title': gls("Подвижная связка")};

			images[BodyDestructor] = {'icon': Sight, 'x': 18, 'y': 18, 'width': 32, 'height': 32, 'name': "Удаление объектов", 'title': gls("Удаление объектов")};
			images[DragTool] = {'icon': TelekinesisIcon, 'width': 38, 'height': 30, 'x': 4, 'y': 3, 'name': "Телекинез", 'title': gls("Телекинез")};

			images[Branch] = {'icon': BranchView, 'width': 40, 'height': 14, x: -4, 'name': "Ветка", 'title': gls("Ветка")};
			images[Trunk] = {'icon': TrunkView, x: 7, y: 17, 'width': 15, 'height': 35, 'name': "Ствол", 'title': gls("Ствол")};

			images[Holes] = {'icon': HolesView, x: 25, y: 17, 'width': 50, 'height': 35, 'name': "Норки", 'title': gls("Норки")};

			images[Trampoline] = {'icon': TrampolineView, x: 21, y: 8, 'width': 46, 'height': 16, 'name': "Батут", 'title': gls("Батут")};

			images[PlatformLavaBody] = {'icon': Lava, 'width': 26, 'height': 26, 'name': "Лава", 'title': gls("Лава")};
			images[PlatformSpaceShipPiece] = {'icon': SpaceShipPieceView, 'width': 63 * 0.4, 'height': 62 * 0.4, 'name': "Осколок косм. корабля", 'title': gls("Осколок косм. корабля")};
			images[PlatformBridgeBody] = {'icon': BridgeLeft, 'x': 0, 'y': 0, 'width': 35, 'height': 26, 'name': "Мост", 'title': gls("Мост")};
			images[PlatformSwampBody] = {'icon': SwampIcon, 'x': 25, 'y': 19, 'width': 26 * 1.7, 'height': 23 * 1.7, 'name': "Болото", 'title': gls("Болото")};
			images[Sensor] = {'icon': SensorIcon, 'width': 35, 'height': 35, 'name': "Сенсор", 'title': gls("Сенсор")};
			images[HintArrowObject] = {'icon': ArrowMovie, 'width': 35, 'height': 24, 'name': "Указатель", 'title': gls("Указатель")};

			images[Helper] = {'icon': HelperImage, 'x': 19, 'y': 19, 'width': 45, 'height': 35, 'name': "Помощник", 'title': gls("Помощник")};
			images[HelperLearning] = {'icon': ShamanIcon, 'width': 24, 'height': 35, 'name': "Помощник2", 'title': gls("Помощник2")};

			images[Water] = {'icon': WaterIcon, 'width': 35, 'height': 35, 'name': "Вода", 'title': gls("Вода")};

			images[ClickButton] = {'icon': ClickButtonUp, 'x': 13, 'y': 13, 'width': 26, 'height': 26, 'name': "Кнопка", 'title': gls("Кнопка")};
			images[ButtonSensor] = {'icon': ButtonScriptUp, 'x': 20, 'y': 0, 'width': 41, 'height': 19, 'name': "Кнопка-сенсор", 'title': gls("Кнопка-сенсор")};

			images[DecorationAppleTree] = {'icon': AppleTree, 'x': 12, 'y': 35, 'width': 26, 'height': 33, 'name': "Яблоня", 'title': gls("Яблоня")};
			images[DecorationBush] = {'icon': Bush, 'x': 20, 'y': 20, 'width': 35, 'height': 18, 'name': "Куст", 'title': gls("Куст")};
			images[DecorationCloud] = {'icon': Cloud, 'x': 20, 'width': 35, 'height': 8, 'name': "Облако", 'title': gls("Облако")};
			images[DecorationFirTree] = {'icon': FirTree, 'x': 12, 'y': 35, 'width': 26, 'height': 35, 'name': "Ёлка", 'title': gls("Ёлка")};
			images[DecorationFirTreeSnowed] = {'icon': FirTreeSnowed, 'x': 15, 'y': 33, 'width': 26, 'height': 33, 'name': "Заснеженная ёлка", 'title': gls("Заснеженная ёлка")};
			images[DecorationMushrooms] = {'icon': Mushrooms, 'x': 12, 'y': 30, 'width': 28, 'height': 35, 'name': "Грибы", 'title': gls("Грибы")};
			images[DecorationOwl] = {'icon': Owl, 'x': 12, 'y': 35, 'width': 23, 'height': 35, 'name': "Сова", 'title': gls("Сова")};

			images[FirCone] = {'icon': FirConeView, 'width': 35, 'height': 20, 'name': "Шишка влево", 'title': gls("Шишка влево")};
			images[FirConeRight] = {'icon': FirConeView, 'x': 35, 'y': 20, 'width': 35, 'height': 20, 'angle': 180, 'name': "Шишка вправо", 'title': gls("Шишка вправо")};

			images[PlatformAcidBody] = {'icon': Acid, 'width': 26, 'height': 26, 'name': "Кислота", 'title': gls("Кислота")};
			images[PlatformSpikesBody] = {'icon': Spikes, 'width': 26, 'height': 26, 'name': "Шипы", 'title': gls("Шипы")};
			images[ScriptedTimer] = {'icon': ScriptedTimerIcon, 'width': 35, 'height': 35, 'name': "Таймер", 'title': gls("Таймер")};
			images[SensorRect] = {'icon': SensorRectIcon, 'width': 35, 'height': 35, 'name': "Квадратный сенсор", 'title': gls("Квадратный сенсор")};

			images[DecorationOctopus] = {'icon': OctopusDec, 'x': 10, 'y': 10, 'width': 26, 'height': 24, 'name': "Морская трава", 'title': gls("Морская трава")};
			images[DecorationPalmTree] = {'icon': PalmDec, 'x': 16, 'y': 18, 'width': 32, 'height': 36, 'name': "Пальма", 'title': gls("Пальма")};
			images[DecorationYellowFish] = {'icon': FishYellowDec, 'x': 10, 'width': 26, 'height': 13, 'name': "Красная рыбка", 'title': gls("Красная рыбка")};
			images[DecorationPinkFish] = {'icon': FishPinkDec, 'x': 10, 'width': 26, 'height': 10, 'name': "Синяя рыбка", 'title': gls("Синяя рыбка")};
			images[DecorationPinguin] = {'icon': PinguinDec, 'x': 0, 'y': 10, 'width': 13, 'height': 26, 'name': "Пингвин", 'title': gls("Пингвин")};

			images[DecorationEagle] = {'icon': Eagle, 'x': 12, 'y': 33, 'width': 27, 'height': 35, 'name': "Орёл", 'title': gls("Орёл")};
			images[DecorationFern] = {'icon': Fern,'x': 20, 'y': 25, 'width': 40, 'height': 23, 'name': "Папоротник", 'title': gls("Папоротник")};
			images[DecorationHedgehog] = {'icon': Hedgehog, 'width': 35, 'height': 20, 'name': "Ёжик", 'title': gls("Ёжик")};
			images[DecorationHedgehogIce] = {'icon': HedgehogIce,'x': 20, 'y': 15, 'width': 35, 'height': 27, 'name': "Подснежник", 'title': gls("Подснежник")};
			images[DecorationIceTree] = {'icon': IceTree, 'x': 18, 'y': 18, 'width': 35, 'height': 34, 'name': "Дерево во льду", 'title': gls("Дерево во льду")};
			images[DecorationPine] = {'icon': Pine, 'x': 12, 'y': 30, 'width': 24, 'height': 35, 'name': "Дерево 2", 'title': gls("Дерево 2")};
			images[DecorationSingleStone] = {'icon': SingleStone, 'x': 15, 'y': 10, 'width': 35, 'height': 23, 'name': "Одиночный камень", 'title': gls("Одиночный камень")};
			images[DecorationFirTreeSnow] = {'icon': FirTreeSnow,'x': 7, 'y': 18, 'width': 18, 'height': 33, 'name': "Ель", 'title': gls("Ель")};
			images[DecorationSnowman] = {'icon': Snowman, 'x': 13, 'y': 25, 'width': 25, 'height': 35, 'name': "Снеговик", 'title': gls("Снеговик")};
			images[DecorationDandelion] = {'icon': Dandelion, 'x': 15, 'width': 35, 'height': 23, 'name': "Одуванчик", 'title': gls("Одуванчик")};
			images[DecorationWoodLog] = {'icon': WoodLog, 'x': 20, 'y': 20, 'width': 40, 'height': 25, 'name': "Бревно", 'title': gls("Бревно")};
			images[DecorationTwoStones] = {'icon': TwoStones, 'x': 24, 'y': 10, 'width': 48, 'height': 16, 'name': "Два камня", 'title': gls("Два камня")};

			images[SeaGrass] = {'icon': SeaGrassView, 'x': 10, 'y': 20, 'width': 26, 'height': 24, 'name': "Водоросли", 'title': gls("Водоросли")};
			images[PlatformSeaShore] = {'icon': SeaShore, 'width': 63 * 0.7, 'height': 45 * 0.7, 'name': "Галька", 'title': gls("Галька")};

			images[SpikePoise] = {'icon': SpikePoiseImage, 'title': gls("Шипастое ядро\nНаносит 2 ед. урона.")};
			images[SpikePoiseRespawn] = {'icon': SpikePoiseRespawnImage, 'name': "Точка возрождения шипастых ядер", 'title': gls("Точка возрождения шипастых ядер")};
			images[PlanetBody] = {'icon': Planet1, x: 15.7, y: 15.5, 'width': 31.5, 'height': 31, 'name': "Планета", 'title': gls("Планета")};
			images[Pusher] = {'icon': ArrowMovie, x: 8, 'width': 45, 'height': 30, 'name': "Направляющая силы", 'title': gls("Направляющая силы")};
			images[RectGravity] = {'icon': GravityCircle, 'width': 26, 'height': 26, 'name': "Зона гравитации", 'title': gls("Зона гравитации")};
			images[MedicKitRespawn] = {'icon': MedicKitImage, 'name': "Точка возрождения аптечек", 'title': gls("Точка возрождения аптечек")};
			images[BouncingPoise] = {'icon': BouncingPoiseImage, 'title': gls("Ядро-Попрыгушка\nОтскакивает от препятствий, наносит 2 ед. урона.")};
			images[GhostPoise] = {'icon': GhostPoiseFooterImage, 'title': gls("Ядро-Призрак\nПроходит сквозь препятствия, наносит 4 ед. урона.")};
			images[BouncingPoiseRespawn] = {'icon': BouncingPoiseRespawnImage, 'name': "Точка возрождения ядер-попрыгушек", 'title': gls("Точка возрождения ядер-попрыгушек")};
			images[GhostPoiseRespawn] = {'icon': GhostPoiseFooterImage, 'name': "Точка возрождения ядер-призраков", 'title': gls("Точка возрождения ядер-призраков")};
			images[GravityPoise] = {'icon': GravityPoiseImage, 'title': gls("Гравибомба\nПритягивает к себе всех белок в небольшом радиусе, наносит 3 ед. урона.")};
			images[GravityPoiseRespawn] = {'icon': GravityPoiseImage, 'name': "Точка возрождения гравибомб", 'title': gls("Точка возрождения гравибомб")};
			images[GrenadePoise] = {'icon': GrenadePoiseImage, 'title': gls("Фугас\nРазрывается на 8 осколков.\nОсколок наносит 1 ед. урона.\nПоражает союзников.")};
			images[GrenadePoiseRespawn] = {'icon': GrenadePoiseImage, 'name': "Точка возрождения фугасов", 'title': gls("Точка возрождения фугасов")};
			images[GrenadePartPoise] = {'icon': GrenadePoiseImage, 'name': "Осколок фугаса", 'title': gls("Осколок фугаса")};
			images[GodModeRespawn] = {'icon': GodModeImage, 'name': "Точка возрождения неуязвимости", 'title': gls("Точка возрождения неуязвимости")};
			images[ExtraDamageRespawn] = {'icon': ExtraDamageImage, 'name': "Точка возрождения супер-урона", 'title': gls("Точка возрождения супер-урона")};
			images[BurstBody] = {'icon': BombImage, 'name': "Хлопушка", 'title': gls("Хлопушка")};

			images[Tornado] = {'icon': TornadoView, x: 15, y: 15, 'width': 30, 'height': 30, 'name': "Вихрь", 'title': gls("Вихрь")};
			images[Quicksand] = {'icon': QuicksandIcon, 'width': 35, 'height': 35, 'name': "Зыбучий песок", 'title': gls("Зыбучий песок")};
			images[PlatformDesertSandBody] = {'icon': Sand,'width': 26, 'height': 26, 'name': "Песок пустыни", 'title': gls("Песок пустыни")};
			images[PlatformBlockBody] = {'icon': Block, x: -2, 'width': 41, 'height': 21, 'name': "Каменный блок", 'title': gls("Каменный блок")};
			images[Pyramid] = {'icon': PyramidView, x: 20, y: 10, 'width': 40, 'height': 20, 'name': "Пирамида", 'title': gls("Пирамида")};
			images[Ribs] = {'icon': RibsView, x: 24, y: 16, 'width': 48, 'height': 32, 'name': "Острые рёбра", 'title': gls("Острые рёбра")};
			images[DecorationDesertCloud1] = {'icon': DesertCloud1, x: 20, y: 10, 'width': 40, 'height': 20, 'name': "Облако 1", 'title': gls("Облако 1")};
			images[DecorationDesertCloud2] = {'icon': DesertCloud2, x: 20, y: 10, 'width': 40, 'height': 20, 'name': "Облако 2", 'title': gls("Облако 2")};
			images[DecorationCactus1] = {'icon': Cactus1, x: 9, y: 18, 'width': 18, 'height': 36, 'name': "Кактус 1", 'title': gls("Кактус 1")};
			images[DecorationCactus2] = {'icon': Cactus2, x: 9, y: 18, 'width': 18, 'height': 36, 'name': "Кактус 2", 'title': gls("Кактус 2")};
			images[DecorationSkull] = {'icon': Skull, x: 20, y: 12, 'width': 40, 'height': 25, 'name': "Череп", 'title': gls("Череп")};
			images[DecorationAmphora] = {'icon': Amphora, 'width': 16, 'height': 30, 'name': "Амфора", 'title': gls("Амфора")};
			images[DecorationStatue] = {'icon': Statue, x: 15, y: 15, 'width': 30, 'height': 30, 'name': "Статуя", 'title': gls("Статуя")};
			images[DecorationSarcophagus] = {'icon': Sarcophagus, x: 7, y: 18, 'width': 14, 'height': 35, 'name': "Саркофаг", 'title': gls("Саркофаг")};
			images[DecorationTorch] = {'icon': Torch, x: 17, y: 17, 'width': 34, 'height': 34, 'name': "Факел", 'title': gls("Факел")};
			images[DecorationFountain] = {'icon': FountainIcon, 'name': "Фонтанчик с водой", 'title': gls("Фонтанчик с водой")};

			images[HarpoonBodyBat] = {'icon': BatmanHarpoonView, 'x': 10, 'y': 10, 'name': "Гарпун", 'title': gls("Гарпун")};
			images[HarpoonBodyCat] = {'icon': CatwomanHarpoonView, 'x': 5, 'y': 15, 'name': "Гарпун", 'title': gls("Гарпун")};

			images[PlatformLiquidAcidBody] = {'icon': Acid, 'width': 26, 'height': 26, 'name': "Жидкая кислота", 'title': gls("Жидкая кислота")};

			images[Bouncer] = {'icon': BouncerView, x: 23, y: 8, 'width': 46, 'height': 16, 'name': "Трамплин", 'title': gls("Трамплин")};

			images[PlatformWoodenBlock] = {'icon': WoodenBlock, 'width': 41, 'height': 21, 'name': "Деревянный блок", 'title': gls("Деревянный блок")};
			images[PlatformMetalBlock] = {'icon': MetalBlock, 'width': 41, 'height': 21, 'name': "Металлический блок", 'title': gls("Металлический блок")};

			images[DecorationScrapMetal] = {'icon': ScrapMetal, 'width': 43, 'height': 22, 'x': 22, 'y': 11, 'name': "Металлолом", 'title': gls("Металлолом")};
			images[DecorationRobot] = {'icon': Robot, 'width': 28, 'height': 35, 'x': 15, 'y': 17,  'name': "Робот", 'title': gls("Робот")};
			images[DecorationPlasmaLamp1] = {'icon': PlasmaLamp1, 'width': 31, 'height': 30, 'x': 17, 'y': 11,  'name': "Плазменная лампа 1", 'title': gls("Плазменная лампа 1")};
			images[DecorationPlasmaLamp2] = {'icon': PlasmaLamp2, 'width': 25, 'height': 37, 'x': 15, 'y': 18,  'name': "Плазменная лампа 2", 'title': gls("Плазменная лампа 2")};

			images[Wheel] = {'icon': WheelImg, x: 15, y: 15, 'width': 30, 'height': 30, 'name': "Колесо", 'title': gls("Колесо")};
			images[BalanceWheel] = {'icon': WheelImg, 'name': "Колесо для равновесия", 'title': gls("Колесо для равновесия")};
			images[Vine] = {'icon': VineSegment, 'width': 10, 'height': 29, 'name': "Лоза", 'title': gls("Лоза")};
			images[Net] = {'icon': NetIcon, 'width': 35, 'height': 35, 'name': "Сетка", 'title': gls("Сетка")};

			images[PlatformTarBody] = {'icon': OilBlackIcon, 'width': 35, 'height': 20, 'x': 18, 'y': 10, 'name': "Чёрная смола", 'title': gls("Чёрная смола")};
			images[PlatformOilBody] = {'icon': OilIcon,'width': 35, 'height': 20, 'x': 18, 'y': 10, 'name': "Масло", 'title': gls("Масло")};

			images[BoostZone] = {'icon': BoostZoneImg, 'width': 48, 'height': 24, 'name': "Зона ускорения", 'title': gls("Зона ускорения")};

			images[BubblesEmitter] = {'icon': BubbleEmitterImg, 'width': 35, 'height': 10, 'x': 18, 'y': 10, 'name': "Генератор пузырей", 'title': gls("Генератор пузырей")};
			images[BubbleBody] = {'name': "Пузырь", 'title': gls("Пузырь")};

			images[Trap] = {'icon': TrapView, x: 20, y: 8, 'width': 40, 'height': 16, 'name': "Капкан", 'title': gls("Капкан")};
			images[Hammer] = {'icon': HammerView, 'name': "Молоток", 'title': gls("Молоток")};

			images[Bungee] = {'icon': BungeeIcon, 'width': 35.2, 'height': 32, 'name': "Тарзанка", 'title': gls("Тарзанка")};
			images[BungeeHarpoon] = {'icon': BungeeHarpoonIcon, 'name': "Гарпун стреляющий тарзанкой", 'title': gls("Гарпун стреляющий тарзанкой")};
			images[BungeeBullet] = {'name': "Тарзанка из гарпуна", 'title': gls("Тарзанка из гарпуна")};

			images[DecorationCrystal1] = {'icon': Crystal1, 'width': 17, 'height': 35, 'x': 9, 'y': 17, 'name': "Кристалл 1", 'title': gls("Кристалл 1")};
			images[DecorationCrystal2] = {'icon': Crystal2, 'width': 43, 'height': 22, 'x': 22, 'y': 11, 'name': "Кристалл 2", 'title': gls("Кристалл 2")};
			images[DecorationCrystal3] = {'icon': Crystal3, 'width': 22, 'height': 33, 'x': 10, 'y': 16, 'name': "Кристалл 3", 'title': gls("Кристалл 3")};
			images[DecorationGlassTree] = {'icon': GlassTree, 'width': 23, 'height': 35, 'x': 12, 'y': 18, 'name': "Стеклянное дерево", 'title': gls("Стеклянное дерево")};
			images[DecorationGlassUnicorn] = {'icon': GlassUnicorn, 'width': 19, 'height': 35, 'x': 12, 'y': 19, 'name': "Стеклянный единорог", 'title': gls("Стеклянный единорог")};

			images[BalkGlass] = {'icon': GlassBalkSmall, 'width': 27, 'height': 5, 'name': "Стеклянная палка", 'title': gls("Стеклянная палка")};
			images[BalkGlassLong] = {'icon': GlassBalkBig, 'width': 42, 'height': 5, 'name': "Длинная стеклянная палка", 'title': gls("Длинная стеклянная палка")};
			images[BoxGlass] = {'icon': GlassBox, 'width': 29, 'height': 29, 'name': "Стеклянный ящик", 'title': gls("Стеклянный ящик")};
			images[PlatformGlassBlock] = {'icon': GlassBlock, 'width': 41, 'height': 21, 'name': "Стеклянный блок", 'title': gls("Стеклянный блок")};

			images[Centrifuge] = {'icon': CentrifugeIcon, 'name': "Центрифуга", 'title': gls("Центрифуга")};
			images[CentrifugeDisc] = {'name': "Диск центрифуги", 'title': gls("Диск центрифуги")};

			images[NutsDisintegrator] = {'icon': Disintegrator, 'width': 35, 'height': 30, 'x': 18, 'y': 30, 'name': "Дезинтегратор орехов", 'title': gls("Дезинтегратор орехов")};
			images[StickyBall] = {'icon': StickyIcon, 'name': "Прилипала", 'title': gls("Прилипала")};
			images[HoppingBall] = {'icon': HoppingIcon, 'name': "Попрыгун", 'title': gls("Попрыгун")};
			images[Magnet] = {'icon': MagnetIcon, 'name': "Магнит", 'title': gls("Магнит")};

			images[HomingGun] = {'icon': HomingGunImg, 'width': 40, 'height': 32, 'x': 9, 'y': 18, 'name': "Самонаводящаяся пушка", 'title': gls("Самонаводящаяся пушка")};
			images[GunPoise] = {'icon':GunPoiseImg, 'name': "Снаряд", 'title': gls("Снаряд"), 'x': 11, 'y': 11};
			images[Conveyor] = {'icon': ConveyorView, 'width': 35, 'height': 10, 'x': 18, 'y': 7, 'name': "Конвейер", 'title': gls("Конвейер")};
			images[Hydrant] = {'icon': HydrantIcon, 'name': "Гидрант", 'title': gls("Гидрант")};

			images[BeamEmitter] = {'icon': BeamEmitterImg, 'width': 30, 'height': 12, 'x': 16, 'y': 7, 'name': "Излучатель", 'title': gls("Излучатель")};
			images[BeamReceiver] = {'icon': BeamEmitterImg, 'width': 30, 'height': 12, 'x': 16, 'y': 7, 'name': "Приёмник", 'title': gls("Приёмник")};

			images[AntimagicBody] = {'icon': AntimagicIcon, 'name': "Антимагическая субстанция", 'title': gls("Антимагическая субстанция")};
			images[MagicFlow] = {'icon': MagicFlowIcon, 'name': "Магический поток", 'title': gls("Магический поток")};

			images[OlympicCoin] = {'icon': OlympicCoinView, 'name': "Олимпийский жетон", 'title': gls("Олимпийский жетон"), 'x': 12, 'y': 12};

			images[StickyBomb] = {'icon': StickyBombImg, 'name': "Бомба-липучка", 'title': gls("Бомба-липучка"), 'x': 9, 'y': 9};
			images[SmokeBomb] = {'icon': SmokeBombImg, 'name': "Дымовая бомба", 'title': gls("Дымовая бомба"), 'x': 9, 'y': 9};

			images[JointSticky] = {'icon': StickyStart, 'name': "Липучка", 'title': gls("Липучка"), 'x': 10, 'y': 10};

			images[PlatformIceGroundBody] = {'icon': IceGroundMiddle, 'name': "Ледяная платформа", 'title': gls("Ледяная платформа"), 'width': 32, 'height': 32};
			images[RespawnPoint] = {'icon': RespawnPointView, 'name': "Точка возрождения", 'title': gls("Точка возрождения"), 'x': 16, 'y': 16};
			images[CollectionPoint] = {'icon': ButterflyImage1, 'width': 30, 'height': 30, 'name': "Точка коллекций", 'title': gls("Точка коллекций")};

			images[OneWayWildBalk] = {'icon': OneWayWildBalkImg, 'width': 40, 'height': 8, 'name': "Одностороняя дикая балка", 'title': gls("Одностороняя дикая балка")};

			images[PlatformGroundWildBody] = {'icon': PlatformGroundWild, 'width': 41, 'height': 29, 'name': "Дикая земля", 'title': gls("Земля")};
			images[PlatformSpikesWildBody] = {'icon': SpikesWild, 'width': 26, 'height': 26, 'name': "Дикие шипы", 'title': gls("Шипы")};
			images[ZombieBody] = {'icon': ZombieBodyImage, 'width': 26, 'height': 26, 'name': "Зомби", 'title': gls("Зомби")};

			images[DecorationWild0] = {'icon': WildDecorImage0, 'width': 27, 'height': 32, 'name': "Дикая декорация", 'title': gls("Дикая декорация")};
			images[DecorationWild1] = {'icon': WildDecorImage1, 'width': 35, 'height': 17, 'name': "Дикая декорация", 'title': gls("Дикая декорация")};
			images[DecorationWild2] = {'icon': WildDecorImage2, 'width': 36, 'height': 24, 'name': "Дикая декорация", 'title': gls("Дикая декорация")};
			images[DecorationWild3] = {'icon': WildDecorImage3, 'name': "Дикая декорация", 'title': gls("Дикая декорация")};
			images[DecorationWild4] = {'icon': WildDecorImage4, 'name': "Дикая декорация", 'title': gls("Дикая декорация")};

			images[IceBlock] = {'icon': IceBlockView0, 'name': "Ледяной блок", 'width': 32, 'height': 16, 'title': "Ледяной блок"};
			images[IceBlockGenerator] = {'icon': Sprite, 'name': "Генератор ледяных блоков", 'width': 40, 'height': 40, 'x': 20, 'y': 40, 'title': "Генератор ледяных блоков"};
			images[NYSnowGenerator] = {'icon': Sprite, 'name': "Куча снега", 'width': 40, 'height': 20, 'title': "Куча снега"};
			images[NYSnowReceiver] = {'icon': Sprite, 'name': "Остов снеговика", 'width': 40, 'height': 40, 'x': 20, 'y': 40, 'title': "Остов снеговика"};
			images[PlatformIceGroundBody] = {'icon': IceGroundMiddle, 'name': "Ледяная платформа", 'width': 32, 'height': 32, 'title': "Ледяная платформа"};

			images[Muffin] = {'icon': MuffinIcon, 'name': "Кексик", 'title': gls("Кексик"), 'x': 16, 'y': 16};
			images[SheepBomb] = {'icon': SheepBombView, 'name': "Зелье Полиморфа", 'title': gls("Зелье Полиморфа"), 'x': 6, 'y': 17};
			images[ShadowBomb] = {'icon': WitchBombView, 'name': "Эликсир Тени", 'title': gls("Эликсир Тени"), 'x': 9, 'y': 17};
		}

		static public function getImage(id:int):Class
		{
			var className:Class = getEntity(id);
			if (className == null)
				return null;
			return images[className]['image'];
		}

		static public function getByName(name:String):Class
		{
			for (var objClass:* in images)
			{
				if (images[objClass]['name'] != name)
					continue;
				return objClass;
			}
			return null;
		}

		static public function getName(object:*):String
		{
			var entity:Class = getEntity(getId(object));

			if (entity == null)
				return "";

			if (!images[entity] || !images[entity].name)
				return '';

			return images[entity].name;
		}

		static public function getTitle(object:*):String
		{
			var entity:Class = getEntity(getId(object));

			if (entity == null)
				return "";

			return images[entity]['title'];
		}

		static public function getIdByName(name:String):int
		{
			return getId(getByName(name));
		}

		static public function getIconByClass(className:Class):DisplayObject
		{
			var data:Object = images[className];

			var obj:* = new data['icon']();
			var image:DisplayObject = obj is BitmapData ? new Bitmap(obj) : obj;
			if (image is MovieClip)
				(image as MovieClip).gotoAndStop(0);
			if ("width" in data)
			{
				image.width = data['width'];
				image.height = data['height'];
			}
			if ("x" in data)
			{
				image.x = data['x'];
				image.y = data['y'];
			}
			if ("angle" in data)
				image.rotation = data['angle'];
			if ("scaleX" in data)
				image.scaleX = - image.scaleX;
			if ("alpha" in data)
				image.alpha = data['alpha'];
			return image;
		}

		static public function getEntity(id:int):Class
		{
			if (entityCollection[id] == null)
				return null;

			return entityCollection[id];
		}

		static public function getId(object:*):int
		{
			for (var id:int = 0, length:int = entityCollection.length; id < length; id++)
			{
				if (object is Class && object == entityCollection[id])
					return id;

				if (getQualifiedClassName(object) == getQualifiedClassName(entityCollection[id]))
					return id;
			}

			return -1;
		}

		static public function getItemByClass(className:Class):Object
		{
			return images[className];
		}
	}
}