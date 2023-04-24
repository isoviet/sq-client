package views
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import utils.DateUtil;

	public class CloseoutTimerView extends Sprite
	{
		static private const FORMAT_TEXT:TextFormat = new TextFormat(null, 11, 0x9D6C57, true);
		static private const FORMAT_VALUE:TextFormat = new TextFormat(null, 14, 0xFF1F13, true);

		static private var elements:Array = [];

		private var timeField:GameField = null;

		public function CloseoutTimerView()
		{
			elements.push(this);

			init();

			this.mouseEnabled = false;
		}

		static public function update(secondsLeft:int):void
		{
			var timeString:String = getTimeString(secondsLeft);
			for each (var element:CloseoutTimerView in elements)
				element.update(timeString);
		}

		static private function getTimeString(secondsLeft:int):String
		{
			return DateUtil.durationDayTime(secondsLeft);
		}

		public function dispose():void
		{
			var index:int = elements.indexOf(this);
			if (index != -1)
				elements.splice(index, 1);
		}

		private function init():void
		{
			var field:GameField = new GameField(gls("Акция действует:"), 0, 0, FORMAT_TEXT);
			addChild(field);

			this.timeField = new GameField("00:00:00", 0, 0, FORMAT_VALUE);
			this.timeField.x = field.width + 2;
			this.timeField.y = field.textHeight - this.timeField.textHeight;
			addChild(this.timeField);

			update("00:00:00");
		}

		private function update(timeString:String):void
		{
			this.timeField.text = timeString;
			this.x = 105 - int(this.width * 0.5);
		}
	}
}