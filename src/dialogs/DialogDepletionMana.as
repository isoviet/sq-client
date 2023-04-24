package dialogs
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.GameConfig;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class DialogDepletionMana extends Dialog
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 12, 0x673401, true);
		static private const FORMAT_CAPTION:TextFormat = new TextFormat(null, 12, 0x673401, true, null, null, null, null, 'center');

		static private var _instance:DialogDepletionMana;

		private var textField:GameField = null;

		private var spriteMana:Sprite = new Sprite();

		private var isShort:Boolean = false;

		public function DialogDepletionMana():void
		{
			this.textField = new GameField("", 0, 0, FORMAT_CAPTION);
			this.textField.width = 625;
			this.textField.wordWrap = true;
			addChild(this.textField);

			super(gls("Недостаточно маны"));

			initSpriteMana();

			place();

			this.height += 30;
			this.buttonClose.x -= 25;
		}

		static public function show():void
		{
			if (_instance == null)
				_instance = new DialogDepletionMana();
			_instance.show();
		}

		override public function show():void
		{
			this.textField.text = gls("Чтобы воспользоваться магией, тебе не хватает маны.\nТы можешь пополнить запас маны, купив:");

			this.spriteMana.y = 30;

			if (!this.isShort)
			{
				this.height -= 240;
				this.buttonClose.x -= 25;

				this.isShort = true;
			}

			super.show();
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 15;
			this.rightOffset = -5;
			this.topOffset = 10;
			this.bottomOffset = 0;
		}

		private function initSpriteMana():void
		{
			var item:Object = DrinkItemsData.DATA[DrinkItemsData.MANA_BIG_ID];

			this.spriteMana = new Sprite();
			this.spriteMana.y = 270;
			addChild(this.spriteMana);

			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(650, 240, Math.PI / 2, 0, 0);

			this.spriteMana.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			this.spriteMana.graphics.drawRect(-10, 0, 650, 240);

			this.spriteMana.graphics.beginFill(0xF7F4EC);
			this.spriteMana.graphics.lineStyle(2, 0xF4E3CA);
			this.spriteMana.graphics.drawRoundRect(0, 30, 145, 135,3);

			var image:ManaGlassBigImage = new ManaGlassBigImage();
			image.x = 22;
			image.y = 31;
			this.spriteMana.addChild(image);

			this.spriteMana.addChild(new GameField(item['title'], 150, 0, Dialog.FORMAT_CAPTION_16)).filters = Dialog.FILTERS_CAPTION;

			var field:GameField = new GameField(DrinkItemsData.getDescription(DrinkItemsData.MANA_BIG_ID), 150, 25, FORMAT);
			field.wordWrap = true;
			field.width = 460;
			this.spriteMana.addChild(field);

			var button:ButtonBase = new ButtonBase(gls("Купить за") + "   -   " + GameConfig.getManaCoinsPrice(), 200);
			button.x = 215;
			button.y = 200;
			button.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				if (Game.buyWithoutPay(PacketClient.BUY_MANA_BIG, GameConfig.getManaCoinsPrice(), 0, Game.selfId))
					hide();
			});
			this.spriteMana.addChild(button);
			FieldUtils.replaceSign(button.field, "-", ImageIconCoins, 0.7, 0.7, -button.field.x + 5, -3, false, false);
		}
	}
}