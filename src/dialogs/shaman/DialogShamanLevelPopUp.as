package dialogs.shaman
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import dialogs.Dialog;
	import game.gameData.ShamanTreeManager;
	import sounds.GameSounds;

	import utils.IntUtil;

	public class DialogShamanLevelPopUp extends Dialog
	{
		public function DialogShamanLevelPopUp(level:int):void
		{
			super("", true, true, DialogBaseBackground);

			init(level);
		}

		override public function show():void
		{
			super.show();

			GameSounds.play("level_up");

			this.x = this.topOffset + 20;
			this.y = this.leftOffset + 40;
		}

		override protected function effectOpen():void
		{}

		private function init(level:int):void
		{
			var caption:GameField = new GameField(gls("Новый уровень шамана!"), 105, 12, new TextFormat(GameField.DEFAULT_FONT, 16, 0x453214, true));
			caption.mouseEnabled = false;
			addChild(caption);

			var digitImage:MovieClip;
			var digits:Vector.<int> = IntUtil.parseDigits(level);
			var classDefinition:Class = null;
			var spriteDigits:Sprite = new Sprite();

			for (var i:int = 0, x:int = 0; i < digits.length; i++)
			{
				classDefinition = ShamanTreeManager.LEVEL_NUMBERS[digits[i]];
				digitImage = new classDefinition();
				digitImage.scaleX = digitImage.scaleY = 0.6;
				digitImage.x = x;
				digitImage.y = digitImage.height + i * 6;
				spriteDigits.addChild(digitImage);

				x = digitImage ? (digitImage.x + digitImage.width - 2) : 20;
			}

			spriteDigits.x = 55 - spriteDigits.width / 2;
			spriteDigits.y = 85 - spriteDigits.height;
			addChild(spriteDigits);

			var feathersIcon:ImageIconFeather = new ImageIconFeather();
			feathersIcon.x = spriteDigits.x + spriteDigits.width - 27;
			feathersIcon.y = 67;
			addChild(feathersIcon);

			var fieldAward:GameField = new GameField(gls("Тебе доступно волшебное перо, которое ты можешь использовать для изучения способностей."), 105, 43, new TextFormat(GameField.DEFAULT_FONT, 13, 0x000000));
			fieldAward.width = 220;
			fieldAward.wordWrap = true;
			fieldAward.multiline = true;
			addChild(fieldAward);

			place();
			this.width = 350;
			this.height = 130;
			this.buttonClose.x -= 22;
		}
	}
}