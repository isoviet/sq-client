package dialogs.clan
{
	import flash.text.StyleSheet;
	import flash.utils.setTimeout;

	import dialogs.DialogNotificationBg;
	import screens.ScreenGame;
	import screens.Screens;

	import com.greensock.TweenMax;

	public class DialogClanNews extends DialogNotificationBg
	{
		static private const HIDE_DELAY:int = 5 * 1000;

		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #432104;
				text-align: center;
			}
			.caption {
				color: #FF0000;
				font-size: 15px;
				font-weight: bold;
			}
		]]>).toString();

		static private var _instance:DialogClanNews = null;

		private var newsField:GameField = null;

		private var tween:TweenMax = null;

		public function DialogClanNews(text:String):void
		{
			if (_instance != null)
				_instance.close();

			_instance = this;

			super("", true, false);

			init(text);
		}

		override public function close():void
		{
			if (this.tween != null)
			{
				this.tween.kill();
				this.tween = null;
			}

			super.close();
		}

		override public function showDialog():void
		{
			this.visible = true;

			addToSprite();
			effectOpen();
		}

		override public function placeInCenter(sceneWidth:Number = Config.GAME_WIDTH, sceneHeight:Number = Config.GAME_HEIGHT):void
		{
			if (sceneWidth || sceneHeight) {/*unused*/}

			this.x = this.leftOffset + Config.GAME_WIDTH - this.width - 13;

			if (Screens.active is ScreenGame)
				this.y = this.topOffset + Config.GAME_HEIGHT - this.height - 58;
			else
				this.y = this.topOffset + Config.GAME_HEIGHT - this.height - 78;
		}

		override protected function effectOpen():void
		{
			this.tween = TweenMax.to(this, 1, {'alpha': 1});
		}

		override protected function initClose():void
		{
			super.initClose();

			this.buttonClose.y -= 2;
		}

		private function init(text:String):void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.newsField = new GameField("", 0, 10, style);
			this.newsField.htmlText = "<body><textformat leading = '7'><span class = 'caption'>" + gls("Новость клана!") + "</span><br/></textformat>";
			this.newsField.htmlText += text;
			this.newsField.htmlText += "</body>";
			this.newsField.width = 200;
			this.newsField.wordWrap = true;
			this.newsField.multiline = true;
			addChild(this.newsField);

			place();

			this.alpha = 0;
			this.height += 25;

			this.buttonClose.x += 5;
			this.buttonClose.y += 5;

			setTimeout(closeAfterDelay, HIDE_DELAY);
		}

		private function closeAfterDelay():void
		{
			if (this == null || !this.visible)
				return;

			this.tween = TweenMax.to(this, 1, {'alpha': 0, 'onComplete': close});
		}
	}
}