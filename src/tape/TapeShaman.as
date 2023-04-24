package tape
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	import buttons.ButtonDouble;
	import events.CastItemsEvent;
	import events.ShamanEvent;
	import footers.FooterGame;
	import game.mainGame.CastItem;
	import game.mainGame.entity.battle.BouncingPoise;
	import game.mainGame.entity.battle.GhostPoise;
	import game.mainGame.entity.battle.GravityPoise;
	import game.mainGame.entity.battle.GrenadePoise;
	import game.mainGame.entity.battle.SpikePoise;
	import game.mainGame.entity.cast.BodyDestructor;
	import game.mainGame.entity.cast.DragTool;
	import game.mainGame.entity.cast.Hammer;
	import game.mainGame.entity.editor.Stone;
	import game.mainGame.entity.iceland.IceBlock;
	import game.mainGame.entity.joints.JointSticky;
	import game.mainGame.entity.magic.HarpoonBodyBat;
	import game.mainGame.entity.magic.HarpoonBodyCat;
	import game.mainGame.entity.magic.Muffin;
	import game.mainGame.entity.magic.ShadowBomb;
	import game.mainGame.entity.magic.SheepBomb;
	import game.mainGame.entity.magic.SmokeBomb;
	import game.mainGame.entity.magic.StickyBomb;
	import game.mainGame.entity.simple.BalanceWheel;
	import game.mainGame.entity.simple.Balk;
	import game.mainGame.entity.simple.BalkIce;
	import game.mainGame.entity.simple.BalkIceLong;
	import game.mainGame.entity.simple.BalkLong;
	import game.mainGame.entity.simple.BalkLongSteel;
	import game.mainGame.entity.simple.BalkSteel;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.Bouncer;
	import game.mainGame.entity.simple.Box;
	import game.mainGame.entity.simple.BoxBig;
	import game.mainGame.entity.simple.BoxBigSteel;
	import game.mainGame.entity.simple.BoxIce;
	import game.mainGame.entity.simple.BoxIceBig;
	import game.mainGame.entity.simple.BoxSteel;
	import game.mainGame.entity.simple.BurstBody;
	import game.mainGame.entity.simple.FirCone;
	import game.mainGame.entity.simple.FirConeRight;
	import game.mainGame.entity.simple.GunPoise;
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
	import game.mainGame.entity.simple.Trampoline;
	import game.mainGame.entity.simple.WeightBody;
	import game.mainGame.events.CastItemEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.HeroBattle;
	import game.mainGame.gameIceland.HeroIceland;
	import game.mainGame.perks.shaman.ui.ShamanToolBar;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenSchool;
	import screens.Screens;

	import utils.CastUtil;

	public class TapeShaman extends TapeShamanView
	{
		static private const NUM_COLUMNS_SHAMAN:int = 7;
		static private const NUM_COLUMNS_SQUIRREL:int = 3;

		static protected var sorted:Array = null;

		private var _hero:Hero = null;

		private var shamanItemsLoaded:Boolean = false;

		private var items:TapeData = new TapeData();
		private var showingItems:TapeData = new TapeData();
		private var castShop:TapeShamanCastShop = new TapeShamanCastShop();

		private var selected:TapeCastElement = null;

		protected var aliases:Object = {};

		public function TapeShaman(columns:int = 4, row:int = 1, marginLeft:int = 0, top:int= 0, isSnake:Boolean = true):void
		{
			super(columns, row, marginLeft, top, isSnake);

			setData(this.showingItems);
			placeButtons();
			update();

			if (TapeShaman.sorted == null)
				TapeShaman.sorted = [IceBlock, SheepBomb, ShadowBomb, Muffin, JointSticky, SmokeBomb, StickyBomb, BalanceWheel, HarpoonBodyBat, HarpoonBodyCat, BurstBody, BodyDestructor, Hammer, DragTool, Poise, PoiseRight, PoiseInvisible, PoiseInvisibleRight, FirCone, FirConeRight, GunPoise, BalloonBody, Bouncer, Trampoline, Balk, BalkIce, BalkSteel, BalkLong, BalkIceLong, BalkLongSteel, PortalRed, PortalBlue, PortalRedDirected, PortalBlueDirected, PortalBB, PortalRB, PortalBR, PortalRR, PortalBBDirected, PortalRBDirected, PortalBRDirected, PortalRRDirected, Box, BoxIce, BoxSteel, BoxBig, BoxIceBig, BoxBigSteel, WeightBody, Stone, SpikePoise, BouncingPoise, GhostPoise, GravityPoise, GrenadePoise];

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}

		public function get hero():Hero
		{
			return this._hero;
		}

		public function set hero(value:Hero):void
		{
			if (this._hero != null)
			{
				this.hero.castItems.removeEventListener(CastItemsEvent.UPDATE, updateItems);
				this.hero.castItems.removeEventListener(CastItemEvent.ITEM_ADD, addItem);
				this.hero.removeEventListener(SquirrelEvent.DIE, resetRoundItems);
				this.hero.removeEventListener(SquirrelEvent.RESET, resetItems);
				this.hero.removeEventListener(SquirrelEvent.SHAMAN, updateShowing);
				this.hero.removeEventListener(SquirrelEvent.TEAM, onChangeTeam);
			}

			this._hero = value;

			if (this.hero == null)
			{
				updateItems();
				return;
			}

			this.hero.castItems.addEventListener(CastItemsEvent.UPDATE, updateItems);
			this.hero.castItems.addEventListener(CastItemEvent.ITEM_ADD, addItem);
			this.hero.addEventListener(SquirrelEvent.DIE, resetRoundItems, false, 1);
			this.hero.addEventListener(SquirrelEvent.RESET, resetItems);
			this.hero.addEventListener(SquirrelEvent.SHAMAN, updateShowing);
			this.hero.addEventListener(SquirrelEvent.TEAM, onChangeTeam);

			updateItems();
		}

		public function reset():void
		{
			this.data.clear();
		}

		public function selectShamanElement(itemClass:Class):void
		{
			unselectShamanElement();

			for (var i:int = 0; i < this.items.objects.length; i++)
			{
				if ((this.items.objects[i] as TapeCastElement).castItem.itemClass != itemClass)
					continue;

				if (this.showShaman && !((this.items.objects[i] as TapeCastElement).castItem.type == CastItem.TYPE_SHAMAN || (this.items.objects[i] as TapeCastElement).castItem.type == CastItem.TYPE_ROUND))
					continue;

				if (!this.showShaman && !((this.items.objects[i] as TapeCastElement).castItem.type == CastItem.TYPE_SQUIRREL || (this.items.objects[i] as TapeCastElement).castItem.type == CastItem.TYPE_ROUND))
					continue;

				this.selected = this.items.objects[i] as TapeCastElement;
				this.selected.addSelect();
			}
		}

		public function unselectShamanElement():void
		{
			if (this.selected != null)
				this.selected.removeSelect();

			this.selected = null;
		}

		public function onPerksShown():void
		{
			updateAliases();
		}

		override protected function update():void
		{
			super.update();
			for each (var item:TapeCastElement in this.items.objects)
			{
				if (item.castItem.type != CastItem.TYPE_ROUND)
					continue;
				item.icon.alpha = item.castItem.count > 0 ? 1 : 0.1;
			}
			this.castShop.visible = Boolean(this.hero && !(this.hero is HeroIceland) && (!(this.showShaman)) && (this.hero.player['level'] >= Game.LEVEL_TO_OPEN_STORAGE) && !Locations.currentLocation.nonItems && !(Screens.active is ScreenSchool));
			dispatchEvent(new CastItemEvent(CastItemEvent.TAPE_UPDATE, null));
			updateAliases();
		}

		override protected function placeButtons():void
		{
			if (this.buttonPrevious == null)
			{
				var buttonLeft:ButtonRewindLeft = new ButtonRewindLeft();

				buttonLeft.upState.cacheAsBitmap = true;
				var buttonLeftInactive:ButtonRewindLeftInactive = new ButtonRewindLeftInactive();
				buttonLeftInactive.upState.cacheAsBitmap = true;
				this.buttonPrevious = new ButtonDouble(buttonLeft, buttonLeftInactive);
			}
			if (this.buttonNext == null)
			{
				var buttonRight:ButtonRewindRight = new ButtonRewindRight();

				buttonRight.upState.cacheAsBitmap = true;
				var buttonRightInactive:ButtonRewindRightInactive = new ButtonRewindRightInactive();
				buttonRightInactive.upState.cacheAsBitmap = true;
				this.buttonNext = new ButtonDouble(buttonRight, buttonRightInactive);
			}

			this.buttonPrevious.x = 2;
			this.buttonPrevious.y = int(((this.offsetY + this.objectHeight) * this.numRows - this.buttonNext.height) / 2);

			this.buttonNext.x = (this.offsetX + this.objectWidth) * this.numColumns - this.offsetX - 12;
			this.buttonNext.y = int(((this.offsetY + this.objectHeight) * this.numRows - this.buttonNext.height) / 2);

			addChild(this.buttonPrevious);
			addChild(this.buttonNext);

			this.buttonPrevious.addEventListener(MouseEvent.CLICK, onButtonClickPrev);
			this.buttonNext.addEventListener(MouseEvent.CLICK, onButtonClickNext);

			this.castShop.x = ((this.items.objects.length < getMaxShow()) ? Math.min(getMaxShow(), this.items.objects.length - this.offset) : getMaxShow()) * (this.offsetX + this.objectWidth) + 63;
			addChild(this.castShop);
		}

		protected function addElement(e:MouseEvent = null):void
		{
			e.stopImmediatePropagation();

			var element:TapeCastElement = e.currentTarget as TapeCastElement;
			dispatchEvent(new ShamanEvent(element.castItem.itemClass));
		}

		private function updateItems(e:CastItemsEvent = null):void
		{
			for (var i:int = 0; i < this.items.objects.length; i++)
			{
				this.items.objects[i].removeEventListener(CastItemEvent.ITEM_END, filterExistingItem);
				this.items.objects[i].removeEventListener(MouseEvent.MOUSE_DOWN, addElement);
				(this.items.objects[i] as TapeCastElement).dispose();
			}

			this.shamanItemsLoaded = false;

			this.items = new TapeData();

			if (this.hero == null)
			{
				updateShowing();
				return;
			}

			addItems(this.hero.castItems.items);

			if (!this.shamanItemsLoaded && this.showShaman && this.hero.game && this.hero.game.map)
				loadShamanItems();
		}

		private function addItem(e:CastItemEvent):void
		{
			if (TapeShaman.sorted.indexOf(e.castItem.itemClass) == -1)
				return;

			var show:Boolean = this.showShaman ? (e.castItem.type != CastItem.TYPE_SQUIRREL) : (e.castItem.type != CastItem.TYPE_SHAMAN);

			if (e.castItem.type == CastItem.TYPE_SHAMAN)
				var item:TapeCastElement = new TapeCastElement(e.castItem);
			else
			{
				item = new TapeSquirrelCastElement(e.castItem);
				item.castItem.addEventListener(CastItemEvent.ITEM_END, filterExistingItem);
			}

			item.addEventListener(MouseEvent.MOUSE_DOWN, addElement);
			this.items.addObject(item);

			if (!show)
				return;

			this.showingItems.addObject(item);
			this.showingItems.objects.sort(sortShow);

			update();
			updateAliases();

			this.castShop.existingItems = this.showingItems.objects;
			updateColumnsCount();
		}

		private function addItems(value:Vector.<CastItem>):void
		{
			if (this.items == null)
				this.items = new TapeData();

			for (var i:int = 0; i < value.length; i++)
			{
				if (TapeShaman.sorted.indexOf(value[i].itemClass) == -1)
					continue;

				if (value[i].type == CastItem.TYPE_SHAMAN)
					var item:TapeCastElement = new TapeCastElement(value[i]);
				else
				{
					item = new TapeSquirrelCastElement(value[i]);
					item.castItem.addEventListener(CastItemEvent.ITEM_END, filterExistingItem);
				}

				item.addEventListener(MouseEvent.MOUSE_DOWN, addElement);
				this.items.addObject(item);
			}

			updateShowing();
		}

		private function updateShowing(e:SquirrelEvent = null):void
		{
			if ((this.hero != null) && (this.showShaman || (this.hero is HeroBattle) || (this.hero is HeroIceland)))
				this.numColumns = NUM_COLUMNS_SHAMAN;
			else
				this.numColumns = NUM_COLUMNS_SQUIRREL;

			placeButtons();

			if (this.hero == null)
			{
				this.showingItems.clear();
				return;
			}

			if (!this.shamanItemsLoaded && this.showShaman)
			{
				loadShamanItems();
				return;
			}

			this.showingItems.objects = this.items.objects.filter(filterShow);
			this.showingItems.objects.sort(sortShow);
			onChangeTeam();

			update();

			this.castShop.existingItems = this.showingItems.objects;
			updateColumnsCount();

			updateAliases();
		}

		private function loadShamanItems():void
		{
			this.shamanItemsLoaded = true;
			if (!this.hero || !this.hero.game)
				return;
			if (!this.hero.game.map || !this.hero.game.map.shamanTools)
				return;
			var shamanItems:Vector.<CastItem> = CastUtil.shamanCastItems(this.hero.game.map.shamanTools);
			addItems(shamanItems);
		}

		private function filterShow(item:TapeCastElement, index:int, parentArray:Vector.<TapeObject>):Boolean
		{
			if (index || parentArray) {/*unused*/}

			if (this.showShaman && (item.castItem.type == CastItem.TYPE_SHAMAN || item.castItem.type == CastItem.TYPE_ROUND))
				return true;

			return (!this.showShaman && (item.castItem.type == CastItem.TYPE_SQUIRREL || item.castItem.type == CastItem.TYPE_ROUND))
		}

		private function filterReset(item:TapeCastElement, index:int, parentArray:Vector.<TapeObject>):Boolean
		{
			if (index || parentArray) {/*unused*/}

			if (item.castItem.type == CastItem.TYPE_SQUIRREL)
				return true;

			item.dispose();
			item.removeEventListener(CastItemEvent.ITEM_END, filterExistingItem);
			return false;
		}

		private function filterRoundReset(item:TapeCastElement, index:int, parentArray:Vector.<TapeObject>):Boolean
		{
			if (index || parentArray) {/*unused*/}

			if (item.castItem.type == CastItem.TYPE_SQUIRREL || item.castItem.type == CastItem.TYPE_SHAMAN)
				return true;

			item.dispose();
			item.removeEventListener(CastItemEvent.ITEM_END, filterExistingItem);
			return false;
		}

		private function filterExist(item:TapeCastElement, index:int, parentArray:Vector.<TapeObject>):Boolean
		{
			if (index || parentArray) {/*unused*/}

			if (item.castItem.type == CastItem.TYPE_SHAMAN)
				return true;

			if (item.castItem.type == CastItem.TYPE_ROUND)
				return true;

			if (item.castItem.count > 0)
				return true;

			item.dispose();
			item.removeEventListener(CastItemEvent.ITEM_END, filterExistingItem);
			return false;
		}

		private function filterPortals(item:TapeCastElement, index:int, parentArray:Vector.<TapeObject>):Boolean
		{
			if (index || parentArray) {/*unused*/}

			if (this.hero && this.hero.team == Hero.TEAM_BLUE && (item.castItem.itemClass == PortalBR || item.castItem.itemClass == PortalRR || item.castItem.itemClass == PortalBRDirected || item.castItem.itemClass == PortalRRDirected))
				return false;

			if (this.hero && this.hero.team == Hero.TEAM_RED && (item.castItem.itemClass == PortalBB || item.castItem.itemClass == PortalRB || item.castItem.itemClass == PortalBBDirected || item.castItem.itemClass == PortalRBDirected))
				return false;

			return true;
		}

		private function sortShow(a:TapeCastElement, b:TapeCastElement):int
		{
			if (TapeShaman.sorted.indexOf(a.castItem.itemClass) < TapeShaman.sorted.indexOf(b.castItem.itemClass))
				return -1;

			if (TapeShaman.sorted.indexOf(a.castItem.itemClass) > TapeShaman.sorted.indexOf(b.castItem.itemClass))
				return 1;

			if (a.castItem.type > b.castItem.type)
				return 1;

			return -1;
		}

		private function resetItems(e:SquirrelEvent):void
		{
			this.items.objects = this.items.objects.filter(filterReset);
			this.shamanItemsLoaded = false;

			updateShowing();
		}

		private function resetRoundItems(e:SquirrelEvent):void
		{
			this.items.objects = this.items.objects.filter(filterRoundReset);

			updateShowing();
		}

		private function filterExistingItem(e:CastItemEvent):void
		{
			this.items.objects = this.items.objects.filter(filterExist);
			this.showingItems.objects = this.showingItems.objects.filter(filterExist);
			this.showingItems.objects.sort(sortShow);

			placeButtons();
			update();
			updateAliases();

			this.castShop.existingItems = this.showingItems.objects;
			updateColumnsCount();
		}

		private function updateAliases():void
		{
			this.aliases = {};
			clearHotKeyStatuses();

			if (!this.data || (this.data.objects.length == 0) || FooterGame.perksShown)
				return;

			for (var i:int = 0; i < this.data.objects.length && i < 10; i++)
			{
				this.aliases[i] = (this.data.objects[i] as TapeCastElement).castItem.itemClass;

				if (i == 9)
					(this.data.objects[i] as TapeCastElement).setHotKeyStatus(0);
				else
					(this.data.objects[i] as TapeCastElement).setHotKeyStatus(i + 1);
			}
		}

		private function clearHotKeyStatuses():void
		{
			if (!this.data)
				return;

			for (var i:int = 0; i < this.data.objects.length; i++)
				(this.data.objects[i] as TapeCastElement).clearHotKeyStatus();
		}

		private function onKey(e:KeyboardEvent):void
		{
			if (e.shiftKey || e.ctrlKey)
				return;

			if (Game.chat.visible || ShamanToolBar.visible)
				return;

			//48-57
			if (e.keyCode == Keyboard.TAB && FooterGame.perksAvailable && !(Screens.active is ScreenEdit))
			{
				updateAliases();
				return;
			}

			var code:int = e.keyCode - 49;
			if (code in this.aliases && this.visible)
				dispatchEvent(new ShamanEvent(this.aliases[code]));

			if ((code == -1) && ('9' in this.aliases))
				dispatchEvent(new ShamanEvent(this.aliases['9']));
		}

		private function onButtonClickNext(e:MouseEvent):void
		{

			if (this.offset + getMaxShow() >= this.data.objects.length)
				return;

			this.offset += this.numColumns;
		}

		private function onButtonClickPrev(e:MouseEvent):void
		{

			if (this.offset == 0)
				return;

			this.offset -= this.numColumns;
		}

		private function get showShaman():Boolean
		{
			return (this.hero.shaman || Screens.active is ScreenEdit);
		}

		private function updateColumnsCount():void
		{
			if (!this.castShop.visible)
				return;

			var newNumColumns:int = NUM_COLUMNS_SQUIRREL + TapeShamanCastShop.NUM_COLUMNS - this.castShop.showingItemsCount;

			if (this.numColumns == newNumColumns)
				return;

			this.numColumns = newNumColumns;
			this.offset = int(this.offset / this.numColumns) * this.numColumns;

			placeButtons();
			update();
		}

		private function onChangeTeam(e:SquirrelEvent = null):void
		{
			if (!this.showShaman || ScreenGame.mode != Locations.TWO_SHAMANS_MODE)
				return;

			this.showingItems.objects = this.showingItems.objects.filter(filterPortals);
			this.showingItems.objects.sort(sortShow);

			update();
			updateAliases();
		}
	}
}