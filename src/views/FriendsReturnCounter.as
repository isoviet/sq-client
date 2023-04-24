package views
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	public class FriendsReturnCounter extends Sprite
	{
		private var acornsCount:GameField = null;
		private var expCount:GameField = null;
		private var playersCount:GradientText = null;

		public function FriendsReturnCounter()
		{
			var format:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0x4F3412);

			this.acornsCount = new GameField("+100", 108, 18, format);
			this.acornsCount.rotation = -30;
			addChild(this.acornsCount);

			this.expCount = new GameField("+100", 200, 18, format);
			this.expCount.rotation = -30;
			addChild(this.expCount);

			this.playersCount = new GradientText("x1", new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFA901), [0xFFC125, 0xFF3300], [new GlowFilter(0x4F3412, 1, 3, 3, 4)]);
			this.playersCount.rotation = -30;
			this.playersCount.y = 14;
			this.playersCount.x = 2;
			addChild(this.playersCount);
		}

		public function set count(value:int):void
		{
			this.visible = value > 0;
			if (!this.visible)
				return;

			this.acornsCount.text = "+" + value * 50;
			this.expCount.text = "+" + value * 500;
			this.playersCount.text = "x" + value.toString();
		}
	}
}