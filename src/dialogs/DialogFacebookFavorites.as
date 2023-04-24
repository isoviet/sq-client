package dialogs
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;

	import utils.FieldUtils;

	public class DialogFacebookFavorites extends Dialog
	{

		static private var titleFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0x755E4A, false, null, null, null, null, TextFormatAlign.CENTER);
		static private var itemFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 14, 0x755E4A, false, null, null, null, null, TextFormatAlign.LEFT);

		static private const FILE_NAME:String = "Facebook";

		static private var _instance:DialogFacebookFavorites = null;

		private var moviePreload:MovieClip = null;
		private var loader:Loader = null;

		public function DialogFacebookFavorites()
		{
			super(gls("Получить монеты"));
			init();
		}

		static public function show():void
		{

			if (!_instance)
				_instance = new DialogFacebookFavorites();
			_instance.show();
		}

		private function init():void
		{
			this.moviePreload = new MoviePreload();
			this.moviePreload.x = 105;
			this.moviePreload.y = 155;
			addChild(this.moviePreload);

			var background:ViralFacebookImage = new ViralFacebookImage();
			background.y = 47;
			background.x = 14;
			addChildAt(background, 0);

			var title:GameField = new GameField(gls("Добавь 'Трагедию белок' в избранное и получи 5  -  в подарок!"), 0, 0, titleFormat, 550);
			title.mouseEnabled = false;
			title.x = -16;
			title.y = 9;
			titleFormat.bold = true;
			title.setTextFormat(titleFormat, 45, title.text.length);

			addChild(title);

			FieldUtils.replaceSign(title, "-", ImageIconCoins, 1.2, 1.2, -title.x+10, -title.y+4, true, true);

			var itemField:GameField = new GameField(gls("Необходимо выполнить следующие шаги:"), 0, 0, itemFormat, 168);
			addChild(itemField);
			itemField.x = 258;
			itemField.y = 46;

			itemField = new GameField(gls("Добавить в избранное"), 0, 0, itemFormat, 223);
			addChild(itemField);
			itemField.x = 301;
			itemField.y = 113;

			itemField = new GameField(gls("Перезагрузить страницу"), 0, 30, itemFormat, 223);
			addChild(itemField);
			itemField.x = 301;
			itemField.y = 174;

			itemField = new GameField(gls("Открыть игру из избранного"), 0, 80, itemFormat, 223);
			addChild(itemField);
			itemField.x = 301;
			itemField.y = 238;

			var button:ButtonBase = new ButtonBase(gls("Продолжить"));
			button.x = 191;
			button.y = 316;
			button.addEventListener(MouseEvent.CLICK, hide);
			addChild(button);

			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
			this.addChild(this.loader);

			loader.load(new URLRequest(Config.PREVIEWS_URL + (Config.isRus ? FILE_NAME + '_ru' : FILE_NAME + '_en') + ".swf"));
			loader.scaleX = 0.672;
			loader.scaleY = 0.672;

			place();

			this.width = 549;
			this.height = 397;
		}

		private function onLoad(event:Event):void
		{
			this.moviePreload.visible = false;
			this.moviePreload.stop();
			loader.x = 122;
			loader.y = 176;
		}
	}
}