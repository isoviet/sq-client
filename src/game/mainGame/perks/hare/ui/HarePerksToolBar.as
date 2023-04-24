package game.mainGame.perks.hare.ui
{
	import game.mainGame.perks.hare.HarePerkButton;
	import game.mainGame.perks.hare.HarePerkFactory;
	import game.mainGame.perks.ui.ToolBar;
	import game.mainGame.perks.ui.ToolButton;

	public class HarePerksToolBar extends ToolBar
	{
		static private const BUTTON_OFFSET:Number = 43;
		static private const V_OFFSET:Number = 5;

		static private var _instance:HarePerksToolBar;

		public function HarePerksToolBar():void
		{
			super();

			_instance = this;

			this.buttonSprite.y = -V_OFFSET;

			//for each(var perkClass:Class in HarePerkFactory.perkCollection)
			//	addButton(new HarePerkButton(perkClass));
			for (var i:int = 0; i < 6; i++)
				addButton(new HarePerkButton(i));
		}

		static public function set hero(value:Hero):void
		{
			for each (var button:HarePerkButton in _instance.buttons)
				button.hero = value;
		}

		override public function addButton(button:ToolButton):void
		{
			button.x = this.buttons.length * BUTTON_OFFSET;
			super.addButton(button);
		}
	}
}