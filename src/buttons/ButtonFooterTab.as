package buttons
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextFormat;

	public class ButtonFooterTab extends SimpleButton
	{
		static public const FORMATS:Array = [new TextFormat(GameField.PLAKAT_FONT, 15, 0xFFFFFF), new TextFormat(GameField.PLAKAT_FONT, 15, 0xFFDD77), new TextFormat(GameField.PLAKAT_FONT, 15, 0xFFCC33)];
		static public const FORMATS_14:Array = [new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF), new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFDD77), new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFCC33)];

		//TODO rework
		public function ButtonFooterTab(text:String, formats:Array = null, buttonClass:Class = null, offsetY:int = -2, offsetX:int = 0, filtersText:Array = null):void
		{
			if (formats == null)
				formats = FORMATS;
			if (buttonClass == null)
				buttonClass = ButtonFooterTabBack;
			var button:SimpleButton = new buttonClass();

			var array:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			array.push(button.upState, button.overState, button.downState);
			var sprites:Vector.<Sprite> = new Vector.<Sprite>();

			for (var i:int = 0; i < array.length; i++)
			{
				sprites.push(new Sprite);

				var field:GameField = new GameField(text, 0, offsetY, formats[i]);
				field.x = int((array[i].width - field.textWidth) * 0.5) + offsetX;
				field.filters = filtersText;
				sprites[i].addChild(array[i]);
				sprites[i].addChild(field);
			}

			super(sprites[0], sprites[1], sprites[2], button.hitTestState);
		}
	}
}