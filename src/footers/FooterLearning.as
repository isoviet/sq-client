package footers
{
	import flash.display.Sprite;

	public class FooterLearning extends Sprite
	{
		static private var _instance:FooterLearning;

		public function FooterLearning():void
		{
			_instance = this;

			this.visible = false;

			init();
		}

		static public function show():void
		{
			_instance.visible = true;
		}

		static public function hide():void
		{
			_instance.visible = false;
		}

		private function init():void
		{
			var background:ImageFooterGame = new ImageFooterGame();
			background.y = 55;
			addChild(background);
		}
	}
}