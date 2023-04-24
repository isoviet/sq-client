package views
{
	import flash.display.Sprite;

	import com.api.Player;

	public class OnlineIcon extends Sprite
	{
		static private const DEFAULT_WIDTH:int = 10;

		private var imageOnline:ImageOnline = new ImageOnline();
		private var imageOffline:ImageOffline = new ImageOffline();

		public function OnlineIcon(width:int = DEFAULT_WIDTH):void
		{
			this.imageOffline.visible = false;
			this.imageOffline.width = this.imageOffline.height = width;
			addChild(this.imageOffline);

			this.imageOnline.visible = false;
			this.imageOnline.width = width;
			this.imageOnline.height = width;
			addChild(this.imageOnline);
		}

		public function setPlayer(player:Player):void
		{
			this.imageOffline.visible = !player.online;
			this.imageOnline.visible = Boolean(player.online);
		}
	}
}