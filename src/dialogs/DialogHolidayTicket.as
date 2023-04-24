package dialogs
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.base.DialogIconHeader;
	import game.gameData.HolidayManager;
	import loaders.ScreensLoader;
	import screens.ScreenProfile;
	import screens.ScreenWardrobe;
	import sounds.SoundConstants;
	import views.PackageImageLoader;

	import utils.WallTool;

	public class DialogHolidayTicket extends DialogIconHeader
	{
		static private const FORMAT_POST_TEXT:TextFormat = new TextFormat(null, 16, 0xFFFFFF, true, null, null, null, null, "center");
		static private const FORMAT_TEXT:TextFormat = new TextFormat(null, 16, 0xFFF5B8, true, null, null, null, null, "center");
		static private const FORMAT_BOTTOM_TEXT:TextFormat = new TextFormat(null, 14, 0x7E5836, false, null, null, null, null, "center");

		private var packageView:PackageImageLoader = null;
		private var current:int = 0;
		private var view:DialogHolidayTicketView = null;
		private var currentId:int = 0;

		public function DialogHolidayTicket()
		{
			super(DialogHeaderTicket, gls("Ты получил костюм"), gls("Поздравляем!"), true, true);
			init();
			this.sound = SoundConstants.REWARD;
		}

		override public function show():void
		{
			super.show();

			this.y = 300;
		}

		private function init():void
		{
			this.view = new DialogHolidayTicketView();
			addChild(this.view);
			this.view.mouseEnabled = this.view.mouseChildren = false;

			this.current = HolidayManager.currentClothes;

			var button:ButtonBase = new ButtonBase(gls("Рассказать друзьям"), 0, 14, onRepost);
			button.x = 127;
			button.y = 170;
			addChild(button);

			button = new ButtonBase(gls("Гардероб"), 0, 14, showWardrobe);
			button.x = 5;
			button.y = 170;
			addChild(button);

			var bottomText:GameField = new GameField(gls("Ты можешь примерить его в гардеробе"),
				-this.leftOffset, 147, FORMAT_BOTTOM_TEXT, 360);
			addChild(bottomText);

			this.height = 298;

			this.setChildIndex(view, this.getChildIndex(this.textHeader)-1);

			this.view.x = this.width*0.5 - this.leftOffset;
			this.view.y = 50;
		}

		public function onClothesChange(clothes:int):void
		{
			this.currentId = clothes;

			if(this.packageView && this.contains(this.packageView))
				this.removeChild(this.packageView);

			packageView = null;

			this.packageView = new PackageImageLoader(HolidayManager.CLOTHES[this.currentId]);
			this.packageView.y = -71;
			this.packageView.x = (this.width - this.packageView.width)*0.5;
			this.addChildAt(this.packageView, this.getChildIndex(this.view)+1);
		}

		private function showWardrobe(e:MouseEvent = null):void
		{
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenWardrobe.instance);
		}

		private function onRepost(e:MouseEvent = null):void
		{
			hide();

			var back:HolidayRepost = new HolidayRepost();
			var repost:Sprite = new Sprite();
			back.x = 140;
			back.y = 140;
			repost.addChild(back);

			removeChild(this.packageView);
			back.container.addChild(this.packageView);

			this.packageView.x = (back.container.width - this.packageView.width)*0.5 - 20;
			this.packageView.y = 0;

			var field:GameField = new GameField(gls("Я получил"), 0, 10, FORMAT_POST_TEXT);
			field.text = field.text.toUpperCase();
			field.filters = [new GlowFilter(0x660000, 1.0, 4, 4, 15)];
			field.x = 140 - field.textWidth * 0.5;
			repost.addChild(field);

			field = new GameField(gls("костюм {0}", (HolidayManager.CLOTHES_NAME[this.currentId] as String)).toUpperCase(), 0, 35, FORMAT_TEXT);

			field.filters = [new GlowFilter(0x660000, 1.0, 4, 4, 15)];
			field.x = 140 - field.textWidth * 0.5;
			repost.addChild(field);

			var logo:MovieClip = Config.isRus ? new ImageLogoRu() : new ImageLogoEn();
			logo.scaleX = logo.scaleY = 0.45;
			back.container.addChild(logo);
			logo.y = 208;
			logo.x = (back.container.width - logo.width)*0.5 - 17;

			var bitmapData:BitmapData = new BitmapData(280, 280, true, 0);
			bitmapData.draw(repost);

			back.container.removeChild(this.packageView);
			addChild(this.packageView);

			var types:Array = [WallTool.WALL_SILVANA, WallTool.WALL_RAPUNCEL, WallTool.WALL_DRUID, WallTool.WALL_BEAR];
			NewsImageGenerator.save(bitmapData, "spring_package_2016", false);
			WallTool.place(Game.self, types[this.current], 0, new Bitmap(bitmapData), gls("Я выиграл костюм {0}!", HolidayManager.CLOTHES_NAME[this.current]));
		}
	}
}