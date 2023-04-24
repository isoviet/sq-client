package dialogs.bank
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.DialogBank;

	import utils.FieldUtils;
	import utils.HtmlTool;

	public class BankTabView extends Sprite
	{
		static private const ROWS:int = 5;
		static private const BONUS_PERCENTS:Array = [0, 5, 10, 15];
		static private const BONUS_PERCENTS_SITE:Array = [0, 4, 8, 10];
		static private const BONUS_VALUES:Array = [0, 175, 350, 700];

		static private const SITE_FORMAT:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 19, 0xFFFFFF, true);

		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 17px;
				color: #64431C;
				font-weight: bold;

			}
			.red {
				font-family: "a_PlakatTitul";
				color: #FF7E3F;
				font-size: 24px;
			}
			.small {
				font-family: "a_PlakatTitul";
				color: #FF7E3F;
				font-size: 9px;
			}
			.brown
			{
				font-size: 15px;
				color: #62411A;
				font-weight: bold;
			}
			.def
			{
				font-size: 17px;
			}
			.site
			{
				font-size: 19px;
			}
			]]>).toString();

		private var style:StyleSheet = null;

		private var buttonsArray:Array = null;
		private var buyCallback:Function = null;
		private var count:Object = null;
		private var price:Object = null;
		private var image:Class = null;

		public function BankTabView(data:Object, price:Object, image:Class, buyCallback:Function)
		{
			super();

			this.count = data;
			this.price = price;
			this.image = image;

			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.buttonsArray = [];

			this.buyCallback = buyCallback;
		}

		static private function calcBonus(price:int):int
		{
			if (price <= 0)
				return 0;

			for (var i:int = 0; i < BONUS_VALUES.length; i++)
			{
				if (BONUS_VALUES[i] > price)
					break;
			}

			return (price * (Game.site ? BONUS_PERCENTS_SITE[i - 1] : BONUS_PERCENTS[i - 1])) / 100;
		}

		public function add(index:int, bonus:Boolean):void
		{
			var isDouble:Boolean = DiscountManager.haveDouble(this.count[Config.LOCALE][index]);

			var sprite:Sprite = new Sprite();
			sprite.x = int(index / ROWS) * 425;
			sprite.y = (index % ROWS) * (Game.isGameOffer ? 48.6 : 53);
			sprite.addEventListener(MouseEvent.CLICK, buyCurrency);
			addChild(sprite);

			var bg:ButtonBankLong = new ButtonBankLong();
			sprite.addChild(bg);
			bg.width = 394;
			bg.height = 47;

			var text:String = int(this.count[Config.LOCALE][index]).toString();
			var field:GameField = new GameField("<body>" + HtmlTool.span(text, Game.site ? "site" : "def") + "</body>", 15, 12, this.style);
			field.mouseEnabled = false;
			sprite.addChild(field);

			if (isDouble)
			{
				var imageLine:RedLine = new RedLine();
				imageLine.mouseEnabled = false;
				imageLine.x = field.x + int((field.textWidth - imageLine.width) * 0.5) + 4;
				imageLine.y = field.y + int((field.textHeight - imageLine.height) * 0.5) + 4 - 2;
				sprite.addChild(imageLine);

				var imageDiscount:DiscountImage = new DiscountImage();
				imageDiscount.mouseEnabled = false;
				imageDiscount.x = field.x + field.textWidth + 10;
				imageDiscount.y = field.y + int((field.textHeight - imageDiscount.height) * 0.5);
				sprite.addChild(imageDiscount);

				field = new GameField("<body>" + HtmlTool.span(int(this.count[Config.LOCALE][index] * 2).toString(), "def")  + "</body>", 0, 12, this.style);
				field.mouseEnabled = false;
				field.x = imageDiscount.x + int((imageDiscount.width - field.textWidth) * 0.5) - 3;
				field.filters = [new DropShadowFilter(0, 0, 0xFFFFFF, 1, 4, 4, 4)];
				sprite.addChild(field);
			}

			var imageIcon:DisplayObjectContainer = new image();
			imageIcon.mouseEnabled = false;
			imageIcon.x = isDouble ? (imageDiscount.x + imageDiscount.width) : (field.x + field.textWidth + 10);
			imageIcon.y = 11;
			sprite.addChild(imageIcon);

			var lastX:int = imageIcon.x + imageIcon.width + 5;
			if (!isDouble && calcBonus(this.count[Config.LOCALE][index]) > 0 && bonus == true)
			{
				field = new GameField("<body>" + HtmlTool.span("+" + calcBonus(this.count[Config.LOCALE][index]), "red") + "</body>", imageIcon.x + imageIcon.width + 10, 2, this.style);
				field.mouseEnabled = false;
				field.filters = DialogBank.FILTERS_BONUS;
				sprite.addChild(field);

				imageIcon = new this.image();
				imageIcon.mouseEnabled = false;
				imageIcon.x = field.x + field.textWidth + 5;
				imageIcon.y = 5;
				sprite.addChild(imageIcon);

				if(!Game.site)
				{
					var fieldExtra:GameField = new GameField("<body>" + HtmlTool.span(gls("В подарок!"), "small") + "</body>", 0, field.y + field.textHeight - 7, this.style);
					fieldExtra.x = field.x + int(((field.textWidth + imageIcon.width + 5) - fieldExtra.textWidth) * 0.5);
					fieldExtra.mouseEnabled = false;
					fieldExtra.filters = DialogBank.FILTERS_BONUS;
					sprite.addChild(fieldExtra);

					lastX = fieldExtra.x + fieldExtra.width + 5;
				}
				else
				{
					field.y += 7;
					imageIcon.y = 12;
					var bonusIcon:MovieClip = new AddBonusImage();
					bonusIcon.stopAllMovieClips();
					bonusIcon.mouseEnabled = false;
					bonusIcon.x = imageIcon.x + 25;
					bonusIcon.y = 6;
					sprite.addChild(bonusIcon);

					lastX = bonusIcon.x + bonusIcon.width + 5;
				}
			}

			if (!Game.site)
			{
				field = new GameField("<body>" + DialogBank.getPriceString(this.price[Config.LOCALE][index]) + "</body>", 0, 12, this.style);
				field.mouseEnabled = false;
				field.x = 289 - field.textWidth;
				sprite.addChild(field);

				var button:ButtonBase = new ButtonBase(gls("купить"));
			}
			else
			{
				var price:String = this.price[Config.LOCALE][index].toString() + (Config.isRus ? "  -" : " $");
				button = new ButtonBase(price, 85, 17);

				if(Config.isRus)
					FieldUtils.replaceSign(button.field, "-", RusSignImage, 1, 1, -button.field.x  + 5, -6, false, true);
				button.field.setTextFormat(SITE_FORMAT);
			}

			button.enabled = false;
			button.x = 298;
			button.y = 9;
			sprite.addChild(button);

			this.buttonsArray.push(sprite);
		}

		private function buyCurrency(event:MouseEvent):void
		{
			for (var i:int = 0; i < this.buttonsArray.length; i++)
			{
				if (event.currentTarget != this.buttonsArray[i])
						continue;
				this.buyCallback(i);
				break;
			}
		}

		public function button(index:int):DisplayObject
		{
			return this.buttonsArray[index];
		}
	}
}