package dialogs
{
	import flash.display.DisplayObject;
	import flash.filters.DropShadowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import clans.TotemsData;
	import views.GameBonusImageView;
	import views.GameBonusValueView;

	import utils.FieldUtils;

	public class DialogTotemBonus extends DialogNotificationBg
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-size: 16px;
				color: #000000;
				font-weight: normal;
			}
			.bold {
				font-weight: bold;
			}
			]]>).toString();

		static private const OFFSET_X:int = 78;

		private var count:int = 0;
		private var bonusImage:DisplayObject;

		public function DialogTotemBonus(count:int, type:int)
		{
			super();

			this.count = count;

			init(type);
		}

		override protected function effectOpen():void
		{}

		override public function show():void
		{
			super.show();

			this.x = this.topOffset + 20;
			this.y = this.leftOffset + 150;

			showBonus();
		}

		private function init(type:int):void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var caption:GameField = new GameField(TotemsData.getName(type), OFFSET_X, 12, new TextFormat(null, 16, 0xFCF43E, true));
			caption.mouseEnabled = false;
			caption.filters = [new DropShadowFilter(0, 0, 0x126419, 1, 5, 5, 10)];
			addChild(caption);

			var itemIcon:TotemItemCircleImage = new TotemItemCircleImage();
			itemIcon.x = 15;
			itemIcon.y = 15;
			addChild(itemIcon);

			var image:DisplayObject = TotemsData.getIcon(type);
			image.x = itemIcon.x + 13;
			image.y = itemIcon.y + 8;
			addChild(image);

			var description:GameField = new GameField("", OFFSET_X, 35, style);
			description.htmlText = gls("<body>Бонус <span class = 'bold'>+{0} </span> #Award</body>", this.count);
			description.mouseEnabled = false;
			addChild(description);

			var bonusIcon:DisplayObject;

			switch (type)
			{
				case TotemsData.MAGIC:
					this.bonusImage = new ImageIconMana();
					FieldUtils.replaceSign(description, "#Award", ImageIconMana, 0.8, 0.8, description.x - 155, -description.y, true, true);
					bonusIcon = new ImageIconMana();
					break;
				case TotemsData.ACORNS:
					this.bonusImage = new ImageIconNut();
					FieldUtils.replaceSign(description, "#Award", ImageIconNut, 0.8, 0.8, description.x - 155, -description.y, true, true);
					bonusIcon = new ImageIconNut();
					break;
				case TotemsData.EXP:
					this.bonusImage = new ImageIconExp();
					FieldUtils.replaceSign(description, "#Award", ImageIconExp, 0.8, 0.8, description.x - 155, -description.y, true, true);
					bonusIcon = new ImageIconExp();
					break;
			}

			place();

			this.height += 30;
			this.width += 50;

			this.buttonClose.x += 5;
			this.buttonClose.y += 5;
		}

		private function showBonus():void
		{
			var acornValueView:GameBonusValueView = new GameBonusValueView(this.count, 155, 40);
			Game.gameSprite.addChild(acornValueView);

			var acornImageView:GameBonusImageView = new GameBonusImageView(this.bonusImage, acornValueView.x + int(acornValueView.width), 135, 160, 5);
			Game.gameSprite.addChild(acornImageView);
		}

	}
}