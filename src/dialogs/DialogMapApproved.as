package dialogs
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;

	import buttons.ButtonBase;
	import events.ScreenEvent;
	import screens.ScreenLocation;
	import screens.ScreenProfile;
	import screens.Screens;

	import utils.StageQualityUtil;
	import utils.StringUtil;
	import utils.WallTool;

	public class DialogMapApproved extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 15px;
				color: #432906;
				text-align: center;
			}
			.bold {
				font-weight: bold;
			}
				]]>).toString();

		private var text:GameField = null;

		public function DialogMapApproved(map:int, location:int):void
		{
			super("", false);
			init();
			loadData(map, location);
		}

		override public function showDialog():void
		{
			if (Screens.active is ScreenLocation || Screens.active is ScreenProfile)
			{
				super.showDialog();
				return;
			}

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			addChild(new MapApprovedBackground);

			place();

			this.text = new GameField("", 0, 300, style);
			this.text.width = 260;
			this.text.wordWrap = true;
			this.text.multiline = true;
			this.text.x = 10 + int((this.width - this.text.width) / 2);
			addChild(this.text);

			switch (Game.self.type)
			{
				case Config.API_VK_ID:
				case Config.API_OK_ID:
				case Config.API_FB_ID:
				case Config.API_MM_ID:
					var postButton:ButtonBase = new ButtonBase(gls("Поделиться"));
					postButton.x = 25 + int((this.width - postButton.width) / 2);
					postButton.y = 380;
					postButton.addEventListener(MouseEvent.CLICK, onPost);
					addChild(postButton);
			}

			this.buttonClose.x -= 32;
			this.buttonClose.y += 22;
		}

		private function loadData(map:int, location:int):void
		{
			if (map > 0 && Locations.getLocation(location) != null)
			{
				this.text.htmlText = gls("<body><textformat leading = '4'>Твоя карта <span class = 'bold'>№ {0}</span> одобрена в локацию <span class = 'bold'>{1}</span>.<br/>", map, Locations.getLocation(location).name);
				this.text.htmlText += gls("Ты заслужил <span class = 'bold'>{0} {1}</span>!</textformat></body>", Locations.getLocation(location).award, StringUtil.word("орехов", Locations.getLocation(location).award));
			}
			else
				this.text.htmlText = gls("<body><textformat leading = '4'>Твоя карта одобрена модератором!\nВ награду ты получаешь <span class='bold'>{0} {1}</span>!</textformat></body>", location, StringUtil.word("орехов", location));
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if (e != null && !(Screens.active is ScreenLocation) && !(Screens.active is ScreenProfile))
				return;

			Screens.instance.removeEventListener(ScreenEvent.SHOW, onScreenChanged);

			super.showDialog();
		}

		private function onPost(e:MouseEvent):void
		{
			var quality:String = Game.stage.quality;
			StageQualityUtil.toggleQuality(StageQuality.HIGH);

			var image:MapApprovedPost = new MapApprovedPost();

			var bitmapData:BitmapData = new BitmapData(image.width, image.height);
			bitmapData.draw(image);

			WallTool.place(Game.self, WallTool.MAP_APPROVED, 0, new Bitmap(bitmapData), gls("Мою карту одобрили и я получил награду!"));

			StageQualityUtil.toggleQuality(quality);

			hide();
		}
	}
}