package game.mainGame.perks.clothes.ui
{
	import flash.display.Sprite;

	import events.GameEvent;
	import footers.FooterGame;
	import game.gameData.FlagsManager;
	import game.gameData.PowerManager;
	import game.mainGame.perks.clothes.PerkClothes;
	import game.mainGame.perks.ui.ToolBar;
	import game.mainGame.perks.ui.ToolButton;
	import screens.ScreenGame;
	import screens.Screens;

	import protocol.Flag;

	public class ClothesToolBar extends ToolBar
	{
		static private const BUTTON_OFFSET:Number = 43;
		static private const H_OFFSET:Number = 5;
		static private const V_OFFSET:Number = 7;

		static private var _instance:ClothesToolBar;

		private var hero:Hero = null;

		public function ClothesToolBar():void
		{
			super();

			_instance = this;

			PowerManager.addEventListener(GameEvent.MANA_CHANGED, onMana);
		}

		static public function set hero(value:Hero):void
		{
			_instance.hero = value;

			if (_instance.hero != null)
			{
				_instance.update();
				return;
			}

			_instance.clearSprite();
		}

		override public function addButton(button:ToolButton):void
		{
			button.x = -int(this.buttons.length + 1) * BUTTON_OFFSET;
			button.hero = this.hero;

			super.addButton(button);
		}

		override public function get perksAvailable():Boolean
		{
			return super.perksAvailable && !Locations.currentLocation.nonClothes;
		}

		override public function get perksVisible():Boolean
		{
			return FooterGame.hero && (FooterGame.hero.isSquirrel || FooterGame.hero.isScrat) && !FooterGame.hero.shaman && Screens.active is ScreenGame && FlagsManager.has(Flag.MAGIC_SCHOOL_FINISH);
		}

		public function setFreeCost(value:Boolean):void
		{
			for each (var button:ClothesSkillButton in this.buttons)
				button.freeCost = value;
		}

		override protected function get hotKeys():Array
		{
			return [];
		}

		private function update():void
		{
			clearSprite();

			for each (var perk:PerkClothes in this.hero.perkController.perksClothes)
				addButton(new ClothesSkillButton(perk.code));

			redraw();
		}

		private function redraw():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xD6D6D6, 0.5);
			this.graphics.beginFill(0xC6EDFF, 0.51);

			var bgWidth:Number = this.buttons.length * BUTTON_OFFSET;
			var bgHeight:Number = this.buttonSprite.height + V_OFFSET;
			this.graphics.drawRoundRectComplex(-bgWidth, -V_OFFSET, bgWidth, bgHeight, 8, 8, 8, 8);
			this.graphics.endFill();
		}

		private function clearSprite():void
		{
			while (this.buttons.length > 0)
				(this.buttons.pop() as ClothesSkillButton).dispose();

			if (contains(this.buttonSprite))
				removeChild(this.buttonSprite);

			this.buttonSprite = new Sprite();
			addChild(this.buttonSprite);
		}

		private function onMana(e:GameEvent):void
		{
			updateButtons();
		}
	}
}