package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;

	public class DialogPaymentResult extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 20px;
				color: #000000;
				font-weight: bold;
				text-align: center;
				letter-spacing: -1;
			}
			.redText {
				color: #D95F00;
			}
		]]>).toString();

		static private const WIDTH:int = 290;

		private var coinsField:GameField;

		private var awardSprite:Sprite;

		private var coinsImage:DisplayObject = null;

		public function DialogPaymentResult()
		{
			super(gls("Поздравляем"));

			init();
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, Config.isRus ? 29 : 24, 0xFFCC00, null, null, null, null, null, "center");
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			this.coinsField.text = "";

			if (this.coinsImage)
				this.coinsImage.visible = false;
		}

		public function setBalance(coins:int):void
		{
			if (coins == 0)
				return;

			if (coins != 0)
			{
				this.coinsField.htmlText = "<body>+<span class='redText'>" + coins.toString() + "</span></body>";

				if (this.coinsImage == null)
				{
					this.coinsImage = new ImageIconCoins();
					this.coinsImage.y = this.coinsField.y + 3;
					this.awardSprite.addChild(this.coinsImage);
				}
				this.coinsImage.visible = true;
			}

			update();

			if (!this.visible)
				show();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var background:PaymentResultImage = new PaymentResultImage();
			background.x = 70;
			background.y = 5;
			background.scaleX = background.scaleY = 1.2;
			addChild(background);

			var field:GameField = new GameField(gls("Ты получил:"), 80, 100, new TextFormat(null, 15, 0x000000, true));
			addChild(field);

			this.awardSprite = new Sprite();
			addChild(this.awardSprite);

			this.coinsField = new GameField("", 0, 116, style);
			this.awardSprite.addChild(this.coinsField);

			var okButton:ButtonBase = new ButtonBase(gls("принять"));
			okButton.addEventListener(MouseEvent.CLICK, hide);

			place(okButton);

			this.width = WIDTH;
			this.height = 240;
		}

		private function update():void
		{
			if (this.coinsImage)
				this.coinsImage.x = this.coinsField.x + this.coinsField.textWidth + 6;

			this.awardSprite.x = (WIDTH - this.awardSprite.width - 60) / 2;
		}
	}
}