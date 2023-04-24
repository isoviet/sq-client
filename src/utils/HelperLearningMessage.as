package utils
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextFormat;

	public class HelperLearningMessage extends Sprite
	{
		public function HelperLearningMessage(text:String):void
		{
			var textFormat:TextFormat = new TextFormat(null, 11, 0x000000, true);

			var fieldText:GameField = new GameField(text, 0, 0, textFormat);
			addChild(fieldText);

			var backgroundWidth:int = Math.floor(super.width) + 30;
			var backgroundHeight:int = Math.floor(super.height) + 40;

			var background:MovieClip = new LearningMessage();
			addChildAt(background, 0);

			background.width = backgroundWidth;
			background.height = backgroundHeight;

			fieldText.x = int((background.width - fieldText.width) / 2);
			fieldText.y = int((background.height - fieldText.height) / 2) - 8;
		}
	}
}