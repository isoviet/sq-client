package game.mainGame.gameEditor
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import fl.controls.ComboBox;
	import fl.controls.RadioButton;

	import buttons.ButtonFooterTab;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import dialogs.DialogMapInfo;
	import game.mainGame.entity.battle.BouncingPoiseRespawn;
	import game.mainGame.entity.battle.ExtraDamageRespawn;
	import game.mainGame.entity.battle.GhostPoiseRespawn;
	import game.mainGame.entity.battle.GodModeRespawn;
	import game.mainGame.entity.battle.GravityPoiseRespawn;
	import game.mainGame.entity.battle.GrenadePoiseRespawn;
	import game.mainGame.entity.battle.MedicKitRespawn;
	import game.mainGame.entity.battle.SpikePoiseRespawn;
	import game.mainGame.entity.cast.BodyDestructor;
	import game.mainGame.entity.cast.DragTool;
	import game.mainGame.entity.cast.Hammer;
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
	import game.mainGame.entity.iceland.IceBlockGenerator;
	import game.mainGame.entity.iceland.NYSnowGenerator;
	import game.mainGame.entity.iceland.NYSnowReceiver;
	import game.mainGame.entity.joints.JointDistance;
	import game.mainGame.entity.joints.JointDrag;
	import game.mainGame.entity.joints.JointLinear;
	import game.mainGame.entity.joints.JointPrismatic;
	import game.mainGame.entity.joints.JointPulley;
	import game.mainGame.entity.joints.JointRope;
	import game.mainGame.entity.joints.JointToBody;
	import game.mainGame.entity.joints.JointToBodyFixed;
	import game.mainGame.entity.joints.JointToBodyMotor;
	import game.mainGame.entity.joints.JointToBodyMotorCCW;
	import game.mainGame.entity.joints.JointToWorld;
	import game.mainGame.entity.joints.JointToWorldFixed;
	import game.mainGame.entity.joints.JointToWorldMotor;
	import game.mainGame.entity.joints.JointToWorldMotorCCW;
	import game.mainGame.entity.joints.JointWeld;
	import game.mainGame.entity.quicksand.Quicksand;
	import game.mainGame.entity.simple.AcornBody;
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
	import game.mainGame.entity.simple.BoostZone;
	import game.mainGame.entity.simple.Bouncer;
	import game.mainGame.entity.simple.Box;
	import game.mainGame.entity.simple.BoxBig;
	import game.mainGame.entity.simple.BoxBigSteel;
	import game.mainGame.entity.simple.BoxGlass;
	import game.mainGame.entity.simple.BoxIce;
	import game.mainGame.entity.simple.BoxIceBig;
	import game.mainGame.entity.simple.BoxSteel;
	import game.mainGame.entity.simple.BubblesEmitter;
	import game.mainGame.entity.simple.Bungee;
	import game.mainGame.entity.simple.BungeeHarpoon;
	import game.mainGame.entity.simple.BurstBody;
	import game.mainGame.entity.simple.Centrifuge;
	import game.mainGame.entity.simple.Conveyor;
	import game.mainGame.entity.simple.FirCone;
	import game.mainGame.entity.simple.FirConeRight;
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
	import game.mainGame.entity.simple.PortalBlue;
	import game.mainGame.entity.simple.PortalBlueDirected;
	import game.mainGame.entity.simple.PortalRed;
	import game.mainGame.entity.simple.PortalRedDirected;
	import game.mainGame.entity.simple.RedHollowBody;
	import game.mainGame.entity.simple.SeaGrass;
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
	import sounds.GameSounds;
	import statuses.Status;
	import tape.TapeBackgrounds;
	import tape.TapeEdit;
	import tape.TapeHero;
	import tape.TapeJoints;
	import tape.TapePlatform;
	import tape.TapeShamaning;

	import com.greensock.TweenNano;

	import protocol.PacketServer;

	import utils.ArrayUtil;
	import utils.ComboBoxUtil;
	//import flash.text.TextFormat;

	public class EditorFooter extends Sprite
	{
		static public const FORMATS:Array = [new TextFormat(null, 12, 0xFFFFFF, true), new TextFormat(null, 12, 0xFFDD77, true), new TextFormat(null, 12, 0xFFCC33, true)];

		private var panels:Object = {};
		private var locations:ComboBox = new ComboBox();

		private var simpleObjectsButton:RadioButton = new RadioButton();
		private var mapButton:RadioButton = new RadioButton();

		private var tapeSprite:Sprite = new Sprite();
		private var platformsSprite:Sprite = new Sprite();
		private var objectsSprite:Sprite = new Sprite();
		private var fixingSprite:Sprite = new Sprite();
		private var sqShSprite:Sprite = new Sprite();
		private var decorationSprite:Sprite = new Sprite();
		private var fonsSprite:Sprite = new Sprite();
		private var forShamanSprite:Sprite = new Sprite();

		private var tabGroup:ButtonTabGroup;
		private var buttonPlatforms:ButtonTab;
		private var buttonObjects:ButtonTab;
		private var buttonFixing:ButtonTab;
		private var buttonCommon:ButtonTab;
		private var buttonDecoration:ButtonTab;
		private var buttonFons:ButtonTab;
		private var buttonShaman:ButtonTab;

		private var currentPanel:String = "platformsIslands";

		public var heroTape:TapeHero;
		public var heroBattleTape:TapeHero;
		public var heroTwoShamansTape:TapeHero;
		public var heroSurvivalTape:TapeHero;
		public var heroZombieTape:TapeHero;
		public var heroVolcanoTape:TapeHero;
		public var heroAllTape:TapeHero;

		public var jointsTape:TapeJoints;
		public var jointsAnomalTape:TapeJoints;
		public var jointsStormTape:TapeJoints;

		public var shamaningTape:TapeShamaning;
		public var shamaningTapeCrazedShaman:TapeShamaning;

		public var tapesDecorations:Object = {};
		public var tapesPlatforms:Object = {};
		public var tapesObjects:Object = {};
		public var tapesFonts:Object = {};

		public var minimize:Boolean = false;

		public var buttonMinimize:FooterMinimize = null;
		public var buttonMaximize:FooterMaximize = null;

		public var backgroundFooter:DisplayObject = null;

		public function EditorFooter():void
		{
			this.backgroundFooter = new ImageFooterEditor();
			this.backgroundFooter.y = Config.GAME_HEIGHT - this.backgroundFooter.height;
			addChild(this.backgroundFooter);

			this.tabGroup = new ButtonTabGroup();
			addChild(this.tabGroup);

			this.buttonPlatforms = new ButtonTab(new ButtonFooterTab(gls("Платформы"), FORMATS));
			this.buttonPlatforms.addEventListener(MouseEvent.CLICK, openPlatforms);
			this.tabGroup.insert(this.buttonPlatforms, this.platformsSprite);

			this.buttonObjects = new ButtonTab(new ButtonFooterTab(gls("Объекты"), FORMATS));
			this.buttonObjects.addEventListener(MouseEvent.CLICK, openObjects);
			this.tabGroup.insert(this.buttonObjects, this.objectsSprite);

			this.buttonFixing = new ButtonTab(new ButtonFooterTab(gls("Крепления"), FORMATS));
			this.buttonFixing.addEventListener(MouseEvent.CLICK, openFixing);
			this.tabGroup.insert(this.buttonFixing, this.fixingSprite);

			this.buttonCommon = new ButtonTab(new ButtonFooterTab(gls("Основное"), FORMATS));
			this.buttonCommon.addEventListener(MouseEvent.CLICK, openSqSh);
			this.tabGroup.insert(this.buttonCommon, this.sqShSprite);

			this.buttonDecoration = new ButtonTab(new ButtonFooterTab(gls("Декорации"), FORMATS));
			this.buttonDecoration.addEventListener(MouseEvent.CLICK, openDecoration);
			this.tabGroup.insert(this.buttonDecoration, this.decorationSprite);

			this.buttonFons = new ButtonTab(new ButtonFooterTab(gls("Фоны"), FORMATS));
			this.buttonFons.addEventListener(MouseEvent.CLICK, openFons);
			this.tabGroup.insert(this.buttonFons, this.fonsSprite);

			this.buttonShaman = new ButtonTab(new ButtonFooterTab(gls("Для шамана"), FORMATS));
			this.buttonShaman.addEventListener(MouseEvent.CLICK, openForShaman);
			this.tabGroup.insert(this.buttonShaman, this.forShamanSprite);

			var offset:int = 45;
			for (var i:int = 0; i < this.tabGroup.tabs.length; i++)
			{
				this.tabGroup.tabs[i].x = offset;
				this.tabGroup.tabs[i].y = this.backgroundFooter.y - this.tabGroup.tabs[i].height + 2;
				offset += this.tabGroup.tabs[i].width + 5;
			}

			this.buttonMinimize = new FooterMinimize();
			this.buttonMinimize.x = 870;
			this.buttonMinimize.y = 510;
			this.buttonMinimize.addEventListener(MouseEvent.CLICK, onMinimize);
			new Status(this.buttonMinimize, gls("Свернуть"));
			addChild(this.buttonMinimize);

			this.buttonMaximize = new FooterMaximize();
			this.buttonMaximize.x = 870;
			this.buttonMaximize.y = 510;
			this.buttonMaximize.visible = false;
			this.buttonMaximize.addEventListener(MouseEvent.CLICK, onMinimize);
			new Status(this.buttonMaximize, gls("Развернуть"));
			addChild(this.buttonMaximize);

			this.tapeSprite.y = -5;
			this.tapeSprite.addChild(this.platformsSprite);
			this.tapeSprite.addChild(this.objectsSprite);
			this.tapeSprite.addChild(this.fixingSprite);
			this.tapeSprite.addChild(this.sqShSprite);
			this.tapeSprite.addChild(this.decorationSprite);
			this.tapeSprite.addChild(this.fonsSprite);
			this.tapeSprite.addChild(this.forShamanSprite);
			addChild(this.tapeSprite);

			initPanels();
			initTapes();
			initLocations();

			this.tabGroup.setSelected(this.buttonPlatforms);
		}

		static private function get platformLocations():Array
		{
			return [Locations.ISLAND_ID, Locations.SWAMP_ID, Locations.DESERT_ID, Locations.ANOMAL_ID, Locations.HARD_ID, Locations.BATTLE_ID, Locations.STORM_ID, Locations.WILD_ID, "all"];
		}

		static private function get objectLocations():Array
		{
			return [Locations.ISLAND_ID, Locations.SWAMP_ID, Locations.DESERT_ID, Locations.ANOMAL_ID, Locations.HARD_ID, Locations.BATTLE_ID, Locations.STORM_ID, Locations.WILD_ID, "all"];
		}

		static private function get decorationLocations():Array
		{
			return [Locations.ISLAND_ID, Locations.SWAMP_ID, Locations.DESERT_ID, Locations.ANOMAL_ID, Locations.STORM_ID, Locations.WILD_ID, "all"];
		}

		static private function get backgroundsLocations():Array
		{
			return [Locations.ISLAND_ID, Locations.SWAMP_ID, Locations.DESERT_ID, Locations.ANOMAL_ID, Locations.HARD_ID, "all"];
		}

		public function loadShamaningTape(shamanObjectsIds:Array):void
		{
			this.shamaningTapeCrazedShaman.load(shamanObjectsIds);
			this.shamaningTape.load(shamanObjectsIds);
		}

		public function get currentShamaningTape():TapeShamaning
		{
			if (DialogMapInfo.mode == Locations.BLACK_SHAMAN_MODE)
				return this.shamaningTapeCrazedShaman;
			else
				return this.shamaningTape;
		}

		public function isOpen(name:String):Boolean
		{
			return this.panels[name].visible;
		}

		public function reset():void
		{
			togglePanelButtons(true);
		}

		public function onNew():void
		{
			toggleByEditorRules();

			this.shamaningTape.reset();
			this.shamaningTapeCrazedShaman.reset();

			this.visible = true;
			this.simpleObjectsButton.selected = true;

			if (Game.editor_access == PacketServer.EDITOR_FULL || Game.editor_access == PacketServer.EDITOR_SUPER)
				openForShaman();
			else
				openPlatforms();
		}

		public function onOpen(location:int, map:int):void
		{
			if (map) {/*unused*/}

			toggleByEditorRules();

			ComboBoxUtil.selectValue(this.locations, location);

			this.visible = true;

			if (Game.editor_access == PacketServer.EDITOR_FULL || Game.editor_access == PacketServer.EDITOR_SUPER)
				openForShaman();
			else
				openPlatforms();
		}

		public function onReloadMap(tapeElements:Array):void
		{
			this.visible = true;

			this.heroTape.visible = true;

			openForShaman();

			this.mapButton.selected = true;

			loadShamaningTape(tapeElements);
		}

		public function visibleButtons(value:Boolean):void
		{
			if (!value)
			{
				for each (var panel:Sprite in this.panels)
				{
					if (panel.visible)
						this.currentPanel = panel.name;
				}
			}
			else
				showPanelByName(this.currentPanel);

			this.buttonPlatforms.visible = value;
			this.buttonObjects.visible = value;
			this.buttonFixing.visible = value;
			this.buttonCommon.visible = value;
			this.buttonDecoration.visible = value;
			this.buttonFons.visible = value;
			this.buttonShaman.visible = value;
		}

		public function get location():int
		{
			return this.locations.selectedItem['value'];
		}

		public function dispose():void
		{
			this.locations.removeEventListener(MouseEvent.CLICK, soundClick);
			this.locations.removeEventListener(MouseEvent.ROLL_OVER, soundOver);
			this.locations.removeEventListener(Event.CHANGE, soundClick);
		}

		public function openObjects(e:Event = null):void
		{
			var tapeName:String = "objects_" + (DialogMapInfo.location in tapesObjects ? DialogMapInfo.location : "all");
			showPanelByName(tapeName);

			this.tabGroup.setSelected(this.buttonObjects);
		}

		public function openPlatforms(e:Event = null):void
		{
			var tapeName:String = "platforms_" + (DialogMapInfo.location in tapesPlatforms ? DialogMapInfo.location : "all");
			showPanelByName(tapeName);

			this.tabGroup.setSelected(this.buttonPlatforms);
		}

		public function openForShaman(e:Event = null):void
		{
			this.tabGroup.setSelected(this.buttonShaman);

			if (DialogMapInfo.mode == Locations.BLACK_SHAMAN_MODE)
				showPanelByName("shamanTwoShamans");
			else
				showPanelByName("shaman");
		}

		public function openDecoration(e:Event = null):void
		{
			var tapeName:String = "decorations_" + (DialogMapInfo.location in tapesDecorations ? DialogMapInfo.location : "all");
			showPanelByName(tapeName);

			this.tabGroup.setSelected(this.buttonDecoration);
		}

		public function openFons(e:Event = null):void
		{
			var tapeName:String = "background_" + (DialogMapInfo.location in tapesFonts ? DialogMapInfo.location : "all");
			showPanelByName(tapeName);

			this.tabGroup.setSelected(this.buttonFons);
		}

		public function openFixing(e:Event = null):void
		{
			this.tabGroup.setSelected(this.buttonFixing);

			if ((DialogMapInfo.mode == Locations.FLY_NUT_MODE) || (DialogMapInfo.location == Locations.DESERT_ID))
			{
				showPanelByName("jointsStorm");
				return;
			}

			switch (DialogMapInfo.location)
			{
				case Locations.ANOMAL_ID:
				case Locations.APPROVED_ID:
				case Locations.NONAME_ID:
				case Locations.HARD_ID:
				case Locations.TENDER:
					showPanelByName("jointsAnomal");
					break;
				default:
					showPanelByName("joints");
					break;
			}
		}

		public function openSqSh(e:Event = null):void
		{
			this.tabGroup.setSelected(this.buttonCommon);

			switch (DialogMapInfo.mode)
			{
				case Locations.TWO_SHAMANS_MODE:
					showPanelByName("heroObjectsTwoShamans");
					return;
				case Locations.BLACK_SHAMAN_MODE:
					showPanelByName("heroObjectsSurvival");
					return;
				case Locations.ZOMBIE_MODE:
					showPanelByName("heroObjectsZombie");
					return;
				case Locations.VOLCANO_MODE:
					showPanelByName("heroObjectsVolcano");
					return;
			}

			switch (DialogMapInfo.location)
			{
				case Locations.BATTLE_ID:
				case Locations.TENDER:
					showPanelByName("heroObjectsBattle");
					break;
				case Locations.APPROVED_ID:
				case Locations.NONAME_ID:
					showPanelByName("heroObjectsAll");
					break;
				default:
					showPanelByName("heroObjects");
					break;
			}
		}

		private function onMinimize(e:MouseEvent):void
		{
			if (!this.minimize)
			{
				TweenNano.to(this.backgroundFooter, 0.5, {y: Config.GAME_HEIGHT});
				TweenNano.to(this.buttonMinimize, 0.5, {y: 605});
				TweenNano.to(this.buttonMaximize, 0.5, {y: 605});
				TweenNano.to(this.tabGroup, 0.5, {y: 120});
				TweenNano.to(this.tapeSprite, 0.5, {y: 90});
				this.buttonMinimize.visible = false;
				this.buttonMaximize.visible = true;
				this.minimize = true;
			}
			else
			{
				TweenNano.to(this.backgroundFooter, 0.5, {y: Config.GAME_HEIGHT - this.backgroundFooter.height});
				TweenNano.to(this.buttonMinimize, 0.5, {y: 510});
				TweenNano.to(this.buttonMaximize, 0.5, {y: 510});
				TweenNano.to(this.tabGroup, 0.5, {y: 0});
				TweenNano.to(this.tapeSprite, 0.5, {y: -5});
				this.buttonMinimize.visible = true;
				this.buttonMaximize.visible = false;
				this.minimize = false;
			}
		}

		private function initPanels():void
		{
			for (var i:int = 0; i < platformLocations.length; i++)
				createPanelSprite("platforms_" + platformLocations[i], this.platformsSprite);

			for (i = 0; i < objectLocations.length; i++)
				createPanelSprite("objects_" + objectLocations[i], this.objectsSprite);

			for (i = 0; i < decorationLocations.length; i++)
				createPanelSprite("decorations_" + decorationLocations[i], this.decorationSprite);

			for (i = 0; i < backgroundsLocations.length; i++)
				createPanelSprite("background_" + backgroundsLocations[i], this.fonsSprite);

			createPanelSprite("heroObjects", this.sqShSprite);
			createPanelSprite("heroObjectsBattle", this.sqShSprite);
			createPanelSprite("heroObjectsTwoShamans", this.sqShSprite);
			createPanelSprite("heroObjectsSurvival", this.sqShSprite);
			createPanelSprite("heroObjectsZombie", this.sqShSprite);
			createPanelSprite("heroObjectsVolcano", this.sqShSprite);
			createPanelSprite("heroObjectsAll", this.sqShSprite);

			createPanelSprite("joints", this.fixingSprite);
			createPanelSprite("jointsAnomal", this.fixingSprite);
			createPanelSprite("jointsStorm", this.fixingSprite);

			createPanelSprite("shaman", this.forShamanSprite);
			createPanelSprite("shamanTwoShamans", this.forShamanSprite);

			createPanelSprite("custom", this.fonsSprite);
			createPanelSprite("map", this.platformsSprite);
		}

		private function createPanelSprite(name:String, owner:DisplayObjectContainer):void
		{
			this.panels[name] = new Sprite();
			this.panels[name].y = Game.ROOM_HEIGHT;
			this.panels[name].name = name;
			this.panels[name].visible = false;
			owner.addChild(this.panels[name]);
		}

		private function initTapes():void
		{
			var backgroundData:Object = {};
			backgroundData[Locations.ISLAND_ID] = ["Background7", "Background6", "Background5", "Background4", "Background3", "Background2", "Background1", "Background0", "MountainsBackground1"];
			backgroundData[Locations.SWAMP_ID] = ["PineryBackground2", "PineryBackground1", "SeaBackGround4", "SeaBackGround3", "SeaBackGround2", "SeaBackGround1"];
			backgroundData[Locations.DESERT_ID] = ["DesertBackground4", "DesertBackground3", "DesertBackground2", "DesertBackground1"];
			backgroundData[Locations.ANOMAL_ID] = ["Background8", "AnomalBackground3", "AnomalBackground2", "AnomalBackground1"];
			backgroundData[Locations.HARD_ID] = ["Background7", "Background6", "Background5", "Background4", "Background3", "Background2", "Background1", "Background0"];
			//backgroundData[Locations.ISLAND_ID] = ["IcelandBackground"];

			var backgrounds:Array = [];
			for (var i:int = 0; i < backgroundsLocations.length - 1; i++)
				backgrounds = backgrounds.concat(backgroundData[backgroundsLocations[i]]);

			backgroundData["all"] = ArrayUtil.valuesToUnic(backgrounds);
			for (i = 0; i < backgroundsLocations.length; i++)
			{
				var tapeFont:TapeBackgrounds = new TapeBackgrounds(backgroundData[backgroundsLocations[i]]);
				tapeFont.x = 5;
				this.tapesFonts[backgroundsLocations[i]] = tapeFont;
				this.panels['background_' + backgroundsLocations[i]].addChild(tapeFont);
			}

			var heroCollection:Array = [];
			if (Game.editor_access != PacketServer.EDITOR_NONE)
				heroCollection.push(IceBlockGenerator, NYSnowGenerator, NYSnowReceiver, OlympicCoin, HintArrowObject, Helper, HelperLearning);
			if (Game.editor_access == PacketServer.EDITOR_FULL)
				heroCollection.push(RespawnPoint, CollectionPoint);

			heroCollection.push(ShamanBody, SquirrelBody, HollowBody, AcornBody, Sensor, SensorRect, ScriptedTimer, ButtonSensor, ClickButton);
			this.heroTape = new TapeHero(heroCollection);
			this.heroTape.x = 5;
			this.panels['heroObjects'].addChild(this.heroTape);

			var heroCollectionBattle:Array = [Sensor, SensorRect, ScriptedTimer, ButtonSensor, ClickButton, MedicKitRespawn, GodModeRespawn, ExtraDamageRespawn, SpikePoiseRespawn, BouncingPoiseRespawn, GhostPoiseRespawn, GravityPoiseRespawn, GrenadePoiseRespawn, RedShamanBody, ShamanBody, RedTeamBody, BlueTeamBody];
			this.heroBattleTape = new TapeHero(heroCollectionBattle);
			this.heroBattleTape.x = 5;
			this.panels['heroObjectsBattle'].addChild(this.heroBattleTape);

			var heroCollectionTwoShamans:Array = [Sensor, SensorRect, ScriptedTimer, ButtonSensor, ClickButton, RedShamanBody, ShamanBody, SquirrelBody, BlueHollowBody, RedHollowBody, AcornBody];
			this.heroTwoShamansTape = new TapeHero(heroCollectionTwoShamans);
			this.heroTwoShamansTape.x = 5;
			this.panels['heroObjectsTwoShamans'].addChild(this.heroTwoShamansTape);

			var heroCollectionSurvival:Array = [Sensor, SensorRect, ScriptedTimer, ButtonSensor, ClickButton, BlackShamanBody, SquirrelBody];
			this.heroSurvivalTape = new TapeHero(heroCollectionSurvival);
			this.heroSurvivalTape.x = 5;
			this.panels['heroObjectsSurvival'].addChild(this.heroSurvivalTape);

			var heroCollectionZombie:Array = [ZombieBody, SquirrelBody];
			this.heroZombieTape = new TapeHero(heroCollectionZombie);
			this.heroZombieTape.x = 5;
			this.panels['heroObjectsZombie'].addChild(this.heroZombieTape);

			var heroCollectionVolcano:Array = [SquirrelBody];
			this.heroVolcanoTape = new TapeHero(heroCollectionVolcano);
			this.heroVolcanoTape.x = 5;
			this.panels['heroObjectsVolcano'].addChild(this.heroVolcanoTape);

			var heroCollectionAll:Array = heroCollection.concat(heroCollectionBattle);
			this.heroAllTape = new TapeHero(ArrayUtil.valuesToUnic(heroCollectionAll));
			this.heroAllTape.x = 5;
			this.panels['heroObjectsAll'].addChild(this.heroAllTape);

			var shamaningCollection:Array = [Stone, Bouncer, Trampoline, Box, BoxBig, Balk, BalkLong, PortalBlue, PortalBlueDirected, PortalRed, PortalRedDirected, Poise, PoiseRight, FirCone, FirConeRight, GunPoise, WeightBody, BalkIce, BalkIceLong, BoxIce, BoxIceBig, JointToWorld, JointToWorldFixed, DragTool, BurstBody, BodyDestructor, Hammer, BoxSteel, BoxBigSteel, BalkSteel, BalkLongSteel];
			shamaningCollection = [BalloonBody].concat(shamaningCollection).concat([JointToBodyMotor, JointToBodyMotorCCW, JointToWorldMotor, JointToWorldMotorCCW, JointToBody, JointToBodyFixed]);
			this.shamaningTape = new TapeShamaning(shamaningCollection);
			this.shamaningTape.x = 5;
			this.panels['shaman'].addChild(this.shamaningTape);

			shamaningCollection = [Stone, Bouncer, Trampoline, Box, BoxBig, Balk, BalkLong, PortalBlue, PortalBlueDirected, PortalRed, PortalRedDirected, Poise, PoiseRight, PoiseInvisible, PoiseInvisibleRight, FirCone, FirConeRight, GunPoise, WeightBody, BalkIce, BalkIceLong, BoxIce, BoxIceBig, JointToWorld, JointToWorldFixed, DragTool, BurstBody, BodyDestructor, Hammer, BoxSteel, BoxBigSteel, BalkSteel, BalkLongSteel];
			shamaningCollection = [BalloonBody].concat(shamaningCollection).concat([JointToBodyMotor, JointToBodyMotorCCW, JointToWorldMotor, JointToWorldMotorCCW, JointToBody, JointToBodyFixed]);
			this.shamaningTapeCrazedShaman = new TapeShamaning(shamaningCollection);
			this.shamaningTapeCrazedShaman.x = 5;
			this.panels['shamanTwoShamans'].addChild(this.shamaningTapeCrazedShaman);

			var objectData:Object = {};
			objectData[Locations.ISLAND_ID] = [BalloonBody, Balk, BalkLong, Box, BoxBig, BalkIce, BalkIceLong, BoxIce, BoxIceBig,PortalRed, PortalRedDirected, PortalBlue, PortalBlueDirected, Trampoline, Bouncer, Stone];
			objectData[Locations.SWAMP_ID] = [BalloonBody, Holes, Vine, SeaGrass, Balk, BalkLong, Box, BoxBig, PortalRed, PortalRedDirected, PortalBlue, PortalBlueDirected, WeightBody, Trampoline, Bouncer, Stone];
			objectData[Locations.DESERT_ID] = [PoiseRight, Poise, BalloonBody, Tornado, DecorationFountain, Balk, BalkLong, Box, BoxBig, PortalRed, PortalRedDirected, PortalBlue, PortalBlueDirected, WeightBody, Trampoline, Bouncer, Net, Bungee, Holes, Stone];
			objectData[Locations.ANOMAL_ID] = [PoiseRight, Poise, BalloonBody, Centrifuge, BeamReceiver, BeamEmitter, Holes, HomingGun, StickyBall, HoppingBall, Magnet, BalkLongSteel, BalkSteel, BoxBigSteel, BoxSteel, PlanetBody, RectGravity, Trampoline, Bouncer, PortalRed, PortalRedDirected, PortalBlue, PortalBlueDirected, WeightBody, Wheel, Net, BoostZone, BubblesEmitter, Trap, Bungee, BungeeHarpoon, BalkGlass, BalkGlassLong, BoxGlass, NutsDisintegrator, Conveyor, Hydrant, Stone];
			objectData[Locations.HARD_ID] = [PoiseRight, Poise, BalloonBody, Centrifuge, BeamReceiver, BeamEmitter, Holes, HomingGun, StickyBall, HoppingBall, Magnet, Trampoline, Stone, Bouncer, PortalRed, PortalRedDirected, PortalBlue, PortalBlueDirected, Balk, BalkLong, Box, BoxBig, WeightBody, Wheel, Net, BoostZone, BubblesEmitter, Trap, Bungee, BungeeHarpoon, BalkGlass, BalkGlassLong, BoxGlass, NutsDisintegrator, Conveyor, Hydrant, Stone];
			objectData[Locations.BATTLE_ID] = [Holes, Trampoline, Bouncer, PortalRed, PortalRedDirected, PortalBlue, PortalBlueDirected, Balk, BalkLong, Box, BoxBig, Net, BalkLongSteel, BalkSteel, BoxBigSteel, BoxSteel];
			objectData[Locations.STORM_ID] = [PoiseRight, Poise, BalloonBody, BeamReceiver, BeamEmitter, StickyBall, HoppingBall, Magnet, Trampoline, Bouncer, PortalRed, PortalRedDirected, PortalBlue, PortalBlueDirected, Balk, BalkLong, Box, BoxBig, WeightBody, Wheel, Net, BoostZone, BubblesEmitter, Trap, Bungee, BalkGlass, BalkGlassLong, BoxGlass, NutsDisintegrator, Stone];
			objectData[Locations.WILD_ID] = [Box, BoxBig, Balk, BalkLong, PortalRed, PortalRedDirected, PortalBlue, PortalBlueDirected, Stone, Holes, Trampoline, Bouncer, WeightBody, Net, Bungee, Vine, OneWayWildBalk];

			var objectsAll:Array = [];

			for (i = 0; i < objectLocations.length - 1; i++)
				objectsAll = objectsAll.concat(objectData[objectLocations[i]]);
			objectData["all"] = ArrayUtil.valuesToUnic(objectsAll);
			for (i = 0; i < objectLocations.length; i++)
			{
				var tapeObject:TapeEdit = new TapeEdit(objectData[objectLocations[i]]);
				tapeObject.x = 5;
				this.tapesObjects[objectLocations[i]] = tapeObject;
				this.panels['objects_' + objectLocations[i]].addChild(tapeObject);
			}

			var decorationData:Object = {};
			decorationData[Locations.ISLAND_ID] = [DecorationSnowman, DecorationFirTreeSnow, DecorationIceTree, DecorationHedgehogIce, DecorationFirTreeSnowed, DecorationDandelion, DecorationHedgehog, DecorationFern, DecorationTwoStones, DecorationSingleStone, DecorationEagle, DecorationWoodLog, DecorationPine, SunflowerBody, TreeBody, DecorationOwl, DecorationFirTree, DecorationBush, DecorationCloud, DecorationMushrooms, DecorationAppleTree];
			decorationData[Locations.SWAMP_ID] = [DecorationOctopus, DecorationYellowFish, DecorationPinkFish, DecorationPinguin, DecorationTwoStones, DecorationSingleStone, DecorationWoodLog, DecorationPine, SunflowerBody, TreeBody, DecorationMushrooms, DecorationBush];
			decorationData[Locations.DESERT_ID] = [DecorationStatue, DecorationSarcophagus, DecorationTorch, DecorationAmphora, DecorationDesertCloud1, DecorationDesertCloud2, DecorationCactus1, DecorationCactus2, DecorationSkull, SunflowerBody];
			decorationData[Locations.ANOMAL_ID] = [DecorationGlassUnicorn, DecorationGlassTree, DecorationCrystal3, DecorationCrystal2, DecorationCrystal1, DecorationRobot, DecorationScrapMetal, DecorationPlasmaLamp1, DecorationPlasmaLamp2, SunflowerBody];
			decorationData[Locations.STORM_ID] = [DecorationOctopus, DecorationPalmTree, DecorationYellowFish, DecorationPinkFish, DecorationPinguin, DecorationDandelion, DecorationHedgehog, DecorationFern, DecorationTwoStones, DecorationSingleStone, DecorationEagle, DecorationWoodLog, DecorationPine, SunflowerBody, TreeBody, DecorationOwl, DecorationFirTree, DecorationFirTreeSnowed, DecorationBush, DecorationCloud, DecorationMushrooms, DecorationAppleTree];
			decorationData[Locations.WILD_ID] = [DecorationWild0, DecorationWild1, DecorationWild2, DecorationWild3, DecorationWild4];
			var decorationAll:Array = [];
			for (i = 0; i < decorationLocations.length - 1; i++)
				decorationAll = decorationAll.concat(decorationData[decorationLocations[i]]);
			decorationData['all'] = ArrayUtil.valuesToUnic(decorationAll);
			for (i = 0; i < decorationLocations.length; i++)
			{
				var tapeDecoration:TapeEdit = new TapeEdit(decorationData[decorationLocations[i]]);
				tapeDecoration.x = 5;
				this.tapesDecorations[decorationLocations[i]] = tapeDecoration;
				this.panels['decorations_' + decorationLocations[i]].addChild(tapeDecoration);
			}

			var platformData:Object = {};
			platformData[Locations.ISLAND_ID] = [PlatformIceGroundBody,  Mount, MountIce, MountSliced, CoverIce, IslandLessSmall, IslandSmall, IslandMedium, IslandBig, PlatformBridgeBody, PlatformGroundBody, PlatformHerbBody];
			platformData[Locations.SWAMP_ID] = [PlatformGroundBody, PlatformHerbBody, PlatformSwampBody, PlatformBridgeBody, Trunk, Branch, PlatformOilBody, PlatformTarBody, PlatformAcidBody, PlatformLiquidAcidBody, Water];
			platformData[Locations.DESERT_ID] = [PlatformBlockBody, PlatformSandBody, PlatformDesertSandBody, PlatformOilBody, PlatformTarBody, Pyramid, Quicksand, Water, Ribs];
			platformData[Locations.ANOMAL_ID] = [PlatformMetalBlock, PlatformGlassBlock, PlatformLavaBody, PlatformOilBody, PlatformTarBody, PlatformSpaceShipPiece, PlatformAcidBody, PlatformLiquidAcidBody, PlatformSpikesBody, Water, PlatformGroundBody, PlatformHerbBody, PlatformSandBody];
			platformData[Locations.STORM_ID] = [PlatformHerbBody, PlatformGroundBody, PlatformWoodenBlock, PlatformSandBody, PlatformLavaBody, PlatformSpikesBody, PlatformAcidBody, PlatformLiquidAcidBody, PlatformGlassBlock, PlatformOilBody, PlatformTarBody, Water, PlatformBridgeBody];
			platformData[Locations.HARD_ID] = [PlatformHerbBody, PlatformGroundBody, PlatformWoodenBlock, PlatformSandBody, PlatformLavaBody, Mount, MountIce, MountSliced, PlatformGlassBlock, PlatformOilBody, PlatformTarBody, Water, PlatformBridgeBody, PlatformSpikesWildBody, PlatformAcidBody];
			platformData[Locations.BATTLE_ID] = [PlatformHerbBody, PlatformGroundBody, PlatformWoodenBlock, PlatformSandBody, PlatformBridgeBody, Mount, MountSliced, PlatformSpaceShipPiece, PlatformMetalBlock];
			platformData[Locations.WILD_ID] = [PlatformWoodenBlock, PlatformLavaBody, Water, PlatformGroundWildBody, PlatformSpikesWildBody];
			var platformsAll:Array = [];
			for (i = 0; i < platformLocations.length - 1; i++)
				platformsAll = platformsAll.concat(platformData[platformLocations[i]]);
			platformData['all'] = ArrayUtil.valuesToUnic(platformsAll);
			for (i = 0; i < platformLocations.length; i++)
			{
				var tapePlatform:TapePlatform = new TapePlatform(platformData[platformLocations[i]]);
				tapePlatform.x = 5;
				tapePlatform.y = 1;
				this.tapesPlatforms[objectLocations[i]] = tapePlatform;
				this.panels['platforms_' + platformLocations[i]].addChild(tapePlatform);
			}

			var jointsCollection:Array = [JointToWorldFixed, JointToWorld, JointToBodyFixed, JointToBody, JointToBodyMotor, JointToBodyMotorCCW, JointToWorldMotor, JointToWorldMotorCCW, JointDistance, JointPulley, JointWeld, JointRope, JointPrismatic, JointLinear];
			if (Game.editor_access == PacketServer.EDITOR_FULL)
				jointsCollection.push(Pusher);
			this.jointsTape = new TapeJoints(jointsCollection);
			this.jointsTape.x = 5;
			this.panels['joints'].addChild(this.jointsTape);

			jointsCollection = [JointDrag, JointToWorldFixed, JointToWorld, JointToBodyFixed, JointToBody, JointToBodyMotor, JointToBodyMotorCCW, JointToWorldMotor, JointToWorldMotorCCW, JointDistance, JointPulley, JointWeld, JointRope, JointPrismatic, JointLinear];
			if (Game.editor_access == PacketServer.EDITOR_FULL)
				jointsCollection.push(Pusher);
			this.jointsAnomalTape = new TapeJoints(jointsCollection);
			this.jointsAnomalTape.x = 5;
			this.panels['jointsAnomal'].addChild(this.jointsAnomalTape);

			this.jointsStormTape = new TapeJoints(jointsCollection.concat([FlyWayPoint]));
			this.jointsStormTape.x = 5;
			this.panels['jointsStorm'].addChild(this.jointsStormTape);
		}

		private function showPanelByName(name:String):void
		{
			for each (var panel:Sprite in this.panels)
				panel.visible = false;

			this.panels[name].visible = true;
		}

		private function initLocations():void
		{
			//var format:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 11, 0x000000);

			this.locations.x = 167;
			this.locations.y = 10;
			this.locations.width = 130;
			this.locations.height = 17;
			this.locations.addEventListener(MouseEvent.CLICK, soundClick, false, 0, true);
			this.locations.addEventListener(MouseEvent.ROLL_OVER, soundOver, false, 0, true);
			this.locations.addEventListener(Event.CHANGE, changeLocation, false, 0, true);
			//ComboBoxUtil.style(this.locations, format, format);
			this.panels['map'].addChild(this.locations);
		}

		private function toggleByEditorRules():void
		{}

		private function togglePanelButtons(value:Boolean):void
		{
			if (value)
			{
				this.mapButton.selected = value;
				return;
			}

			currentShamaningTape.visible = false;
		}

		private function changeLocation(e:Event):void
		{
			soundClick(e);
		}

		private function soundClick(e:Event):void
		{
			GameSounds.play("click");
		}

		private function soundOver(e:Event):void
		{

		}
	}
}