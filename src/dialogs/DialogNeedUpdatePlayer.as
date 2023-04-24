package dialogs
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;

	public class DialogNeedUpdatePlayer extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 10px;
				color: #442205;
				font-weight: bold;
				text-align: center;
			}
			a {
				color: #D13E04;
				text-decoration: underline;
				margin-right: 0px;
			}
			a:hover {
				text-decoration: underline;
				color: #FF6225;
			}
		]]>).toString();

		static private var _instance:DialogNeedUpdatePlayer = null;

		private var newsField:GameField = null;
		private var newsTitle:GameField = null;
		private var newsFieldHowTo:GameField = null;

		public function DialogNeedUpdatePlayer():void
		{
			if (_instance != null)
				_instance.close();

			_instance = this;

			super();

			init();
		}

		static public function close():void
		{
			if (_instance == null)
				return;

			_instance.close();
		}

		override public function placeInCenter(sceneWidth:Number = Config.GAME_WIDTH, sceneHeight:Number = Config.GAME_HEIGHT):void
		{
			if (sceneWidth || sceneHeight) {/*unused*/}

			this.x = Config.GAME_WIDTH / 2 - 130;
			this.y = Config.GAME_HEIGHT / 2 - 90;
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();

			var textHowTo: String = "<body>";
			textHowTo += gls("<body>Для корректной работы приложения Вам необходимо обновить Flash Player до последней версии.</body>");

			style.parseCSS(CSS);

			this.newsTitle = new GameField(gls("ВНИМАНИЕ!"), 0, 5, new TextFormat(GameField.DEFAULT_FONT, 15, 0xD03D03, true));
			this.newsTitle.x = int((220 - this.newsTitle.width) / 2);
			this.newsTitle.wordWrap = false;
			this.newsTitle.multiline = false;
			addChild(this.newsTitle);

			this.newsField = new GameField(gls("<body>У Вас установлена устаревшая версия<br>Flash Player</body>"), -2, 28, style);
			this.newsField.width = 220;
			this.newsField.wordWrap = true;
			this.newsField.multiline = true;
			addChild(this.newsField);

			this.newsFieldHowTo = new GameField(textHowTo, -2, 28, style);
			this.newsFieldHowTo.width = 212;
			this.newsFieldHowTo.wordWrap = true;
			this.newsFieldHowTo.multiline = true;
			this.newsFieldHowTo.y = this.newsField.y + this.newsField.height + 10;
			addChild(this.newsFieldHowTo);

			var updatePlayerButton:ButtonBase = new ButtonBase(gls("Обновить"));
			updatePlayerButton.x = 75;
			updatePlayerButton.y = 110;
			updatePlayerButton.addEventListener(MouseEvent.CLICK, onClickUpdatePlayer);
			addChild(updatePlayerButton);

			place();
			this.width = 290;
			this.height = 180;
		}

		private function onClickUpdatePlayer(e:MouseEvent):void
		{
		    var request: URLRequest = new URLRequest(Config.URL_UPDATE_PLAYER);
		    navigateToURL(request, "_blank");
		}
	}
}