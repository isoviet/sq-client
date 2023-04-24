package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;

	import menu.MenuProfile;

	import com.api.Player;

	import utils.FiltersUtil;
	import utils.HtmlTool;

	public class FriendAmurSendView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #5D8FC1;
			}
			a {
				text-decoration: underline;
			}
			a:hover {
				text-decoration: none;
			}
				]]>).toString();

		static private var style:StyleSheet = null;

		private var photo:ProfilePhoto = null;
		private var caption:GameField = null;

		private var selected:DisplayObject = null;

		private var callback:Function = null;

		public var playerId:int = -1;
		public var state:Boolean = false;

		public function FriendAmurSendView(playerId:int, callback:Function):void
		{
			if (style == null)
			{
				style = new StyleSheet();
				style.parseCSS(CSS);
			}

			this.playerId = playerId;
			this.callback = callback;

			init();
		}

		public function send():void
		{
			switchState(null);
		}

		public function set block(value:Boolean):void
		{
			if (this.state && value)
				return;

			this.mouseEnabled = !value;
			this.mouseChildren = !value;

			this.filters = value ? FiltersUtil.GREY_FILTER : [];
		}

		private function init():void
		{
			if (this.playerId == -1)
			{
				addChild(new FriendGiftSendEmpty);

				this.state = false;
				return;
			}

			this.photo = new ProfilePhoto(60);
			this.photo.addEventListener(MouseEvent.CLICK, switchState);
			this.photo.buttonMode = true;
			addChild(this.photo);

			var image:ImageAmurFrame = new ImageAmurFrame();
			addChild(image);

			this.selected = new ImageAmurSelected();
			this.selected.visible = false;
			addChild(this.selected);

			this.caption = new GameField("", 0, 62, style);
			this.caption.addEventListener(TextEvent.LINK, onLink);
			addChild(this.caption);

			var player:Player = Game.getPlayer(this.playerId);
			player.addEventListener(PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE, onPlayerLoad);

			Game.request(this.playerId, PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE);
		}

		private function switchState(e:MouseEvent):void
		{
			this.state = !this.state;

			this.selected.visible = this.state;

			this.callback(this.state);
		}

		private function onLink(e:TextEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}

		private function onPlayerLoad(player:Player):void
		{
			player.removeEventListener(onPlayerLoad);

			this.photo.setPlayer(player);

			this.caption.htmlText = "<body><b>" + HtmlTool.anchor(player.name, "event:" + player.id) + "</b></body>";
			this.caption.x = int((60 - this.caption.textWidth) * 0.5);
		}
	}
}