package game.mainGame.perks.ui
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import dialogs.DialogDepletionMana;
	import game.gameData.PowerManager;
	import game.mainGame.perks.Perk;
	import screens.ScreenGame;
	import screens.Screens;
	import statuses.Status;
	import statuses.StatusIcons;

	import utils.FiltersUtil;
	import utils.Sector;

	public class ToolButton extends Sprite
	{
		public var id:int = -1;

		protected var _glow:Boolean = false;
		protected var _gray:Boolean = false;
		protected var _cost:int = 0;

		protected var status:Status = null;
		protected var sector:Sector = null;
		protected var perkInstance:Perk = null;

		protected var costView:PerkCostView;
		protected var button:SimpleButton = null;
		protected var hotKeyText:String = "";

		public function ToolButton(id:int):void
		{
			this.id = id;

			this.status = new StatusIcons(this, 190, "", false);
			this.button = createButton();
			this.button.x = this.iconOffset.x;
			this.button.y = this.iconOffset.y;
			addChild(this.button);

			this.costView = getCostView();
			this.cost = this.pekManaCost;
			addChild(this.costView);

			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}

		public function get iconOffset():Point
		{
			return new Point(0, 0);
		}

		public function clone():ToolButton
		{
			var answer:ToolButton = new ToolButton(this.id);
			answer.hero = this.hero;
			return answer;
		}

		protected function createButton():SimpleButton
		{
			var upState:DisplayObject = new iconClass();
			var overState:DisplayObject = new iconClass();
			overState.filters = [FiltersUtil.perkOverFilter];
			var downState:DisplayObject = new iconClass();
			downState.filters = [FiltersUtil.perkDownFilter];

			return new SimpleButton(upState, overState, downState);
		}

		public function get iconClass():Class
		{
			return null;
		}

		public function get pekManaCost():int
		{
			return 0;
		}

		protected function onDown(e:MouseEvent):void
		{
			if (!(Screens.active is ScreenGame))
				return;
			FastPerksBar.startDraging(this, this.localToGlobal(new Point(e.currentTarget.x - this.x, e.currentTarget.y - this.y)));
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
		public function get available():Boolean
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

			if (this.perkInstance.totalCooldown != 0 && this.perkInstance.haveUseCount)
				this.sector.end = Math.PI * 2 - ((this.perkInstance.totalCooldown - this.perkInstance.currentCooldown) / this.perkInstance.totalCooldown) * Math.PI * 2;
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