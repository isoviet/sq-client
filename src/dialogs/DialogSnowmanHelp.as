package dialogs
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import utils.FieldUtils;

	public class DialogSnowmanHelp extends Dialog
	{
		static public var showed:Boolean = false;

		public function DialogSnowmanHelp():void
		{
			super();

			init();
		}

		private function init():void
		{
			var sprite:Sprite = new Sprite();
			//sprite.addChild(new DialogSnowmanCaption);

			var field:GameField = new GameField(gls(" * Хватай ледяные блоки, чтобы построить путь до сугробов со снегом\n * Отнеси снег от сугробов к снеговику\n * Чем больше снега принесут белочки снеговику, тем больше они получат снежинок\n * Следи за прогрессом на индикаторе в нижней панели."), 0, 30, new TextFormat(null, 18, 0x6D430D));
			field.width = 345;
			field.multiline = true;
			field.wordWrap = true;
			sprite.addChild(field);

			FieldUtils.replaceSign(field, "*", TextItemImage, 1.5, 1.5, 0, -33, false);

			/*var okButton:OkButton = new OkButton();
			okButton.x = 125;
			okButton.y = 220;
			okButton.addEventListener(MouseEvent.CLICK, hide);
			sprite.addChild(okButton);
*/
			sprite.x = 10;
			sprite.y = 30;
			addChild(sprite);

			place();

			this.width += 15;
			this.height += 40;
		}
	}
}