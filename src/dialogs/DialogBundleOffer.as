package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.BundleInsidesInfo;
	import game.gameData.BundleManager;
	import game.gameData.BundleModel;
	import loaders.RuntimeLoader;
	import screens.Screens;
	import statuses.Status;
	import views.BankBundleView;
	import views.widgets.DiscountWidget;

	import com.api.Services;

	public class DialogBundleOffer extends Dialog
	{
		static public const FILTERS:Array = [new BevelFilter(1.0, 58, 0xFF3300, 1.0, 0xFFCC00, 1.0, 2, 2),
			new GlowFilter(0xFFFFFF, 1.0, 4, 4, 8),
			new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];

		static private var showed:Object = {};

		private var type:int = -1;

		static public function show(type:int):void
		{
			if (type in showed)
				return;
			showed[type] = true;

			Screens.addCallback(function():void
			{
				RuntimeLoader.load(function ():void
				{
					new DialogBundleOffer(type).show();
				}, true);
			});
		}

		public function DialogBundleOffer(type:int):void
		{
			this.type = type;
			var bundle:BundleModel = BundleManager.getBundleById(type);

			super(bundle.name, true);

			var image:DisplayObject = new DialogBundleBack();
			addChild(image);

			var field:GameField = new GameField(this.text, 0, 0, new TextFormat(null, 14, 0x6B3A1F, true));
			field.x = int((image.width - field.textWidth) * 0.5);
			addChild(field);

			image = this.bundleImage;
			image.scaleX = image.scaleY = 1.2;
			image.x = 210 - int(image.width * 0.5);
			image.y = 80;
			addChild(image);

			field = new GameField(this.specialOffer, 0, 275, new TextFormat(GameField.PLAKAT_FONT, 15, 0xFF5515));
			field.x = 210 - int((field.textWidth) * 0.5);
			field.filters = FILTERS;
			addChild(field);

			var discountWidget:DiscountWidget = new DiscountWidget();
			discountWidget.y = 20;
			discountWidget.discount = bundle.discount;
			addChild(discountWidget);

			var object:Vector.<BundleInsidesInfo> = bundle.insidesInfo;
			var spriteBonuses:Sprite = new Sprite();
			addChild(spriteBonuses);

			for (var i:int = 0; i < object.length; i++)
			{
				var sprite:Sprite = new Sprite();
				sprite.x = i < 3 ? 5 + (i % 3) * 140 : 35 + (i % 3) * 185;
				sprite.y = 320 + int(i / 3) * 60;
				spriteBonuses.addChild(sprite);

				image = new object[i].imageClass();
				sprite.addChild(image);
				new Status(image, BankBundleView.getStatus(object[i].imageClass));

				field = new GameField(object[i].description, image.width + 5, 0, BankBundleView.FORMAT_TEXT);
				field.wordWrap = true;
				field.width = 145;
				field.y = (image.height - field.textHeight) * 0.5 - 2;
				sprite.addChild(field);
			}

			var button:ButtonBase = new ButtonBase(gls("В банк"));
			button.x = 210 - int(button.width * 0.5);
			button.y = 440;
			button.addEventListener(MouseEvent.CLICK, onClick);
			addChild(button);

			place();

			switch (this.type)
			{
				case BundleManager.NEWBIE_RICH:
				case BundleManager.NEWBIE_POOR:
					this.width -= 70;
					this.height += 40;
					break;
				case BundleManager.HOLIDAY_1000:
				case BundleManager.HOLIDAY_100:
					this.height -= 20;
					button.y -= 60;
					spriteBonuses.x += 120;
					break;
			}

			this.buttonClose.x = this.width - 35;
		}

		private function get bundleImage():DisplayObject
		{
			switch (this.type)
			{
				case BundleManager.NEWBIE_RICH:
					return new ImageBundleNewbieRich;
				case BundleManager.NEWBIE_POOR:
					return new ImageBundleNewbiePoor;
			}
			return null;
		}

		private function get text():String
		{
			switch (this.type)
			{
				case BundleManager.NEWBIE_RICH:
					return gls("Незаменимая помощь на первых порах!");
				case BundleManager.NEWBIE_POOR:
					return gls("Помощь юным белкам по невероятно выгодной цене!");
				case BundleManager.HOLIDAY_100:
				case BundleManager.HOLIDAY_500:
				case BundleManager.HOLIDAY_1000:
				case BundleManager.HOLIDAY_1500:
				case BundleManager.HOLIDAY_2000:
					return gls("Увеличь свои шансы получить заветный костюм!");
			}
			return "";
		}

		private function get specialOffer():String
		{
			switch (this.type)
			{
				case BundleManager.NEWBIE_RICH:
				case BundleManager.NEWBIE_POOR:
					return gls("Ограниченное предложение!");
			}
			return "";
		}

		private function onClick(e:MouseEvent):void
		{
			hide();

			Services.bank.open();
			BankBundleView.selectCurrent(this.type);
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 5;
			this.rightOffset = 5;
			this.topOffset = 10;
			this.bottomOffset = 0;
		}
	}
}