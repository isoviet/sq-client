package game.mainGame.perks.ui
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import dialogs.DialogDepletionMana;
	import game.gameData.PowerManager;
	import game.mainGame.perks.ICounted;
	import game.mainGame.perks.PerkOld;
	import screens.ScreenGame;
	import screens.Screens;
	import statuses.Status;
	import statuses.StatusIcons;

	import utils.FiltersUtil;
	import utils.Sector;

	public class ToolButtonOld extends Sprite
	{
		public var perkClass:Class = null;
		public var perkData:Object = null;

		protected var _glow:Boolean = false;
		protected var _gray:Boolean = false;
		protected var _cost:int = 0;

		protected var status:Status = null;
		protected var sector:Sector = null;
		protected var perkInstance:PerkOld = null;

		protected var costView:PerkCostView;
		protected var button:SimpleButton = null;
		protected var hotKeyText:String = "";

		public function ToolButtonOld(perkClass:Class, perkData:Object):void
		{
			this.perkClass = perkClass;
			this.perkData = perkData;
			this.status = new StatusIcons(this, 190, "", false);
			this.button = new this.perkData['buttonClass']();
			addChild(this.button);

			this.costView = getCostView();
			this.cost = this.perkData['cost'] ? this.perkData['cost'] : 0;
			addChild(this.costView);

			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}

		public function clone():ToolButtonOld
		{
			var answer:ToolButtonOld = new ToolButtonOld(this.perkClass, this.perkData);
			answer.hero = this.hero;
			return answer;
		}

		protected function onDown(e:MouseEvent):void
		{
			//if (!(Screens.active is ScreenGame))
			//	return;
			//FastPerksBar.startDraging(this, this.localToGlobal(new Point(e.currentTarget.x - this.x, e.currentTarget.y - this.y)));
		}

		public function get glow():Boolean
		{
			return _glow;
		}

		public function set glow(value:Boolean):void
		{
			if (_glow == value)
				return;

			_glow = value;
			updateView();
		}

		public function get gray():Boolean
		{
			return _gray;
		}

		public function set gray(value:Boolean):void
		{
			if (_gray == value)
				return;

			_gray = value;
			this.button.mouseEnabled = !value;
			this.button.enabled = !value;
			updateView();
		}

		public function get cost():int
		{
			return _cost;
		}

		public function set cost(value:int):void
		{
			_cost = value;
			this.costView.text = String(value);
			this.costView.visible = value > 0 && Screens.active is ScreenGame;
		}

		public function get hero():Hero
		{
			if (this.perkInstance)
				return this.perkInstance.hero;

			return null;
		}

		public function get active():Boolean
		{
			if (!this.perkInstance)
				return false;
			return this.perkInstance.active;
		}
		public function  get available():Boolean
		{
			if(!this.perkInstance)
				return false;
			return this.perkInstance.available;
		}

		public function set hero(value:Hero):void
		{
			checkHero(value);
		}

		public function addHotKeyStatus(key:String):void
		{
			this.hotKeyText = key;
			updateState();
		}

		public function removeHotKeyStatus():void
		{
			this.hotKeyText = "";
			updateState();
		}

		public function onClick(e:Event = null):void
		{
			checkClick();
		}

		public function updateState(e:Event = null):void
		{
			if (!checkState())
				return;

			if ((this.perkInstance is ICounted) && ((this.perkInstance as ICounted).charge != 0))
				this.sector.end = Math.PI * 2 - (this.perkInstance as ICounted).charge / (this.perkInstance as ICounted).count * Math.PI * 2;
			else
				this.sector.end = 0;
		}

		protected function getCostView():PerkCostView
		{
			this.costView = new PerkCostView(ImageIconMana, 0.7);
			this.costView.x = 18;
			this.costView.y = 39;

			return this.costView;
		}

		protected function checkClick():Boolean
		{
			if (this.gray)
				return false;

			if (!perkInstance)
				return false;

			if (!(Screens.active is ScreenGame))
			{
				this.perkInstance.active = !this.perkInstance.active;
				return false;
			}

			return true;
		}

		public function get isEnoughtMana():Boolean
		{
			return PowerManager.isEnoughMana(this.cost);
		}

		protected function showManaDialog():Boolean
		{
			if (!isEnoughtMana && !this.perkInstance.active)
			{
				DialogDepletionMana.show();
				return true;
			}

			return false;
		}

		protected function checkHero(hero:Hero):Boolean
		{
			if (this.perkInstance)
				this.perkInstance.removeEventListener("STATE_CHANGED", updateState);

			if (hero)
				return true;

			this.perkInstance = null;
			return false;
		}

		protected function checkState():Boolean
		{
			if (!perkInstance)
				return false;

			this.glow = perkInstance.active && this.perkInstance.available;
			this.gray = !perkInstance.available;

			if (!perkInstance.hero)
				this.hero = null;

			return true;
		}

		protected function setSector():void
		{
			this.sector = new Sector();
			this.sector.start = 0;
			this.sector.x = this.sector.radius;
			this.sector.y = this.sector.radius;
			this.sector.color = 0xFF0000;
			this.sector.alpha = 0.5;
			this.sector.mouseEnabled = false;
			this.sector.mouseChildren = false;
			addChild(this.sector);
		}

		public function getStatus():StatusIcons
		{
			return this.status as StatusIcons;
		}

		protected function updateView():void
		{
			var filters:Array = [];
			if (this.glow)
				filters = filters.concat(FiltersUtil.GLOW_FILTER);
			if (this.gray)
				filters = filters.concat(FiltersUtil.GREY_FILTER);
			this.button.filters = filters;
		}
	}
}