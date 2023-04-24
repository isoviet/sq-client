package dialogs.education
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.Dialog;

	public class DialogEducationFinish extends Dialog
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 15, 0x745C47, true);

		public function DialogEducationFinish():void
		{
			super(gls("Обучение завершено!"), true, true, null, false);

			init();
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 24, 0xFFCC00, null, null, null, null, null, "center");
		}

		private function init():void
		{
			var image:EducationWelcomeImage = new EducationWelcomeImage();
			image.y = 5;
			image.imageShaman.imageHandWelcome.visible = false;
			addChild(image);
			addChild(new GameField(gls("Вот и окончилось твоё обучение.\nТеперь ты знаешь всё, что надо знать белке\nдля успешной игры.\n\nВпереди тебя ждёт ещё не мало новых\nприключений и увлекательных событий."), 300, 19, FORMAT));
			addChild(new GameField(gls("Если захочешь мне помочь, у меня\nвсегда есть для тебя парочка новых\nпоручений.\n\nТы сможешь узнать о них побольше\nкликнув по кнопке заданий."), 300, 163, FORMAT));

			var buttonClose:ButtonBase = new ButtonBase(gls("Продолжить"));
			buttonClose.x = 415;
			buttonClose.y = 325;
			buttonClose.addEventListener(MouseEvent.CLICK, hide);
			addChild(buttonClose);

			place();

			this.height = 505;

			this.graphics.beginFill(0x000000, 0.3);
			this.graphics.drawRect(-this.x, -this.y, Config.GAME_WIDTH, Config.GAME_HEIGHT);
		}
	}
}