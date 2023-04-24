package game.mainGame.perks.dragon.ui
{
	import game.mainGame.perks.dragon.DragonPerkFactory;
	import game.mainGame.perks.ui.ToolBar;
	import game.mainGame.perks.ui.ToolButton;

	public class DragonPerksToolBar extends ToolBar
	{
		static private const BUTTON_OFFSET:Number = 43;
		static private const V_OFFSET:Number = 5;

		static private var _instance:DragonPerksToolBar;

		public function DragonPerksToolBar():void
		{
			_instance = this;

			this.buttonSprite.y = -V_OFFSET;

			//for each(var perkClass:Class in DragonPerkFactory.perkCollection)
			//	addButton(new DragonPerkButton(perkClass));
			for (var i:int = 0; i < 2; i++)
				addButton(new DragonPerkButton(i));
		}

		static public function set hero(value:Hero):void
		{
			for each (var button:DragonPerkButton in _instance.buttons)
				button.hero = value;
		}

		override public function addButton(button:ToolButton):void
		{
			button.x = this.buttons.length * BUTTON_OFFSET;
			super.addButton(button);
		}

		override protected function get hotKeys():Array
		{
			return [];
		}
	}
}