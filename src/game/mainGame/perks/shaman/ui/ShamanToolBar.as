package game.mainGame.perks.shaman.ui
{
	import flash.display.Sprite;
	import flash.ui.Keyboard;

	import footers.FooterGame;
	import game.mainGame.gameSchool.SquirrelGameSchool;
	import game.mainGame.perks.IPerkWithoutButton;
	import game.mainGame.perks.shaman.PerkShaman;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import game.mainGame.perks.ui.ToolBarOld;
	import game.mainGame.perks.ui.ToolButtonOld;
	import screens.ScreenGame;
	import screens.Screens;

	public class ShamanToolBar extends ToolBarOld
	{
		static private const BUTTON_SIZE:int = 35;
		static private const BUTTON_OFFSET:int = 10;

		static private const H_OFFSET:Number = 5;
		static private const V_OFFSET:Number = 7;

		static private const BUTTONS_IN_COLUMN:int = 2;

		static private var _instance:ShamanToolBar = null;

		private var hero:Hero = null;

		private var bgWidth:Number;
		private var bgHeight:Number;

		public function ShamanToolBar():void
		{
			super();

			_instance = this;
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

		static public function get visible():Boolean
		{
			return _instance.visible;
		}

		override public function get perksVisible():Boolean
		{
			return super.perksVisible && FooterGame.hero && FooterGame.hero.shaman && (Screens.active is ScreenGame) && ScreenGame.mode != Locations.BLACK_SHAMAN_MODE && !(FooterGame.hero.game is SquirrelGameSchool);
		}

		override public function addButton(button:ToolButtonOld):void
		{
			button.y = int(this.buttons.length % BUTTONS_IN_COLUMN) * (BUTTON_SIZE + BUTTON_OFFSET);
			button.x = int(this.buttons.length / BUTTONS_IN_COLUMN) * (BUTTON_SIZE + BUTTON_OFFSET);

			button.hero = this.hero;

			super.addButton(button);
		}

		override public function get width():Number
		{
			return this.bgWidth;
		}

		override public function get height():Number
		{
			return this.bgHeight;
		}

		override protected function get keyCode():uint
		{
			return Keyboard.T;
		}

		private function update():void
		{
			clearSprite();

			var abilityIds:Array = [];

			for each (var perk:PerkShaman in this.hero.perkController.perksShaman)
			{
				if (perk is IPerkWithoutButton)
					continue;

				abilityIds.push(PerkShamanFactory.getId(perk));
			}

			abilityIds.sort(Array.NUMERIC);

			for (var i:int = 0; i < abilityIds.length; i++)
				addButton(new ShamanSkillButton(PerkShamanFactory.getClassById(abilityIds[i])));

			redraw();
		}

		private function redraw():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xD6D6D6, 0.5);
			this.graphics.beginFill(0xC6EDFF, 0.51);

			this.bgWidth = (int(this.buttons.length / BUTTONS_IN_COLUMN) + this.buttons.length % BUTTONS_IN_COLUMN) * (BUTTON_SIZE + BUTTON_OFFSET) + H_OFFSET * 2 - BUTTON_OFFSET;
			this.bgHeight = (this.buttons.length < BUTTONS_IN_COLUMN ? this.buttons.length : BUTTONS_IN_COLUMN) * (BUTTON_SIZE + BUTTON_OFFSET) + 2 * V_OFFSET - BUTTON_OFFSET;
			this.graphics.drawRoundRectComplex(-H_OFFSET, -V_OFFSET, this.bgWidth, this.bgHeight, 8, 8, 8, 8);
			this.graphics.endFill();
		}

		private function clearSprite():void
		{
			while (this.buttons.length > 0)
				(this.buttons.pop() as ShamanSkillButton).dispose();

			if (contains(this.buttonSprite))
				removeChild(this.buttonSprite);

			this.buttonSprite = new Sprite();
			addChild(this.buttonSprite);
		}
	}
}