package footers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	import buttons.ButtonLockable;
	import dialogs.DialogInfo;
	import events.GameEvent;
	import events.ShamanEvent;
	import game.gameData.EmotionManager;
	import game.gameData.FlagsManager;
	import game.gameData.VIPManager;
	import game.mainGame.CastItem;
	import game.mainGame.GameMap;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameIceland.HeroIceland;
	import game.mainGame.gameNet.SquirrelCollectionNet;
	import game.mainGame.gameQuests.GameQuest;
	import game.mainGame.perks.clothes.ui.ClothesToolBar;
	import game.mainGame.perks.dragon.ui.DragonPerksToolBar;
	import game.mainGame.perks.hare.ui.HarePerksToolBar;
	import game.mainGame.perks.mana.ui.PerksToolBar;
	import game.mainGame.perks.shaman.ui.ShamanToolBar;
	import game.mainGame.perks.ui.FastPerksBar;
	import game.mainGame.perks.ui.ToolBar;
	import game.mainGame.perks.ui.ToolBarOld;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenSchool;
	import screens.Screens;
	import statuses.StatusIcons;
	import tape.TapeShaman;
	import tape.shopTapes.TapeShopCast;
	import views.EmotionBarView;
	import views.NewYearSnowBar;
	import views.widgets.HotKeyView;

	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketServer;
	import protocol.packages.server.PacketRoomRound;

	import utils.anchorHelp.AnchorEnum;
	import utils.anchorHelp.AnchorHelpManager;

	public class FooterGame extends Sprite
	{

		static public var statusLinePosition:Number = 541;

		static private var _instance:FooterGame;

		static public var gameState:int = -1;

		private var dialogSuicide:DialogInfo;

		private var buttonEmotions:ButtonLockable = null;
		private var buttonClothesPerk:ButtonLockable = null;
		private var buttonShamanPerk:ButtonLockable = null;
		private var buttonPerk:ButtonLockable = null;
		private var buttonSuicide:ButtonLockable = null;
		private var buttonQuestPerk:ButtonQuestPerk = null;
		private var buttonFastPerk:ButtonLockable = null;

		private var buttonsArray:Vector.<DisplayObject> = new Vector.<DisplayObject>();

		private var emotionsToolbar:EmotionBarView = null;
		private var clothesToolBar:ToolBar = null;
		private var shamanToolBar:ToolBarOld = null;
		private var hareToolBar:ToolBar = null;
		private var dragonToolBar:ToolBar = null;
		private var fastPerkToolBar:ToolBar = null;
		private var perkTool:PerksToolBar = null;
		private var shamanTape:TapeShaman = null;

		private var toolSprite:Sprite = new Sprite();

		private var tooltips:Dictionary = new Dictionary();

		private var arrowRespawn:ImageArrowRespawn = null;
		private var newYearBar:Sprite;

		private var roundStarted:Boolean = true;
		private var initedGame:Boolean = false;

		private var _hero:Hero = null;

		public function FooterGame():void
		{
			_instance = this;

			super();

			this.visible = false;

			init();

			Game.stage.addEventListener(MouseEvent.CLICK, hideToolBars);

			Connection.listen(onPacket, [PacketRoomRound.PACKET_ID]);
			EmotionManager.addEventListener(GameEvent.SMILES_CHANGED, onChange);
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullScreen);
			onFullScreen();
		}

		private function onFullScreen(e:Event = null):void
		{
			statusLinePosition = GameMap.gameScreenHeight - 79;

			for (var i:int = 0; i < this.buttonsArray.length; i++)
			{
				if (tooltips[this.buttonsArray[i]] != null)

					if (FullScreenManager.instance().fullScreen)
						(tooltips[this.buttonsArray[i]] as StatusIcons).fixed = null;
					else
						(tooltips[this.buttonsArray[i]] as StatusIcons).setPosition(this.x + this.buttonsArray[i].x + this.buttonsArray[i].width / 2 - tooltips[this.buttonsArray[i]].width / 2, statusLinePosition);
			}
		}

		static public function show():void
		{
			if (!_instance.initedGame)
				_instance.initGame();
			_instance.visible = true;
		}

		static public function hide():void
		{
			_instance.visible = false;
		}

		static public function initGame():void
		{
			if (!_instance.initedGame)
				_instance.initGame();
		}

		//Разобраться ВТФ
		static public function set roundStarted(value:Boolean):void
		{
			if (_instance.roundStarted == value)
				return;

			_instance.roundStarted = value;
			_instance.update();
		}

		static public function get hero():Hero
		{
			return _instance._hero;
		}

		static public function set hero(value:Hero):void
		{
			if (hero == value)
				return;

			if (hero != null)
			{
				hero.removeEventListener(SquirrelEvent.DIE, _instance.update);
				hero.removeEventListener(SquirrelEvent.HARE, _instance.update);
				hero.removeEventListener(SquirrelEvent.HIDE, _instance.update);
				hero.removeEventListener(SquirrelEvent.RESET, _instance.update);
				hero.removeEventListener(SquirrelEvent.RESPAWN, _instance.update);
				hero.removeEventListener(SquirrelEvent.SCRAT, _instance.update);
				hero.removeEventListener(SquirrelEvent.SHAMAN, _instance.update);
				hero.removeEventListener(SquirrelEvent.DRAGON, _instance.update);
			}

			_instance._hero = value;

			if (hero != null)
			{
				hero.addEventListener(SquirrelEvent.DIE, _instance.update);
				hero.addEventListener(SquirrelEvent.HARE, _instance.update);
				hero.addEventListener(SquirrelEvent.HIDE, _instance.update);
				hero.addEventListener(SquirrelEvent.RESET, _instance.update);
				hero.addEventListener(SquirrelEvent.RESPAWN, _instance.update);
				hero.addEventListener(SquirrelEvent.SCRAT, _instance.update);
				hero.addEventListener(SquirrelEvent.SHAMAN, _instance.update);
				hero.addEventListener(SquirrelEvent.DRAGON, _instance.update);
			}

			_instance.shamanTape.hero = value;
			_instance.emotionsToolbar.hero = value;

			_instance.update();
		}

		static public function listenShaman(listener:Function):void
		{
			if (!_instance.initedGame)
				_instance.initGame();

			_instance.shamanTape.addEventListener(ShamanEvent.NAME, listener, false, 0, true);
		}

		static public function removeListenerShaman(listener:Function):void
		{
			_instance.shamanTape.removeEventListener(ShamanEvent.NAME, listener);
		}

		static public function selectShamanElement(itemClass:Class):void
		{
			_instance.shamanTape.selectShamanElement(itemClass);
		}

		static public function unselectShamanElement():void
		{
			_instance.shamanTape.unselectShamanElement();
		}

		static public function updateCastItems(items:Array, isPerk:Boolean = false):void
		{
			TapeShopCast.update();
			if (_instance == null || _instance.shamanTape == null || _instance.shamanTape.hero == null)
				return;
			if (!((Screens.active is ScreenGame) && !(isPerk ? Locations.currentLocation.nonPerk : Locations.currentLocation.nonItems)) || Screens.active is ScreenSchool)
				return;
			for (var i:int = 0; i < items.length; i += 2)
				_instance.shamanTape.hero.castItems.add(new CastItem(CastItemsData.getClass(items[i]), CastItem.TYPE_SQUIRREL, items[i + 1]));
			_instance.shamanTape.hero.castItems.update();
		}

		static public function toggleFreeRespawn(value:Boolean):void
		{
			if (_instance.perkTool == null)
				return;

			_instance.perkTool.toggleFreeRespawn(value);
			(_instance.fastPerkToolBar as FastPerksBar).toggleFreeRespawn(value);
		}

		static public function toggleFreeCast(value:Boolean):void
		{
			if (_instance.perkTool == null || !DiscountManager.freePerkCast)
				return;

			_instance.perkTool.toggleFreeCast(value);
			(_instance.fastPerkToolBar as FastPerksBar).toggleFreeCast(value);
		}

		static public function setFreeClothesPerk(value:Boolean):void
		{
			if (_instance.clothesToolBar == null)
				return;

			_instance.setFreeClothesPerk(value);
		}

		static public function get perksShown():Boolean
		{
			return _instance.perkTool.visible;
		}

		static public function get perksAvailable():Boolean
		{
			return _instance.buttonPerk.mouseEnabled && _instance.buttonPerk.visible;
		}

		static public function onPerksShown():void
		{
			if (_instance.shamanTape)
				_instance.shamanTape.onPerksShown();
			if (_instance.clothesToolBar && _instance.perkTool.visible)
				_instance.clothesToolBar.visible = false;
			if (_instance.shamanToolBar && _instance.perkTool.visible)
				_instance.shamanToolBar.visible = false;
			if (_instance.emotionsToolbar && _instance.perkTool.visible)
				_instance.emotionsToolbar.visible = false;
		}

		static public function updatePerkButtons():void
		{
			_instance.perkTool.updateButtons();
			_instance.clothesToolBar.updateButtons();
			_instance.fastPerkToolBar.updateButtons();
		}

		private function init():void
		{
			var background:ImageFooterGame = new ImageFooterGame();
			background.y = Config.GAME_HEIGHT - Footers.FOOTER_OFFSET - background.height;
			background.cacheAsBitmap = true;
			addChild(background);

			this.newYearBar = new NewYearSnowBar();
			this.newYearBar.x = 85;
			this.newYearBar.y = 73;
			addChild(this.newYearBar);

			this.buttonFastPerk = new ButtonLockable(new ButtonFastMagic);
			this.buttonFastPerk.y = 73;
			this.buttonFastPerk.addEventListener(MouseEvent.CLICK, fastPerkClick);
			this.toolSprite.addChild(this.buttonFastPerk);

			tooltips[this.buttonFastPerk] = new StatusIcons(this.buttonFastPerk, 80, gls("Быстрая магия"), false, new Point(0, statusLinePosition));

			this.buttonsArray.push(this.buttonFastPerk);

			this.buttonSuicide = new ButtonLockable(new ButtonSuicide);
			this.buttonSuicide.y = 73;
			this.buttonSuicide.addEventListener(MouseEvent.CLICK, showDialogSuicide);
			this.toolSprite.addChild(this.buttonSuicide);

			tooltips[this.buttonSuicide] = new StatusIcons(this.buttonSuicide, 70, gls("Сдаться"), false, new Point(0, statusLinePosition));

			this.buttonsArray.push(this.buttonSuicide);

			this.buttonPerk = new ButtonLockable(new ButtonMagic);
			this.buttonPerk.y = 73;
			this.buttonPerk.addEventListener(MouseEvent.CLICK, magicClick);
			this.toolSprite.addChild(this.buttonPerk);

			tooltips[this.buttonPerk] = new StatusIcons(this.buttonPerk, 70, gls("Магия"), false, new Point(0, statusLinePosition), [new HotKeyView("Tab")]);

			this.buttonsArray.push(this.buttonPerk);

			this.arrowRespawn = new ImageArrowRespawn();
			this.arrowRespawn.visible = false;
			this.arrowRespawn.y = 19;
			addChild(this.arrowRespawn);

			AnchorHelpManager.instance.addAnchorObject(AnchorEnum.GameMagicAnchor, this.buttonPerk);

			this.buttonClothesPerk = new ButtonLockable(new ButtonClothesMagic);
			this.buttonClothesPerk.y = 73;
			this.buttonClothesPerk.addEventListener(MouseEvent.CLICK, clothesClick);
			this.toolSprite.addChild(this.buttonClothesPerk);

			tooltips[this.buttonClothesPerk] = new StatusIcons(this.buttonClothesPerk, 100, gls("Уникальные способности"), false, new Point(0, statusLinePosition));

			this.buttonsArray.push(this.buttonClothesPerk);

			this.buttonShamanPerk = new ButtonLockable(new ButtonShamanMagic);
			this.buttonShamanPerk.y = 73;
			this.buttonShamanPerk.addEventListener(MouseEvent.CLICK, shamanClick);
			this.toolSprite.addChild(this.buttonShamanPerk);

			tooltips[this.buttonShamanPerk] = new StatusIcons(this.buttonShamanPerk, 100, gls("Способности шамана"), false, new Point(0, statusLinePosition));

			this.buttonsArray.push(this.buttonShamanPerk);

			this.buttonQuestPerk = new ButtonQuestPerk();
			this.buttonQuestPerk.y = 75;
			this.buttonQuestPerk.visible = false;
			this.buttonQuestPerk.addEventListener(MouseEvent.CLICK, usePerkQuest);
			this.toolSprite.addChild(this.buttonQuestPerk);

			tooltips[this.buttonQuestPerk] = new StatusIcons(this.buttonQuestPerk, 100, gls("Способность по заданию"), false, new Point(0, statusLinePosition));

			this.buttonsArray.push(this.buttonQuestPerk);

			this.buttonEmotions = new ButtonLockable(new ButtonOpenSmile());
			this.buttonEmotions.y = 75;
			this.buttonEmotions.addEventListener(MouseEvent.CLICK, emotionsClick);
			this.toolSprite.addChild(this.buttonEmotions);

			tooltips[this.buttonEmotions] = new StatusIcons(this.buttonEmotions, 100, gls("Эмоции белки"), false, new Point(0, statusLinePosition));

			this.buttonsArray.push(this.buttonEmotions);

			addChild(this.toolSprite);

			this.emotionsToolbar = new EmotionBarView();
			this.emotionsToolbar.y = 20;
			this.emotionsToolbar.visible = false;
			this.emotionsToolbar.addEventListener(MouseEvent.CLICK, stopPropagation);
			this.toolSprite.addChild(this.emotionsToolbar);

			this.perkTool = new PerksToolBar();
			this.perkTool.x = 850;
			this.perkTool.y = 2;
			this.perkTool.visible = false;
			this.perkTool.addEventListener(MouseEvent.CLICK, stopPropagation);
			this.toolSprite.addChild(this.perkTool);

			this.clothesToolBar = new ClothesToolBar();
			this.clothesToolBar.x = 900;
			this.clothesToolBar.y = 9;
			this.clothesToolBar.addEventListener(MouseEvent.CLICK, stopPropagation);
			this.toolSprite.addChild(this.clothesToolBar);

			this.shamanToolBar = new ShamanToolBar();
			this.shamanToolBar.x = 760;
			this.shamanToolBar.y = 10;
			this.shamanToolBar.addEventListener(MouseEvent.CLICK, stopPropagation);
			this.toolSprite.addChild(this.shamanToolBar);

			this.fastPerkToolBar = new FastPerksBar();
			this.fastPerkToolBar.x = 900;
			this.fastPerkToolBar.y = 25;
			this.fastPerkToolBar.visible = false;
			this.fastPerkToolBar.addEventListener(MouseEvent.CLICK, stopPropagation);
			this.toolSprite.addChild(this.fastPerkToolBar);

			Game.listen(onPlayerLoad);

			this.dialogSuicide = new DialogInfo(gls("Сдаться"), gls("Закончить игру на этом уровне?"), true, suicide);

			Hero.listenSelf([Hero.EVENT_DIE, Hero.EVENT_REMOVE, SquirrelEvent.LEAVE, SquirrelEvent.HIDE, SquirrelEvent.DIE], onHideToolBar);
		}

		private function onHideToolBar():void
		{
			this.perkTool.visible = false;
		}

		private function initGame():void
		{
			this.shamanTape = new TapeShaman(9, 1, 32, 0);
			this.shamanTape.y = 75;
			addChild(this.shamanTape);

			this.hareToolBar = new HarePerksToolBar();
			this.hareToolBar.x = 20;
			this.hareToolBar.y = 78;
			this.toolSprite.addChild(this.hareToolBar);

			this.dragonToolBar = new DragonPerksToolBar();
			this.dragonToolBar.x = 20;
			this.dragonToolBar.y = 78;
			this.toolSprite.addChild(this.dragonToolBar);

			update();

			this.initedGame = true;
		}

		private function update(e:SquirrelEvent = null):void
		{
			this.toolSprite.visible = false;
			this.newYearBar.visible = false;

			if (hero == null)
			{
				updateTool();
				return;
			}

			if (!this.roundStarted)
				return;

			this.toolSprite.visible = true;

			var isSquirrel:Boolean = !hero.isHare && !hero.isDragon;

			this.hareToolBar.visible = hero.isHare;
			this.dragonToolBar.visible = hero.isDragon && !(Screens.active is ScreenEdit);
			this.fastPerkToolBar.visible = false;
			this.clothesToolBar.visible = false;
			this.shamanToolBar.visible = false;
			this.shamanTape.visible = isSquirrel && !hero.isDead;

			this.buttonQuestPerk.visible = GameQuest.perkAvaliable;
			this.buttonPerk.visible = this.perkTool.perksVisible;
			this.buttonClothesPerk.visible = this.clothesToolBar.perksVisible;
			this.buttonShamanPerk.visible = this.shamanToolBar.perksVisible;
			this.newYearBar.visible = hero is HeroIceland;
			this.buttonFastPerk.visible = Screens.active is ScreenGame && FlagsManager.has(Flag.MAGIC_SCHOOL_FINISH);

			toggleEmotionButtons(!hero.isDead && Screens.active is ScreenGame && (hero.shaman || (EmotionManager.smiles.length > 0 && !hero.isHare)));

			updateTool();
			sortButtons();

			//TODO WTF
			this.visibleArrowRespawn = respawn;
		}

		private function get respawn():Boolean
		{
			var isSquirrel:Boolean = !hero.isHare && !hero.isDragon;
			var perkAvailable:Boolean = FlagsManager.has(Flag.MAGIC_SCHOOL_FINISH);
			var freeVIPRespawn:Boolean = SquirrelCollectionNet.countVIPRespawn == 0 && VIPManager.haveVIP;
			return !freeVIPRespawn && isSquirrel && hero.isDead && !hero.inHollow && this.perkTool.perksAvailable && perkAvailable && Screens.active is ScreenGame;
		}

		private function set visibleArrowRespawn(value:Boolean):void
		{
			this.arrowRespawn.visible = value;
			if(value)
				this.arrowRespawn.play();
			else
				this.arrowRespawn.stop();
		}

		private function sortButtons():void
		{
			var offsetX:int = 857;
			for (var i:int = 0; i < this.buttonsArray.length; i++)
			{
				this.buttonsArray[i].x = offsetX;
				this.buttonsArray[i].y = 70;

				if (tooltips[this.buttonsArray[i]] != null)
					(tooltips[this.buttonsArray[i]] as StatusIcons).setPosition(this.buttonsArray[i].x + this.buttonsArray[i].width / 2 - tooltips[this.buttonsArray[i]].width / 2, tooltips[this.buttonsArray[i]].y);

				offsetX -= this.buttonsArray[i].visible ? 45 : 0;
			}
			this.clothesToolBar.x = Math.min(Config.GAME_WIDTH - 60, this.buttonClothesPerk.x + (this.buttonClothesPerk.width + this.clothesToolBar.width) * 0.5);

			this.arrowRespawn.x = this.buttonPerk.x + this.arrowRespawn.width/2;

			this.shamanToolBar.x = this.buttonShamanPerk.x - this.shamanToolBar.width * 0.5;
			this.shamanToolBar.y = this.buttonShamanPerk.y - this.shamanToolBar.height;

			this.emotionsToolbar.x = Config.GAME_WIDTH - this.emotionsToolbar.width - 60 - this.x;
		}

		private function fastPerkClick(e:MouseEvent):void
		{
			if (!this.buttonFastPerk.mouseEnabled)
				return;

			this.fastPerkToolBar.visible = !this.fastPerkToolBar.visible;
			e.stopImmediatePropagation();
		}

		private function clothesClick(e:Event):void
		{
			if (!this.buttonClothesPerk.mouseEnabled)
				return;

			this.clothesToolBar.visible = !this.clothesToolBar.visible;
			this.shamanToolBar.visible = this.perkTool.visible = this.emotionsToolbar.visible = false;
			e.stopImmediatePropagation();
		}

		private function shamanClick(e:Event):void
		{
			if (!this.buttonShamanPerk.mouseEnabled)
				return;

			this.shamanToolBar.visible = !this.shamanToolBar.visible;
			this.clothesToolBar.visible = this.perkTool.visible = this.emotionsToolbar.visible = false;

			e.stopImmediatePropagation();
		}

		private function magicClick(e:Event):void
		{
			if (!this.buttonPerk.mouseEnabled)
				return;

			this.visibleArrowRespawn = false;
			this.perkTool.visibleAs(!this.perkTool.visible, true);
			this.perkTool.visibleArrowRespawn = respawn;
			this.clothesToolBar.visible = this.shamanToolBar.visible = this.emotionsToolbar.visible = false;

			e.stopImmediatePropagation();
		}

		private function emotionsClick(e:MouseEvent):void
		{
			this.emotionsToolbar.visible = !this.emotionsToolbar.visible;
			this.clothesToolBar.visible = this.shamanToolBar.visible = this.perkTool.visible = false;

			e.stopImmediatePropagation();
		}

		private function suicide():void
		{
			if (!hero)
				return;

			hero.dieReason = Hero.DIE_SUICIDE;
			hero.dead = true;
		}

		private function showDialogSuicide(e:MouseEvent):void
		{
			if (hero && !hero.isDead && this.buttonSuicide.mouseEnabled)
				this.dialogSuicide.show();
		}

		private function usePerkQuest(e:MouseEvent):void
		{
			if (!hero || hero.isDead || hero.inHollow)
				return;
			hero.dispatchEvent(new Event(Hero.EVENT_PERK_QUEST));
		}

		private function stopPropagation(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
		}

		private function toggleEmotionButtons(value:Boolean):void
		{
			this.buttonEmotions.visible = value;
			if ((!this.buttonEmotions.visible || !this.buttonEmotions.mouseEnabled) && this.emotionsToolbar.visible)
				this.emotionsToolbar.visible = false;
		}

		private function onPacket(packet:PacketRoomRound):void
		{
			if (packet.type != PacketServer.ROUND_CUT)
				gameState = packet.type;
			setTimeout(updateTool, 1);
			if (gameState == PacketServer.ROUND_START)
				setFreeClothesPerk(true);
		}

		private function onChange(e:GameEvent):void
		{
			if (!this.initedGame)
				return;
			toggleEmotionButtons(!this.hareToolBar.visible);
			sortButtons();
		}

		private function onPlayerLoad(e:PlayerEvent):void
		{
			if (hero == null)
				return;

			if (e.player['id'] != hero.id)
				return;

			toggleEmotionButtons(!hero.isDead && Screens.active is ScreenGame && EmotionManager.smiles.length > 0 && !hero.isHare);
			sortButtons();
		}

		private function updateTool():void
		{
			this.buttonClothesPerk.mouseEnabled = this.clothesToolBar.perksAvailable;
			this.buttonPerk.mouseEnabled = this.perkTool.perksAvailable;
			this.buttonFastPerk.mouseEnabled = this.buttonPerk.mouseEnabled || this.buttonClothesPerk.mouseEnabled;
			this.buttonShamanPerk.mouseEnabled = this.shamanToolBar.perksAvailable;
			this.buttonSuicide.mouseEnabled = (hero != null && gameState == PacketServer.ROUND_START && !hero.isDead && !hero.inHollow);
			this.buttonEmotions.mouseEnabled = !(hero != null && (hero.isDead || hero.inHollow || gameState != PacketServer.ROUND_START));

			if (!this.perkTool.perksAvailable && this.perkTool.visible)
				this.perkTool.visible = false;
		}

		private function setFreeClothesPerk(value:Boolean):void
		{
			(this.clothesToolBar as ClothesToolBar).setFreeCost(value);
			(this.fastPerkToolBar as FastPerksBar).setFreeCost(value);

			if (DiscountManager.freePerkCast)
				toggleFreeCast(true);
		}

		private function hideToolBars(e:MouseEvent):void
		{
			if (!_instance.visible)
				return;
			this.clothesToolBar.visible = false;
			this.shamanToolBar.visible = false;
			this.perkTool.visible = false;
			this.emotionsToolbar.visible = false;
		}
	}
}