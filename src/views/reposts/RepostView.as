package views.reposts
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	public class RepostView extends Sprite
	{
		static protected const FILTER_POST: GlowFilter = new GlowFilter(0x19545E, 1.0, 4, 4, 16);
		static protected const FORMAT_POST_TEXT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 17, 0xFFFFFF);
		static protected const FORMAT_POST_CAPTION:TextFormat =  new TextFormat(GameField.PLAKAT_FONT, 17, 0xFFCC00, null, null, null, null, null, "center");

		private static const SIZE_OF_REPOST_VIEW: int = 280;

		protected var background:Sprite = null;
		protected var filedCaption:GameField = null;

		public function RepostView()
		{
			configurateView();
		}

		protected function configurateView(): void
		{
			if (background)
				addChild(background);

			if (filedCaption)
			{
				addChild(filedCaption);
				this.filedCaption.x = this.width / 2 - this.filedCaption.width /  2;
				this.filedCaption.y = 5;
			}
		}

		public function set caption(value:String):void
		{
			this.filedCaption = new GameField(value, 0, 0, FORMAT_POST_CAPTION, SIZE_OF_REPOST_VIEW - 10);
			this.filedCaption.filters = [FILTER_POST];
		}

		public function get caption():String
		{
			return (this.filedCaption ? this.filedCaption.text : "");
		}

		public function get id(): int
		{
			return 0;
		}

		public function get bitmapData():BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(SIZE_OF_REPOST_VIEW, SIZE_OF_REPOST_VIEW);
			var logo:DisplayObject = PreLoader.getLogo();

			logo.scaleX = logo.scaleY = 0.6;
			logo.x = int((SIZE_OF_REPOST_VIEW - logo.width) * 0.5);
			logo.y = int((SIZE_OF_REPOST_VIEW - logo.height / 1.5));
			this.addChild(logo);

			bitmapData.draw(this);
			return bitmapData;
		}
	}
}