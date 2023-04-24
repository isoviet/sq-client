package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import screens.ScreenLocation;
	import views.FriendGiftSendView;

	import protocol.Connection;
	import protocol.PacketClient;

	public class DialogGifts extends Dialog
	{
		static private const FRIENDS_COUNT:int = 6;

		static private var _instance:DialogGifts = null;
		static public var sendedIds:Array = [];

		private var dialogSuccess:DialogInfo = null;
		private var dialogError:DialogInfo = null;
		private var buttonSend:ButtonBase = null;

		private var friendsViews:Vector.<FriendGiftSendView> = new <FriendGiftSendView>[];

		static public function show():void
		{
			if (!MailManager.friendsArray)
				return;
			if (!_instance)
				_instance = new DialogGifts();
			_instance.show();
		}

		public function DialogGifts():void
		{
			super(gls("Подарки друзьям"));

			init();

			this.dialogSuccess = new DialogInfo(gls("Подарки"), gls("Подарки друзьям успешно отправлены!\nНе забудь проверять почту, тебе\nобязательно отправят подарки в ответ."));
			this.dialogError = new DialogInfo(gls("Подарки"), gls("Чтобы отправить подарки, выбери хотя бы одного\nдруга, которому ещё не оправлял сегодня подарок."));
		}

		private function init():void
		{
			if (MailManager.friendsArray.length != 0)
			{
				var field:GameField = new GameField(gls("Отправляй друзьям подарки каждый день и они обязательно ответят тебе взаимностью!"), 0, 10, new TextFormat(null, 14, 0x46443F, true));
				field.x = 375 - int(field.textWidth * 0.5);
				addChild(field);

				for (var i:int = 0; i < FRIENDS_COUNT; i++)
				{
					var view:FriendGiftSendView = new FriendGiftSendView(i >= MailManager.friendsArray.length ? -1 : MailManager.friendsArray[i]);
					view.x = 25 + 350 * (i % 2);
					view.y = 40 + 75 * int(i / 2);
					addChild(view);

					this.friendsViews.push(view);
				}

				this.buttonSend = new ButtonBase(gls("Отправить"));
				this.buttonSend.addEventListener(MouseEvent.CLICK, sendGifts);
				addChild(this.buttonSend);
			}
			else
			{
				field = new GameField(gls("У тебя нет друзей, чтобы обмениваться подарками."), 0, 10, new TextFormat(null, 14, 0x46443F, true));
				field.x = 190 - int(field.textWidth * 0.5);
				addChild(field);

				var image:ImageNoFriends = new ImageNoFriends();
				image.y = 40;
				image.x = 205 - int(image.width * 0.5);
				addChild(image);

				this.buttonSend = new ButtonBase(gls("Пригласить друзей"));
				this.buttonSend.addEventListener(MouseEvent.CLICK, inviteFriends);
				addChild(this.buttonSend);
			}

			place(this.buttonSend);

			this.width = MailManager.friendsArray.length != 0 ? 750 : 410;
			this.height = 350;
		}

		private function inviteFriends(e:MouseEvent):void
		{
			Game.inviteFriends();

			hide();
		}

		private function sendGifts(e:MouseEvent):void
		{
			var sendIds:Array = [];
			for (var i:int = 0; i < this.friendsViews.length; i++)
			{
				if (!this.friendsViews[i].state || this.friendsViews[i].sended)
					continue;
				this.friendsViews[i].send(sendIds.length * 5000);
				sendIds.push(this.friendsViews[i].playerId);
			}
			if (sendIds.length == 0)
			{
				this.dialogError.show();
				return;
			}

			sendedIds = sendedIds.concat(sendIds);
			Connection.sendData(PacketClient.GIFT_SEND, sendIds);

			ScreenLocation.sortMenu();

			hide();

			this.dialogSuccess.show();
			ScreenLocation.sortMenu();
		}
	}
}