package views
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getQualifiedClassName;

	import buttons.ButtonBase;
	import buttons.ButtonBaseMultiLine;
	import buttons.ButtonFooterTab;
	import dialogs.Dialog;
	import dialogs.DialogShop;
	import dialogs.hotWheels.DialogHotWheels;
	import events.DiscountEvent;
	import game.gameData.DialogOfferManager;
	import game.gameData.EducationQuestManager;
	import game.gameData.NotificationManager;
	import game.gameData.OutfitData;
	import loaders.RuntimeLoader;
	import screens.Screens;
	import tape.TapeNewsData;
	import tape.TapeNewsElement;
	import tape.TapeNewsView;

	import by.blooddy.crypto.image.PNGEncoder;

	import com.api.Services;
	import com.inspirit.MultipartURLLoader;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.FieldUtils;
	import utils.FiltersUtil;
	import utils.LoaderUtil;
	import utils.StageQualityUtil;
	import utils.WallTool;

	public class TvView extends Dialog
	{
		static private const MAX_COUNT:int = 4;

		static private const IMG_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 15, 7);
		static private const FRAME_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 2, 2);
		static private const LOGO_MATRIX:Matrix = new Matrix(0.5, 0, 0, 0.5, 30, 400);
		static private const IMAGERECT:Rectangle = new Rectangle(0, 0, 720, 470);

		static private var LOGO:DisplayObject = null;
		static private var FRAME:DisplayObject = null;

		static private const FORMAT_TEXT_BROWN:TextFormat = new TextFormat(null, 18, 0x661824, true, null, null, null, null, "center");
		static private const FORMAT_TEXT_WHITE:TextFormat = new TextFormat(null, 18, 0xFFFFFF, true, null, null, null, null, "center");
		static private const FORMAT_TEXT_BROWNW:TextFormat = new TextFormat(null, 18, 0x2E150C, true, null, null, null, null, "center");
		static private const FORMAT_TEXT_YELLOW:TextFormat = new TextFormat(null, 18, 0xFEFD99, true, null, null, null, null, "center");

		static private const FORMAT_CAPTION_YELLOW:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 28, 0xFFFD7B);
		static private const FORMAT_CAPTION_WHITE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 28, 0xFFFFFF);
		static private const FORMAT_CAPTION_BROWN:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 28, 0xFFCE31);

		static private const FILTERS_CAPTION_YELLOW:Array = [new BevelFilter(1.0, 58, 0xFFFFFF, 1.0, 0x996600, 1.0, 2, 2),
			new GlowFilter(0x663300, 1.0, 4, 4, 8),
			new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];

		static public const BUNDLES:int = 112;
		static public const NEW_SITE:int = 116;
		static public const CAMERA_TRACK:int = 122;
		static public const PACKAGES_18_05:int = 127;
		static public const HOT_WHEELS:int = 128;

		static private var _instance:TvView = null;

		static private var newsStorage:Object = {};
		static private var newsTexts:Object = {};
		static private var newsButtons:Object = {};
		static private var newsImages:Object = {};

		static public var last_news:int = -1;
		static public var have_action:Boolean = false;

		private var currentIndex:int = -1;
		private var _newsId:int = -1;
		private var isDiscount:Boolean = false;

		private var tapeNews:TapeNewsView = null;
		private var buttonRepost:SimpleButton = null;
		private var imageAward:MovieClip = null;

		private var socialType:String;

		public function TvView():void
		{
			super(null, true, true, null, false);

			init();

			DiscountManager.addEventListener(DiscountEvent.END, onRemoveDiscount);
		}

		static public function get instance():TvView
		{
			return _instance;
		}

		static public function show(force:Boolean = false):void
		{
			if (!_instance)
				_instance = new TvView();

			if (!force && !have_action && NotificationManager.instance.lastNews == last_news)
			{
				Screens.setStatus(Screens.TV);
				return;
			}
			NotificationManager.instance.saveNewsData(last_news);
			DialogOfferManager.showed(DialogOfferManager.NEWS);
			_instance.show();

			EducationQuestManager.done(EducationQuestManager.NEWS);
		}

		static public function getButtonClass(id:int):Class
		{
			switch (id)
			{
				case BUNDLES:
					return BundlesButton;
				case NEW_SITE:
					return NewSiteButton;
				case PACKAGES_18_05:
					return Packages170516Button;
				case CAMERA_TRACK:
					return CameraTrackButton;
				case HOT_WHEELS:
					return HotWheelsButton;
			}
			return null;
		}

		static public function getNews(id:int):MovieClip
		{
			if (id in newsStorage)
				return newsStorage[id];

			switch (id)
			{
				case BUNDLES:
					newsStorage[id] = new NewsBundles();
					addCaption(newsStorage[id], FORMAT_CAPTION_YELLOW, FILTERS_CAPTION_YELLOW, gls("Потрясающие сундуки на любой вкус!"));
					addText(newsStorage[id], FORMAT_TEXT_BROWN, [], gls("Невероятно роскошные предложения!\nВыбирай те, что по душе - успей купить по выгодной цене!"));
					newsButtons[id] = addButton(newsStorage[id], gls("В банк"), function(e:MouseEvent):void
					{
						_instance.hide();
						RuntimeLoader.load(function ():void
						{
							Services.bank.open();
						});
					});
					newsTexts[id] = gls("В Трагедии Белок 2 появились потрясающие сундуки! Спеши в банк, чтобы увидеть все уникальные предложения! И не расслабляйся скоро появятся новые удивительные сундуки!");
					break;
				case NEW_SITE:
					newsStorage[id] = new NewSiteNews();
					addCaption(newsStorage[id], FORMAT_CAPTION_YELLOW, FILTERS_CAPTION_YELLOW, gls("Новый сайт Трагедии Белок!"));
					addText(newsStorage[id], FORMAT_TEXT_YELLOW, [new GlowFilter(0x241C59, 1, 12, 12, 3, 2)], gls("Играй на сайте и получай невероятную выгоду!"));

					var field:GameField = new GameField(gls("БЕСКОНЕЧНАЯ энергия - на 30 дней!"), 80, 115, FORMAT_TEXT_WHITE);
					field.filters = [new GlowFilter(0x241C59, 1, 12, 12, 3, 2)];
					newsStorage[id].addChild(field);
					FieldUtils.replaceSign(field, "-", ImageIconEnergy, 1, 1, -field.x, -field.y, false, true);
					field.setTextFormat(FORMAT_TEXT_YELLOW, 0, 11);

					field = new GameField(gls("Щедрые ПОДАРКИ каждый день!"), 80, 142, FORMAT_TEXT_WHITE);
					field.filters = [new GlowFilter(0x241C59, 1, 12, 12, 3, 2)];
					field.setTextFormat(FORMAT_TEXT_YELLOW, 7, 14);
					newsStorage[id].addChild(field);

					var format:TextFormat = FORMAT_TEXT_WHITE;
					format.align = TextFormatAlign.LEFT;
					field = new GameField(gls("БОНУСЫ за покупку монет!\nи много другое!"), 80, 167, format);
					field.filters = [new GlowFilter(0x241C59, 1, 12, 12, 3, 2)];
					field.setTextFormat(FORMAT_TEXT_YELLOW, 0, 6);
					newsStorage[id].addChild(field);

					newsButtons[id] = addButton(newsStorage[id], gls("Перейти на сайт"), function(e:MouseEvent):void
					{
						_instance.hide();

						Connection.sendData(PacketClient.COUNT, PacketClient.NEWS_SITE_REDIRECT);

						navigateToURL(new URLRequest("http://www.racefornuts.com/?lang_change=" + Config.LOCALE), "_blank");
					});
					newsTexts[id] = gls("Новый сайт Трагедии Белок! Играй на нашем сайте и получай невероятную выгоду!");
					break;
				case PACKAGES_18_05:
					newsStorage[id] = new Packages170516News();
					var textField:GameField = addCaption(newsStorage[id], FORMAT_CAPTION_BROWN, FILTERS_CAPTION_YELLOW, gls("Модная среда в трагедии белок!"));
					addText(newsStorage[id], FORMAT_TEXT_BROWNW, [new GlowFilter(0xF6E5E3, 1, 7, 7, 3, 2)], gls("НОВЫЕ, невероятно КРУТЫЕ образы для твоей белки!"));

					textField.setTextFormat(FORMAT_CAPTION_YELLOW, 0, Config.isRus ? 12 : 18);

					newsButtons[id] = addButton(newsStorage[id], gls("Магазин"), function(e:MouseEvent):void
					{
						_instance.hide();
						RuntimeLoader.load(function ():void
						{
							DialogShop.selectTape(DialogShop.PACKAGES);
							DialogShop.selectOutfit(OutfitData.packageToOutfit(OutfitData.ORC), OutfitData.ORC);
						});
					});
					newsTexts[id] = gls("Модная среда в Трагедии Белок! Невероятно крутые образы Орка и Чарли Чаплина уже в игре!");
					break;
				case CAMERA_TRACK:
					newsStorage[id] = new CameraTrackNews();
					field = addCaption(newsStorage[id], FORMAT_CAPTION_WHITE, FILTERS_CAPTION_YELLOW, gls("Твоя белка в центре внимания!"));
					Config.isRus ? field.setTextFormat(FORMAT_CAPTION_YELLOW, 11, 19) : field.setTextFormat(FORMAT_CAPTION_YELLOW, 21, 31);
					newsButtons[id] = addButton(newsStorage[id], gls("Подробнее"), function(e:MouseEvent):void
					{
						navigateToURL(new URLRequest("http://www.racefornuts.com/news/30/?lang_change=" + (Config.isRus ? "ru" : "en")), "_blank");

						_instance.hide();
					});
					newsTexts[id] = gls("Обновление в Трагедии Белок! Теперь тебе не придётся искать свою белочку среди всех игроков!");
					break;
				case HOT_WHEELS:
					newsStorage[id] = new HotWheelsNews();
					newsButtons[id] = addButton(newsStorage[id], gls("Подробнее"), function(e:MouseEvent):void
					{
						DialogHotWheels.show();

						_instance.hide();
					});
					newsButtons[id].x = 450;
					newsButtons[id].y = 405;
					break;
			}
			if (newsButtons[id] != null)
				newsButtons[id].addEventListener(MouseEvent.CLICK, onUsed);
			return newsStorage[id];
		}

		static private function addCaption(parent:MovieClip, format:TextFormat, filters:Array, value:String):GameField
		{
			var field:GameField = new GameField(value, 0, 35, format);
			field.x = 350 - int(field.textWidth * 0.5);
			field.filters = filters;
			parent.addChild(field);

			return field;
		}

		static private function addText(parent:MovieClip, format:TextFormat, filters:Array, value:String):void
		{
			var field:GameField = new GameField(value, 0, 75, format);
			field.x = 350 - int( field.textWidth * 0.5);
			field.filters = filters;
			parent.addChild(field);
		}

		static private function addButton(parent:MovieClip, value:String, handler:Function):ButtonBase
		{
			var button:ButtonBaseMultiLine = new ButtonBaseMultiLine(value, 0, 21, handler, 1.5);
			button.x = 350 - int(button.width * 0.5);
			button.y = 400;
			parent.addChild(button);

			return button;
		}

		static private function onUsed(e:MouseEvent):void
		{
			DialogOfferManager.used(DialogOfferManager.NEWS);
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			Screens.setStatus(Screens.TV);
		}

		private function init():void
		{
			if ("useApiType" in PreLoader.session)
				this.socialType = PreLoader.session['useApiType'];
			else if ("useapitype" in PreLoader.session)
				this.socialType = PreLoader.session['useapitype'];
			else
				this.socialType = Config.DEFAULT_API;

			place();

			this.width = 857;
			this.height = 587;

			var format:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 28, 0xFFFFFF);
			this.buttonRepost = new ButtonFooterTab(gls("Поделиться!"), [format, format, format], ButtonNewsRepost, 15, -10, [new BevelFilter(1, 300, 0xFFFFFF, 1.0, 0x4B8036, 1.0, 1, 1)]);
			this.buttonRepost.x = 335;
			this.buttonRepost.y = 480;
			this.buttonRepost.addEventListener(MouseEvent.CLICK, post);
			addChild(this.buttonRepost);

			this.imageAward = new ImageNewsAward();
			this.imageAward.mouseEnabled = false;
			this.imageAward.mouseChildren = false;
			this.imageAward.x = this.buttonRepost.x + 370;
			this.imageAward.y = this.buttonRepost.y + 7;
			addChild(this.imageAward);

			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xFFFFFF);
			sprite.graphics.lineStyle(1, 0xE0CFC1);
			sprite.graphics.drawRoundRect(10, 480, 310, 70, 15, 15);
			sprite.filters = [new DropShadowFilter(4, 136, 0xC7AF96, 1, 6, 6, 1, 1, true)];
			addChild(sprite);

			var tapeData:TapeNewsData = new TapeNewsData();
			tapeData.setData(this.baseNews);
			this.tapeNews = new TapeNewsView(onChange);
			this.tapeNews.setData(tapeData);
			addChild(this.tapeNews);
		}

		private function removePage(id:int = 0, type:int = 0):void
		{
			this.tapeNews.removeObject(id, type);
		}

		private function onRemoveDiscount(e:DiscountEvent):void
		{
			removePage(e.id, TapeNewsElement.DISCOUNT);
		}

		private function get baseNews():Array
		{
			var data:Array = [];

			//if (Config.isRus)
			//	data.push(HOT_WHEELS);
			data.push(PACKAGES_18_05);
			data.push(CAMERA_TRACK);
			data.push(NEW_SITE);
			data.push(BUNDLES);

			last_news = data[0];
			if (last_news == NotificationManager.instance.lastNews)
				NotificationDispatcher.hide(NotificationManager.NEWS);

			data = data.slice(0, MAX_COUNT);
			return data.reverse();
		}

		private function onChange(index:int, isDiscount:Boolean):void
		{
			this.isDiscount = isDiscount;
			this.currentNews = index;
		}

		private function get currentNews():int
		{
			return this._newsId;
		}

		private function set currentNews(value:int):void
		{
			this._newsId = value;

			this.buttonRepost.filters = this.canPost ? [] : FiltersUtil.GREY_FILTER;
			this.buttonRepost.mouseEnabled = this.canPost;
			this.imageAward.visible = this.canPost && (Game.newsRepost.indexOf(this._newsId) == -1) && !this.isDiscount;
		}

		private function get canPost():Boolean
		{
			return (this.socialType != "sa");
		}

		private function post(e:MouseEvent):void
		{
			if (this.isDiscount)
			{
				if (Game.self.type == Config.API_VK_ID)
					WallTool.place(Game.self, WallTool.WALL_NEWS, 0, new Bitmap(generateBitmapDiscount()), gls("Уникальная акция в Трагедии Белок! Заходи скорее в игру!"));
				else
					LoaderUtil.uploadFile(Config.SCREENSHOT_UPLOAD_URL, PNGEncoder.encode(generateBitmapDiscount()), {}, onUploadResultsComplete, onUploadError);
			}
			else
			{
				this.currentIndex = this.currentNews;

				var imageName:String = getQualifiedClassName(newsStorage[this.currentNews]);
				if (imageName.indexOf("::") != -1)
					imageName = imageName.split("::")[1];
				NewsImageGenerator.save(generateBitmap(), imageName);
				WallTool.place(Game.self, WallTool.WALL_NEWS, 0, new Bitmap(generateBitmap()), newsTexts[this.currentNews], Config.IMAGES_URL + "news/" + imageName + ".jpg", true, onPost);
			}
		}

		private function onPost(response:Object):void
		{
			if (response == null || this.currentIndex == -1)
				return;

			Connection.sendData(PacketClient.REPOST_NEWS, 0, this.currentIndex);
			Game.newsRepost.push(this.currentIndex);

			this.currentIndex = -1;
		}

		private function onUploadResultsComplete(e:Event):void
		{
			var newResultsURL:String = (e.currentTarget as MultipartURLLoader).loader.data;

			WallTool.place(Game.self, WallTool.WALL_NEWS, 0, null, gls("Уникальная акция в Трагедии Белок! Заходи скорее в игру!"), newResultsURL);
		}

		private function onUploadError(e:Event):void
		{
			Logger.add("Error on upload game results!");
		}

		private function generateBitmap():BitmapData
		{
			if (!(this.currentNews in newsImages))
			{
				var quality:String = Game.stage.quality;
				StageQualityUtil.toggleQuality(StageQuality.HIGH);

				if (FRAME == null)
					FRAME = new ImageNewsFrame();
				var bitmapData:BitmapData = new BitmapData(FRAME.width + 3, FRAME.height + 3);

				var button:DisplayObject = newsButtons[this.currentNews];
				if (button)
					button.visible = false;
				bitmapData.draw(newsStorage[this.currentNews], IMG_MATRIX, null, null, IMAGERECT);
				if (button)
					button.visible = true;

				if (LOGO == null)
					LOGO = PreLoader.getLogo();

				bitmapData.draw(LOGO, LOGO_MATRIX);
				bitmapData.draw(FRAME, FRAME_MATRIX);
				newsImages[this.currentNews] = bitmapData;

				StageQualityUtil.toggleQuality(quality);
			}
			return newsImages[this.currentNews];
		}

		private function generateBitmapDiscount():BitmapData
		{
			var quality:String = Game.stage.quality;
			StageQualityUtil.toggleQuality(StageQuality.HIGH);

			if (FRAME == null)
				FRAME = new ImageNewsFrame();
			var bitmapData:BitmapData = new BitmapData(FRAME.width + 3, FRAME.height + 3);
			var image:Sprite = this.tapeNews.getImage();
			bitmapData.draw(image, new Matrix(image.scaleX, 0, 0, image.scaleY, image.x, image.y), null, null, IMAGERECT);

			if (LOGO == null)
				LOGO = PreLoader.getLogo();

			bitmapData.draw(LOGO, LOGO_MATRIX);
			bitmapData.draw(FRAME, FRAME_MATRIX);

			StageQualityUtil.toggleQuality(quality);
			return bitmapData;
		}
	}
}