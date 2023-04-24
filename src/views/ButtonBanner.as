package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class ButtonBanner extends Sprite
	{
		//TODO move
		private var banner:BannerIcon = null;

		public function ButtonBanner(button:DisplayObject):void
		{
			addChild(button);

			this.banner = new BannerIcon();
			this.banner.mouseEnabled = false;
			this.banner.x = button.width;
			addChild(this.banner);

			addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(e:MouseEvent):void
		{
			removeChild(this.banner);
			removeEventListener(MouseEvent.CLICK, onClick);
		}
	}
}