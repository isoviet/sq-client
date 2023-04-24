package views.widgets
{
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class HotKeyView extends LearningKey
	{
		static private const DEFAULT:TextFormat = new TextFormat(null, 14, 0, true, null, null, null, null, TextFormatAlign.CENTER);

		public function HotKeyView(key:String)
		{
			super();

			var text:GameField = new GameField(key, 0, 0, DEFAULT, this.width);
			text.mouseEnabled = false;
			text.x = -1;
			text.y = this.height/2 - text.height/2 - 2;
			addChild(text);
		}
	}
}