package views.dialogEvents
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;

	import buttons.ButtonBase;
	import events.PostEvent;
	import menu.MenuProfile;
	import views.FriendGiftBonusView;
	import views.ProfilePhoto;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketGiftsAccept;

	import utils.HtmlTool;

	public class PostGiftView extends PostElementView
	{
		static private const GIFT_TIME:int = 24 * 60 * 60;

		private var playerId:int = -1;
		private var giftType:int = -1;

		private var caption:GameField = null;
		private var photo:ProfilePhoto = null;

		private var buttonTake:ButtonBase = null;
		private var movieGift:MovieClip = null;

		private var sended:Boolean = false;

		public function PostGiftView(id:int, type:int, playerId:int, time:uint):void
		{
			super(id, type, time);

			this.playerId = playerId;
		}

		override public function onShow():void
		{
			if (this.caption != null)
				return;
			super.onShow();

			this.photo = new ProfilePhoto(80);
			addChild(this.photo);

			var ratingPlaceButton:RatingPlaceButton = new RatingPlaceButton();
			ratingPlaceButton.width = this.photo.width;
			ratingPlaceButton.height = this.photo.height;
			ratingPlaceButton.addEventListener(MouseEvent.MOUSE_UP, showMenu);
			addChild(ratingPlaceButton);

			addChild(new GameField("<body>" + gls("Твой друг") + "</body>", 85, 10, style));

			this.caption = new GameField("", 148, 10, style);
			this.caption.addEventListener(TextEvent.LINK, onLink);
			addChild(this.caption);

			var description:GameField = new GameField("<body>" + gls("подарил тебе подарок! Скорее узнай, что там внутри!") + "</body>", 85, 25, style);
			addChild(description);

			this.buttonTake = new ButtonBase(gls("Принять"));
			this.buttonTake.x = 660 - int(this.buttonTake.width * 0.5);
			this.buttonTake.y = 35;
			this.buttonTake.addEventListener(MouseEvent.CLICK, onGift);
			addChild(this.buttonTake);

			this.movieGift = new PostGiftMovie();
			this.movieGift.x = 580;
			this.movieGift.y = 35;
			this.movieGift.gotoAndStop(0);
			addChild(this.movieGift);

			EnterFrameManager.addPerSecondTimer(updateTime);

			var player:Player = Game.getPlayer(this.playerId);
			player.addEventListener(PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE, onPlayerLoad);

			Game.request(this.playerId, PlayerInfoParser.PHOTO | PlayerInfoParser.NAME | PlayerInfoParser.ONLINE);
		}

		override protected function get timeString():String
		{
			var value:int = (this.time + GIFT_TIME) - (Game.unix_time + int(getTimer() / 1000));
			if (value <= 0)
			{
				EnterFrameManager.removePerSecondTimer(updateTime);
				dispatchEvent(new PostEvent(eventId));
				return "";
			}

			var seconds:String = (value % 60).toString();
			seconds = (seconds.length == 1 ? "0" : "") + seconds;
			value /= 60;

			var minutes:String = (value % 60).toString();
			minutes = (minutes.length == 1 ? "0" : "") + minutes;
			value /= 60;

			var hours:String = (value % 60).toString();
			hours = (hours.length == 1 ? "0" : "") + hours;

			return hours + ":" + minutes + ":" + seconds;
		}

		override protected function onRemove(e:MouseEvent):void
		{
			if (this.sended)
				return;
			this.sended = true;

			Connection.sendData(PacketClient.GIFT_ACCEPT, 1, this.eventId);

			super.onRemove(e);
		}

		private function onGift(e:MouseEvent):void
		{
			if (this.sended)
				return;
			this.sended = true;

			this.buttonClose.visible = false;
			this.buttonTake.visible = false;
			this.timeField.visible = false;

			Connection.sendData(PacketClient.GIFT_ACCEPT, 0, this.eventId);
			Connection.listen(onPacket, PacketGiftsAccept.PACKET_ID);
		}

		private function onPacket(packet:PacketGiftsAccept):void
		{
			if (packet.id != this.eventId)
				return;
			if (packet.data != FriendGiftBonusView.MAX_TYPE)
			{
				this.giftType = packet.data;

				this.movieGift.play();
				this.movieGift.addFrameScript(17, function():void
				{
					showAward();
				});
				this.movieGift.addFrameScript(this.movieGift.totalFrames - 1, function():void
				{
					dispatchEvent(new PostEvent(eventId));
					movieGift.stop();
				});
			}
			else
				dispatchEvent(new PostEvent(eventId));
			Connection.forget(onPacket, PacketGiftsAccept.PACKET_ID);
		}

		private function updateTime():void
		{
			this.timeField.text = this.timeString;
			this.timeField.x = 657 - int(this.timeField.textWidth * 0.5);
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

			this.caption.htmlText = "<body><b>" + HtmlTool.anchor(player.name, "event:" + player.id) + "</b>,</body>";
		}

		private function showAward():void
		{
			new FriendGiftBonusView(this.giftType, this.localToGlobal(new Point(this.movieGift.x, this.movieGift.y))).show();
		}
	}
}