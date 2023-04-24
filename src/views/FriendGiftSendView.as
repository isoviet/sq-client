package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;

	import buttons.ButtonDouble;
	import menu.MenuProfile;

	import com.api.Player;
	import com.api.Services;

	import utils.HtmlTool;

	public class FriendGiftSendView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #63421B;
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

		private var back:MovieClip = null;
		private var buttonDouble:ButtonDouble = null;

		public var playerId:int = -1;
		public var state:Boolean = true;
		public var sended:Boolean = false;

		public function FriendGiftSendView(playerId:int):void
		{
			if (style == null)
			{
				style = new StyleSheet();
				style.parseCSS(CSS);
			}

			this.playerId = playerId;

			init();
		}

		public function send(timeout:int):void
		{
			setTimeout(Services.sendMessage, timeout, Game.getPlayer(this.playerId).nid, gls("Отправил тебе подарок, скорее открой его!"));

			(this.back as FriendGiftSendBack).imageRect.visible = false;
			this.buttonDouble.visible = false;

			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xF7F4EC);
			sprite.graphics.lineStyle(2, 0xF4E3CA);
			sprite.graphics.drawRoundRect(0, 0, 120, 23, 5, 5);
			var field:GameField = new GameField(gls("Отправлено!"), 0, 2, new TextFormat(GameField.PLAKAT_FONT, 14, 0xFF4A0D));
			field.x = 56 - int(field.textWidth * 0.5);
			sprite.addChild(field);
			sprite.x = 120;
			addChild(sprite);

			this.sended = true;
		}

		private function init():void
		{
			if (this.playerId == -1)
			{
				addChild(new FriendGiftSendEmpty);

				this.state = false;
				return;
			}

			this.photo = new ProfilePhoto(66);
			addChild(this.photo);

			var ratingPlaceButton:RatingPlaceButton = new RatingPlaceButton();
			ratingPlaceButton.width = this.photo.width;
			ratingPlaceButton.height = this.photo.height;
			ratingPlaceButton.addEventListener(MouseEvent.MOUSE_UP, showMenu);
			addChild(ratingPlaceButton);

			this.back = new FriendGiftSendBack();
			this.back.x = 68;
			this.back.y = 6;
			addChild(this.back);

			var buttonSend:SetDecorationButton = new SetDecorationButton();
			buttonSend.x = 12;
			buttonSend.y = -5;
			buttonSend.scaleX = buttonSend.scaleY = 2.0;
			buttonSend.addEventListener(MouseEvent.CLICK, switchState);

			var buttonReject:HideDecorationButton = new HideDecorationButton();
			buttonReject.x = 5;
			buttonReject.scaleX = buttonReject.scaleY = 2.0;
			buttonReject.addEventListener(MouseEvent.CLICK, switchState);

			this.buttonDouble = new ButtonDouble(buttonSend, buttonReject, true);
			this.buttonDouble.x = this.back.x + 230 - int(this.buttonDouble.width * 0.5);
			this.buttonDouble.y = this.back.y + 25 - int(this.buttonDouble.height * 0.5);
			this.buttonDouble.setState(true);
			addChild(this.buttonDouble);

			this.caption = new GameField("", 75, 0, style);
			this.caption.addEventListener(TextEvent.LINK, onLink);
			addChild(this.caption);

			var player:Player = Game.getPlayer(this.playerId);
			player.addEventListener(PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE, onPlayerLoad);

			Game.request(this.playerId, PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE);
		}

		private function switchState(e:MouseEvent):void
		{
			this.state = !this.state;

			this.buttonDouble.setState(this.state);
		}

		private function onLink(e:TextEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}

		private function showMenu(e:MouseEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}

		private function onPlayerLoad(player:Player):void
		{
			player.removeEventListener(onPlayerLoad);

			this.photo.setPlayer(player);

			this.caption.htmlText = "<body><b>" + HtmlTool.anchor(player.name, "event:" + player.id) + "</b></body>";
			this.caption.y = int((this.photo.height - this.caption.textHeight) * 0.5);
		}
	}
}