package dialogs
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import fl.controls.CheckBox;

	import buttons.ButtonBase;
	import game.gameData.FlagsManager;
	import screens.ScreenGame;
	import screens.Screens;

	import protocol.Flag;

	import utils.TextFieldUtil;

	public class DialogLagsDetected extends DialogNotificationBg
	{
		static private const CSSHowTo:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #442205;
				font-weight: normal;
				text-align: left;
			}
		]]>).toString();

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

		static private var _instance:DialogLagsDetected = null;

		private var newsField:GameField = null;
		private var newsFieldHowTo:GameField = null;
		private var checkBox:CheckBox = null;

		public function DialogLagsDetected():void
		{
			if (_instance != null)
				_instance.close();

			_instance = this;

			super(gls("ВНИМАНИЕ!"), true, false);

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

			this.x = Config.GAME_WIDTH - this.width - 13 + this.leftOffset;

			if (Screens.active is ScreenGame)
				this.y = Config.GAME_HEIGHT - this.height - 58 + this.topOffset;
			else
				this.y = Config.GAME_HEIGHT - this.height - 78 + this.topOffset;
		}

		override public function hide(e:MouseEvent = null):void
		{
			if (this.checkBox.selected)
			{
				Game.showLagWarning = false;
				FlagsManager.set(Flag.HIDE_LOW_FPS);
			}

			super.hide();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			var styleHowTo: StyleSheet = new StyleSheet();

			var textHowTo:String = "<body>";
			textHowTo += gls("1)Включите аппаратное ускорение.<br>");
			textHowTo += gls("2)Воспользуйтесь другим браузером'<br>");
			textHowTo += gls("3)Обновите Adobe Flash Player'<br>");
			textHowTo += gls("4)Обновите драйвера видеокарты</body>");

			style.parseCSS(CSS);
			styleHowTo.parseCSS(CSSHowTo);

			this.newsField = new GameField(gls("<body>Игра работает медленно.<br>Чтобы повысить производительность</body>"), -2, 0, style);
			this.newsField.width = 220;
			this.newsField.wordWrap = true;
			this.newsField.multiline = true;
			addChild(this.newsField);

			this.newsFieldHowTo = new GameField(textHowTo, -2, this.newsField.y + this.newsField.height + 10, styleHowTo);
			this.newsFieldHowTo.width = 220;
			this.newsFieldHowTo.wordWrap = true;
			this.newsFieldHowTo.multiline = true;
			addChild(this.newsFieldHowTo);

			var button:ButtonBase = new ButtonBase(gls("Подробнее"));
			button.x = 52;
			button.y = 100;
			button.addEventListener(MouseEvent.CLICK, onRedirectToFAQ);
			addChild(button);

			this.checkBox = new CheckBox();
			TextFieldUtil.setStyleCheckBox(this.checkBox, new TextFormat(null, 11, 0x432104));
			this.checkBox.width = 200;
			this.checkBox.x = 10;
			this.checkBox.y = button.y + button.height + this.checkBox.height / 4;
			this.checkBox.label = gls("Больше не показывать это окно");
			this.checkBox.selected = false;
			addChild(this.checkBox);

			place();

			this.height -=45;
			this.buttonClose.x += 5;
			this.buttonClose.y += 5;
		}

		private function onRedirectToFAQ(e:MouseEvent): void
		{
			var request: URLRequest = new URLRequest(gls("http://forum.itsrealgames.com/topic/747-faq/"));
	    		navigateToURL(request, "_blank");
		}
	}
}