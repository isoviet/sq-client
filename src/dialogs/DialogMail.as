package dialogs
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	import fl.containers.ScrollPane;

	import events.GameEvent;
	import events.PostEvent;
	import game.gameData.CollectionsData;
	import game.gameData.EducationQuestManager;
	import game.gameData.NotificationManager;
	import views.FriendGiftBonusView;
	import views.dialogEvents.PostClanAcceptView;
	import views.dialogEvents.PostClanInviteView;
	import views.dialogEvents.PostCollectionView;
	import views.dialogEvents.PostEducationDemo;
	import views.dialogEvents.PostElementView;
	import views.dialogEvents.PostFriendsLevelReachedView;
	import views.dialogEvents.PostGiftView;
	import views.dialogEvents.PostMapApprovedView;
	import views.dialogEvents.PostReturnerPlayerView;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.structs.PacketEventsItems;
	import protocol.packages.server.structs.PacketGiftsItems;

	public class DialogMail extends Dialog
	{
		static private const HEIGHT:int = 85;

		static private var _instance:DialogMail = null;

		private var postElements:Vector.<PostElementView> = new Vector.<PostElementView>();
		private var filteredElements:Vector.<PostElementView> = new Vector.<PostElementView>();

		private var scrollPane:ScrollPane = null;
		private var scrollSource:Sprite = null;

		private var fieldNoMessage:GameField = null;

		private var updating:Boolean = false;

		public function DialogMail():void
		{
			super(gls("Почта"), true, true, null, false);

			MailManager.addEventListener(GameEvent.EVENT_CHANGE, onEventChange);
			MailManager.addEventListener(GameEvent.GIFT_CHANGE, onGiftChange);
			MailManager.addEventListener(GameEvent.ON_CHANGE, update);

			init();

			parseData();
		}

		static public function show():void
		{
			if (_instance == null)
				_instance = new DialogMail();
			_instance.show();
			if (EducationQuestManager.done(EducationQuestManager.MAIL))
				MailManager.addDemoMail();
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide(e);

			FriendGiftBonusView.hide();
		}

		private function parseData():void
		{
			parserGift(MailManager.giftsArray);
			parserEvent(MailManager.eventsArray);

			update();
		}

		private function init():void
		{
			this.scrollPane = new ScrollPane();
			this.scrollPane.x = 10;
			this.scrollPane.y = 10;
			this.scrollPane.setSize(780, 425);
			addChild(this.scrollPane);

			this.scrollSource = new Sprite();
			this.scrollPane.source = this.scrollSource;

			this.fieldNoMessage = new GameField(gls("У тебя нет сообщений"), 0, 190, new TextFormat(null, 16, 0x663300, true));
			this.fieldNoMessage.x = int((780 - this.fieldNoMessage.textWidth) * 0.5);

			place();

			this.width = 815;
			this.height = 500;

			this.graphics.beginFill(0x000000, 0.1);
			this.graphics.drawRect(-this.x, -this.y, Config.GAME_WIDTH, Config.GAME_HEIGHT);
		}

		private function onEventChange(e:GameEvent):void
		{
			parserEvent(MailManager.eventsArray);

			update();
		}

		private function onGiftChange(e:GameEvent):void
		{
			parserGift(MailManager.giftsArray);

			update();
		}

		private function update(e:GameEvent = null):void
		{
			this.updating = true;

			while (this.scrollSource.numChildren > 0)
				this.scrollSource.removeChildAt(0);

			this.filteredElements = this.postElements.filter(filterTime);
			for (var i:int = 0; i < this.filteredElements.length; i++)
			{
				this.filteredElements[i].y = HEIGHT * i;
				this.filteredElements[i].onShow();
				this.scrollSource.addChild(this.filteredElements[i]);
			}

			if (this.filteredElements.length == 0)
			{
				this.scrollSource.addChild(this.fieldNoMessage);
				NotificationDispatcher.hide(NotificationManager.MAIL);
			}

			this.scrollSource.graphics.clear();
			this.scrollSource.graphics.beginFill(0x000000, 0);
			this.scrollSource.graphics.drawRect(0, 0, 1, HEIGHT * this.filteredElements.length);
			this.scrollPane.update();

			this.updating = false;
		}

		private function onRemoveEvent(e:PostEvent):void
		{
			if (!this.updating)
			{
				if (e.id != 0)
					Connection.sendData(PacketClient.EVENT_REMOVE, e.id);
				removeEvent(e.id, false);
			}
			else
				setTimeout(onRemoveEvent, 1000, e);
		}

		private function onRemoveGift(e:PostEvent):void
		{
			if (!this.updating)
				removeEvent(e.id, true);
			else
				setTimeout(onRemoveGift, 1000, e);
		}

		private function removeEvent(id:int, isGift:Boolean = false):void
		{
			for (var i:int = 0; i < this.postElements.length; i++)
			{
				if (this.postElements[i].eventId != id)
					continue;
				if (isGift != (this.postElements[i] is PostGiftView))
					continue;
				this.postElements.splice(i, 1);
				break;
			}

			var isDelete:Boolean = false;
			for (i = 0; i < this.filteredElements.length; i++)
			{
				if (isDelete)
				{
					this.filteredElements[i].y -= HEIGHT;
					continue;
				}
				if (this.filteredElements[i].eventId != id)
					continue;
				if (isGift != (this.filteredElements[i] is PostGiftView))
					continue;
				if (this.scrollSource.contains(this.filteredElements[i]))
					this.scrollSource.removeChild(this.filteredElements[i]);
				this.filteredElements.splice(i, 1);
				i--;
				isDelete = true;
			}

			if (!isDelete)
				return;
			this.scrollSource.graphics.clear();
			this.scrollSource.graphics.beginFill(0x000000, 0);
			this.scrollSource.graphics.drawRect(0, 0, 1, HEIGHT * this.filteredElements.length);
			this.scrollPane.update();

			if (this.filteredElements.length == 0)
			{
				this.scrollSource.addChild(this.fieldNoMessage);
				NotificationDispatcher.hide(NotificationManager.MAIL);
			}
		}

		private function parserGift(data: Vector.<PacketGiftsItems>):void
		{
			var elements:Vector.<PostElementView> = this.postElements.filter(filterGifts);
			for (var i:int = 0; i < elements.length; i++)
				elements[i].removeEventListener(PostEvent.REMOVE_EVENT, onRemoveGift);

			this.postElements = this.postElements.filter(filterEvents);

			if (data.length == 0)
				return;

			for (i = 0; i < data.length; i++)
			{
				var postElement:PostElementView = new PostGiftView(data[i].id, data[i].type, data[i].senderId, data[i].time);
				postElement.addEventListener(PostEvent.REMOVE_EVENT, onRemoveGift);
				this.postElements.push(postElement);
			}
		}

		private function parserEvent(data:Vector.<PacketEventsItems>):void
		{
			var elements:Vector.<PostElementView> = this.postElements.filter(filterEvents);
			for (var i:int = 0; i < elements.length; i++)
				elements[i].removeEventListener(PostEvent.REMOVE_EVENT, onRemoveEvent);

			this.postElements = this.postElements.filter(filterGifts);

			if (data.length == 0)
				return;

			for (i = 0; i < data.length; i++)
			{
				var postElement:PostElementView = null;
				switch(data[i].type)
				{
					case PacketServer.MAIL_DEMO:
						postElement = new PostEducationDemo(parseInt(data[i].id), data[i].type, data[i].time);
						break;
					case PacketServer.MAP_APPROVED:
						if (MailManager.dialogsArray.length == 0)
							new DialogMapApproved(data[i].actorId, data[i].data).show();
					case PacketServer.MAP_REJECTED:
					case PacketServer.MAP_RETURN:
						postElement = new PostMapApprovedView(parseInt(data[i].id), data[i].type, data[i].actorId, data[i].data, data[i].time);
						break;
					case PacketServer.CLAN_INVITE:
					case PacketServer.CLAN_KICK:
						postElement = new PostClanInviteView(parseInt(data[i].id), data[i].type, data[i].actorId, data[i].data, data[i].time);
						break;
					case PacketServer.CLAN_ACCEPT:
					case PacketServer.CLAN_REJECT:
					case PacketServer.CLAN_BLOCK_EVENT:
						postElement = new PostClanAcceptView(parseInt(data[i].id), data[i].type, data[i].data, data[i].time);
						break;
					case PacketServer.CLAN_CLOSE_EVENT:
						postElement = new PostClanAcceptView(parseInt(data[i].id), data[i].type, data[i].data, data[i].time);
						break;
					case PacketServer.CLAN_NEWS_EVENT:
						postElement = new PostClanAcceptView(parseInt(data[i].id), data[i].type, data[i].data, data[i].time);
						break;
					case PacketServer.FRIEND_QUEST_EVENT:
						postElement = new PostFriendsLevelReachedView(parseInt(data[i].id), data[i].actorId, data[i].time);
						break;
					case PacketServer.EXCHANGE_EVENT:
						if ((data[i].data & 255) >= CollectionsData.COLLECTION_ITEM_END)
						{
							Connection.sendData(PacketClient.EVENT_REMOVE, data[i]);
							break;
						}
						postElement = new PostCollectionView(parseInt(data[i].id), data[i].actorId, data[i].data, data[i].time);
						break;
					case PacketServer.RETURNER_AWARD:
						postElement = new PostReturnerPlayerView(parseInt(data[i].id), data[i].type, data[i].actorId, data[i].time);
						break;
					case PacketServer.AMUR_MAIL:
						Connection.sendData(PacketClient.EVENT_REMOVE, data[i]);
						break;
				}

				if (postElement == null)
					continue;

				postElement.addEventListener(PostEvent.REMOVE_EVENT, onRemoveEvent);
				this.postElements.push(postElement);
			}
		}

		private function filterTime(item:PostElementView, index:int, parentArray:Vector.<PostElementView>):Boolean
		{
			if (parentArray || index) {/*unused*/}

			return item.time <= Game.unix_time + int(getTimer() / 1000);
		}

		private function filterEvents(item:PostElementView, index:int, parentArray:Vector.<PostElementView>):Boolean
		{
			if (parentArray || index) {/*unused*/}

			return !(item is PostGiftView);
		}

		private function filterGifts(item:PostElementView, index:int, parentArray:Vector.<PostElementView>):Boolean
		{
			if (parentArray || index) {/*unused*/}

			return (item is PostGiftView);
		}
	}
}