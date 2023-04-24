package dialogs
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.HolidayManager;

	public class DialogDoublingIngredientGet extends Dialog
	{
		static private const FILTER_DOUBLING_EVENT: Array = [new GlowFilter(0x660099, 1, 5, 5, 5), new GlowFilter(0x99CCFF, 0.5, 10, 10, 5)];

		static private var _instance:DialogDoublingIngredientGet = null;

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogDoublingIngredientGet();
			_instance.show();
		}

		public function DialogDoublingIngredientGet()
		{
			super(gls("Поздравляем!"));

			init();
		}

		override protected function get captionFormat():TextFormat
		{
			return FORMAT_CAPTION_29_CENTER;
		}

		private function init():void
		{
			var image:Sprite = new ImageDoublingIngredient;

			var buttonAction:ButtonBase = new ButtonBase(gls("Ок"), 100, 14, hide);

			this.useCaption = false;
			this.setDescription(gls("Теперь ты собираешь в два\nраза больше ингридиентов!"));

			place();

			this.width = 405;
			this.height = 420;

			this.addChild(image);

			image.x = (this.width - image.width) * 0.5 - 15;
			image.y = (this.height - image.height) * 0.5;

			for (var i:int = 0 ; i < HolidayManager.images.length; i++)
			{
				var imageClass:Class = HolidayManager.images[i];
				image = new imageClass();
				image.x = 50 + 60 * i;
				image.y = 310;
				image.filters = FILTER_DOUBLING_EVENT;
				addChild(image);
			}

			var field:GameField = new GameField("x2", 0, 235, new TextFormat(GameField.PLAKAT_FONT, 60, 0xFFFFFF));
			field.filters = FILTER_DOUBLING_EVENT;
			field.x = int((350 - field.textWidth) * 0.5);
			addChild(field);

			buttonAction.x = int((350 - buttonAction.width) * 0.5);
			buttonAction.y = 370;
			addChild(buttonAction);

			if (this.fieldMessage)
			{
				this.fieldMessage.y -= 10;
				addChild(this.fieldMessage);
			}
		}
	}
}