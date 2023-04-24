package views
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	public class DiscountTimerView extends Sprite
	{
		private var field:GameField;

		public function DiscountTimerView():void
		{
			this.graphics.beginFill(0xFF490D);
			this.graphics.lineStyle(2, 0xFFFFFF);
			this.graphics.drawRoundRect(0, 0, 56, 14, 5, 5);

			this.field = new GameField("", 0, -2, new TextFormat(null, 12, 0xFFFFFF, true));
			addChild(this.field);

			this.rotation = -10;
			this.y = 10;
		}

		public function set time(value:int):void
		{
			var timeString:String = new Date(0, 0, 0, 0, 0, value).toTimeString().slice(2, 8);
			var hours:int = int(value / (60 * 60));
			timeString = (hours > 9 ? hours : "0" + hours) + timeString;

			this.field.text = timeString;
			this.field.x = 28 - int(this.field.textWidth * 0.5) - 3;
		}
	}
}